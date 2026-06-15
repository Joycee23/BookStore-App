import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import crypto from 'crypto';

export async function POST(request: Request) {
  try {
    const { token } = await request.json();
    if (!token) return NextResponse.json({ error: 'Token is required' }, { status: 400 });

    const magic = await prisma.magicToken.findUnique({ where: { token } });
    if (!magic) return NextResponse.json({ error: 'Token không hợp lệ hoặc đã hết hạn' }, { status: 400 });
    
    if (magic.expiresAt < new Date()) {
      await prisma.magicToken.delete({ where: { id: magic.id } });
      return NextResponse.json({ error: 'Token đã hết hạn' }, { status: 400 });
    }

    // Token is valid, delete it so it can't be reused
    await prisma.magicToken.delete({ where: { id: magic.id } });

    // Find or create user
    let user = await prisma.user.findUnique({ where: { email: magic.email } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          id: crypto.randomUUID(),
          email: magic.email,
          fullName: magic.email.split('@')[0], // default name
        }
      });
    }

    return NextResponse.json({
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      address: user.address,
      token: user.id,
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
