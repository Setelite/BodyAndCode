-- Body&Code training programs schema (PostgreSQL / Supabase-ready)

create table if not exists users (
    id uuid primary key,
    role text not null check (role in ('coach', 'client')),
    name text not null,
    email text not null unique,
    created_at timestamptz not null default now()
);

create table if not exists coach_client_links (
    id uuid primary key default gen_random_uuid(),
    coach_id uuid not null references users(id) on delete cascade,
    client_id uuid not null references users(id) on delete cascade,
    status text not null default 'active' check (status in ('active', 'paused', 'blocked')),
    created_at timestamptz not null default now(),
    unique (coach_id, client_id)
);

create table if not exists training_programs (
    id uuid primary key default gen_random_uuid(),
    coach_id uuid not null references users(id) on delete cascade,
    title text not null,
    summary text not null default '',
    status text not null default 'draft' check (status in ('draft', 'published', 'archived')),
    version int not null default 1,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists training_program_exercises (
    id uuid primary key default gen_random_uuid(),
    program_id uuid not null references training_programs(id) on delete cascade,
    sort_order int not null default 0,
    exercise_name text not null,
    muscle_group text not null,
    sets int not null,
    reps int not null,
    rest_seconds int not null default 90,
    target_weight numeric not null default 0
);

create table if not exists training_program_assignments (
    id uuid primary key default gen_random_uuid(),
    program_id uuid not null references training_programs(id) on delete cascade,
    coach_id uuid not null references users(id) on delete cascade,
    client_id uuid not null references users(id) on delete cascade,
    note text,
    assigned_at timestamptz not null default now(),
    is_active boolean not null default true
);

-- Optional: workout execution logs
create table if not exists workout_sessions (
    id uuid primary key default gen_random_uuid(),
    assignment_id uuid not null references training_program_assignments(id) on delete cascade,
    client_id uuid not null references users(id) on delete cascade,
    started_at timestamptz not null,
    ended_at timestamptz,
    duration_seconds int not null default 0
);

create table if not exists workout_sets (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null references workout_sessions(id) on delete cascade,
    exercise_name text not null,
    set_number int not null,
    target_weight numeric not null default 0,
    target_reps int not null default 0,
    completed_weight numeric not null default 0,
    completed_reps int not null default 0
);

create index if not exists idx_programs_coach on training_programs(coach_id, status);
create index if not exists idx_assignments_client on training_program_assignments(client_id, is_active);
create index if not exists idx_assignments_program on training_program_assignments(program_id, is_active);
create index if not exists idx_program_exercises_program on training_program_exercises(program_id, sort_order);

