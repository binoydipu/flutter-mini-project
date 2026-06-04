-- This SQL script defines the database schema for a healthcare application. 
-- It includes tables for user profiles, medical specialities, symptoms, hospitals, doctors, and their relationships.

-- Create the profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  email TEXT,
  role TEXT CHECK (role IN ('Doctor', 'User', 'Admin')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- e.g. cardiology, neurology
create table specialities (
  id bigserial primary key,

  name text not null unique,
  icon text,

  created_at timestamptz default now()
);

-- e.g. chest pain, headaches
create table symptoms (
  id bigserial primary key,

  name text not null unique
);

-- e.g. chest pain → cardiology, headache → neurology
create table symptom_specialities (
  symptom_id bigint references symptoms(id) on delete cascade,
  speciality_id bigint references specialities(id) on delete cascade,

  priority int default 1,

  primary key (symptom_id, speciality_id)
);

create table hospitals (
  id bigserial primary key,

  name text not null,

  phone text,
  emergency_phone text,

  email text,
  website text,

  address text,

  city text not null,
  area text,

  latitude numeric(9,6),
  longitude numeric(9,6),

  description text,

  is_active boolean default true,

  created_by uuid references profiles(id),

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table doctors (
  id bigserial primary key,

  full_name text not null,

  gender text,

  profile_image text,

  qualification text,
  designation text,

  experience_years int,

  bio text,

  phone text,
  email text,

  consultation_fee numeric(10,2),

  is_active boolean default true,

  created_by uuid references profiles(id),

  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table doctor_specialities (
  doctor_id bigint references doctors(id) on delete cascade,
  speciality_id bigint references specialities(id) on delete cascade,

  primary key (doctor_id, speciality_id)
);

create table doctor_hospitals (
  id bigserial primary key,

  doctor_id bigint not null
      references doctors(id) on delete cascade,

  hospital_id bigint not null
      references hospitals(id) on delete cascade,

  chamber_name text,

  room_no text,

  appointment_phone text,

  is_active boolean default true,

  unique (doctor_id, hospital_id)
);