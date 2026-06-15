'use client';
import { useState } from 'react';
import { X } from 'lucide-react';

export function ReviewButton({ request }: { request: any }) {
  const [isOpen, setIsOpen] = useState(false);

  const [isUpdating, setIsUpdating] = useState(false);

  const handleUpdateStatus = async (newStatus: string) => {
    try {
      setIsUpdating(true);
      const res = await fetch(`/api/return_requests/${request.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });
      if (res.ok) {
        window.location.reload(); // Refresh to show new status
      } else {
        alert('Có lỗi xảy ra khi cập nhật trạng thái');
      }
    } catch (err) {
      console.error(err);
      alert('Lỗi kết nối');
    } finally {
      setIsUpdating(false);
    }
  };

  return (
    <>
      <button 
        onClick={() => setIsOpen(true)}
        className="text-indigo-600 hover:text-indigo-800 font-medium text-xs border border-indigo-200 hover:bg-indigo-50 px-3 py-1.5 rounded transition-colors"
      >
        Review
      </button>

      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
          <div className="bg-white rounded-xl shadow-xl max-w-lg w-full max-h-[90vh] overflow-y-auto text-left">
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <h2 className="text-lg font-semibold text-gray-900">Return Request Details</h2>
              <button onClick={() => setIsOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="p-6 space-y-4">
              <div>
                <label className="text-xs font-medium text-gray-500 uppercase">Customer Name</label>
                <p className="mt-1 text-sm font-medium text-gray-900">{request.name}</p>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Phone Number</label>
                  <p className="mt-1 text-sm text-gray-900">{request.phone}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Status</label>
                  <p className="mt-1 text-sm text-gray-900 font-medium">{request.status}</p>
                </div>
              </div>
              <div>
                <label className="text-xs font-medium text-gray-500 uppercase">Address</label>
                <p className="mt-1 text-sm text-gray-900">{request.address}</p>
              </div>
              <div>
                <label className="text-xs font-medium text-gray-500 uppercase">Product</label>
                <p className="mt-1 text-sm text-gray-900">{request.product}</p>
              </div>
              <div>
                <label className="text-xs font-medium text-gray-500 uppercase">Reason for Return</label>
                <p className="mt-1 text-sm text-gray-900 bg-gray-50 p-3 rounded-lg border border-gray-100">{request.reason}</p>
              </div>
              {request.imageUrl && (
                <div>
                  <label className="text-xs font-medium text-gray-500 uppercase">Attached Image</label>
                  <div className="mt-2 rounded-lg overflow-hidden border border-gray-200 bg-gray-50 flex justify-center">
                    <img src={request.imageUrl} alt="Return proof" className="max-w-full max-h-64 object-contain" />
                  </div>
                </div>
              )}
            </div>
            <div className="p-6 border-t border-gray-100 bg-gray-50 flex flex-col gap-3 sm:flex-row sm:justify-between">
              <div className="flex gap-2">
                {request.status === 'Chưa xử lý' && (
                  <button 
                    disabled={isUpdating}
                    onClick={() => handleUpdateStatus('Đang xử lý')}
                    className="px-3 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                  >
                    Tiếp nhận
                  </button>
                )}
                {(request.status === 'Chưa xử lý' || request.status === 'Đang xử lý') && (
                  <>
                    <button 
                      disabled={isUpdating}
                      onClick={() => handleUpdateStatus('Đã duyệt')}
                      className="px-3 py-2 text-sm font-medium text-white bg-emerald-600 rounded-lg hover:bg-emerald-700 disabled:opacity-50"
                    >
                      Duyệt & Hoàn tiền
                    </button>
                    <button 
                      disabled={isUpdating}
                      onClick={() => handleUpdateStatus('Từ chối')}
                      className="px-3 py-2 text-sm font-medium text-white bg-rose-600 rounded-lg hover:bg-rose-700 disabled:opacity-50"
                    >
                      Từ chối
                    </button>
                  </>
                )}
              </div>
              <button 
                onClick={() => setIsOpen(false)}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
