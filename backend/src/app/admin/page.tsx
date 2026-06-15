import React from 'react';
import { prisma } from '@/lib/prisma';
import { RevenueChart } from './components/RevenueChart';
import { 
  DollarSign, 
  ShoppingBag, 
  Users, 
  TrendingUp
} from 'lucide-react';
import { cn } from '@/lib/utils';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

export default async function AdminDashboard() {
  // Fetch real data from DB
  const totalUsers = await prisma.user.count();
  const totalOrders = await prisma.order.count();
  
  const revenueResult = await prisma.order.aggregate({
    _sum: { totalAmount: true },
    where: { status: { not: 'CANCELLED' } }
  });
  const totalRevenue = revenueResult._sum.totalAmount || 0;

  const latestOrders = await prisma.order.findMany({
    take: 5,
    orderBy: { createdAt: 'desc' },
    include: { user: true }
  });

  // Calculate monthly revenue for current year
  const currentYear = new Date().getFullYear();
  const ordersThisYear = await prisma.order.findMany({
    where: {
      createdAt: {
        gte: new Date(`${currentYear}-01-01T00:00:00.000Z`),
        lte: new Date(`${currentYear}-12-31T23:59:59.999Z`)
      },
      status: { not: 'CANCELLED' }
    },
    select: {
      totalAmount: true,
      createdAt: true
    }
  });

  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const monthlyData = monthNames.map(name => ({ name, total: 0 }));
  
  ordersThisYear.forEach(order => {
    const monthIndex = order.createdAt.getMonth();
    monthlyData[monthIndex].total += order.totalAmount;
  });

  const statCards = [
    { title: 'Total Revenue', value: `$${totalRevenue.toLocaleString()}`, change: 'Overall', icon: DollarSign, trend: 'up' },
    { title: 'Total Orders', value: totalOrders.toString(), change: 'Overall', icon: ShoppingBag, trend: 'up' },
    { title: 'Total Users', value: totalUsers.toString(), change: 'Overall', icon: Users, trend: 'up' },
    { title: 'Growth Rate', value: '+12.5%', change: 'Mocked metric', icon: TrendingUp, trend: 'up' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Dashboard Overview</h1>
        <p className="text-sm text-gray-500 mt-1">Here's what's happening with your store today.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        {statCards.map((stat, idx) => {
          const Icon = stat.icon;
          return (
            <div key={idx} className="bg-white rounded-xl border border-gray-100 p-6 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-center justify-between">
                <p className="text-sm font-medium text-gray-500">{stat.title}</p>
                <div className="p-2 bg-indigo-50 rounded-lg text-indigo-600">
                  <Icon className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-4">
                <h3 className="text-3xl font-bold text-gray-900">{stat.value}</h3>
                <p className={cn(
                  "text-xs mt-1 font-medium",
                  stat.trend === 'up' ? "text-emerald-600" : "text-rose-600"
                )}>
                  {stat.change}
                </p>
              </div>
            </div>
          )
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Chart Section */}
        <div className="bg-white rounded-xl border border-gray-100 p-6 shadow-sm lg:col-span-2">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-lg font-semibold text-gray-900">Revenue {currentYear}</h2>
          </div>
          <RevenueChart data={monthlyData} />
        </div>

        {/* Recent Orders Section */}
        <div className="bg-white rounded-xl border border-gray-100 p-0 shadow-sm overflow-hidden flex flex-col">
          <div className="p-6 border-b border-gray-100 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-gray-900">Recent Orders</h2>
            <Link href="/admin/orders" className="text-sm text-indigo-600 font-medium hover:text-indigo-700">View All</Link>
          </div>
          <div className="flex-1 overflow-x-auto">
            <table className="w-full text-left text-sm text-gray-600">
              <thead className="bg-gray-50/50 text-gray-500 text-xs uppercase font-medium">
                <tr>
                  <th className="px-6 py-3">Order</th>
                  <th className="px-6 py-3">Status</th>
                  <th className="px-6 py-3 text-right">Amount</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {latestOrders.map((order) => (
                  <tr key={order.id} className="hover:bg-gray-50 transition-colors group">
                    <td className="px-6 py-4">
                      <p className="font-medium text-gray-900 line-clamp-1">{order.user?.fullName || order.user?.email || 'Guest'}</p>
                      <p className="text-xs text-gray-400 mt-0.5">{order.id.split('-')[0]}...</p>
                    </td>
                    <td className="px-6 py-4">
                      <span className={cn(
                        "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                        order.status === 'COMPLETED' || order.status === 'PAID' ? "bg-emerald-50 text-emerald-700" :
                        order.status === 'PROCESSING' || order.status === 'SHIPPING' ? "bg-blue-50 text-blue-700" :
                        order.status === 'PENDING' ? "bg-amber-50 text-amber-700" :
                        "bg-rose-50 text-rose-700"
                      )}>
                        {order.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right font-medium text-gray-900">
                      ${order.totalAmount}
                    </td>
                  </tr>
                ))}
                {latestOrders.length === 0 && (
                  <tr>
                    <td colSpan={3} className="px-6 py-8 text-center text-gray-500">No recent orders</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
