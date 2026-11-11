create table public.student_profiles (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  full_name text not null default '',
  country text not null default '',
  institution text not null default '',
  course_of_study text not null default '',
  academic_level text not null default '',
  cgpa numeric(5,2),
  cgpa_scale numeric(5,2),
  qualifications text not null default '',
  age smallint,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint student_profiles_valid_scale check (cgpa_scale is null or (cgpa_scale > 0 and cgpa_scale <= 10)),
  constraint student_profiles_valid_cgpa check (cgpa is null or (cgpa_scale is not null and cgpa >= 0 and cgpa <= cgpa_scale)),
  constraint student_profiles_valid_age check (age is null or age between 10 and 120)
);
create trigger trg_student_profiles_updated_at
before update on public.student_profiles
for each row execute function app_private.set_updated_at();

alter table public.student_profiles enable row level security;
revoke all on table public.student_profiles from anon, authenticated;
grant select, insert, update, delete on table public.student_profiles to authenticated;
grant all on table public.student_profiles to service_role;

create policy "student_profiles_select_self" on public.student_profiles
for select to authenticated using ((select auth.uid()) = user_id);
create policy "student_profiles_insert_self" on public.student_profiles
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "student_profiles_update_self" on public.student_profiles
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "student_profiles_delete_self" on public.student_profiles
for delete to authenticated using ((select auth.uid()) = user_id);
