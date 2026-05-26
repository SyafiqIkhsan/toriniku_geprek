"use client";

import { useState } from "react";
import { usePOS, Order, OrderStatus } from "../context/POSContext";

const STATUS_COLORS: Record<OrderStatus, string> = {
  Baru: "bg-blue-100 text-blue-700",
  Diproses: "bg-yellow-100 text-yellow-700",
  Selesai: "bg-green-100 text-green-700",
  Dibatalkan: "bg-red-100 text-red-700",
};

function OrderCard({ order }: { order: Order }) {
  const { updateOrderStatus, setActiveScreen } = usePOS();
  const [showMenu, setShowMenu] = useState(false);

  const formatRupiah = (n: number) =>
    "Rp " + n.toLocaleString("id-ID");

  const statusOptions: OrderStatus[] = ["Baru", "Diproses", "Selesai", "Dibatalkan"];

  return (
    <div
      id={`order-card-${order.id}`}
      className="bg-white rounded-2xl p-4 shadow-sm hover:shadow-md active:scale-[0.99] relative"
      onClick={() => setActiveScreen(`order-detail-${order.id}`)}
    >
      <div className="flex items-start justify-between mb-2">
        <span className="font-bold text-gray-800 text-base">#{order.orderNumber}</span>
        <button
          id={`btn-status-${order.id}`}
          onClick={(e) => {
            e.stopPropagation();
            setShowMenu((v) => !v);
          }}
          className={`text-xs font-semibold px-3 py-1 rounded-full cursor-pointer ${STATUS_COLORS[order.status]}`}
        >
          {order.status}
        </button>
      </div>

      {/* Status dropdown */}
      {showMenu && (
        <div
          className="absolute right-4 top-12 bg-white rounded-xl shadow-xl border border-gray-100 z-50 py-1 min-w-32"
          onClick={(e) => e.stopPropagation()}
        >
          {statusOptions.map((s) => (
            <button
              key={s}
              id={`status-option-${order.id}-${s}`}
              onClick={() => {
                updateOrderStatus(order.id, s);
                setShowMenu(false);
              }}
              className={`w-full text-left px-4 py-2 text-sm font-medium hover:bg-gray-50 ${
                order.status === s ? "text-orange-500" : "text-gray-700"
              }`}
            >
              {s}
            </button>
          ))}
        </div>
      )}

      <p className="text-sm text-gray-600 mb-3">{order.items}</p>
      <div className="flex items-center justify-between">
        <span className="text-xs text-gray-400">Jam: {order.time}</span>
        <span className="text-sm font-bold text-orange-500">{formatRupiah(order.total)}</span>
      </div>
    </div>
  );
}

export default function PesananScreen() {
  const { orders, setActiveScreen } = usePOS();
  const [filter, setFilter] = useState<"semua" | "Baru" | "Diproses" | "Selesai" | "Dibatalkan">("semua");

  const filtered =
    filter === "semua" ? orders : orders.filter((o) => o.status === filter);

  const filters: Array<{ id: string; label: string }> = [
    { id: "semua", label: "Semua" },
    { id: "Baru", label: "Baru" },
    { id: "Diproses", label: "Diproses" },
    { id: "Selesai", label: "Selesai" },
  ];

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="bg-orange-500 px-5 pt-12 pb-6 relative overflow-hidden">
        <div className="absolute -top-8 -right-8 w-28 h-28 bg-orange-400 rounded-full opacity-40" />
        <div className="relative z-10">
          <h1 className="text-white text-2xl font-bold">Pesanan</h1>
          <p className="text-orange-100 text-sm mt-0.5">Pantau semua orderan masuk di sini</p>
        </div>
      </div>

      {/* Filter tabs */}
      <div className="bg-white px-4 py-2 flex gap-2 overflow-x-auto border-b border-gray-100 flex-shrink-0">
        {filters.map((f) => (
          <button
            key={f.id}
            id={`filter-${f.id}`}
            onClick={() => setFilter(f.id as typeof filter)}
            className={`px-4 py-1.5 rounded-full text-sm font-semibold whitespace-nowrap flex-shrink-0 cursor-pointer ${
              filter === f.id
                ? "bg-orange-500 text-white"
                : "bg-gray-100 text-gray-500 hover:bg-gray-200"
            }`}
          >
            {f.label}
          </button>
        ))}
      </div>

      {/* Orders list */}
      <div className="flex-1 overflow-y-auto px-4 py-4 pb-24 bg-gray-50 flex flex-col gap-3">
        {filtered.length === 0 ? (
          <div className="flex-1 flex flex-col items-center justify-center py-20 text-gray-400">
            <svg className="w-16 h-16 mb-3 opacity-30" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
              <line x1="3" x2="21" y1="6" y2="6" />
            </svg>
            <p className="text-sm font-medium">Tidak ada pesanan</p>
          </div>
        ) : (
          filtered.map((order) => <OrderCard key={order.id} order={order} />)
        )}
      </div>

      {/* FAB */}
      <button
        id="fab-new-order"
        onClick={() => setActiveScreen("pesanan-baru")}
        className="absolute bottom-20 right-5 w-14 h-14 bg-orange-500 rounded-full shadow-lg flex items-center justify-center hover:bg-orange-600 active:scale-95"
      >
        <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 5v14m-7-7h14" />
        </svg>
      </button>
    </div>
  );
}
