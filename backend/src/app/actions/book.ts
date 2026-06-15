'use server';

import { prisma } from '@/lib/prisma';
import { revalidatePath } from 'next/cache';

export async function createBook(formData: FormData) {
  const title = formData.get('title') as string;
  const author = formData.get('author') as string;
  const imageUrl = formData.get('imageUrl') as string;
  const price = parseFloat(formData.get('price') as string);
  const category = formData.get('category') as string;
  const description = formData.get('description') as string;
  const discountPercentStr = formData.get('discountPercent') as string;
  const discountPercent = discountPercentStr ? parseFloat(discountPercentStr) : null;
  const isVisible = formData.get('isVisible') === 'on';

  await prisma.book.create({
    data: {
      title,
      author,
      imageUrl,
      price,
      category,
      description: description || "Chưa có mô tả.",
      discountPercent,
      isVisible
    }
  });

  revalidatePath('/admin/products');
  return { success: true };
}

export async function updateBook(id: string, formData: FormData) {
  const title = formData.get('title') as string;
  const author = formData.get('author') as string;
  const imageUrl = formData.get('imageUrl') as string;
  const price = parseFloat(formData.get('price') as string);
  const category = formData.get('category') as string;
  const description = formData.get('description') as string;
  const discountPercentStr = formData.get('discountPercent') as string;
  const discountPercent = discountPercentStr ? parseFloat(discountPercentStr) : null;
  const isVisible = formData.get('isVisible') === 'on';

  await prisma.book.update({
    where: { id },
    data: {
      title,
      author,
      imageUrl,
      price,
      category,
      description: description || "Chưa có mô tả.",
      discountPercent,
      isVisible
    }
  });

  revalidatePath('/admin/products');
  return { success: true };
}

export async function deleteBook(id: string) {
  try {
    // Check if book exists in any order
    const orderItemCount = await prisma.orderItem.count({
      where: { bookId: id }
    });

    if (orderItemCount > 0) {
      return { 
        success: false, 
        message: 'Không thể xóa sách này vì đã có người mua. Vui lòng sử dụng tính năng Ẩn (Is Visible = false).' 
      };
    }

    // Delete cart items associated with this book first
    await prisma.cartItem.deleteMany({
      where: { bookId: id }
    });

    // Delete the book
    await prisma.book.delete({
      where: { id }
    });

    revalidatePath('/admin/products');
    return { success: true };
  } catch (error) {
    console.error("Delete book error:", error);
    return { success: false, message: 'Đã xảy ra lỗi khi xóa sách.' };
  }
}
