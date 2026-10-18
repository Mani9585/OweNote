-- OweNote cloud database schema for Supabase
-- Paste into Supabase Dashboard → SQL Editor → New query → Run.
-- These policies ensure users can only access their own loans and repayments.

create extension if not exists pgcrypto;

create table if not exists public.loans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 100),
  amount numeric(12,2) not null check (amount > 0),
  lent_date date not null default current_date,
  due_date date,
  phone text,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint due_after_lent check (due_date is null or due_date >= lent_date)
);

create table if not exists public.repayments (
  id uuid primary key default gen_random_uuid(),
  loan_id uuid not null references public.loans(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  paid_date date not null default current_date,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists loans_user_id_idx on public.loans(user_id);
create index if not exists loans_due_date_idx on public.loans(user_id, due_date);
create index if not exists repayments_loan_id_idx on public.repayments(loan_id);
create index if not exists repayments_user_id_idx on public.repayments(user_id);

alter table public.loans enable row level security;
alter table public.repayments enable row level security;

drop policy if exists "Users can read their own loans" on public.loans;
create policy "Users can read their own loans" on public.loans
for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own loans" on public.loans;
create policy "Users can create their own loans" on public.loans
for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own loans" on public.loans;
create policy "Users can update their own loans" on public.loans
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their own loans" on public.loans;
create policy "Users can delete their own loans" on public.loans
for delete to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "Users can read their own repayments" on public.repayments;
create policy "Users can read their own repayments" on public.repayments
for select to authenticated using (
  (select auth.uid()) = user_id and exists (
    select 1 from public.loans l where l.id = loan_id and l.user_id = (select auth.uid())
  )
);

drop policy if exists "Users can create their own repayments" on public.repayments;
create policy "Users can create their own repayments" on public.repayments
for insert to authenticated with check (
  (select auth.uid()) = user_id and exists (
    select 1 from public.loans l where l.id = loan_id and l.user_id = (select auth.uid())
  )
);

drop policy if exists "Users can update their own repayments" on public.repayments;
create policy "Users can update their own repayments" on public.repayments
for update to authenticated using (
  (select auth.uid()) = user_id and exists (
    select 1 from public.loans l where l.id = loan_id and l.user_id = (select auth.uid())
  )
) with check (
  (select auth.uid()) = user_id and exists (
    select 1 from public.loans l where l.id = loan_id and l.user_id = (select auth.uid())
  )
);

drop policy if exists "Users can delete their own repayments" on public.repayments;
create policy "Users can delete their own repayments" on public.repayments
for delete to authenticated using (
  (select auth.uid()) = user_id and exists (
    select 1 from public.loans l where l.id = loan_id and l.user_id = (select auth.uid())
  )
);

grant select, insert, update, delete on public.loans to authenticated;
grant select, insert, update, delete on public.repayments to authenticated;
