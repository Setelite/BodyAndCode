-- Body&Code: Supabase initial schema
-- Run in Supabase SQL Editor

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('client', 'coach')),
  name text not null,
  email text not null,
  avatar_url text,
  bio text,
  city text,
  current_weight numeric,
  goal_weight numeric,
  coach_id uuid references public.profiles(id) on delete set null,
  specialization text,
  experience_years int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.coach_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  specialization text not null default '',
  experience_years int not null default 0,
  price numeric not null default 0,
  rating numeric not null default 0,
  reviews_count int not null default 0,
  instagram text,
  telegram text,
  updated_at timestamptz not null default now()
);

create table if not exists public.client_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  age int,
  height_cm int,
  fitness_level text,
  goals text[] not null default '{}',
  updated_at timestamptz not null default now()
);

create table if not exists public.coach_client_links (
  id uuid primary key default gen_random_uuid(),
  coach_id uuid not null references public.profiles(id) on delete cascade,
  client_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'active' check (status in ('pending', 'active', 'archived')),
  created_at timestamptz not null default now(),
  unique (coach_id, client_id)
);

create table if not exists public.training_programs (
  id uuid primary key default gen_random_uuid(),
  coach_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  visibility text not null default 'private' check (visibility in ('private', 'public')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.program_assignments (
  id uuid primary key default gen_random_uuid(),
  program_id uuid not null references public.training_programs(id) on delete cascade,
  client_id uuid not null references public.profiles(id) on delete cascade,
  assigned_by uuid not null references public.profiles(id) on delete cascade,
  assigned_at timestamptz not null default now(),
  unique (program_id, client_id)
);

create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now()
);

create table if not exists public.chat_members (
  chat_id uuid not null references public.chats(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('client', 'coach')),
  joined_at timestamptz not null default now(),
  primary key (chat_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  text text not null default '',
  attachment_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.workout_logs (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles(id) on delete cascade,
  coach_id uuid references public.profiles(id) on delete set null,
  program_id uuid references public.training_programs(id) on delete set null,
  exercise_name text not null,
  sets int not null,
  reps int not null,
  weight numeric not null default 0,
  workout_date date not null default current_date,
  created_at timestamptz not null default now()
);

create or replace view public.coach_social_feed as
select
  p.id as coach_id,
  p.name,
  coalesce(cp.specialization, p.specialization, '') as specialization,
  coalesce(cp.experience_years, p.experience_years, 0) as experience_years,
  cp.rating,
  cp.reviews_count,
  p.bio,
  p.avatar_url
from public.profiles p
left join public.coach_profiles cp on cp.user_id = p.id
where p.role = 'coach';

alter table public.profiles enable row level security;
alter table public.coach_profiles enable row level security;
alter table public.client_profiles enable row level security;
alter table public.coach_client_links enable row level security;
alter table public.training_programs enable row level security;
alter table public.program_assignments enable row level security;
alter table public.chats enable row level security;
alter table public.chat_members enable row level security;
alter table public.messages enable row level security;
alter table public.workout_logs enable row level security;

-- profiles
drop policy if exists "profiles select own or coaches public" on public.profiles;
create policy "profiles select own or coaches public"
on public.profiles for select
using (
  id = auth.uid()
  or role = 'coach'
);

drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own"
on public.profiles for insert
with check (id = auth.uid());

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

-- coach/client profile edits are owner-only
drop policy if exists "coach profiles owner rw" on public.coach_profiles;
create policy "coach profiles owner rw"
on public.coach_profiles for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "client profiles owner rw" on public.client_profiles;
create policy "client profiles owner rw"
on public.client_profiles for all
using (user_id = auth.uid())
with check (user_id = auth.uid());

-- links are visible to linked users, managed by coach
drop policy if exists "links visible to members" on public.coach_client_links;
create policy "links visible to members"
on public.coach_client_links for select
using (coach_id = auth.uid() or client_id = auth.uid());

drop policy if exists "links managed by coach" on public.coach_client_links;
create policy "links managed by coach"
on public.coach_client_links for all
using (coach_id = auth.uid())
with check (coach_id = auth.uid());

-- training programs visible to owner or public
drop policy if exists "programs select owner or public" on public.training_programs;
create policy "programs select owner or public"
on public.training_programs for select
using (coach_id = auth.uid() or visibility = 'public');

drop policy if exists "programs write owner" on public.training_programs;
create policy "programs write owner"
on public.training_programs for all
using (coach_id = auth.uid())
with check (coach_id = auth.uid());

-- assignments visible to coach/client
drop policy if exists "assignments visible to members" on public.program_assignments;
create policy "assignments visible to members"
on public.program_assignments for select
using (assigned_by = auth.uid() or client_id = auth.uid());

drop policy if exists "assignments managed by coach" on public.program_assignments;
create policy "assignments managed by coach"
on public.program_assignments for all
using (assigned_by = auth.uid())
with check (assigned_by = auth.uid());

-- chat access
drop policy if exists "chat members select own" on public.chat_members;
create policy "chat members select own"
on public.chat_members for select
using (user_id = auth.uid());

drop policy if exists "chats select by membership" on public.chats;
create policy "chats select by membership"
on public.chats for select
using (exists (
  select 1 from public.chat_members cm
  where cm.chat_id = chats.id and cm.user_id = auth.uid()
));

drop policy if exists "messages select by membership" on public.messages;
create policy "messages select by membership"
on public.messages for select
using (exists (
  select 1 from public.chat_members cm
  where cm.chat_id = messages.chat_id and cm.user_id = auth.uid()
));

drop policy if exists "messages insert by membership" on public.messages;
create policy "messages insert by membership"
on public.messages for insert
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.chat_members cm
    where cm.chat_id = messages.chat_id and cm.user_id = auth.uid()
  )
);

-- workout logs visible to owner and linked coach
drop policy if exists "workout logs visible to members" on public.workout_logs;
create policy "workout logs visible to members"
on public.workout_logs for select
using (client_id = auth.uid() or coach_id = auth.uid());

drop policy if exists "workout logs insert owner" on public.workout_logs;
create policy "workout logs insert owner"
on public.workout_logs for insert
with check (client_id = auth.uid());

