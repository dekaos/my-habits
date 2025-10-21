# Quick Start Guide

Get Habit Hero up and running in 10 minutes!

## Prerequisites Checklist

- [ ] Flutter SDK installed (3.0.0+)
- [ ] Firebase account created
- [ ] iOS/Android development environment set up
- [ ] Code editor (VS Code or Android Studio)

## 5-Minute Setup

### 1. Install Dependencies (1 min)

```bash
cd flutter_app
flutter pub get
```

### 2. Configure Firebase (3 min)

```bash
# Install Firebase CLI if you haven't
npm install -g firebase-tools

# Login
firebase login

# Install FlutterFire
dart pub global activate flutterfire_cli

# Configure Firebase for your app
flutterfire configure
```

Follow the prompts:
- Select your Firebase project (or create a new one)
- Select platforms (iOS, Android, or both)
- Wait for configuration to complete

### 3. Enable Firebase Services (2 min)

Go to [Firebase Console](https://console.firebase.google.com/):

1. **Authentication**:
   - Click "Get started"
   - Enable "Email/Password"

2. **Firestore Database**:
   - Click "Create database"
   - Start in test mode (we'll add rules later)
   - Choose a location

3. **Done!** Firebase is configured.

### 4. Update main.dart (1 min)

Open `lib/main.dart` and uncomment these lines:

```dart
// Around line 12-13, uncomment:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

And add the import at the top:
```dart
import 'firebase_options.dart';
```

### 5. Run the App! (1 min)

```bash
flutter run
```

Select your device/emulator and watch the app launch!

## First Steps in the App

1. **Create an account**: Sign up with any email
2. **Add your first habit**: Tap the "+" button
3. **Complete a habit**: Check it off to start your streak!
4. **Add friends**: Search for other users (create a second test account)
5. **See the activity feed**: Watch your social feed come alive

## Test Credentials (Optional)

Create these accounts for testing social features:
- test1@example.com / password123
- test2@example.com / password123

## Troubleshooting

### "Firebase not configured"
Run: `flutterfire configure`

### "Missing GoogleService files"
The files should be at:
- iOS: `ios/Runner/GoogleService-Info.plist`
- Android: `android/app/google-services.json`

If missing, download manually from Firebase Console.

### Build errors
```bash
flutter clean
flutter pub get
# For iOS:
cd ios && pod install && cd ..
```

### Firestore permission denied
Update Firestore rules in Firebase Console (see SETUP.md)

## Next Steps

Now that your app is running:

1. **Customize it**:
   - Change app name in `pubspec.yaml`
   - Update colors in `lib/main.dart` (line 28)
   - Add your app icon

2. **Add features** from the roadmap:
   - Push notifications
   - Habit templates
   - Advanced analytics

3. **Deploy**:
   - Follow SETUP.md for production deployment
   - Set up proper Firestore security rules
   - Configure app signing

## What You've Built

✅ Complete habit tracking system
✅ User authentication
✅ Social features with friends
✅ Activity feed with reactions
✅ Streak tracking and statistics
✅ Beautiful Material 3 UI
✅ Real-time Firebase backend

## Resources

- 📖 [Full README](README.md)
- 🔧 [Detailed Setup Guide](SETUP.md)
- 💰 [Monetization Strategy](MONETIZATION.md)
- 🐛 [Report Issues](https://github.com/yourusername/habit-hero/issues)

## Need Help?

- Check the full documentation in README.md and SETUP.md
- Look at Firebase documentation
- Search Flutter documentation
- Ask in Flutter community forums

---

**Congratulations! You now have a fully functional habit tracking app!** 🎉

Start building better habits and making money! 💰

