import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: Request) {
  try {
    const searchParams = new URL(request.url).searchParams;
    const search = searchParams.get('search');
    const sort = searchParams.get('sort');
    
    let whereClause: any = { isVisible: true };
    if (search) {
      whereClause.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { author: { contains: search, mode: 'insensitive' } },
      ];
    }
    
    let orderByClause: any = { createdAt: 'desc' };
    if (sort === 'sold') {
      orderByClause = { sold: 'desc' };
    }

    const books = await prisma.book.findMany({ 
      where: whereClause,
      orderBy: orderByClause
    });
    return NextResponse.json(books);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const data = await request.json();
    const book = await prisma.book.create({
      data
    });
    return NextResponse.json(book);
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
