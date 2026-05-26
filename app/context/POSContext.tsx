"use client";

import React, { createContext, useContext, useState, ReactNode } from "react";

export type OrderStatus = "Baru" | "Diproses" | "Selesai" | "Dibatalkan";

export interface MenuItem {
  id: string;
  name: string;
  price: number;
  category: "food" | "drink";
  status: "Ready" | "Habis";
  note?: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerName: string;
  items: string;
  notes?: string;
  total: number;
  time: string;
  status: OrderStatus;
  createdAt: Date;
}

interface POSContextType {
  isAuthenticated: boolean;
  login: (username: string, password: string) => boolean;
  logout: () => void;
  activeTab: "beranda" | "pesanan" | "menu";
  setActiveTab: (tab: "beranda" | "pesanan" | "menu") => void;
  activeScreen: string;
  setActiveScreen: (screen: string) => void;
  orders: Order[];
  addOrder: (order: Omit<Order, "id" | "orderNumber" | "time" | "createdAt">) => void;
  updateOrderStatus: (id: string, status: OrderStatus) => void;
  menuItems: MenuItem[];
  addMenuItem: (item: Omit<MenuItem, "id">) => void;
  updateMenuItemStatus: (id: string, status: "Ready" | "Habis") => void;
  deleteMenuItem: (id: string) => void;
}

const POSContext = createContext<POSContextType | undefined>(undefined);

const initialMenuItems: MenuItem[] = [
  { id: "m1", name: "Ayam Geprek", price: 18000, category: "food", status: "Ready" },
  { id: "m2", name: "Es Teh Manis", price: 5000, category: "drink", status: "Habis" },
  { id: "m3", name: "Jeruk Peras (Es/Hangat)", price: 7000, category: "drink", status: "Habis" },
  { id: "m4", name: "Paket Ayam Geprek", price: 22000, category: "food", status: "Ready" },
];

const initialOrders: Order[] = [
  {
    id: "o1",
    orderNumber: "TN-001",
    customerName: "Meja 05",
    items: "2x Ayam Geprek, 1x Es Teh",
    total: 500000,
    time: "14:20",
    status: "Baru",
    createdAt: new Date(),
  },
  {
    id: "o2",
    orderNumber: "TN-002",
    customerName: "Meja 03",
    items: "1x Paket Ayam Geprek, 1x Jeruk Hangat",
    total: 320000,
    time: "13:45",
    status: "Diproses",
    createdAt: new Date(),
  },
  {
    id: "o3",
    orderNumber: "TN-003",
    customerName: "Andi",
    items: "5x Ayam Geprek",
    total: 900000,
    time: "12:05",
    status: "Selesai",
    createdAt: new Date(),
  },
];

let orderCounter = 4;
let menuCounter = 5;

export function POSProvider({ children }: { children: ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [activeTab, setActiveTab] = useState<"beranda" | "pesanan" | "menu">("beranda");
  const [activeScreen, setActiveScreen] = useState("beranda");
  const [orders, setOrders] = useState<Order[]>(initialOrders);
  const [menuItems, setMenuItems] = useState<MenuItem[]>(initialMenuItems);

  const addOrder = (order: Omit<Order, "id" | "orderNumber" | "time" | "createdAt">) => {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, "0");
    const minutes = String(now.getMinutes()).padStart(2, "0");
    const newOrder: Order = {
      ...order,
      id: `o${orderCounter}`,
      orderNumber: `TN-${String(orderCounter).padStart(3, "0")}`,
      time: `${hours}:${minutes}`,
      createdAt: now,
    };
    orderCounter++;
    setOrders((prev) => [newOrder, ...prev]);
  };

  const updateOrderStatus = (id: string, status: OrderStatus) => {
    setOrders((prev) =>
      prev.map((o) => (o.id === id ? { ...o, status } : o))
    );
  };

  const addMenuItem = (item: Omit<MenuItem, "id">) => {
    const newItem: MenuItem = { ...item, id: `m${menuCounter}` };
    menuCounter++;
    setMenuItems((prev) => [...prev, newItem]);
  };

  const updateMenuItemStatus = (id: string, status: "Ready" | "Habis") => {
    setMenuItems((prev) =>
      prev.map((m) => (m.id === id ? { ...m, status } : m))
    );
  };

  const deleteMenuItem = (id: string) => {
    setMenuItems((prev) => prev.filter((m) => m.id !== id));
  };

  const login = (username: string, password: string): boolean => {
    if (username === "admin" && password === "admin123") {
      setIsAuthenticated(true);
      return true;
    }
    return false;
  };

  const logout = () => {
    setIsAuthenticated(false);
  };

  return (
    <POSContext.Provider
      value={{
        isAuthenticated,
        login,
        logout,
        activeTab,
        setActiveTab,
        activeScreen,
        setActiveScreen,
        orders,
        addOrder,
        updateOrderStatus,
        menuItems,
        addMenuItem,
        updateMenuItemStatus,
        deleteMenuItem,
      }}
    >
      {children}
    </POSContext.Provider>
  );
}

export function usePOS() {
  const ctx = useContext(POSContext);
  if (!ctx) throw new Error("usePOS must be used within POSProvider");
  return ctx;
}
