import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(request: Request) {
  try {
    const { id, email, fullName, phoneNumber, address } = await request.json();

    if (!id || !email) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });
    }

    // Try to find the user
    let user = await prisma.user.findUnique({
      where: { email },
    });

    if (user) {
      // If user exists but id is different (e.g., they logged in via Supabase the first time), update id
      if (user.id !== id) {
        user = await prisma.user.update({
          where: { email },
          data: { id, fullName: fullName || user.fullName },
        });
      }
    } else {
      // If user doesn't exist, create them using the Supabase auth.users ID
      user = await prisma.user.create({
        data: {
          id,
          email,
          fullName: fullName || email.split('@')[0],
          phoneNumber: phoneNumber || null,
          address: address || null,
        },
      });
    }

    return NextResponse.json({
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      address: user.address,
      walletBalance: user.walletBalance,
      token: user.id, // For legacy compatibility with the Flutter app's token system
    });
  } catch (error: any) {
    console.error('SYNC ERROR:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
