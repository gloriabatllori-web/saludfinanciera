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

-- Ejecutar solo si la tabla reflexiones ya existía sin estas columnas:
alter table public.reflexiones add column if not exists user_name text;
alter table public.reflexiones add column if not exists user_email text;

create table if not exists public.preguntas (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  user_name text,
  user_email text,
  text text not null,
  respuesta text,
  respondida boolean default false,
  created_at timestamptz default now(),
  answered_at timestamptz
);

alter table public.preguntas enable row level security;

drop policy if exists "Users can view own preguntas" on public.preguntas;
create policy "Users can view own preguntas"
  on public.preguntas for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own preguntas" on public.preguntas;
create policy "Users can insert own preguntas"
  on public.preguntas for insert
  with check (auth.uid() = user_id);

-- Panel de administración: Gloria ve todo y puede contestar preguntas.
-- Identificación por email (sin rol/tabla de admins separada) porque es la única cuenta que lo necesita.
drop policy if exists "Admin can view all preguntas" on public.preguntas;
create policy "Admin can view all preguntas"
  on public.preguntas for select
  using (auth.jwt() ->> 'email' = 'gloriabatllori@gmail.com');

drop policy if exists "Admin can update preguntas" on public.preguntas;
create policy "Admin can update preguntas"
  on public.preguntas for update
  using (auth.jwt() ->> 'email' = 'gloriabatllori@gmail.com');

drop policy if exists "Admin can view all reflexiones" on public.reflexiones;
create policy "Admin can view all reflexiones"
  on public.reflexiones for select
  using (auth.jwt() ->> 'email' = 'gloriabatllori@gmail.com');
