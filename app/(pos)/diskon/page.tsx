"use client";

import { useState } from "react";
import { usePOS, Discount } from "../../context/POSContext";

function Skeleton({ className }: { className?: string }) {
  return <div className={`animate-pulse bg-gray-200 rounded-lg ${className}`} />;
}

export default function DiskonPage() {
  const { discounts, discountsLoading, addDiscount, toggleDiscountActive, deleteDiscount } = usePOS();
  
  // Drawer / Add Discount Form State
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [name, setName] = useState("");
  const [type, setType] = useState<"percent" | "fixed">("percent");
  const [value, setValue] = useState("");
  const [expiresAt, setExpiresAt] = useState("");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Stats
  const totalCount = discounts.length;
  const activeCount = discounts.filter((d) => d.isActive).length;
  const percentCount = discounts.filter((d) => d.type === "percent").length;
  const fixedCount = discounts.filter((d) => d.type === "fixed").length;

  const formatRupiah = (n: number) => "Rp " + n.toLocaleString("id-ID");

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) {
      setError("Nama diskon harus diisi");
      return;
    }

    const parsedValue = parseFloat(value.replace(/\D/g, ""));
    if (isNaN(parsedValue) || parsedValue <= 0) {
      setError("Nilai diskon harus lebih dari 0");
      return;
    }

    if (type === "percent" && parsedValue > 100) {
      setError("Diskon persentase tidak boleh lebih dari 100%");
      return;
    }

    setIsSubmitting(true);
    setError("");

    try {
      await addDiscount({
        name: name.trim(),
        type,
        value: parsedValue,
        isActive: true,
        expiresAt: expiresAt ? new Date(expiresAt).toISOString() : undefined,
      });

      // Clear Form & Close Drawer
      setName("");
      setType("percent");
      setValue("");
      setExpiresAt("");
      setIsDrawerOpen(false);
    } catch (err) {
      setError("Gagal menambahkan diskon");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleFormatValue = (val: string) => {
    if (type === "fixed") {
      const digits = val.replace(/\D/g, "");
      return digits ? parseInt(digits).toLocaleString("id-ID") : "";
    } else {
      const digits = val.replace(/\D/g, "");
      return digits ? Math.min(parseInt(digits), 100).toString() : "";
    }
  };

  const isExpired = (dateStr?: string) => {
    if (!dateStr) return false;
    return new Date(dateStr).getTime() < new Date().getTime();
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return "Tanpa Batas Waktu";
    const date = new Date(dateStr);
    return date.toLocaleDateString("id-ID", {
      day: "2-digit",
      month: "short",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <div className="flex flex-col min-h-full relative overflow-x-hidden">
      {/* ── Header ── */}
      <div className="bg-orange-500 px-5 md:px-8 pt-8 pb-8 relative overflow-hidden">
        <div className="absolute -top-10 -right-10 w-40 h-40 bg-orange-400 rounded-full opacity-40" />
        <div className="absolute top-4 -right-4 w-24 h-24 bg-orange-300 rounded-full opacity-20" />
        <div className="relative z-10 flex items-center justify-between">
          <div>
            <h1 className="text-white text-2xl font-bold">Kelola Diskon</h1>
            <p className="text-orange-100 text-sm mt-0.5">Atur potongan harga, program member, & promo warung</p>
          </div>
          <button
            id="btn-tambah-diskon"
            onClick={() => setIsDrawerOpen(true)}
            className="flex items-center gap-2 bg-white text-orange-600 hover:bg-orange-50 font-bold text-sm px-4 py-2.5 rounded-xl shadow-lg active:scale-95 transition-all cursor-pointer"
          >
            <svg className="w-4.5 h-4.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 5v14m-7-7h14" />
            </svg>
            Tambah Diskon
          </button>
        </div>

        {/* ── Metrics Cards ── */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3.5 mt-6 relative z-10">
          <div className="bg-white/15 backdrop-blur-md rounded-2xl p-4 border border-white/20 text-white">
            <p className="text-orange-100 text-xs font-semibold uppercase tracking-wider">Total Diskon</p>
            {discountsLoading ? <Skeleton className="h-7 w-10 mt-2 bg-white/20" /> : <p className="text-2xl font-bold mt-1">{totalCount}</p>}
            <p className="text-orange-200 text-xxs mt-1">Aturan diskon terdaftar</p>
          </div>

          <div className="bg-white/15 backdrop-blur-md rounded-2xl p-4 border border-white/20 text-white">
            <p className="text-orange-100 text-xs font-semibold uppercase tracking-wider">Diskon Aktif</p>
            {discountsLoading ? <Skeleton className="h-7 w-10 mt-2 bg-white/20" /> : <p className="text-2xl font-bold mt-1 text-green-200">{activeCount}</p>}
            <p className="text-orange-200 text-xxs mt-1">Sedang aktif di kasir</p>
          </div>

          <div className="bg-white/15 backdrop-blur-md rounded-2xl p-4 border border-white/20 text-white">
            <p className="text-orange-100 text-xs font-semibold uppercase tracking-wider">Tipe Persentase</p>
            {discountsLoading ? <Skeleton className="h-7 w-10 mt-2 bg-white/20" /> : <p className="text-2xl font-bold mt-1">{percentCount}</p>}
            <p className="text-orange-200 text-xxs mt-1">Potongan berbasis %</p>
          </div>

          <div className="bg-white/15 backdrop-blur-md rounded-2xl p-4 border border-white/20 text-white">
            <p className="text-orange-100 text-xs font-semibold uppercase tracking-wider">Tipe Nominal</p>
            {discountsLoading ? <Skeleton className="h-7 w-10 mt-2 bg-white/20" /> : <p className="text-2xl font-bold mt-1">{fixedCount}</p>}
            <p className="text-orange-200 text-xxs mt-1">Potongan nominal tetap (Rp)</p>
          </div>
        </div>
      </div>

      {/* ── Main Panel ── */}
      <div className="flex-1 px-5 md:px-8 py-6 pb-24 md:pb-8 bg-gray-50">
        {discountsLoading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 flex gap-4 animate-pulse">
                <div className="w-14 h-14 bg-gray-200 rounded-full flex-shrink-0" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 bg-gray-200 rounded w-2/3" />
                  <div className="h-3 bg-gray-200 rounded w-1/3" />
                  <div className="h-3 bg-gray-200 rounded w-1/2" />
                </div>
              </div>
            ))}
          </div>
        ) : discounts.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-gray-400">
            <div className="w-20 h-20 bg-orange-50 rounded-full flex items-center justify-center mb-4">
              <svg className="w-10 h-10 text-orange-400" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9.5 14.5 14.5 9.5M9.5 9.5h.01M14.5 14.5h.01M16.5 18.5a6 6 0 0 0 6-6v-7a2 2 0 0 0-2-2h-7a6 6 0 0 0-6 6v7a2 2 0 0 0 2 2h7z" />
              </svg>
            </div>
            <p className="text-gray-800 font-bold">Belum ada promo diskon</p>
            <p className="text-gray-400 text-sm mt-1">Buat diskon pertamamu untuk memikat pelanggan!</p>
            <button
              id="btn-tambah-diskon-empty"
              onClick={() => setIsDrawerOpen(true)}
              className="mt-4 bg-orange-500 hover:bg-orange-600 text-white font-bold text-sm px-5 py-2.5 rounded-xl shadow-lg cursor-pointer"
            >
              Buat Diskon Pertama
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {discounts.map((discount) => {
              const expired = isExpired(discount.expiresAt);
              const label = discount.type === "percent" ? `${discount.value}%` : `-${formatRupiah(discount.value)}`;
              
              return (
                <div
                  key={discount.id}
                  id={`discount-card-${discount.id}`}
                  className={`bg-white rounded-2xl p-5 border border-gray-100 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all flex flex-col justify-between ${
                    !discount.isActive ? "opacity-60 bg-gray-50/50" : ""
                  }`}
                >
                  <div className="flex items-start gap-4">
                    {/* circular discount icon */}
                    <div className={`w-14 h-14 rounded-full flex items-center justify-center flex-shrink-0 text-white font-bold tracking-tight text-center text-sm px-1.5 ${
                      discount.type === "percent"
                        ? "bg-gradient-to-tr from-orange-500 to-amber-400 shadow-md shadow-orange-100"
                        : "bg-gradient-to-tr from-rose-500 to-orange-400 shadow-md shadow-rose-100"
                    }`}>
                      {discount.type === "percent" ? `${discount.value}%` : `Rp`}
                    </div>

                    <div className="flex-1 min-w-0">
                      <h3 className="font-bold text-gray-800 text-base truncate" title={discount.name}>
                        {discount.name}
                      </h3>
                      <p className="text-sm font-semibold text-orange-500 mt-0.5">
                        {discount.type === "percent" ? "Diskon Persentase" : `Nominal: ${formatRupiah(discount.value)}`}
                      </p>
                      
                      {/* expiry and status badge */}
                      <div className="flex flex-col gap-1 mt-3">
                        <div className="flex items-center gap-1.5 text-xs text-gray-400">
                          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0z" />
                          </svg>
                          <span className={expired ? "text-red-500 font-medium" : ""}>
                            {expired ? "Expired" : formatDate(discount.expiresAt)}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between border-t border-gray-100 pt-4 mt-5">
                    {/* Active toggle */}
                    <div className="flex items-center gap-2">
                      <button
                        id={`toggle-active-${discount.id}`}
                        onClick={() => toggleDiscountActive(discount.id, !discount.isActive)}
                        className={`w-11 h-6 rounded-full p-0.5 transition-colors cursor-pointer outline-none ${
                          discount.isActive ? "bg-green-500" : "bg-gray-200"
                        }`}
                      >
                        <div className={`w-5 h-5 bg-white rounded-full shadow-md transform transition-transform ${
                          discount.isActive ? "translate-x-5" : "translate-x-0"
                        }`} />
                      </button>
                      <span className={`text-xs font-bold ${discount.isActive ? "text-green-600" : "text-gray-400"}`}>
                        {discount.isActive ? "Aktif" : "Nonaktif"}
                      </span>
                    </div>

                    {/* Delete button */}
                    <button
                      id={`btn-delete-${discount.id}`}
                      onClick={() => deleteDiscount(discount.id)}
                      className="text-gray-300 hover:text-red-500 hover:bg-red-50 p-2 rounded-xl transition-all active:scale-90 cursor-pointer"
                    >
                      <svg className="w-4.5 h-4.5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0 1 16.138 21H7.862a2 2 0 0 1-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* ── Premium Add Discount Drawer (Slide-over panel) ── */}
      {isDrawerOpen && (
        <div className="fixed inset-0 z-50 overflow-hidden flex justify-end" id="drawer-container">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-gray-900/40 backdrop-blur-sm transition-opacity"
            onClick={() => setIsDrawerOpen(false)}
          />

          {/* Panel */}
          <div className="relative w-full max-w-md bg-white h-full shadow-2xl flex flex-col justify-between z-10 animate-slide-in">
            {/* Header */}
            <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-orange-50">
              <div>
                <h2 className="text-lg font-bold text-gray-800">Tambah Diskon Baru</h2>
                <p className="text-gray-500 text-xs mt-0.5">Buat penawaran diskon kustom untuk warung</p>
              </div>
              <button
                id="btn-close-drawer"
                onClick={() => setIsDrawerOpen(false)}
                className="w-8 h-8 rounded-full hover:bg-gray-200/60 flex items-center justify-center text-gray-400 hover:text-gray-700 transition-colors cursor-pointer"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            {/* Form Content */}
            <form onSubmit={handleSave} className="flex-1 overflow-y-auto px-6 py-5 space-y-4">
              {/* Type tabs selector */}
              <div>
                <label className="block text-xs font-semibold text-gray-500 mb-2 uppercase tracking-wider">Tipe Diskon</label>
                <div className="flex gap-2 p-1 bg-gray-100 rounded-xl">
                  <button
                    type="button"
                    id="type-percent"
                    onClick={() => { setType("percent"); setValue(""); setError(""); }}
                    className={`flex-1 py-2.5 rounded-lg text-sm font-semibold transition-all cursor-pointer ${
                      type === "percent" ? "bg-white text-orange-600 shadow-sm" : "text-gray-500 hover:text-gray-700"
                    }`}
                  >
                    Persentase (%)
                  </button>
                  <button
                    type="button"
                    id="type-fixed"
                    onClick={() => { setType("fixed"); setValue(""); setError(""); }}
                    className={`flex-1 py-2.5 rounded-lg text-sm font-semibold transition-all cursor-pointer ${
                      type === "fixed" ? "bg-white text-orange-600 shadow-sm" : "text-gray-500 hover:text-gray-700"
                    }`}
                  >
                    Nominal Tetap (Rp)
                  </button>
                </div>
              </div>

              {/* Name */}
              <div>
                <label htmlFor="input-discount-name" className="block text-xs font-semibold text-gray-500 mb-2 uppercase tracking-wider">Nama Diskon / Promo</label>
                <input
                  id="input-discount-name"
                  type="text"
                  value={name}
                  onChange={(e) => { setName(e.target.value); setError(""); }}
                  placeholder="Contoh: Diskon Member Baru, Promo Lebaran"
                  className="w-full px-4 py-3 border border-gray-200 rounded-xl text-sm text-gray-700 placeholder-gray-300 focus:outline-none focus:border-orange-400 focus:ring-2 focus:ring-orange-100"
                />
              </div>

              {/* Value */}
              <div>
                <label htmlFor="input-discount-value" className="block text-xs font-semibold text-gray-500 mb-2 uppercase tracking-wider">
                  {type === "percent" ? "Nilai Potongan (%)" : "Nominal Potongan (Rp)"}
                </label>
                <div className="relative">
                  {type === "fixed" && (
                    <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-sm text-gray-400 font-semibold">Rp</span>
                  )}
                  <input
                    id="input-discount-value"
                    type="text"
                    inputMode="numeric"
                    value={value}
                    onChange={(e) => { setValue(handleFormatValue(e.target.value)); setError(""); }}
                    placeholder={type === "percent" ? "Contoh: 10" : "Contoh: 5.000"}
                    className={`w-full py-3 border border-gray-200 rounded-xl text-sm text-gray-700 placeholder-gray-300 focus:outline-none focus:border-orange-400 focus:ring-2 focus:ring-orange-100 ${
                      type === "fixed" ? "pl-9 pr-4" : "px-4"
                    }`}
                  />
                  {type === "percent" && (
                    <span className="absolute right-3.5 top-1/2 -translate-y-1/2 text-sm text-gray-400 font-semibold">%</span>
                  )}
                </div>
              </div>

              {/* Expiry */}
              <div>
                <label htmlFor="input-expiry" className="block text-xs font-semibold text-gray-500 mb-2 uppercase tracking-wider">Tanggal & Waktu Berakhir (Opsional)</label>
                <input
                  id="input-expiry"
                  type="datetime-local"
                  value={expiresAt}
                  onChange={(e) => setExpiresAt(e.target.value)}
                  className="w-full px-4 py-3 border border-gray-200 rounded-xl text-sm text-gray-700 placeholder-gray-400 focus:outline-none focus:border-orange-400 focus:ring-2 focus:ring-orange-100"
                />
                <p className="text-gray-400 text-xxs mt-1">Kosongkan jika diskon berlaku selamanya tanpa batas waktu.</p>
              </div>

              {/* Error block */}
              {error && (
                <div className="flex items-center gap-2 bg-red-50 border border-red-100 text-red-600 text-xs font-medium px-3 py-2.5 rounded-xl">
                  <svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="10" />
                    <line x1="12" y1="8" x2="12" y2="12" strokeLinecap="round" />
                    <line x1="12" y1="16" x2="12.01" y2="16" strokeLinecap="round" />
                  </svg>
                  {error}
                </div>
              )}
            </form>

            {/* Footer */}
            <div className="px-6 py-4 border-t border-gray-100 bg-gray-50 flex gap-3">
              <button
                type="button"
                id="btn-cancel"
                onClick={() => setIsDrawerOpen(false)}
                className="flex-1 py-3 bg-white border border-gray-200 rounded-xl text-gray-500 font-bold text-sm hover:bg-gray-50 active:scale-[0.98] cursor-pointer"
              >
                Batal
              </button>
              <button
                type="button"
                id="btn-submit"
                onClick={handleSave}
                disabled={isSubmitting}
                className="flex-1 py-3 bg-orange-500 hover:bg-orange-600 disabled:bg-orange-300 text-white font-bold text-sm rounded-xl shadow-lg shadow-orange-100 active:scale-[0.98] cursor-pointer flex items-center justify-center gap-2"
              >
                {isSubmitting ? (
                  <>
                    <svg className="w-4.5 h-4.5 animate-spin text-white" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth={4} />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z" />
                    </svg>
                    Menyimpan...
                  </>
                ) : (
                  "Simpan Promo"
                )}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ── Slide-in & Scale Animation Styles ── */}
      <style jsx global>{`
        @keyframes slideIn {
          from { transform: translateX(100%); }
          to { transform: translateX(0); }
        }
        .animate-slide-in {
          animation: slideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }
        .text-xxs {
          font-size: 0.65rem;
        }
        .text-xxs {
          font-size: 0.65rem;
        }
      `}</style>
    </div>
  );
}
