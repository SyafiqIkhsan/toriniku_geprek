-- ============================================================
-- UMKM POS — Supabase Migration
-- ============================================================

-- Enable UUID generation
create extension if not exists "pgcrypto";


-- ------------------------------------------------------------
-- CATEGORIES
-- ------------------------------------------------------------
create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  sort_order  int not null default 0
);

-- ------------------------------------------------------------
-- MENU ITEMS
-- ------------------------------------------------------------
create table public.menu_items (
  id            uuid primary key default gen_random_uuid(),
  category_id   uuid references public.categories(id) on delete set null,
  name          text not null,
  description   text,
  price         numeric(12, 2) not null check (price >= 0),
  is_available  boolean not null default true,
  is_archived   boolean not null default false
);

-- ------------------------------------------------------------
-- MODIFIERS  (e.g. "Extra shot +5000", "Less sugar")
-- ------------------------------------------------------------
create table public.modifiers (
  id            uuid primary key default gen_random_uuid(),
  menu_item_id  uuid not null references public.menu_items(id) on delete cascade,
  name          text not null,
  price_delta   numeric(12, 2) not null default 0  -- can be negative
);

-- ------------------------------------------------------------
-- DISCOUNTS
-- ------------------------------------------------------------
create table public.discounts (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  type        text not null check (type in ('percent', 'fixed')),
  value       numeric(12, 2) not null check (value >= 0),
  is_active   boolean not null default true,
  expires_at  timestamptz
);

-- ------------------------------------------------------------
-- ORDERS
-- ------------------------------------------------------------
create table public.orders (
  id               uuid primary key default gen_random_uuid(),
  discount_id      uuid references public.discounts(id) on delete set null,

  order_type       text not null default 'dine_in'
                     check (order_type in ('dine_in', 'takeaway')),
  status           text not null default 'open'
                     check (status in ('open', 'paid', 'cancelled', 'refunded')),

  -- Totals (computed and stored for historical accuracy)
  subtotal         numeric(12, 2) not null default 0,
  discount_amount  numeric(12, 2) not null default 0,
  tax              numeric(12, 2) not null default 0,
  total            numeric(12, 2) not null default 0,

  -- Payment (folded in — no separate table needed for UMKM)
  payment_method   text check (payment_method in ('cash', 'qris')),
  amount_paid      numeric(12, 2),
  change_given     numeric(12, 2) default 0,
  paid_at          timestamptz,

  created_at       timestamptz not null default now()
);

-- ------------------------------------------------------------
-- ORDER ITEMS
-- ------------------------------------------------------------
create table public.order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders(id) on delete cascade,
  menu_item_id  uuid references public.menu_items(id) on delete set null,
  quantity      int not null check (quantity > 0),
  unit_price    numeric(12, 2) not null,  -- snapshot at time of order
  notes         text
);

-- ------------------------------------------------------------
-- ORDER ITEM MODIFIERS
-- ------------------------------------------------------------
create table public.order_item_modifiers (
  id            uuid primary key default gen_random_uuid(),
  order_item_id uuid not null references public.order_items(id) on delete cascade,
  modifier_id   uuid references public.modifiers(id) on delete set null,
  price_delta   numeric(12, 2) not null  -- snapshot at time of order
);

-- ============================================================
-- INDEXES
-- ============================================================
create index on public.orders(status);
create index on public.orders(created_at desc);
create index on public.order_items(order_id);
create index on public.menu_items(category_id);
create index on public.menu_items(is_available) where is_archived = false;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
alter table public.categories             enable row level security;
alter table public.menu_items             enable row level security;
alter table public.modifiers              enable row level security;
alter table public.discounts              enable row level security;
alter table public.orders                 enable row level security;
alter table public.order_items            enable row level security;
alter table public.order_item_modifiers   enable row level security;

-- Basic policy: authenticated users can read/write everything.
-- Tighten per-role in your app logic or expand these policies.
create policy "authenticated full access" on public.categories
  for all to authenticated using (true) with check (true);
create policy "authenticated full access" on public.menu_items
  for all to authenticated using (true) with check (true);
create policy "authenticated full access" on public.modifiers
  for all to authenticated using (true) with check (true);
create policy "authenticated full access" on public.discounts
  for all to authenticated using (true) with check (true);
create policy "authenticated full access" on public.orders
  for all to authenticated using (true) with check (true);
create policy "authenticated full access" on public.order_items
  for all to authenticated using (true) with check (true);
create policy "authenticated full access" on public.order_item_modifiers
  for all to authenticated using (true) with check (true);

-- ============================================================
-- SEED DATA (optional — safe to delete)
-- ============================================================
insert into public.categories (name, sort_order) values
  ('Minuman', 1),
  ('Makanan', 2),
  ('Snack', 3);

insert into public.discounts (name, type, value) values
  ('Diskon Member 10%', 'percent', 10),
  ('Promo Pelajar 5000', 'fixed', 5000);