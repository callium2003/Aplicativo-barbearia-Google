-- BarbeariaSP — Fase B: tenants, configuração operacional e Storage.
-- Esta migration não inclui dados demonstrativos e deve ser aplicada somente pelo CLI Supabase.

create extension if not exists btree_gist;
create extension if not exists pgcrypto;

create type public.app_role as enum ('owner', 'manager', 'barber');
create type public.schedule_mode as enum ('barbershop', 'custom');
create type public.invitation_status as enum ('pending', 'accepted', 'revoked', 'expired');

create table public.barbershops (
  id uuid primary key default gen_random_uuid(),
  public_name text not null check (char_length(public_name) between 2 and 120),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  description text check (char_length(description) <= 1200),
  phone text,
  normalized_phone text,
  contact_email text,
  normalized_contact_email text,
  address_line text,
  address_complement text,
  neighborhood text,
  city text,
  state text check (state is null or state ~ '^[A-Z]{2}$'),
  postal_code text,
  cover_image_path text,
  timezone text not null default 'America/Sao_Paulo' check (timezone = 'America/Sao_Paulo'),
  is_public boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.barbershop_registration_details (
  barbershop_id uuid primary key references public.barbershops(id) on delete cascade,
  legal_name text,
  tax_document text,
  billing_email text,
  billing_address text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.customers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  name text check (char_length(name) between 2 and 120),
  phone text,
  normalized_phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.professionals (
  id uuid primary key default gen_random_uuid(),
  barbershop_id uuid not null references public.barbershops(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 120),
  phone text,
  normalized_phone text,
  contact_email text,
  normalized_contact_email text,
  instagram_url text,
  photo_path text,
  active boolean not null default true,
  schedule_mode public.schedule_mode not null default 'barbershop',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, barbershop_id)
);

create table public.team_members (
  id uuid primary key default gen_random_uuid(),
  barbershop_id uuid not null references public.barbershops(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  professional_id uuid,
  role public.app_role not null,
  active boolean not null default true,
  invited_at timestamptz,
  activated_at timestamptz,
  deactivated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, barbershop_id),
  foreign key (professional_id, barbershop_id)
    references public.professionals(id, barbershop_id),
  check ((role = 'barber' and professional_id is not null) or (role in ('owner', 'manager')))
);

create unique index team_members_one_active_membership_per_tenant
  on public.team_members (barbershop_id, user_id)
  where active;

create table public.team_invitations (
  id uuid primary key default gen_random_uuid(),
  barbershop_id uuid not null references public.barbershops(id) on delete cascade,
  professional_id uuid,
  role public.app_role not null,
  normalized_email text not null,
  token_hash text not null unique,
  expires_at timestamptz not null,
  accepted_at timestamptz,
  revoked_at timestamptz,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  foreign key (professional_id, barbershop_id)
    references public.professionals(id, barbershop_id),
  check (expires_at > created_at),
  check ((role = 'barber' and professional_id is not null) or role = 'manager')
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  barbershop_id uuid not null references public.barbershops(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 120),
  description text check (char_length(description) <= 1000),
  duration_minutes integer not null check (duration_minutes > 0 and duration_minutes % 10 = 0),
  price_cents integer not null check (price_cents >= 0),
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, barbershop_id)
);

create table public.business_hours (
  barbershop_id uuid not null references public.barbershops(id) on delete cascade,
  weekday smallint not null check (weekday between 0 and 6),
  is_open boolean not null default false,
  start_time time,
  end_time time,
  updated_at timestamptz not null default now(),
  primary key (barbershop_id, weekday),
  check (
    (is_open and start_time is not null and end_time is not null and start_time < end_time)
    or (not is_open and start_time is null and end_time is null)
  )
);

create table public.professional_hours (
  professional_id uuid not null,
  barbershop_id uuid not null,
  weekday smallint not null check (weekday between 0 and 6),
  is_open boolean not null default false,
  start_time time,
  end_time time,
  updated_at timestamptz not null default now(),
  primary key (professional_id, weekday),
  foreign key (professional_id, barbershop_id)
    references public.professionals(id, barbershop_id) on delete cascade,
  check (
    (is_open and start_time is not null and end_time is not null and start_time < end_time)
    or (not is_open and start_time is null and end_time is null)
  )
);

create table public.professional_time_blocks (
  id uuid primary key default gen_random_uuid(),
  professional_id uuid not null,
  barbershop_id uuid not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  reason_code text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (professional_id, barbershop_id)
    references public.professionals(id, barbershop_id) on delete cascade,
  check (ends_at > starts_at)
);

create table public.professional_deactivation_reviews (
  id uuid primary key default gen_random_uuid(),
  barbershop_id uuid not null references public.barbershops(id) on delete cascade,
  professional_id uuid not null,
  open_appointment_count integer not null check (open_appointment_count >= 0),
  status text not null default 'open' check (status in ('open', 'resolved')),
  created_by uuid not null references auth.users(id),
  resolved_by uuid references auth.users(id),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  foreign key (professional_id, barbershop_id)
    references public.professionals(id, barbershop_id),
  check ((status = 'open' and resolved_by is null and resolved_at is null) or (status = 'resolved' and resolved_by is not null and resolved_at is not null))
);

create index professionals_public_catalog_idx on public.professionals (barbershop_id, active, name);
create index services_public_catalog_idx on public.services (barbershop_id, active, sort_order, name);
create index time_blocks_by_professional_idx on public.professional_time_blocks (professional_id, starts_at, ends_at) where active;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.has_active_role(target_barbershop_id uuid, allowed_roles public.app_role[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members member
    where member.barbershop_id = target_barbershop_id
      and member.user_id = auth.uid()
      and member.active
      and member.role = any(allowed_roles)
  );
$$;

revoke all on function public.has_active_role(uuid, public.app_role[]) from public;
grant execute on function public.has_active_role(uuid, public.app_role[]) to authenticated;

create or replace function public.can_manage_professional(target_professional_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.professionals professional
    join public.team_members member
      on member.barbershop_id = professional.barbershop_id
    where professional.id = target_professional_id
      and member.user_id = auth.uid()
      and member.active
      and (member.role in ('owner', 'manager') or member.professional_id = professional.id)
  );
$$;

revoke all on function public.can_manage_professional(uuid) from public;
grant execute on function public.can_manage_professional(uuid) to authenticated;

create or replace function public.is_valid_professional_schedule()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  business_day public.business_hours%rowtype;
begin
  select * into business_day
  from public.business_hours
  where barbershop_id = new.barbershop_id and weekday = new.weekday;

  if new.is_open and (business_day is null or not business_day.is_open
    or new.start_time < business_day.start_time or new.end_time > business_day.end_time) then
    raise exception 'Professional schedule must remain within business hours';
  end if;

  return new;
end;
$$;

create trigger barbershops_set_updated_at before update on public.barbershops
for each row execute function public.set_updated_at();
create trigger registration_details_set_updated_at before update on public.barbershop_registration_details
for each row execute function public.set_updated_at();
create trigger customers_set_updated_at before update on public.customers
for each row execute function public.set_updated_at();
create trigger professionals_set_updated_at before update on public.professionals
for each row execute function public.set_updated_at();
create trigger team_members_set_updated_at before update on public.team_members
for each row execute function public.set_updated_at();
create trigger services_set_updated_at before update on public.services
for each row execute function public.set_updated_at();
create trigger business_hours_set_updated_at before update on public.business_hours
for each row execute function public.set_updated_at();
create trigger professional_hours_validate before insert or update on public.professional_hours
for each row execute function public.is_valid_professional_schedule();
create trigger professional_hours_set_updated_at before update on public.professional_hours
for each row execute function public.set_updated_at();
create trigger professional_blocks_set_updated_at before update on public.professional_time_blocks
for each row execute function public.set_updated_at();

alter table public.barbershops enable row level security;
alter table public.barbershop_registration_details enable row level security;
alter table public.customers enable row level security;
alter table public.professionals enable row level security;
alter table public.team_members enable row level security;
alter table public.team_invitations enable row level security;
alter table public.services enable row level security;
alter table public.business_hours enable row level security;
alter table public.professional_hours enable row level security;
alter table public.professional_time_blocks enable row level security;
alter table public.professional_deactivation_reviews enable row level security;

revoke all on all tables in schema public from anon, authenticated;
grant select on public.barbershops, public.barbershop_registration_details,
  public.customers, public.professionals, public.services, public.business_hours,
  public.professional_hours, public.professional_time_blocks to authenticated;

create policy "team can read their barbershop" on public.barbershops for select to authenticated
using (public.has_active_role(id, array['owner', 'manager', 'barber']::public.app_role[]));
create policy "owners and managers can update their barbershop" on public.barbershops for update to authenticated
using (public.has_active_role(id, array['owner', 'manager']::public.app_role[]))
with check (public.has_active_role(id, array['owner', 'manager']::public.app_role[]));
create policy "owners manage registration details" on public.barbershop_registration_details for all to authenticated
using (public.has_active_role(barbershop_id, array['owner']::public.app_role[]))
with check (public.has_active_role(barbershop_id, array['owner']::public.app_role[]));
create policy "customers read own profile" on public.customers for select to authenticated using (user_id = auth.uid());
create policy "customers update own profile" on public.customers for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "management reads tenant professionals" on public.professionals for select to authenticated
using (public.has_active_role(barbershop_id, array['owner', 'manager']::public.app_role[]));
create policy "barber reads own professional profile" on public.professionals for select to authenticated
using (public.can_manage_professional(id));
create policy "team reads tenant services" on public.services for select to authenticated
using (public.has_active_role(barbershop_id, array['owner', 'manager', 'barber']::public.app_role[]));
create policy "team reads tenant business hours" on public.business_hours for select to authenticated
using (public.has_active_role(barbershop_id, array['owner', 'manager', 'barber']::public.app_role[]));
create policy "team reads tenant professional hours" on public.professional_hours for select to authenticated
using (public.has_active_role(barbershop_id, array['owner', 'manager', 'barber']::public.app_role[]));
create policy "team reads tenant blocks" on public.professional_time_blocks for select to authenticated
using (public.has_active_role(barbershop_id, array['owner', 'manager', 'barber']::public.app_role[]));

-- Mutations for professionals, services, team membership and hours are intentionally RPC-only.
-- No broad insert/update/delete policies are granted to the browser.

create or replace function public.get_public_barbershop_catalog(target_slug text)
returns table (
  id uuid,
  public_name text,
  slug text,
  description text,
  phone text,
  address_line text,
  address_complement text,
  neighborhood text,
  city text,
  state text,
  postal_code text,
  cover_image_path text,
  timezone text
)
language sql
stable
security definer
set search_path = ''
as $$
  select shop.id, shop.public_name, shop.slug, shop.description, shop.phone,
    shop.address_line, shop.address_complement, shop.neighborhood, shop.city,
    shop.state, shop.postal_code, shop.cover_image_path, shop.timezone
  from public.barbershops shop
  where shop.slug = lower(trim(target_slug))
    and shop.active
    and shop.is_public;
$$;

revoke all on function public.get_public_barbershop_catalog(text) from public;
grant execute on function public.get_public_barbershop_catalog(text) to anon, authenticated;

create or replace function public.get_public_services(target_barbershop_id uuid)
returns table (id uuid, name text, description text, duration_minutes integer, price_cents integer, sort_order integer)
language sql
stable
security definer
set search_path = ''
as $$
  select service.id, service.name, service.description, service.duration_minutes,
    service.price_cents, service.sort_order
  from public.services service
  join public.barbershops shop on shop.id = service.barbershop_id
  where service.barbershop_id = target_barbershop_id
    and service.active and shop.active and shop.is_public
  order by service.sort_order, service.name;
$$;

create or replace function public.get_public_professionals(target_barbershop_id uuid)
returns table (id uuid, name text, instagram_url text, photo_path text)
language sql
stable
security definer
set search_path = ''
as $$
  select professional.id, professional.name, professional.instagram_url, professional.photo_path
  from public.professionals professional
  join public.barbershops shop on shop.id = professional.barbershop_id
  where professional.barbershop_id = target_barbershop_id
    and professional.active and shop.active and shop.is_public
  order by professional.name;
$$;

revoke all on function public.get_public_services(uuid) from public;
revoke all on function public.get_public_professionals(uuid) from public;
grant execute on function public.get_public_services(uuid) to anon, authenticated;
grant execute on function public.get_public_professionals(uuid) to anon, authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('barbershop-images', 'barbershop-images', true, 3145728, array['image/jpeg', 'image/png', 'image/webp']),
  ('professional-images', 'professional-images', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "team uploads own barbershop images" on storage.objects for insert to authenticated
with check (
  bucket_id = 'barbershop-images'
  and (storage.foldername(name))[1] ~ '^[0-9a-f-]{36}$'
  and public.has_active_role(((storage.foldername(name))[1])::uuid, array['owner', 'manager']::public.app_role[])
);
create policy "team updates own barbershop images" on storage.objects for update to authenticated
using (bucket_id = 'barbershop-images' and public.has_active_role(((storage.foldername(name))[1])::uuid, array['owner', 'manager']::public.app_role[]))
with check (bucket_id = 'barbershop-images' and public.has_active_role(((storage.foldername(name))[1])::uuid, array['owner', 'manager']::public.app_role[]));
create policy "team removes own barbershop images" on storage.objects for delete to authenticated
using (bucket_id = 'barbershop-images' and public.has_active_role(((storage.foldername(name))[1])::uuid, array['owner', 'manager']::public.app_role[]));
create policy "authorized members upload professional images" on storage.objects for insert to authenticated
with check (
  bucket_id = 'professional-images'
  and (storage.foldername(name))[1] ~ '^[0-9a-f-]{36}$'
  and public.can_manage_professional(((storage.foldername(name))[1])::uuid)
);
create policy "authorized members update professional images" on storage.objects for update to authenticated
using (bucket_id = 'professional-images' and public.can_manage_professional(((storage.foldername(name))[1])::uuid))
with check (bucket_id = 'professional-images' and public.can_manage_professional(((storage.foldername(name))[1])::uuid));
create policy "authorized members remove professional images" on storage.objects for delete to authenticated
using (bucket_id = 'professional-images' and public.can_manage_professional(((storage.foldername(name))[1])::uuid));
