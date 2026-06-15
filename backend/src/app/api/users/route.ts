import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function POST(request: Request) {
  try {
    const { id, email, fullName, phoneNumber, address, walletBalance } = await request.json();
    const updateData: any = { email, fullName, phoneNumber, address };
    if (walletBalance !== undefined) {
      updateData.walletBalance = walletBalance;
    }
    const user = await prisma.user.upsert({
      where: { id },
      update: updateData,
      create: { id, email, fullName, phoneNumber, address, walletBalance: walletBalance ?? 0.0 }
    });
    return NextResponse.json(user);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
