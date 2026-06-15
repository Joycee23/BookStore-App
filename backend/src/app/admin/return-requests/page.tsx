import React from 'react';
import { prisma } from '@/lib/prisma';
import { cn } from '@/lib/utils';
import { Calendar, User, FileText } from 'lucide-react';

import { ReviewButton } from './components/ReviewButton';

export const dynamic = 'force-dynamic';

export default async function ReturnRequestsPage() {
  const returnRequests = await prisma.returnRequest.findMany({
    orderBy: { createdAt: 'desc' },
    include: { 
      user: true,
      order: true
    }
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Return Requests</h1>
          <p className="text-sm text-gray-500 mt-1">Manage customer return and refund requests.</p>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-gray-600">
            <thead className="bg-gray-50/50 text-gray-500 text-xs uppercase font-medium">
              <tr>
                <th className="px-6 py-4">Request Info</th>
                <th className="px-6 py-4">Customer</th>
                <th className="px-6 py-4">Product & Reason</th>
                <th className="px-6 py-4 text-center">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {returnRequests.map((req) => (
                <tr key={req.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <span className="font-medium text-gray-900">
                        {req.orderId ? `Order #${req.orderId.split('-')[0]}` : `#${req.id.split('-')[0]}`}
                      </span>
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-gray-500 mt-1">
                      <Calendar className="w-3.5 h-3.5" />
                      <span>{new Date(req.createdAt).toLocaleDateString()}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <p className="font-medium text-gray-900 flex items-center gap-1.5">
                      <User className="w-3.5 h-3.5 text-gray-400" />
                      {req.name || req.user?.fullName || 'Unknown'}
                    </p>
                    <p className="text-xs text-gray-500 mt-0.5 ml-5">{req.phone}</p>
                  </td>
                  <td className="px-6 py-4 max-w-xs">
                    <p className="font-medium text-gray-900 line-clamp-1">{req.product}</p>
                    <div className="flex items-start gap-1.5 text-xs text-gray-500 mt-1">
                      <FileText className="w-3.5 h-3.5 flex-shrink-0 mt-0.5" />
                      <span className="line-clamp-2">{req.reason}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-center">
                    <span className={cn(
                      "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium",
                      req.status === 'Đã duyệt' ? "bg-emerald-50 text-emerald-700" :
                      req.status === 'Đang xử lý' ? "bg-blue-50 text-blue-700" :
                      req.status === 'Chưa xử lý' ? "bg-amber-50 text-amber-700" :
                      "bg-rose-50 text-rose-700"
                    )}>
                      {req.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <ReviewButton request={req} />
                  </td>
                </tr>
              ))}
              {returnRequests.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-gray-500">No return requests found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
