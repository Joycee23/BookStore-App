import React from 'react';
import { prisma } from '@/lib/prisma';
import { ProductClient } from './components/ProductClient';

export const dynamic = 'force-dynamic';

export default async function ProductsPage() {
  const books = await prisma.book.findMany({
    orderBy: { createdAt: 'desc' }
  });

  return (
    <div className="space-y-6">
      <ProductClient books={books} />
    </div>
  );
}
