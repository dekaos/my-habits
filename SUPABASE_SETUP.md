# Supabase Setup Guide

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign in with GitHub
4. Click "New project"
5. Fill in:
   - Name: `habit-hero`
   - Database Password: (save this securely!)
   - Region: Choose closest to you
6. Click "Create new project"

## 2. Get Your API Keys

1. Go to Project Settings (gear icon)
2. Click "API" in the sidebar
3. Copy:
   - **Project URL** (looks like: `https://xxx.supabase.co`)
   - **anon public** key

## 3. Update Your Flutter App

Open `lib/main.dart` and replace:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

With your actual URL and key.

## 4. Create Database Tables

Go to SQL Editor in Supabase and run this script:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  photo_url TEXT,
  bio TEXT,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  friends TEXT[] DEFAULT '{}',
  friend_requests TEXT[] DEFAULT '{}',
  total_streaks INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habits table
CREATE TABLE habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT DEFAULT '#6366F1',
  frequency INTEGER DEFAULT 0,
  custom_days INTEGER[] DEFAULT '{}',
  target_count INTEGER DEFAULT 1,
  is_public BOOLEAN DEFAULT FALSE,
  accountability_partners TEXT[] DEFAULT '{}',
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_completed_date TIMESTAMP WITH TIME ZONE,
  total_completions INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habit completions table
CREATE TABLE habit_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  note TEXT,
  image_url TEXT,
  count INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activities table
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo_url TEXT,
  type INTEGER NOT NULL,
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  habit_title TEXT,
  message TEXT,
  streak_count INTEGER,
  reactions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_created_at ON habits(created_at DESC);
CREATE INDEX idx_habit_completions_habit_id ON habit_completions(habit_id);
CREATE INDEX idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX idx_habit_completions_completed_at ON habit_completions(completed_at DESC);
CREATE INDEX idx_activities_user_id ON activities(user_id);
CREATE INDEX idx_activities_created_at ON activities(created_at DESC);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can read all profiles"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- RLS Policies for habits
CREATE POLICY "Users can read own habits"
  ON habits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can read public habits"
  ON habits FOR SELECT
  USING (is_public = true);

CREATE POLICY "Users can create own habits"
  ON habits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits"
  ON habits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits"
  ON habits FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for habit_completions
CREATE POLICY "Users can read own completions"
  ON habit_completions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own completions"
  ON habit_completions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own completions"
  ON habit_completions FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own completions"
  ON habit_completions FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for activities
CREATE POLICY "Users can read all activities"
  ON activities FOR SELECT
  USING (true);

CREATE POLICY "Users can create own activities"
  ON activities FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update any activity (for reactions)"
  ON activities FOR UPDATE
  USING (true);

CREATE POLICY "Users can delete own activities"
  ON activities FOR DELETE
  USING (auth.uid()::text = user_id::text);

-- Function to automatically create user profile
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name)
  VALUES (new.id, new.email, COALESCE(new.raw_user_meta_data->>'display_name', 'User'));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## 5. Enable Email Authentication

1. Go to "Authentication" → "Providers"
2. Enable "Email"
3. Disable "Confirm email" for testing (optional)
4. Click "Save"

## 6. Test Your App

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 7. Optional: Configure Storage (for profile/habit images)

1. Go to "Storage"
2. Create a new bucket: `avatars`
3. Set it to public
4. Create policies for authenticated users

## Advantages of Supabase over Firebase

✅ **Open Source**: Self-hostable
✅ **PostgreSQL**: Full SQL database with relationships
✅ **Cheaper**: More generous free tier
✅ **Real-time**: Built-in subscriptions
✅ **Row Level Security**: Better security model
✅ **No vendor lock-in**: Can migrate easily

## Free Tier Limits

- 500MB database space
- 1GB file storage
- 2GB bandwidth
- 50,000 monthly active users
- Unlimited API requests

Perfect for launching and growing to 10,000+ users!

## Troubleshooting

### "relation does not exist"
Run the SQL script in the SQL Editor

### "JWT expired"
The anon key doesn't expire, check you're using the right one

### "permission denied for table"
Check RLS policies are created correctly

### "duplicate key value"
User profile already exists, this is okay

## Next Steps

1. Set up authentication in Supabase Dashboard
2. Run SQL script to create tables
3. Update main.dart with your keys
4. Test signup and login
5. Deploy to production!

