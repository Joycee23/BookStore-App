import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { name, phone, product, address, reason, imageUrl, userId, orderId } = body;

    const returnRequest = await prisma.returnRequest.create({
      data: {
        name,
        phone,
        product,
        address,
        reason,
        imageUrl,
        userId,
        orderId,
        status: "Chưa xử lý"
      }
    });
    return NextResponse.json(returnRequest);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');
    
    let whereClause = {};
    if (userId) {
      whereClause = { userId };
    }

    const returnRequests = await prisma.returnRequest.findMany({
      where: whereClause,
      orderBy: { createdAt: 'desc' }
    });
    return NextResponse.json(returnRequests);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
