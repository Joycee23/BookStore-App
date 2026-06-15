import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
const { PayOS } = require('@payos/node');

const payos = new PayOS({
  clientId: process.env.PAYOS_CLIENT_ID!,
  apiKey: process.env.PAYOS_API_KEY!,
  checksumKey: process.env.PAYOS_CHECKSUM_KEY!
});

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return NextResponse.json({}, { headers: corsHeaders });
}

export async function POST(request: Request) {
  try {
    const { userId, items, cancelUrl, returnUrl } = await request.json();
    
    if (!items || items.length === 0) {
      return NextResponse.json({ error: 'Cart is empty' }, { status: 400, headers: corsHeaders });
    }

    let totalAmount = 0;
    const orderItemsData = [];
    
    for (const item of items) {
      const book = await prisma.book.findUnique({ where: { id: item.bookId } });
      if (!book) throw new Error(`Book not found: ${item.bookId}`);
      
      const price = (book.discountPercent && book.discountEndDate && new Date() < new Date(book.discountEndDate)) 
        ? book.price * (1 - book.discountPercent / 100) 
        : book.price;
        
      totalAmount += price * item.quantity;
      
      orderItemsData.push({
        bookId: book.id,
        quantity: item.quantity,
        price: price
      });
    }

    const payosAmount = Math.round(totalAmount);
    if (payosAmount <= 0) return NextResponse.json({ error: 'Invalid total amount' }, { status: 400, headers: corsHeaders });

    const orderCode = Number(String(Date.now()).slice(-6) + Math.floor(Math.random() * 100));
    
    const order = await prisma.order.create({
      data: {
        userId,
        totalAmount,
        originalAmount: totalAmount,
        orderCode,
        status: 'PENDING',
        items: {
          create: orderItemsData
        }
      }
    });

    const paymentData = {
      orderCode,
      amount: payosAmount,
      description: `Don hang ${orderCode}`,
      items: orderItemsData.map((i) => ({ name: `Book ${i.bookId.slice(-4)}`, quantity: i.quantity, price: Math.round(i.price) })),
      cancelUrl: cancelUrl || 'app://bookstore/payment/cancel',
      returnUrl: returnUrl || 'app://bookstore/payment/success'
    };

    const paymentLink = await payos.paymentRequests.create(paymentData);

    return NextResponse.json({
      orderId: order.id,
      checkoutUrl: paymentLink.checkoutUrl
    }, { headers: corsHeaders });

  } catch (error: any) {
    console.error(error);
    return NextResponse.json({ error: error.message }, { status: 500, headers: corsHeaders });
  }
}
