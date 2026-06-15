import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import nodemailer from 'nodemailer';
import crypto from 'crypto';

export async function POST(request: Request) {
  try {
    const { email } = await request.json();
    if (!email) return NextResponse.json({ error: 'Vui lòng cung cấp email' }, { status: 400 });

    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins

    await prisma.magicToken.create({
      data: { email, token, expiresAt }
    });

    const magicLink = `bookstore://login?token=${token}`;

    if (process.env.EMAIL_USER && process.env.EMAIL_PASS) {
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        }
      });

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Đăng nhập vào BookStore App',
        html: `
          <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
            <h2>Chào mừng đến với BookStore</h2>
            <p>Bấm vào nút bên dưới để đăng nhập vào ứng dụng:</p>
            <a href="${magicLink}" style="display: inline-block; padding: 12px 24px; background-color: #4F46E5; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; margin-top: 10px;">Đăng Nhập Ngay</a>
            <p style="margin-top: 30px; font-size: 12px; color: #888;">Nếu nút không hoạt động, copy link sau vào trình duyệt trên điện thoại:</p>
            <p style="font-size: 12px; color: #888; word-break: break-all;">${magicLink}</p>
          </div>
        `
      });
      return NextResponse.json({ message: 'Email sent successfully' });
    } else {
      // For testing without SMTP configured
      console.log('MAGIC LINK GENERATED (NO SMTP):', magicLink);
      return NextResponse.json({ 
        message: 'Dev mode: check terminal for link',
        magicLink 
      });
    }

  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
