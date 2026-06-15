import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// GET /api/discounts?userId=xxx  — Lấy mã giảm giá của user
export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    if (!userId) return NextResponse.json({ error: 'userId required' }, { status: 400 });

    const codes = await prisma.discountCode.findMany({ where: { userId } });
    return NextResponse.json(codes);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// GET /api/discounts/all  — Lấy tất cả mã chưa dùng (dùng cho confirm order)
// POST /api/discounts  — Tạo mã giảm giá mới (admin)
export async function POST(request: Request) {
  try {
    const { code, amount, expiryDate, userId } = await request.json();
    const discount = await prisma.discountCode.create({
      data: {
        code,
        amount,
        expiryDate: new Date(expiryDate),
        userId,
        isUsed: false,
      }
    });
    return NextResponse.json(discount);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
