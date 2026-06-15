import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// POST /api/discounts/validate  — Validate discount code
export async function POST(request: Request) {
  try {
    const { code, userId } = await request.json();
    
    const discount = await prisma.discountCode.findUnique({
      where: { code }
    });

    if (!discount) {
      return NextResponse.json({ error: 'Mã giảm giá không tồn tại' }, { status: 404 });
    }

    if (discount.isUsed) {
      return NextResponse.json({ error: 'Mã giảm giá đã được sử dụng' }, { status: 400 });
    }

    if (new Date(discount.expiryDate) < new Date()) {
      return NextResponse.json({ error: 'Mã giảm giá đã hết hạn' }, { status: 400 });
    }

    // Tùy chọn: kiểm tra userId nếu mã giảm giá gán cố định cho 1 user
    if (discount.userId && discount.userId !== userId) {
      return NextResponse.json({ error: 'Mã giảm giá không dành cho bạn' }, { status: 400 });
    }

    return NextResponse.json(discount);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
