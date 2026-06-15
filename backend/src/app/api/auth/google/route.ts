import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { OAuth2Client } from 'google-auth-library';
import crypto from 'crypto';

// The client id could be multiple if Android and iOS have different IDs
// We verify without specifying an audience to accept any valid Google token from our project
const client = new OAuth2Client();

export async function POST(request: Request) {
  try {
    const { idToken } = await request.json();
    if (!idToken) return NextResponse.json({ error: 'Missing idToken' }, { status: 400 });

    const ticket = await client.verifyIdToken({
      idToken,
      // audience: process.env.GOOGLE_CLIENT_ID, // You can specify audience here if needed
    });
    
    const payload = ticket.getPayload();
    if (!payload || !payload.email) return NextResponse.json({ error: 'Invalid token' }, { status: 400 });

    const { email, name } = payload;
    
    let user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          id: crypto.randomUUID(),
          email,
          fullName: name || 'Người dùng Google',
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
