-- India Job Alert: saved jobs table
-- Run this entire script in Supabase Dashboard -> SQL Editor -> New query.

create table if not exists public.saved_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_url text not null,
  title text not null default 'Technology job',
  company text not null default '',
  location text not null default '',
  created_at timestamptz not null default now(),
  constraint saved_jobs_user_job_unique unique (user_id, job_url)
);

alter table public.saved_jobs enable row level security;

drop policy if exists "Users can read their own saved jobs" on public.saved_jobs;
create policy "Users can read their own saved jobs"
  on public.saved_jobs for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can save their own jobs" on public.saved_jobs;
create policy "Users can save their own jobs"
  on public.saved_jobs for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can remove their own saved jobs" on public.saved_jobs;
create policy "Users can remove their own saved jobs"
  on public.saved_jobs for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create index if not exists saved_jobs_user_created_idx
  on public.saved_jobs (user_id, created_at desc);
