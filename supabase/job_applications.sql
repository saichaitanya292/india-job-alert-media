-- India Job Alert: job application tracker
-- Run this entire script in Supabase Dashboard -> SQL Editor -> New query.
-- Each signed-in user can only read/change their own tracker records.

create table if not exists public.job_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_url text not null,
  title text not null default 'Technology job',
  company text not null default '',
  location text not null default '',
  status text not null default 'Interested'
    check (status in ('Interested', 'Applied', 'Interviewing', 'Offered', 'Rejected')),
  applied_date date,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint job_applications_user_job_unique unique (user_id, job_url)
);

alter table public.job_applications enable row level security;

drop policy if exists "Users can read their own applications" on public.job_applications;
create policy "Users can read their own applications"
  on public.job_applications for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can add their own applications" on public.job_applications;
create policy "Users can add their own applications"
  on public.job_applications for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own applications" on public.job_applications;
create policy "Users can update their own applications"
  on public.job_applications for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can remove their own applications" on public.job_applications;
create policy "Users can remove their own applications"
  on public.job_applications for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create index if not exists job_applications_user_updated_idx
  on public.job_applications (user_id, updated_at desc);
