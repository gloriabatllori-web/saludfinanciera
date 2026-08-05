-- Ejecuta este script en Supabase: Dashboard > SQL Editor > New query > Run

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  gap_mensual numeric,
  capital_objetivo numeric,
  aportacion_mensual numeric,
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = user_id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = user_id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = user_id);

create table if not exists public.reflexiones (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null,
  created_at timestamptz default now()
);

alter table public.reflexiones enable row level security;

create policy "Users can view own reflexiones"
  on public.reflexiones for select
  using (auth.uid() = user_id);

create policy "Users can insert own reflexiones"
  on public.reflexiones for insert
  with check (auth.uid() = user_id);
