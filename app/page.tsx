"use client";

import { POSProvider, usePOS } from "./context/POSContext";
import BottomNav from "./components/BottomNav";
import BerandaScreen from "./components/BerandaScreen";
import PesananScreen from "./components/PesananScreen";
import MenuScreen from "./components/MenuScreen";
import TambahMenuScreen from "./components/TambahMenuScreen";
import PesananBaruScreen from "./components/PesananBaruScreen";

function POSApp() {
  const { activeScreen } = usePOS();

  const showBottomNav = !["tambah-menu", "pesanan-baru"].includes(activeScreen) &&
    !activeScreen.startsWith("order-detail-");

  const renderScreen = () => {
    if (activeScreen === "beranda") return <BerandaScreen />;
    if (activeScreen === "pesanan") return <PesananScreen />;
    if (activeScreen === "menu") return <MenuScreen />;
    if (activeScreen === "tambah-menu") return <TambahMenuScreen />;
    if (activeScreen === "pesanan-baru") return <PesananBaruScreen />;
    return <BerandaScreen />;
  };

  return (
    /* Mobile shell */
    <div className="relative w-[375px] h-[812px] bg-white overflow-hidden rounded-[40px] shadow-2xl shadow-black/30 border border-gray-200">
      {/* Status bar */}
      <div className="absolute top-0 left-0 right-0 z-50 h-10 bg-transparent flex items-center justify-between px-8 pointer-events-none">
        <span className="text-xs font-semibold text-white drop-shadow">
          {new Date().toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" })}
        </span>
        <div className="flex items-center gap-1.5">
          <svg className="w-4 h-3 text-white drop-shadow" fill="currentColor" viewBox="0 0 24 18">
            <rect x="0" y="12" width="4" height="6" rx="1" />
            <rect x="5" y="8" width="4" height="10" rx="1" />
            <rect x="10" y="4" width="4" height="14" rx="1" />
            <rect x="15" y="0" width="4" height="18" rx="1" />
          </svg>
          <svg className="w-4 h-3 text-white drop-shadow" fill="currentColor" viewBox="0 0 24 18">
            <path d="M12 3C8.1 3 4.6 4.7 2.2 7.3l2.1 2.1C6 7.5 8.9 6 12 6s6 1.5 7.7 3.4l2.1-2.1C19.4 4.7 15.9 3 12 3zm0 6c-2.2 0-4.2.9-5.7 2.3l2.1 2.1c.9-.8 2.2-1.4 3.6-1.4s2.7.5 3.6 1.4l2.1-2.1C16.2 9.9 14.2 9 12 9zm0 6c-1.1 0-2 .4-2.8 1L12 18l2.8-2c-.8-.6-1.7-1-2.8-1z" />
          </svg>
          <svg className="w-6 h-3 text-white drop-shadow" fill="currentColor" viewBox="0 0 25 12">
            <rect x="0" y="0" width="22" height="12" rx="3" stroke="currentColor" strokeWidth="1.5" fill="none" />
            <rect x="2" y="2" width="16" height="8" rx="1.5" fill="currentColor" />
            <rect x="23" y="3.5" width="2" height="5" rx="1" fill="currentColor" />
          </svg>
        </div>
      </div>

      {/* Screen content */}
      <div className="absolute inset-0 flex flex-col overflow-hidden">
        {renderScreen()}
      </div>

      {/* Bottom nav */}
      {showBottomNav && (
        <div className="absolute bottom-0 left-0 right-0 z-40">
          <BottomNav />
        </div>
      )}
    </div>
  );
}

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-orange-50 via-gray-100 to-orange-100 flex items-center justify-center p-8">
      <POSProvider>
        <POSApp />
      </POSProvider>
    </main>
  );
}
