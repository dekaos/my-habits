# My Habits

A beautiful habit tracking app with social accountability features built with Flutter and Supabase. Stay motivated by building better habits with your friends!

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.0+ with Material 3 Design
- **State Management**: Riverpod
- **Backend**: Supabase (PostgreSQL + Realtime + Auth + Storage)
- **Charts**: FL Chart with isolate-based calculations
- **Notifications**: Firebase Cloud Messaging
- **Local Storage**: SharedPreferences

## ✨ Features

### Core Features
- **Habit Management**: Create, edit, and delete custom habits
- **Flexible Scheduling**: Daily, weekly, or custom frequency options
- **Streak Tracking**: Track current and longest streaks for each habit
- **Daily Check-ins**: Mark habits complete with optional notes and photos
- **Advanced Analytics**: Comprehensive performance dashboard with:
  - 90-day activity heatmap showing completion patterns
  - 30-day trend chart with interactive data points
  - Weekly pattern analysis to identify your most productive days
  - Streak insights (average, best, and active streaks)
  - Top performing habits leaderboard
  - Background isolate calculations for smooth performance

### Social Features
- **Friends System**: Connect with friends to stay motivated together
- **Activity Feed**: See your friends' achievements and progress in realtime
- **Reactions**: Cheer on your friends with emoji reactions
- **Accountability Partners**: Share specific habits with accountability partners
- **Public/Private Habits**: Choose which habits to share
- **Realtime Updates**: Powered by Supabase realtime subscriptions for instant updates

### UI/UX
- **Material 3 Design**: Modern, beautiful interface
- **Dark Mode Support**: Automatic theme switching
- **Smooth Animations**: Delightful user experience
- **Responsive Design**: Works great on all screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Supabase account (for backend services)
- iOS/Android development environment setup

### Installation

1. **Clone the repository**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   
   a. Create a new Supabase project at [Supabase Console](https://app.supabase.com/)
   
   b. Copy your project URL and anon key from Project Settings > API
   
   c. Create a `.env` file in the project root:
   ```bash
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```
   
   d. Run the database setup script in the Supabase SQL Editor:
   ```sql
   -- See SUPABASE_QUICK_SETUP.sql for the complete schema
   ```
   
   e. Enable the following in your Supabase project:
   - Authentication (Email/Password, Social OAuth)
   - Row Level Security (RLS) policies
   - Storage bucket for profile images
   - Realtime subscriptions for social features

4. **Create asset directories**
   ```bash
   mkdir -p assets/images assets/animations
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── habit.dart
│   ├── habit_completion.dart
│   ├── user_profile.dart
│   └── activity.dart
├── providers/                # State management (Riverpod)
│   ├── auth_provider.dart
│   ├── habit_provider.dart
│   └── social_provider.dart
├── services/                 # Backend services
│   ├── supabase_service.dart
│   ├── notification_service.dart
│   ├── haptic_service.dart
│   └── image_service.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── habits_tab.dart
│   │   ├── performance_tab.dart  # Advanced analytics & charts
│   │   ├── social_tab.dart
│   │   └── profile_tab.dart
│   ├── habits/
│   │   ├── add_habit_screen.dart
│   │   └── habit_detail_screen.dart
│   └── social/
│       ├── friends_screen.dart
│       └── search_users_screen.dart
├── widgets/                  # Reusable widgets
│   ├── habit_card.dart
│   ├── slidable_habit_card.dart
│   ├── celebration_animation.dart
│   └── activity_card.dart
└── utils/                    # Utilities & helpers
    └── chart_calculator.dart # Isolate-based chart calculations
```

## 🗄️ Supabase Database Schema

### Tables

**users**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  display_name TEXT,
  photo_url TEXT,
  bio TEXT,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  total_streaks INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**habits**
```sql
CREATE TABLE habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT NOT NULL,
  frequency INTEGER NOT NULL DEFAULT 0, -- 0=daily, 1=weekly, 2=custom
  custom_days INTEGER[],
  target_count INTEGER DEFAULT 1,
  is_public BOOLEAN DEFAULT FALSE,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_completed_date TIMESTAMPTZ,
  total_completions INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**habit_completions**
```sql
CREATE TABLE habit_completions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  note TEXT,
  image_url TEXT,
  count INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**friend_requests**
```sql
CREATE TABLE friend_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, accepted, rejected
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(from_user_id, to_user_id)
);
```

**activities**
```sql
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo_url TEXT,
  type INTEGER NOT NULL, -- 0=completed, 1=milestone, 2=new, 3=encouragement
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  habit_title TEXT,
  message TEXT,
  streak_count INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**reactions**
```sql
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(activity_id, user_id)
);
```

**notifications**
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- friend_request, habit_reaction, etc.
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Row Level Security (RLS) Policies

All tables have RLS enabled with policies that:
- Users can only read/write their own data
- Public habits are visible to friends
- Activities are visible to friends
- Friend requests follow bidirectional visibility rules

See `SUPABASE_QUICK_SETUP.sql` for complete RLS policies.

## 🎯 Roadmap

### Phase 1: MVP (Current)
- [x] Core habit tracking
- [x] Social features
- [x] Authentication
- [x] Beautiful UI with animations
- [x] Advanced analytics dashboard
- [x] Performance optimization with isolates

### Phase 2: Enhancement
- [x] Push notifications
- [x] Habit reminders
- [ ] Calendar view
- [ ] Habit templates
- [x] Profile customization
- [ ] Export analytics data

### Phase 3: Growth
- [ ] Challenges and competitions
- [ ] Leaderboards
- [ ] Community forums
- [ ] Habit coaching tips
- [ ] Integration with health apps (Apple Health, Google Fit)
- [ ] Wearable device support

### Phase 4: Scale
- [ ] AI-powered habit recommendations
- [ ] Personalized insights
- [ ] Voice commands
- [ ] Web app version
- [ ] API for third-party integrations

## 🧪 Testing

### Unit & Widget Tests
Run tests:
```bash
flutter test
```

### Release Build Testing

**⚠️ IMPORTANT:** Always test release builds before deploying! Release builds behave differently than debug builds due to code optimization and obfuscation.

#### Quick Testing (Recommended)
Use our helper scripts for easy testing:

```bash
# Full release test with clean build
./scripts/test_release.sh

# Quick release test (faster, no clean)
./scripts/quick_release_test.sh

# Monitor logs for issues
./scripts/monitor_logs.sh

# Check for ProGuard issues
./scripts/check_proguard_issues.sh
```

#### Manual Testing
```bash
# Test in release mode
flutter run --release

# Build and analyze size
flutter build apk --release --analyze-size
```

#### Why Release Testing Matters
Debug and release builds are very different:
- **ProGuard/R8**: Obfuscates code in release builds
- **Tree Shaking**: Removes unused code
- **Optimization**: Different performance characteristics
- **Native Code**: May break due to reflection

Common issues that only appear in release:
- Notifications not working ✓ (Fixed with ProGuard rules)
- JSON serialization failures
- Database queries failing
- Plugin method calls missing
- Reflection-based code breaking

📚 **See [DEBUG_VS_RELEASE.md](DEBUG_VS_RELEASE.md)** for detailed explanation of differences.

📋 **See [RELEASE_TESTING_CHECKLIST.md](RELEASE_TESTING_CHECKLIST.md)** for comprehensive testing guide.

### Automated Testing (CI/CD)

This project includes GitHub Actions workflow for automated release build testing:
- Builds release APK and App Bundle on every PR
- Uploads artifacts for manual testing
- Runs Android lint checks

See `.github/workflows/release-build-test.yml` for configuration.

## 📱 Building for Production

### Android
```bash
# APK (for direct distribution)
flutter build apk --release

# App Bundle (for Play Store - recommended)
flutter build appbundle --release

# Split APKs by architecture (smaller downloads)
flutter build apk --release --split-per-abi
```

### iOS
```bash
flutter build ios --release
```

### ProGuard Configuration

This app uses ProGuard/R8 for code shrinking and obfuscation in release builds. The rules are configured in `android/app/proguard-rules.pro`.

If you add new dependencies that use reflection or native code, you may need to add additional ProGuard rules. Check the package documentation for required rules.

## 🤝 Contributing

Contributions are welcome! This is a personal project template, but feel free to fork and customize.

## 📄 License

This project is open source and available under the MIT License.

## 🎨 Design Credits

- Material Design 3 by Google
- Icons from Material Icons
- Inspiration from apps like Habitica, Streaks, and Done

## 📞 Support

For questions or support, please open an issue in the repository.

---

**Built with ❤️ using Flutter**

## Tips for Success

1. **Start Small**: Begin with just 1-2 habits
2. **Be Consistent**: Daily check-ins are key
3. **Stay Accountable**: Connect with friends who share similar goals
4. **Celebrate Wins**: React to your friends' achievements
5. **Iterate**: Adjust habits as you learn what works for you

## Marketing Ideas

1. **Social Media**: Share success stories and milestones
2. **Content Marketing**: Blog about habit formation science
3. **Partnerships**: Collaborate with fitness/wellness influencers
4. **App Store Optimization**: Use compelling screenshots and descriptions
5. **Referral Program**: Reward users for inviting friends
6. **Community Building**: Create Facebook group or Discord server
7. **Press Coverage**: Reach out to tech and wellness publications

Good luck building better habits! 🚀

