const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const books = await prisma.book.findMany({
    where: {
      OR: [
        { title: { contains: 'Kiêu Hãnh' } },
        { title: { contains: 'Vé Đi' } },
        { title: { contains: 'Mắt Biếc' } }
      ]
    },
    select: { title: true, imageUrl: true }
  });
  console.log(JSON.stringify(books, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
