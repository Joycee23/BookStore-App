import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(
  request: Request,
  { params }: { params: { userId: string } }
) {
  try {
    const cart = await prisma.cart.findUnique({
      where: { userId: params.userId },
      include: { items: { include: { book: true } } }
    });
    return NextResponse.json(cart || { items: [] });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(
  request: Request,
  { params }: { params: { userId: string } }
) {
  try {
    const { bookId, quantity } = await request.json();
    
    let cart = await prisma.cart.findUnique({ where: { userId: params.userId } });
    if (!cart) {
      cart = await prisma.cart.create({ data: { userId: params.userId } });
    }

    const existingItem = await prisma.cartItem.findUnique({
      where: { cartId_bookId: { cartId: cart.id, bookId } }
    });

    if (existingItem) {
      await prisma.cartItem.update({
        where: { id: existingItem.id },
        data: { quantity: quantity }
      });
    } else {
      await prisma.cartItem.create({
        data: { cartId: cart.id, bookId, quantity }
      });
    }
    
    const updatedCart = await prisma.cart.findUnique({
      where: { userId: params.userId },
      include: { items: { include: { book: true } } }
    });
    return NextResponse.json(updatedCart);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(
  request: Request,
  { params }: { params: { userId: string } }
) {
  try {
    const cart = await prisma.cart.findUnique({ where: { userId: params.userId } });
    if (cart) {
      await prisma.cartItem.deleteMany({ where: { cartId: cart.id } });
    }
    return NextResponse.json({ success: true });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
