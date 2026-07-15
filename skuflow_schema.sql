-- SKUFlow Schema SQL
-- Run this in your Supabase SQL Editor (bufysvflmcffsqlntrwp)
-- Go to: supabase.com/dashboard/project/bufysvflmcffsqlntrwp/sql/new

-- ─────────────────────────────────────────
-- 1. WORKSPACES
-- One row per customer account
-- ─────────────────────────────────────────
create table workspaces (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,                          -- e.g. "Archive District"
  tier          text not null default 'core'            -- 'core' | 'plus' | 'pro' | 'internal'
                check (tier in ('core','plus','pro','internal')),
  listing_limit integer not null default 300,           -- enforced in app
  created_at    timestamptz not null default now(),
  is_active     boolean not null default true           -- false = suspended
);

-- ─────────────────────────────────────────
-- 2. PROFILES
-- One row per user, linked to Supabase Auth
-- ─────────────────────────────────────────
create table profiles (
  id             uuid primary key references auth.users(id) on delete cascade,
  workspace_id   uuid not null references workspaces(id) on delete cascade,
  full_name      text,
  email          text,
  is_admin       boolean not null default false,        -- true = access to /admin
  created_at     timestamptz not null default now()
);

-- ─────────────────────────────────────────
-- 3. APP STATE
-- One row per workspace — mirrors existing app_state structure
-- ─────────────────────────────────────────
create table app_state (
  id             uuid primary key default gen_random_uuid(),
  workspace_id   uuid not null unique references workspaces(id) on delete cascade,
  listings       jsonb not null default '[]'::jsonb,
  stock_data     jsonb not null default '[]'::jsonb,
  goals          jsonb not null default '{}'::jsonb,
  updated_at     timestamptz not null default now()
);

-- ─────────────────────────────────────────
-- 4. CONTACT SUBMISSIONS
-- Stores Contact Us form entries from all tiers
-- ─────────────────────────────────────────
create table contact_submissions (
  id             uuid primary key default gen_random_uuid(),
  workspace_id   uuid references workspaces(id) on delete set null,
  user_name      text,
  user_email     text,
  tier           text,
  type           text not null                          -- 'question' | 'suggestion' | 'issue'
                 check (type in ('question','suggestion','issue')),
  subject        text not null,
  message        text not null,
  status         text not null default 'new'            -- 'new' | 'read' | 'resolved'
                 check (status in ('new','read','resolved')),
  created_at     timestamptz not null default now()
);

-- ─────────────────────────────────────────
-- 5. ANNOUNCEMENTS
-- Admin pushes update notices to specific tiers
-- ─────────────────────────────────────────
create table announcements (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  body           text not null,
  tiers          text[] not null default array['core','plus','pro','internal'],
  is_active      boolean not null default true,
  created_at     timestamptz not null default now()
);

-- ─────────────────────────────────────────
-- 6. DRAFTER LANGUAGE CONFIG
-- Pro + Internal only — one row per workspace
-- ─────────────────────────────────────────
create table drafter_config (
  id                    uuid primary key default gen_random_uuid(),
  workspace_id          uuid not null unique references workspaces(id) on delete cascade,
  tone                  text default 'casual'           -- 'casual' | 'formal' | 'hype'
                        check (tone in ('casual','formal','hype')),
  dialect               text default 'uk'               -- 'uk' | 'us'
                        check (dialect in ('uk','us')),
  description_length    text default 'medium'           -- 'short' | 'medium' | 'detailed'
                        check (description_length in ('short','medium','detailed')),
  always_include        text,                           -- free text
  never_include         text,                           -- free text
  brand_voice_notes     text,                           -- free text
  setup_complete        boolean not null default false, -- true once 6-step flow done
  created_at            timestamptz not null default now()
);

-- ─────────────────────────────────────────
-- 7. ROW LEVEL SECURITY
-- Users can only read/write their own workspace data
-- ─────────────────────────────────────────
alter table workspaces          enable row level security;
alter table profiles            enable row level security;
alter table app_state           enable row level security;
alter table contact_submissions enable row level security;
alter table announcements       enable row level security;
alter table drafter_config      enable row level security;

-- Profiles: users see only their own
create policy "own profile" on profiles
  for all using (id = auth.uid());

-- Workspaces: users see only their workspace
create policy "own workspace" on workspaces
  for all using (
    id = (select workspace_id from profiles where id = auth.uid())
  );

-- App state: users see only their workspace
create policy "own app_state" on app_state
  for all using (
    workspace_id = (select workspace_id from profiles where id = auth.uid())
  );

-- Contact submissions: users can insert and read their own
create policy "own submissions" on contact_submissions
  for all using (
    workspace_id = (select workspace_id from profiles where id = auth.uid())
  );

-- Announcements: all authenticated users can read active ones
create policy "read announcements" on announcements
  for select using (auth.uid() is not null and is_active = true);

-- Drafter config: users see only their workspace
create policy "own drafter_config" on drafter_config
  for all using (
    workspace_id = (select workspace_id from profiles where id = auth.uid())
  );

-- ─────────────────────────────────────────
-- 8. YOUR WORKSPACE (Archive District / Internal)
-- Run this AFTER the tables above are created
-- ─────────────────────────────────────────
insert into workspaces (name, tier, listing_limit)
values ('Archive District', 'internal', 999999)
returning id;
-- IMPORTANT: Copy the returned UUID — you'll need it when we create your user account

-- ─────────────────────────────────────────
-- 9. SELF-SERVE SIGNUP
-- Runs with elevated privileges but is scoped entirely to auth.uid(),
-- so a signed-up user can only ever create their own workspace + profile once.
-- New workspaces default to the 'core' tier — upgrade manually via SQL for testing/demo accounts.
-- ─────────────────────────────────────────
create or replace function create_workspace_and_profile(p_workspace_name text, p_full_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_workspace_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  if exists (select 1 from profiles where id = auth.uid()) then
    raise exception 'Profile already exists for this user';
  end if;

  insert into workspaces (name, tier, listing_limit)
  values (p_workspace_name, 'core', 300)
  returning id into new_workspace_id;

  insert into profiles (id, workspace_id, full_name, email, is_admin, onboarding_complete)
  values (auth.uid(), new_workspace_id, p_full_name, auth.email(), true, false);

  return new_workspace_id;
end;
$$;

grant execute on function create_workspace_and_profile(text, text) to authenticated;

-- ─────────────────────────────────────────
-- 10. WAITLIST
-- Public landing page at /waitlist collects signups for the launch campaign.
-- Anyone can insert (join); only workspace admins can read the list.
-- ─────────────────────────────────────────
create table waitlist (
  id         uuid primary key default gen_random_uuid(),
  email      text not null unique,
  name       text,
  notified   boolean not null default false,
  created_at timestamptz not null default now()
);

alter table waitlist enable row level security;

create policy "anyone can join waitlist" on waitlist
  for insert
  with check (true);

create policy "admins can view waitlist" on waitlist
  for select
  using (exists (select 1 from profiles where id = auth.uid() and is_admin = true));

-- ─────────────────────────────────────────
-- 11. VERSION HISTORY (server-side, replaces localStorage snapshots)
-- One row per workspace per day. Auto-filled at 6am UK time (DST-aware)
-- by pg_cron; also upserted on-demand by the app's manual Save button.
-- Rolling 14-day retention, cleaned up by the same cron job.
-- ─────────────────────────────────────────
create table app_state_snapshots (
  id            uuid primary key default gen_random_uuid(),
  workspace_id  uuid not null references workspaces(id) on delete cascade,
  snapshot_date date not null,
  listings      jsonb not null default '[]'::jsonb,
  stock_data    jsonb not null default '[]'::jsonb,
  goals         jsonb not null default '{}'::jsonb,
  manual        boolean not null default false,
  created_at    timestamptz not null default now(),
  unique (workspace_id, snapshot_date)
);

alter table app_state_snapshots enable row level security;

create policy "read own snapshots" on app_state_snapshots
  for select
  using (workspace_id = (select workspace_id from profiles where id = auth.uid()));

-- Lets the app's manual "Save" button write an on-demand snapshot for today
create policy "insert own snapshots" on app_state_snapshots
  for insert
  with check (workspace_id = (select workspace_id from profiles where id = auth.uid()));

create policy "update own snapshots" on app_state_snapshots
  for update
  using (workspace_id = (select workspace_id from profiles where id = auth.uid()));

-- Runs hourly but only does work at 6am Europe/London (handles BST/GMT automatically)
create or replace function run_daily_snapshot()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if extract(hour from (now() at time zone 'Europe/London')) <> 6 then
    return;
  end if;

  insert into app_state_snapshots (workspace_id, snapshot_date, listings, stock_data, goals, manual)
  select workspace_id, (now() at time zone 'Europe/London')::date, listings, stock_data, goals, false
  from app_state
  on conflict (workspace_id, snapshot_date) do update
    set listings   = excluded.listings,
        stock_data = excluded.stock_data,
        goals      = excluded.goals,
        created_at = now();
  -- Note: does NOT overwrite manual=true rows' flag, only the automatic ones —
  -- if a manual save already happened today, this still refreshes its data
  -- but leaves it correctly attributed as that day's snapshot either way.

  delete from app_state_snapshots
  where snapshot_date < (now() at time zone 'Europe/London')::date - interval '14 days';
end;
$$;

-- Requires the pg_cron extension (enable via Database > Extensions in the
-- Supabase dashboard, or: create extension if not exists pg_cron;)
select cron.schedule('daily-app-state-snapshot', '0 * * * *', 'select run_daily_snapshot();');

-- ─────────────────────────────────────────
-- 12. ONBOARDING WIZARD
-- Defaults to true so existing accounts never see the wizard —
-- create_workspace_and_profile() explicitly sets false for new signups.
-- Admin-provisioned accounts (manual SQL insert) should also set this
-- to false if you want them to see the wizard on first login.
-- ─────────────────────────────────────────
alter table profiles add column if not exists onboarding_complete boolean not null default true;
