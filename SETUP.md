# Detailed Setup Guide

## Step-by-Step Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "habit-hero" (or your choice)
4. Enable Google Analytics (optional)
5. Create project

### 2. Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. Save

### 3. Set Up Firestore Database

1. Go to "Firestore Database"
2. Click "Create database"
3. Start in **production mode** (you can change rules later)
4. Choose a location (closest to your target users)

### 4. Set Up Firestore Security Rules

Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read their own profile and public profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can CRUD their own habits
    match /habits/{habitId} {
      allow read: if request.auth != null && 
                     (resource.data.userId == request.auth.uid || 
                      resource.data.isPublic == true);
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Habit completions
    match /habit_completions/{completionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                               resource.data.userId == request.auth.uid;
    }
    
    // Activities (feed)
    match /activities/{activityId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null; // For reactions
      allow delete: if request.auth != null && 
                       resource.data.userId == request.auth.uid;
    }
  }
}
```

### 5. Set Up Firebase Storage (Optional, for profile pictures)

1. Go to "Storage"
2. Click "Get started"
3. Use default rules for now

### 6. Configure Flutter App

Run this command in your project directory:

```bash
flutterfire configure
```

This will:
- Create Firebase configuration files
- Add necessary configuration to your iOS and Android projects
- Generate `firebase_options.dart`

### 7. Update main.dart

Uncomment the Firebase initialization lines in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uncomment this line:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

And add the import at the top:
```dart
import 'firebase_options.dart';
```

## Platform-Specific Setup

### iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Update minimum deployment target to iOS 12.0 or higher
3. Add these keys to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload habit completion photos</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take habit completion photos</string>
```

### Android Setup

1. Update `android/app/build.gradle`:
   - Ensure `minSdkVersion` is at least 21
   - Ensure `compileSdkVersion` is at least 33

2. Add internet permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Testing

### Test Accounts

For testing, create a few test accounts:
- test1@example.com / password123
- test2@example.com / password123

### Firebase Emulators (Optional, for development)

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Initialize emulators:
```bash
firebase init emulators
```

3. Run emulators:
```bash
firebase emulators:start
```

4. Update your app to use emulators (in `main.dart`):
```dart
// For development only
await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

## Troubleshooting

### Issue: "Firebase not initialized"
- Make sure you've run `flutterfire configure`
- Check that `firebase_options.dart` exists
- Verify Firebase.initializeApp() is called before runApp()

### Issue: "Missing GoogleService-Info.plist / google-services.json"
- Run `flutterfire configure` again
- Manually download from Firebase Console if needed

### Issue: "Platform specific build errors"
- Clean build: `flutter clean && flutter pub get`
- For iOS: Delete `ios/Podfile.lock` and run `cd ios && pod install`
- For Android: Sync Gradle files in Android Studio

### Issue: "Firestore permission denied"
- Check Firestore security rules
- Ensure user is authenticated
- Verify user IDs match in rules

## Next Steps

1. **Customize the app**:
   - Change app name in `pubspec.yaml`
   - Update app icon using `flutter_launcher_icons`
   - Customize colors in `main.dart`

2. **Add features**:
   - Push notifications
   - Habit reminders
   - Advanced analytics

3. **Deploy**:
   - Set up CI/CD pipeline
   - Configure app signing
   - Submit to App Store / Play Store

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Material Design 3](https://m3.material.io/)

