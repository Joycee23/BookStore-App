import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
const PayOS = require('@payos/node');

const payos = new PayOS(
  process.env.PAYOS_CLIENT_ID!,
  process.env.PAYOS_API_KEY!,
  process.env.PAYOS_CHECKSUM_KEY!
);

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const webhookData = payos.verifyPaymentWebhookData(body);
    
    if (webhookData.code === '00') {
      const orderCode = webhookData.orderCode;
      
      await prisma.order.update({
        where: { orderCode },
        data: { status: 'PAID' }
      });
    }

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Webhook error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 400 });
  }
}
