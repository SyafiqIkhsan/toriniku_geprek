"use client";

import React from "react";
import { usePathname } from "next/navigation";
import { POSProvider } from "../context/POSContext";
import { Sidebar, BottomNav } from "../components/Nav";

export default function POSLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const isFullScreenPos = pathname === "/pesanan/baru";

  if (isFullScreenPos) {
    return (
      <POSProvider>
        <div className="min-h-screen bg-gray-50 flex flex-col">
          {children}
        </div>
      </POSProvider>
    );
  }

  return (
    <POSProvider>
      <div className="flex min-h-screen bg-gray-50 pb-16 md:pb-0">
        <Sidebar />
        <main className="flex-1 flex flex-col overflow-y-auto">
          {children}
        </main>
        <BottomNav />
      </div>
    </POSProvider>
  );
}
