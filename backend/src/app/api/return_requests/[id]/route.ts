import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const returnRequest = await prisma.returnRequest.findUnique({
      where: { id: params.id }
    });
    if (!returnRequest) return NextResponse.json({ error: 'Not found' }, { status: 404 });
    return NextResponse.json(returnRequest);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function PUT(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const { status } = await request.json();
    const returnRequest = await prisma.returnRequest.update({
      where: { id: params.id },
      data: { status }
    });

    if (status === 'Đã duyệt' && returnRequest.orderCode && returnRequest.userId) {
      // Find the order
      const order = await prisma.order.findUnique({
        where: { orderCode: returnRequest.orderCode },
        include: { items: true }
      });

      if (order && !order.isReturned) {
        // Mark order as returned
        await prisma.order.update({
          where: { id: order.id },
          data: { isReturned: true, status: 'RETURNED' }
        });

        // Refund wallet
        const user = await prisma.user.findUnique({ where: { id: returnRequest.userId } });
        if (user && order.paymentMethod === 'Ví của tôi') {
          await prisma.user.update({
            where: { id: returnRequest.userId },
            data: { walletBalance: user.walletBalance + order.totalAmount }
          });
        }
      }
    }

    return NextResponse.json(returnRequest);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
