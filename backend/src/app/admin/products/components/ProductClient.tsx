'use client';

import React, { useState } from 'react';
import { Tag, Edit, Trash2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { ProductFormModal } from './ProductFormModal';
import { deleteBook } from '@/app/actions/book';

type Book = {
  id: string;
  title: string;
  author: string;
  imageUrl: string;
  price: number;
  category: string;
  description: string;
  discountPercent: number | null;
  isVisible: boolean;
  sold: number;
};

export function ProductClient({ books }: { books: Book[] }) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedBook, setSelectedBook] = useState<Book | null>(null);

  const handleAdd = () => {
    setSelectedBook(null);
    setIsModalOpen(true);
  };

  const handleEdit = (book: Book) => {
    setSelectedBook(book);
    setIsModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this book?')) {
      const result = await deleteBook(id);
      if (!result.success) {
        alert(result.message);
      }
    }
  };

  return (
    <>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">Products Management</h1>
          <p className="text-sm text-gray-500 mt-1">Manage books inventory and visibility.</p>
        </div>
        <button 
          onClick={handleAdd}
          className="px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700 transition-colors"
        >
          Add New Book
        </button>
      </div>

      <div className="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm text-gray-600">
            <thead className="bg-gray-50/50 text-gray-500 text-xs uppercase font-medium">
              <tr>
                <th className="px-6 py-4">Book Details</th>
                <th className="px-6 py-4">Category</th>
                <th className="px-6 py-4 text-right">Price</th>
                <th className="px-6 py-4 text-right">Sold</th>
                <th className="px-6 py-4 text-center">Status</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {books.map((book) => (
                <tr key={book.id} className="hover:bg-gray-50 transition-colors group">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-4">
                      {book.imageUrl ? (
                        <div className="h-16 w-12 flex-shrink-0 relative rounded bg-gray-100 overflow-hidden shadow-sm">
                          <img src={book.imageUrl} alt={book.title} className="object-cover w-full h-full" />
                        </div>
                      ) : (
                        <div className="h-16 w-12 flex-shrink-0 bg-gray-100 rounded flex items-center justify-center">
                          <Tag className="w-5 h-5 text-gray-400" />
                        </div>
                      )}
                      <div>
                        <p className="font-medium text-gray-900 line-clamp-1">{book.title}</p>
                        <p className="text-xs text-gray-500 mt-0.5 line-clamp-1">{book.author}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="inline-flex items-center px-2 py-1 rounded-md bg-gray-100 text-gray-600 text-xs font-medium">
                      {book.category}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex flex-col items-end">
                      <span className="font-medium text-gray-900">${book.price}</span>
                      {book.discountPercent && book.discountPercent > 0 && (
                        <span className="text-xs text-rose-500 font-medium">-{book.discountPercent}%</span>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 text-right font-medium text-gray-900">
                    {book.sold}
                  </td>
                  <td className="px-6 py-4 text-center">
                    <span className={cn(
                      "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                      book.isVisible ? "bg-emerald-50 text-emerald-700" : "bg-gray-100 text-gray-600"
                    )}>
                      {book.isVisible ? 'Visible' : 'Hidden'}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button 
                        onClick={() => handleEdit(book)}
                        className="p-1.5 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded transition-colors"
                        title="Edit Book"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleDelete(book.id)}
                        className="p-1.5 text-gray-400 hover:text-rose-600 hover:bg-rose-50 rounded transition-colors"
                        title="Delete Book"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {books.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-6 py-8 text-center text-gray-500">No books found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <ProductFormModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        book={selectedBook}
      />
    </>
  );
}
