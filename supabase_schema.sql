-- Supabase schema for Lil fairy award
-- Run this in Supabase SQL editor to create tables and RLS policies

-- 1) Profiles table (links to auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  full_name text,
  grade text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Profiles: allow insert as owner" on public.profiles
  for insert
  with check (auth.uid() = id);

create policy "Profiles: allow select own" on public.profiles
  for select
  using (auth.uid() = id);

create policy "Profiles: allow update own" on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 2) Classrooms table: one row per classroom, owned by a teacher (auth.users.id)
create table if not exists public.classrooms (
  id text primary key,
  owner uuid references auth.users(id) on delete cascade,
  name text,
  data jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz
);

alter table public.classrooms enable row level security;

-- Allow authenticated users to insert classrooms where owner = auth.uid()
create policy "Classrooms: allow insert for owner" on public.classrooms
  for insert
  with check (auth.uid() = owner::text or auth.uid() = owner);

-- Allow users to select their own classrooms
create policy "Classrooms: allow select own" on public.classrooms
  for select
  using (auth.uid() = owner::text or auth.uid() = owner);

-- Allow users to update their own classrooms
create policy "Classrooms: allow update own" on public.classrooms
  for update
  using (auth.uid() = owner::text or auth.uid() = owner)
  with check (auth.uid() = owner::text or auth.uid() = owner);

-- Optional: provide a read-only admin view if you manage admin claims
-- create policy "Classrooms: admin select all" on public.classrooms
--   for select
--   using (auth.role() = 'admin' OR auth.uid() = owner);
