"use client";

import { usePOS, MenuItem } from "../context/POSContext";

function MenuItemCard({ item }: { item: MenuItem }) {
  const { updateMenuItemStatus, deleteMenuItem } = usePOS();
  const isFood = item.category === "food";
  const isHabis = item.status === "Habis";

  const formatRupiah = (n: number) =>
    "Rp " + n.toLocaleString("id-ID");

  return (
    <div
      id={`menu-card-${item.id}`}
      className={`bg-white rounded-2xl p-4 flex items-center gap-4 shadow-sm ${isHabis ? "opacity-60" : ""}`}
    >
      {/* Icon */}
      <div className={`w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 ${isFood ? "bg-orange-100" : "bg-orange-100"}`}>
        {isFood ? (
          <svg className="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 2h1a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H3zM7 13H3M12 2v20M17 7l5-5M22 7c0 4-4.5 5-6 2.5" />
          </svg>
        ) : (
          <svg className="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" strokeWidth={1.8} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M7 21h10M6 6h12l-1 9H7L6 6zM6 6l-.5-2H4M10 6V4M14 6V4" />
          </svg>
        )}
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        <p className={`font-semibold text-gray-800 text-sm truncate ${isHabis ? "line-through text-gray-400" : ""}`}>
          {item.name}
        </p>
        <p className={`text-sm font-bold mt-0.5 ${isHabis ? "text-gray-400" : "text-orange-500"}`}>
          {formatRupiah(item.price)}
        </p>
      </div>

      {/* Status toggle */}
      <div className="flex flex-col items-end gap-2">
        <button
          id={`toggle-status-${item.id}`}
          onClick={() =>
            updateMenuItemStatus(item.id, isHabis ? "Ready" : "Habis")
          }
          className={`text-xs font-bold px-3 py-1 rounded-full cursor-pointer ${
            isHabis ? "bg-red-100 text-red-600" : "bg-green-100 text-green-700"
          }`}
        >
          {item.status}
        </button>
        <button
          id={`delete-menu-${item.id}`}
          onClick={() => deleteMenuItem(item.id)}
          className="text-gray-300 hover:text-red-400 active:scale-90"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6" />
          </svg>
        </button>
      </div>
    </div>
  );
}

export default function MenuScreen() {
  const { menuItems, setActiveScreen } = usePOS();
  const activeCount = menuItems.filter((m) => m.status === "Ready").length;

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="bg-orange-500 px-5 pt-12 pb-6 relative overflow-hidden">
        <div className="absolute -top-8 -right-8 w-28 h-28 bg-orange-400 rounded-full opacity-40" />
        <div className="relative z-10 flex items-center justify-between">
          <div>
            <h1 className="text-white text-2xl font-bold">Kelola Menu</h1>
            <p className="text-orange-100 text-sm mt-0.5">
              Total: {activeCount} Produk aktif
            </p>
          </div>
          <button
            id="btn-tambah-menu"
            onClick={() => setActiveScreen("tambah-menu")}
            className="w-9 h-9 bg-white/25 rounded-full flex items-center justify-center hover:bg-white/40 active:scale-95"
          >
            <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 5v14m-7-7h14" />
            </svg>
          </button>
        </div>
      </div>

      {/* Menu list */}
      <div className="flex-1 overflow-y-auto px-4 py-4 pb-24 bg-gray-50 flex flex-col gap-3">
        {menuItems.length === 0 ? (
          <div className="flex-1 flex flex-col items-center justify-center py-20 text-gray-400">
            <svg className="w-16 h-16 mb-3 opacity-30" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 2h1a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H3zM7 13H3M12 2v20" />
            </svg>
            <p className="text-sm font-medium">Belum ada menu</p>
            <button
              id="btn-add-first-menu"
              onClick={() => setActiveScreen("tambah-menu")}
              className="mt-3 bg-orange-500 text-white text-sm font-semibold px-4 py-2 rounded-full hover:bg-orange-600 active:scale-95"
            >
              Tambah Menu
            </button>
          </div>
        ) : (
          menuItems.map((item) => <MenuItemCard key={item.id} item={item} />)
        )}
      </div>
    </div>
  );
}
