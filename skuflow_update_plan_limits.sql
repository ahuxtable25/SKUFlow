-- Run once in the Supabase SQL editor (SKUFlow project).
-- New plan limits: Core 1000, Plus 2500, Pro 5000 ('internal' stays unlimited).
alter table workspaces alter column listing_limit set default 1000;

update workspaces set listing_limit = 1000 where tier = 'core';
update workspaces set listing_limit = 2500 where tier = 'plus';
update workspaces set listing_limit = 5000 where tier = 'pro';

-- also update the signup function so new workspaces start on 1000:
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
  values (p_workspace_name, 'core', 1000)
  returning id into new_workspace_id;

  insert into profiles (id, workspace_id, full_name, email, is_admin, onboarding_complete)
  values (auth.uid(), new_workspace_id, p_full_name, auth.email(), true, false);

  return new_workspace_id;
end;
$$;

select name, tier, listing_limit from workspaces order by tier;
