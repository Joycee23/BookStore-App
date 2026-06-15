'use client';

import React, { useRef, useState } from 'react';
import { X } from 'lucide-react';
import { createBook, updateBook } from '@/app/actions/book';

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
};

interface ProductFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  book?: Book | null; // If null, it's create mode
}

export function ProductFormModal({ isOpen, onClose, book }: ProductFormModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const formRef = useRef<HTMLFormElement>(null);

  if (!isOpen) return null;

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setIsSubmitting(true);
    setError('');

    const formData = new FormData(e.currentTarget);
    
    try {
      if (book) {
        await updateBook(book.id, formData);
      } else {
        await createBook(formData);
      }
      onClose();
    } catch (err: any) {
      setError(err.message || 'Something went wrong');
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl max-h-[90vh] flex flex-col">
        <div className="flex items-center justify-between p-6 border-b border-gray-100">
          <h2 className="text-xl font-bold text-gray-900">
            {book ? 'Edit Book' : 'Add New Book'}
          </h2>
          <button 
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 overflow-y-auto flex-1">
          {error && (
            <div className="mb-4 p-3 bg-rose-50 text-rose-600 text-sm rounded-lg border border-rose-100">
              {error}
            </div>
          )}

          <form id="product-form" ref={formRef} onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-gray-700">Title <span className="text-rose-500">*</span></label>
                <input 
                  name="title" 
                  defaultValue={book?.title} 
                  required 
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                  placeholder="e.g. The Great Gatsby"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-gray-700">Author <span className="text-rose-500">*</span></label>
                <input 
                  name="author" 
                  defaultValue={book?.author} 
                  required 
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                  placeholder="e.g. F. Scott Fitzgerald"
                />
              </div>
              
              <div className="space-y-1.5 sm:col-span-2">
                <label className="text-sm font-medium text-gray-700">Image URL <span className="text-rose-500">*</span></label>
                <input 
                  name="imageUrl" 
                  defaultValue={book?.imageUrl} 
                  required 
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                  placeholder="https://..."
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-sm font-medium text-gray-700">Price ($) <span className="text-rose-500">*</span></label>
                <input 
                  name="price" 
                  type="number" 
                  step="0.01"
                  min="0"
                  defaultValue={book?.price} 
                  required 
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-sm font-medium text-gray-700">Category <span className="text-rose-500">*</span></label>
                <input 
                  name="category" 
                  defaultValue={book?.category} 
                  required 
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                  placeholder="e.g. Fiction"
                />
              </div>

              <div className="space-y-1.5 sm:col-span-2">
                <label className="text-sm font-medium text-gray-700">Description</label>
                <textarea 
                  name="description" 
                  defaultValue={book?.description} 
                  rows={4}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm resize-none"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-sm font-medium text-gray-700">Discount Percent (%)</label>
                <input 
                  name="discountPercent" 
                  type="number" 
                  min="0"
                  max="100"
                  defaultValue={book?.discountPercent || ''} 
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm"
                />
              </div>
              <div className="space-y-1.5 flex items-center pt-8">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input 
                    name="isVisible" 
                    type="checkbox" 
                    defaultChecked={book ? book.isVisible : true} 
                    className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                  />
                  <span className="text-sm font-medium text-gray-700">Visible on Store</span>
                </label>
              </div>
            </div>
          </form>
        </div>

        <div className="p-6 border-t border-gray-100 flex justify-end gap-3 bg-gray-50/50 rounded-b-xl">
          <button 
            type="button" 
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            Cancel
          </button>
          <button 
            type="submit" 
            form="product-form"
            disabled={isSubmitting}
            className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 transition-colors disabled:opacity-50"
          >
            {isSubmitting ? 'Saving...' : 'Save Book'}
          </button>
        </div>
      </div>
    </div>
  );
}
