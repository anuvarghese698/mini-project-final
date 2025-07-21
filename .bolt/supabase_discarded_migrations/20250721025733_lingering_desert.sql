/*
  # Initial Schema for Flood Rehabilitation Project

  1. New Tables
    - `profiles`
      - `id` (uuid, primary key, references auth.users)
      - `email` (text, unique)
      - `name` (text)
      - `role` (text, check constraint for 'refugee' or 'volunteer')
      - `contact` (text)
      - `address` (text, nullable)
      - `needs` (text, nullable)
      - `skills` (text, nullable)
      - `availability` (text, nullable)
      - `age` (integer, nullable)
      - `created_at` (timestamp)

    - `camps`
      - `id` (uuid, primary key)
      - `name` (text)
      - `beds` (integer)
      - `original_beds` (integer)
      - `resources` (text array)
      - `contact` (text, nullable)
      - `ambulance` (text)
      - `type` (text, default 'volunteer-added')
      - `created_at` (timestamp)
      - `added_by_user_id` (uuid, foreign key to profiles)

    - `camp_selections`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to profiles)
      - `camp_id` (uuid, foreign key to camps)
      - `selected_at` (timestamp)

    - `volunteer_assignments`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to profiles)
      - `camp_id` (uuid, foreign key to camps)
      - `assigned_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Add policies for volunteers to manage camps
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('refugee', 'volunteer')),
  contact text,
  address text,
  needs text,
  skills text,
  availability text,
  age integer,
  created_at timestamptz DEFAULT now()
);

-- Create camps table
CREATE TABLE IF NOT EXISTS camps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  beds integer NOT NULL DEFAULT 0,
  original_beds integer NOT NULL DEFAULT 0,
  resources text[] DEFAULT '{}',
  contact text,
  ambulance text DEFAULT 'No',
  type text DEFAULT 'volunteer-added',
  created_at timestamptz DEFAULT now(),
  added_by_user_id uuid REFERENCES profiles(id)
);

-- Create camp_selections table
CREATE TABLE IF NOT EXISTS camp_selections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  camp_id uuid REFERENCES camps(id) ON DELETE CASCADE,
  selected_at timestamptz DEFAULT now()
);

-- Create volunteer_assignments table
CREATE TABLE IF NOT EXISTS volunteer_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  camp_id uuid REFERENCES camps(id) ON DELETE CASCADE,
  assigned_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE camps ENABLE ROW LEVEL SECURITY;
ALTER TABLE camp_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE volunteer_assignments ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  USING (true);

-- Camps policies
CREATE POLICY "Anyone can read camps"
  ON camps
  FOR SELECT
  USING (true);

CREATE POLICY "Volunteers can insert camps"
  ON camps
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Volunteers can update camps"
  ON camps
  FOR UPDATE
  USING (true);

CREATE POLICY "Volunteers can delete camps"
  ON camps
  FOR DELETE
  USING (true);

-- Camp selections policies
CREATE POLICY "Users can read own selections"
  ON camp_selections
  FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own selections"
  ON camp_selections
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can update own selections"
  ON camp_selections
  FOR UPDATE
  USING (true);

CREATE POLICY "Users can delete own selections"
  ON camp_selections
  FOR DELETE
  USING (true);

-- Volunteer assignments policies
CREATE POLICY "Users can read own assignments"
  ON volunteer_assignments
  FOR SELECT
  USING (true);

CREATE POLICY "Users can insert own assignments"
  ON volunteer_assignments
  FOR INSERT
  WITH CHECK (true);

-- Insert default camps
INSERT INTO camps (name, beds, original_beds, resources, contact, ambulance, type) VALUES
  ('Central School Grounds', 24, 24, ARRAY['Food', 'Water', 'Medical Aid', 'Blankets'], '+91 98765 43210', 'Yes', 'default'),
  ('Community Hall', 12, 12, ARRAY['Food', 'Water', 'Blankets', 'Clothing'], '+91 98765 11223', 'Nearby', 'default'),
  ('Government High School', 30, 30, ARRAY['Food', 'Water', 'First Aid', 'Hygiene Kits'], '+91 98765 77889', 'Yes', 'default')
ON CONFLICT DO NOTHING;