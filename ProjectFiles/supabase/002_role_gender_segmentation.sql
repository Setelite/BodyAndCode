-- Body&Code: role/gender segmentation
-- Run after 001_initial_schema.sql

alter table if exists public.profiles
  add column if not exists gender text not null default 'not_specified'
  check (gender in ('male', 'female', 'other', 'not_specified'));

create index if not exists idx_profiles_role on public.profiles(role);
create index if not exists idx_profiles_gender on public.profiles(gender);
create index if not exists idx_profiles_role_gender on public.profiles(role, gender);

create or replace view public.clients_feed as
select
  id,
  name,
  email,
  gender,
  city,
  current_weight,
  goal_weight,
  coach_id,
  created_at
from public.profiles
where role = 'client';

create or replace view public.coaches_feed as
select
  p.id,
  p.name,
  p.email,
  p.gender,
  coalesce(cp.specialization, p.specialization, '') as specialization,
  coalesce(cp.experience_years, p.experience_years, 0) as experience_years,
  cp.rating,
  cp.reviews_count,
  p.created_at
from public.profiles p
left join public.coach_profiles cp on cp.user_id = p.id
where p.role = 'coach';
