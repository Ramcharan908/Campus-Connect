create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text,
  role text not null default 'student' check (role in ('student','organiser','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.event (
  id uuid primary key default gen_random_uuid(),
  organiser_id uuid references public.users(id) on delete set null,
  title text not null,
  category text not null default 'Other',
  description text,
  date date not null,
  time text not null,
  venue text not null,
  price numeric(10,2) not null default 0,
  capacity integer not null default 100,
  registered integer not null default 0,
  image text,
  created_at timestamptz not null default now()
);

create table if not exists public.registrations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id uuid not null references public.event(id) on delete cascade,
  payment_status text not null default 'pending',
  payment_method text,
  amount numeric(10,2) not null default 0,
  created_at timestamptz not null default now(),
  unique(user_id, event_id)
);

alter table public.users enable row level security;
alter table public.event enable row level security;
alter table public.registrations enable row level security;

create policy "public can read events" on public.event for select using (true);
create policy "users can read own profile" on public.users for select using (auth.uid() = id);
create policy "users can insert own profile" on public.users for insert with check (auth.uid() = id);
create policy "users can read own registrations" on public.registrations for select using (auth.uid() = user_id);
create policy "users can create own registrations" on public.registrations for insert with check (auth.uid() = user_id);

insert into public.event (title, category, description, date, time, venue, price, capacity, registered, image)
values
('Web Development Workshop','Tech','Learn the basics of web development and build your own website in this hands-on workshop.','2026-11-15','10:00 AM - 1:00 PM','Main Auditorium',499,120,64,'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=1200&q=80'),
('Singing Competition','Cultural','Bring your voice to the stage and compete with talented students from across campus.','2026-11-18','5:00 PM - 8:00 PM','Open Air Stage',199,80,52,'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1200&q=80'),
('Football Tournament','Sports','A high-energy campus football tournament with team-based competition and prizes.','2026-11-22','9:00 AM - 5:00 PM','Sports Ground',299,160,98,'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=1200&q=80'),
('Art & Craft Workshop','Workshops','Explore creative techniques and make something you can take home.','2026-11-25','10:00 AM - 2:00 PM','Art Block',249,60,41,'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&w=1200&q=80');
