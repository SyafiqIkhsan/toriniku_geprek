"use client";

import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  ReactNode,
} from "react";
import { Session } from "@supabase/supabase-js";
import { createClient } from "../../lib/supabase/client";

const supabase = createClient();

// ─── Types ────────────────────────────────────────────────────────────────────

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
  createdAt: string;
}

interface POSContextType {
  session: Session | null;
  orders: Order[];
  ordersLoading: boolean;
  addOrder: (order: Pick<Order, "customerName" | "items" | "notes" | "total">) => Promise<void>;
  updateOrderStatus: (id: string, status: OrderStatus) => Promise<void>;
  menuItems: MenuItem[];
  menuLoading: boolean;
  addMenuItem: (item: Omit<MenuItem, "id">) => Promise<void>;
  updateMenuItemStatus: (id: string, status: "Ready" | "Habis") => Promise<void>;
  deleteMenuItem: (id: string) => Promise<void>;
}

// ─── Context ──────────────────────────────────────────────────────────────────

const POSContext = createContext<POSContextType | undefined>(undefined);

// ─── Provider ─────────────────────────────────────────────────────────────────

export function POSProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [orders, setOrders] = useState<Order[]>([]);
  const [ordersLoading, setOrdersLoading] = useState(true);
  const [menuItems, setMenuItems] = useState<MenuItem[]>([]);
  const [menuLoading, setMenuLoading] = useState(true);

  // ── Session ─────────────────────────────────────────────────────────────────

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_e, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  // ── Fetch data ───────────────────────────────────────────────────────────────

  const fetchOrders = useCallback(async () => {
    setOrdersLoading(true);
    const { data, error } = await supabase
      .from("orders")
      .select("*")
      .order("created_at", { ascending: false });

    if (!error && data) {
      setOrders(
        data.map((row) => ({
          id: row.id,
          orderNumber: row.order_number,
          customerName: row.customer_name,
          items: row.items,
          notes: row.notes ?? undefined,
          total: row.total,
          time: row.time,
          status: row.status as OrderStatus,
          createdAt: row.created_at,
        }))
      );
    }
    setOrdersLoading(false);
  }, []);

  const fetchMenuItems = useCallback(async () => {
    setMenuLoading(true);
    const { data, error } = await supabase
      .from("menu_items")
      .select("*")
      .order("created_at", { ascending: true });

    if (!error && data) {
      setMenuItems(
        data.map((row) => ({
          id: row.id,
          name: row.name,
          price: row.price,
          category: row.category as "food" | "drink",
          status: row.status as "Ready" | "Habis",
          note: row.note ?? undefined,
        }))
      );
    }
    setMenuLoading(false);
  }, []);

  useEffect(() => {
    if (session) {
      fetchOrders();
      fetchMenuItems();
    }
  }, [session, fetchOrders, fetchMenuItems]);

  // ── Order mutations ──────────────────────────────────────────────────────────

  const addOrder = async (order: Pick<Order, "customerName" | "items" | "notes" | "total">) => {
    const now = new Date();
    const time = `${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}`;

    const { error } = await supabase.from("orders").insert({
      customer_name: order.customerName,
      items: order.items,
      notes: order.notes ?? null,
      total: order.total,
      time,
      status: "Baru",
    });

    if (!error) await fetchOrders();
  };

  const updateOrderStatus = async (id: string, status: OrderStatus) => {
    const { error } = await supabase.from("orders").update({ status }).eq("id", id);
    if (!error) {
      setOrders((prev) => prev.map((o) => (o.id === id ? { ...o, status } : o)));
    }
  };

  // ── Menu mutations ───────────────────────────────────────────────────────────

  const addMenuItem = async (item: Omit<MenuItem, "id">) => {
    const { error } = await supabase.from("menu_items").insert({
      name: item.name,
      price: item.price,
      category: item.category,
      status: item.status,
      note: item.note ?? null,
    });
    if (!error) await fetchMenuItems();
  };

  const updateMenuItemStatus = async (id: string, status: "Ready" | "Habis") => {
    const { error } = await supabase.from("menu_items").update({ status }).eq("id", id);
    if (!error) {
      setMenuItems((prev) => prev.map((m) => (m.id === id ? { ...m, status } : m)));
    }
  };

  const deleteMenuItem = async (id: string) => {
    const { error } = await supabase.from("menu_items").delete().eq("id", id);
    if (!error) setMenuItems((prev) => prev.filter((m) => m.id !== id));
  };

  return (
    <POSContext.Provider
      value={{
        session,
        orders,
        ordersLoading,
        addOrder,
        updateOrderStatus,
        menuItems,
        menuLoading,
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
