"use client";

import { usePOS } from "../context/POSContext";

export default function BottomNav() {
  const { activeTab, setActiveTab, setActiveScreen } = usePOS();

  const tabs = [
    {
      id: "beranda" as const,
      label: "Beranda",
      icon: (active: boolean) => (
        <svg
          className={`w-6 h-6 mx-auto mb-1 ${active ? "text-orange-500" : "text-gray-400"}`}
          fill="none"
          stroke="currentColor"
          strokeWidth={active ? 2.5 : 2}
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
          <polyline points="9 22 9 12 15 12 15 22" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      ),
    },
    {
      id: "pesanan" as const,
      label: "Pesanan",
      icon: (active: boolean) => (
        <svg
          className={`w-6 h-6 mx-auto mb-1 ${active ? "text-orange-500" : "text-gray-400"}`}
          fill="none"
          stroke="currentColor"
          strokeWidth={active ? 2.5 : 2}
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
          <line x1="3" x2="21" y1="6" y2="6" strokeLinecap="round" />
          <path strokeLinecap="round" strokeLinejoin="round" d="M16 10a4 4 0 0 1-8 0" />
        </svg>
      ),
    },
    {
      id: "menu" as const,
      label: "Menu",
      icon: (active: boolean) => (
        <svg
          className={`w-6 h-6 mx-auto mb-1 ${active ? "text-orange-500" : "text-gray-400"}`}
          fill="none"
          stroke="currentColor"
          strokeWidth={active ? 2.5 : 2}
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M3 2h1a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H3z" />
          <path strokeLinecap="round" strokeLinejoin="round" d="M7 13H3" />
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 2v20" />
          <path strokeLinecap="round" strokeLinejoin="round" d="m17 7 5-5" />
          <path strokeLinecap="round" strokeLinejoin="round" d="M22 7c0 4-4.5 5-6 2.5" />
        </svg>
      ),
    },
  ];

  const handleTabClick = (tabId: "beranda" | "pesanan" | "menu") => {
    setActiveTab(tabId);
    setActiveScreen(tabId);
  };

  return (
    <nav className="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex">
      {tabs.map((tab) => {
        const isActive = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            id={`nav-${tab.id}`}
            onClick={() => handleTabClick(tab.id)}
            className={`flex-1 py-3 flex flex-col items-center text-xs font-medium cursor-pointer
              ${isActive ? "text-orange-500" : "text-gray-400"}`}
          >
            {tab.icon(isActive)}
            {tab.label}
          </button>
        );
      })}
    </nav>
  );
}
