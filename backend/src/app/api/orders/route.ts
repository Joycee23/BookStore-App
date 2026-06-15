import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// GET /api/orders?userId=xxx  — Lấy danh sách đơn hàng của user
export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    if (!userId) return NextResponse.json({ error: 'userId required' }, { status: 400 });

    const orders = await prisma.order.findMany({
      where: { userId },
      include: {
        items: {
          include: { book: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
    return NextResponse.json(orders);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// POST /api/orders  — Tạo đơn hàng mới
export async function POST(request: Request) {
  try {
    const body = await request.json();
    const {
      userId,
      items, // [{ bookId, quantity, price }]
      totalAmount,
      originalAmount,
      usedDiscount,
      discountCode,
      paymentMethod,
      address,
      fullName,
      phoneNumber,
    } = body;

    if (!userId || !items || items.length === 0) {
      return NextResponse.json({ error: 'userId và items là bắt buộc' }, { status: 400 });
    }

    // Đảm bảo user tồn tại
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) return NextResponse.json({ error: 'Không tìm thấy user' }, { status: 404 });

    // Nếu thanh toán bằng ví, kiểm tra và trừ số dư
    if (paymentMethod === 'Ví của tôi') {
      if (user.walletBalance < totalAmount) {
        return NextResponse.json({ error: 'Ví không đủ tiền' }, { status: 400 });
      }
      await prisma.user.update({
        where: { id: userId },
        data: { walletBalance: { decrement: totalAmount } }
      });
    }

    // Tạo đơn hàng
    const order = await prisma.order.create({
      data: {
        userId,
        totalAmount,
        originalAmount: originalAmount ?? totalAmount,
        usedDiscount: usedDiscount ?? false,
        status: paymentMethod === 'Chuyển khoản (PayOS)' ? 'PENDING' : 'PAID',
        items: {
          create: items.map((item: any) => ({
            bookId: item.bookId,
            quantity: item.quantity,
            price: item.price,
          }))
        }
      },
      include: { items: { include: { book: true } } }
    });

    // Tăng sold count cho từng sách
    for (const item of items) {
      await prisma.book.update({
        where: { id: item.bookId },
        data: { sold: { increment: item.quantity } }
      });
    }

    // Đánh dấu discount code đã dùng
    if (discountCode) {
      await prisma.discountCode.updateMany({
        where: { code: discountCode, userId },
        data: { isUsed: true }
      });
    }

    return NextResponse.json(order);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
