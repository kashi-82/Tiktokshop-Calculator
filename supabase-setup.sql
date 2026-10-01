-- TikTok Shop UK Calculator — Supabase Setup
-- Run this in: https://supabase.com/dashboard/project/ywhbrvgenmpdalqeedfp/sql/new

-- 1. Create table
create table if not exists public.user_products (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  data        jsonb not null default '[]'::jsonb,
  sr_counter  integer not null default 1,
  updated_at  timestamptz not null default now(),
  constraint user_products_user_id_key unique (user_id)
);

-- 2. Enable Row Level Security (each user sees only their own row)
alter table public.user_products enable row level security;

-- 3. RLS policies
create policy "Users can read their own data"
  on public.user_products for select
  using (auth.uid() = user_id);

create policy "Users can insert their own data"
  on public.user_products for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own data"
  on public.user_products for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own data"
  on public.user_products for delete
  using (auth.uid() = user_id);

-- 4. Auto-update timestamp
create or replace function public.handle_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger on_user_products_update
  before update on public.user_products
  for each row execute procedure public.handle_updated_at();
