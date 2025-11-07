# 🗄️ Supabase Setup Guide

## Overview

Complete guide to set up Supabase tables and policies for the Habit Hero app.

## 📋 Prerequisites

1. Create a Supabase project at [https://supabase.com](https://supabase.com)
2. Get your project URL and anon key
3. Add them to your Flutter app configuration

## 🔧 Database Setup

### 1. Users Table

Run this SQL in your Supabase SQL Editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable trigram extension for better fuzzy search (MUST be first!)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  display_name TEXT NOT NULL,
  email TEXT,
  photo_url TEXT,
  bio TEXT,
  friends TEXT[] DEFAULT '{}',
  friend_requests TEXT[] DEFAULT '{}',
  total_streaks INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster searches
CREATE INDEX IF NOT EXISTS users_display_name_idx ON public.users(LOWER(display_name));
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users(LOWER(email));
CREATE INDEX IF NOT EXISTS users_display_name_trgm_idx ON public.users USING gin(display_name gin_trgm_ops);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can send friend requests" ON public.users;

-- RLS Policies for users table
-- Policy 1: Anyone authenticated can view user profiles (for search)
CREATE POLICY "Users can view all profiles"
  ON public.users
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: Users can insert their own profile
CREATE POLICY "Users can insert their own profile"
  ON public.users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Policy 3: Users can update their own profile
CREATE POLICY "Users can update their own profile"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy 4: Users can send friend requests (update others' friend_requests field)
-- ⚠️ CRITICAL: This policy allows users to update OTHER users' friend_requests array
CREATE POLICY "Users can send friend requests"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
```

### 2. Habits Table

```sql
-- Create habits table
CREATE TABLE IF NOT EXISTS public.habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT,
  frequency TEXT DEFAULT 'daily',
  target_count INTEGER DEFAULT 1,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_completions INTEGER DEFAULT 0,
  last_completed_date TIMESTAMP WITH TIME ZONE,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for user habits
CREATE INDEX IF NOT EXISTS habits_user_id_idx ON public.habits(user_id);
CREATE INDEX IF NOT EXISTS habits_created_at_idx ON public.habits(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view their own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can view public habits" ON public.habits;
DROP POLICY IF EXISTS "Users can insert their own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can update their own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can delete their own habits" ON public.habits;

-- RLS Policies for habits table
-- Policy 1: Users can view their own habits
CREATE POLICY "Users can view their own habits"
  ON public.habits
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy 2: Users can view public habits from friends
CREATE POLICY "Users can view public habits"
  ON public.habits
  FOR SELECT
  TO authenticated
  USING (
    is_public = true AND
    user_id IN (
      SELECT unnest(friends)::uuid
      FROM public.users
      WHERE id = auth.uid()
    )
  );

-- Policy 3: Users can insert their own habits
CREATE POLICY "Users can insert their own habits"
  ON public.habits
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy 4: Users can update their own habits
CREATE POLICY "Users can update their own habits"
  ON public.habits
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy 5: Users can delete their own habits
CREATE POLICY "Users can delete their own habits"
  ON public.habits
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
```

### 3. Habit Completions Table

```sql
-- Create habit_completions table
CREATE TABLE IF NOT EXISTS public.habit_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  note TEXT,
  count INTEGER DEFAULT 1
);

-- Create indexes
CREATE INDEX IF NOT EXISTS completions_habit_id_idx ON public.habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS completions_user_id_idx ON public.habit_completions(user_id);
CREATE INDEX IF NOT EXISTS completions_completed_at_idx ON public.habit_completions(completed_at DESC);

-- Enable Row Level Security
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view their own completions" ON public.habit_completions;
DROP POLICY IF EXISTS "Users can insert their own completions" ON public.habit_completions;
DROP POLICY IF EXISTS "Users can delete their own completions" ON public.habit_completions;

-- RLS Policies
CREATE POLICY "Users can view their own completions"
  ON public.habit_completions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own completions"
  ON public.habit_completions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own completions"
  ON public.habit_completions
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
```

### 4. Activities Table (Social Feed)

```sql
-- Create activities table
CREATE TABLE IF NOT EXISTS public.activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo_url TEXT,
  type INTEGER NOT NULL,
  habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE,
  habit_title TEXT,
  message TEXT,
  streak_count INTEGER,
  reactions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS activities_user_id_idx ON public.activities(user_id);
CREATE INDEX IF NOT EXISTS activities_created_at_idx ON public.activities(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view activities from friends" ON public.activities;
DROP POLICY IF EXISTS "Users can insert their own activities" ON public.activities;
DROP POLICY IF EXISTS "Users can update their own activities" ON public.activities;
DROP POLICY IF EXISTS "Users can delete their own activities" ON public.activities;

-- RLS Policies
CREATE POLICY "Users can view activities from friends"
  ON public.activities
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    user_id IN (
      SELECT unnest(friends)::uuid
      FROM public.users
      WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own activities"
  ON public.activities
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own activities"
  ON public.activities
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own activities"
  ON public.activities
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
```

### 5. Messages Table

```sql
-- Create messages table
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS messages_sender_id_idx ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS messages_receiver_id_idx ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS messages_created_at_idx ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS messages_conversation_idx ON public.messages(sender_id, receiver_id, created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view their own messages" ON public.messages;
DROP POLICY IF EXISTS "Users can insert messages to friends" ON public.messages;
DROP POLICY IF EXISTS "Users can update their received messages" ON public.messages;
DROP POLICY IF EXISTS "Users can delete their own messages" ON public.messages;

-- RLS Policies for messages table
-- Policy 1: Users can view messages they sent or received
CREATE POLICY "Users can view their own messages"
  ON public.messages
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = sender_id OR 
    auth.uid() = receiver_id
  );

-- Policy 2: Users can only send messages to friends
CREATE POLICY "Users can insert messages to friends"
  ON public.messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = sender_id AND
    receiver_id IN (
      SELECT unnest(friends)::uuid
      FROM public.users
      WHERE id = auth.uid()
    )
  );

-- Policy 3: Users can update (mark as read) only messages they received
CREATE POLICY "Users can update their received messages"
  ON public.messages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = receiver_id)
  WITH CHECK (auth.uid() = receiver_id);

-- Policy 4: Users can delete their own sent messages
CREATE POLICY "Users can delete their own messages"
  ON public.messages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = sender_id);
```

## 🔐 Authentication Setup

### Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider
3. Configure email templates (optional)

### Create Auth Trigger for User Profile

```sql
-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, display_name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

## 🧪 Testing the Setup

Run these queries to verify everything works:

```sql
-- Test 1: Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'habits', 'habit_completions', 'activities', 'messages');

-- Test 2: Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('users', 'habits', 'habit_completions', 'activities', 'messages');

-- Test 3: Check policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Test 4: Verify indexes
SELECT tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'public'
AND tablename IN ('users', 'habits', 'habit_completions', 'activities', 'messages');
```

## 🐛 Troubleshooting

### Activities Not Showing in Feed

**Problem:** User completes a habit with "Share with friends" enabled, but friends can't see the activity

**Possible Causes:**

1. **Users are not friends yet**
   - Both users must have accepted the friend request
   - Check in Supabase SQL Editor:
   ```sql
   -- Check if User A and User B are friends
   SELECT 
     id, 
     display_name, 
     friends 
   FROM public.users 
   WHERE id IN ('USER_A_ID', 'USER_B_ID');
   ```

2. **Activity was not posted** (habit `isPublic` was false)
   - Check console logs for `📢 Posting activity` messages
   - Verify in Supabase:
   ```sql
   -- See all activities
   SELECT 
     user_id,
     type,
     habit_title,
     created_at 
   FROM public.activities 
   ORDER BY created_at DESC 
   LIMIT 20;
   ```

3. **RLS policy issue**
   - Verify RLS policies exist (see section above)
   - Test query as user:
   ```sql
   -- Replace USER_ID with actual user ID
   SELECT * FROM public.activities 
   WHERE user_id IN (
     SELECT unnest(friends)::uuid 
     FROM public.users 
     WHERE id = 'USER_ID'
   );
   ```

**Quick Fix:**
- Restart the app to ensure activity feed is loaded
- Check console logs for `🎯 Loading activity feed` and `🎯 Activities query returned` messages
- Verify the habit has "Share with friends" toggle enabled when creating it

### Friend Requests Not Showing Up

**Problem:** User A sends a friend request, but User B can't see it

**Root Cause:** Missing RLS policy to allow updating other users' `friend_requests` field

**Solution:** Run this SQL in Supabase SQL Editor:

```sql
-- Allow users to update others' friend_requests (for sending requests)
CREATE POLICY "Users can send friend requests"
  ON public.users
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);
```

**⚠️ Security Note:** This policy is permissive for development. For production, consider:
- Using a Postgres function with `SECURITY DEFINER`
- Implementing additional validation logic
- Audit logging for sensitive updates

**Verify it works:**
1. Send a friend request from User A to User B
2. Check the logs for `📤 Sending friend request` and `✅ Friend request sent successfully`
3. User B should see the notification badge on the 🔔 icon
4. User B can tap 🔔 to see and accept the request

**SQL Queries to Check Friend Requests:**

```sql
-- 1. See ALL users with their friend requests and friends
SELECT 
  id,
  display_name,
  email,
  friend_requests,
  friends,
  array_length(friend_requests, 1) as pending_requests_count,
  array_length(friends, 1) as friends_count
FROM public.users
ORDER BY created_at DESC;

-- 2. See friend requests for a SPECIFIC user (replace with actual email)
SELECT 
  display_name,
  email,
  friend_requests,
  friends
FROM public.users
WHERE email = 'user@example.com';

-- 3. See WHO sent friend requests (with names)
-- Replace 'TARGET_USER_ID' with the actual user ID
SELECT 
  u.id,
  u.display_name,
  u.email,
  'Sent request to' as status
FROM public.users u
WHERE u.id = ANY(
  SELECT unnest(friend_requests) 
  FROM public.users 
  WHERE id = 'TARGET_USER_ID'
);

-- 4. See complete friend request status between TWO users
-- Replace USER_A_ID and USER_B_ID
WITH user_a AS (
  SELECT id, display_name, friends, friend_requests 
  FROM public.users 
  WHERE id = 'USER_A_ID'
),
user_b AS (
  SELECT id, display_name, friends, friend_requests 
  FROM public.users 
  WHERE id = 'USER_B_ID'
)
SELECT 
  'User A -> User B' as direction,
  CASE 
    WHEN (SELECT id FROM user_b) = ANY(SELECT unnest(friends) FROM user_a) 
      THEN '✅ Friends'
    WHEN (SELECT id FROM user_a) = ANY(SELECT unnest(friend_requests) FROM user_b)
      THEN '📤 Request Pending'
    ELSE '❌ No Connection'
  END as status
UNION ALL
SELECT 
  'User B -> User A' as direction,
  CASE 
    WHEN (SELECT id FROM user_a) = ANY(SELECT unnest(friends) FROM user_b) 
      THEN '✅ Friends'
    WHEN (SELECT id FROM user_b) = ANY(SELECT unnest(friend_requests) FROM user_a)
      THEN '📤 Request Pending'
    ELSE '❌ No Connection'
  END as status;

-- 5. Quick check: See users with PENDING requests (non-empty friend_requests)
SELECT 
  display_name,
  email,
  friend_requests,
  array_length(friend_requests, 1) as pending_count
FROM public.users
WHERE array_length(friend_requests, 1) > 0;
```

### 404 Error on Search Users

**Problem:** Getting 404 when searching for users

**Solutions:**
1. **Check RLS Policy**: Run the "Users can view all profiles" policy above
2. **Verify Authentication**: Ensure user is logged in
3. **Check Table Name**: Table should be `public.users` not `users`
4. **Test Query Directly**:
```sql
-- Test display_name search
SELECT id, display_name, email, photo_url, bio, total_streaks 
FROM public.users 
WHERE display_name ILIKE '%test%' 
LIMIT 20;

-- Test email search
SELECT id, display_name, email, photo_url, bio, total_streaks 
FROM public.users 
WHERE email ILIKE '%test@example%' 
LIMIT 20;

-- Test combined search (what the app uses)
SELECT id, display_name, email, photo_url, bio, total_streaks 
FROM public.users 
WHERE display_name ILIKE '%test%' OR email ILIKE '%test%'
LIMIT 20;
```

### Permission Denied Errors

**Problem:** Can't insert/update records

**Solutions:**
1. Verify RLS policies are created
2. Check that `auth.uid()` matches the `user_id` field
3. Ensure user is authenticated

### No Results When Searching

**Problem:** Search returns empty array

**Solutions:**
1. Add test users to the database manually
2. Check if display_name field has data
3. Verify the ILIKE query is working:
```sql
SELECT * FROM public.users WHERE display_name ILIKE '%john%';
```

## 📊 Sample Data for Testing

Insert some test users:

```sql
-- Create test users (requires valid auth.users records first)
INSERT INTO public.users (id, display_name, bio, total_streaks)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'John Doe', 'Fitness enthusiast', 45),
  ('00000000-0000-0000-0000-000000000002', 'Jane Smith', 'Health coach', 89),
  ('00000000-0000-0000-0000-000000000003', 'Mike Johnson', 'Running lover', 23)
ON CONFLICT (id) DO NOTHING;
```

## 🔄 Migrations

If you need to update the schema later, create migration files in Supabase Dashboard → SQL Editor.

## ✅ Verification Checklist

- [ ] All tables created
- [ ] RLS enabled on all tables
- [ ] All policies created and active
- [ ] Indexes created for performance
- [ ] Auth trigger set up for new users
- [ ] Test users created
- [ ] Search query works
- [ ] Friend requests work
- [ ] Activities can be posted

## 🚀 Next Steps

1. Run all SQL scripts above in order
2. Test authentication (sign up/login)
3. Verify user profile is created automatically
4. Test friend search functionality
5. Create a few test habits
6. Test social features

## 💡 Tips

- Use **Supabase Studio** to view data
- Check **Database** → **Tables** for table structure
- Use **Authentication** → **Users** to see registered users
- Monitor **Logs** for debugging
- Test RLS policies in SQL Editor with `SET LOCAL role TO authenticated;`

Your Supabase backend is now ready for the Habit Hero app! 🎉
