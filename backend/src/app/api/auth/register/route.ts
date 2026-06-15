import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(request: Request) {
  try {
    const { email, password, fullName, phoneNumber, address } = await request.json();
    
    if (!email || !password) {
      return NextResponse.json({ error: 'Email và mật khẩu là bắt buộc' }, { status: 400 });
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return NextResponse.json({ error: 'Email đã tồn tại' }, { status: 400 });
    }

    const user = await prisma.user.create({
      data: {
        id: crypto.randomUUID(),
        email,
        password, // In a real app we would hash this, but we'll store it as plain text here for simplicity since it's a dev project
        fullName: fullName || '',
        phoneNumber: phoneNumber || '',
        address: address || '',
        walletBalance: 0.0
      }
    });

    return NextResponse.json({
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      address: user.address,
      token: user.id // For simplicity, we use the user id as a dummy token
    });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
