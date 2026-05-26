"use client";

import React from "react";
import { POSProvider } from "../context/POSContext";
import { Sidebar, BottomNav } from "../components/Nav";

export default function POSLayout({
  children,
}: {
  children: React.ReactNode;
}) {
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
