import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Habit Hero'**
  String get appTitle;

  /// App name displayed on splash screen
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get myHabitsTitle;

  /// Splash screen tagline
  ///
  /// In en, this message translates to:
  /// **'Build Better Habits Together'**
  String get buildBetterHabits;

  /// Login screen greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your habit journey'**
  String get signInToContinue;

  /// Email input label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password input label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Prompt to create new account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign up screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Sign up screen header
  ///
  /// In en, this message translates to:
  /// **'Join My Habits'**
  String get joinMyHabits;

  /// Sign up screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Start building better habits with friends'**
  String get startBuildingHabits;

  /// Full name input label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Confirm password input label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Prompt to login instead
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Password confirmation validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Habit title validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a habit title'**
  String get pleaseEnterHabitTitle;

  /// Custom habit days validation error
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day for custom habits'**
  String get pleaseSelectAtLeastOneDay;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// Signup error message
  ///
  /// In en, this message translates to:
  /// **'Signup failed. Please try again.'**
  String get signupFailed;

  /// Habits tab title
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// Social tab title
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// Performance tab title
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Profile tab title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Habits tab app bar title
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get myHabits;

  /// Button to create new habit
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabit;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'Begin Your Journey'**
  String get beginYourJourney;

  /// Empty state message for habits
  ///
  /// In en, this message translates to:
  /// **'Every great journey begins with a single step.\n\nCreate your first habit and start building the life you want, one day at a time.'**
  String get everyGreatJourney;

  /// Motivational tagline
  ///
  /// In en, this message translates to:
  /// **'Small steps, big changes'**
  String get smallStepsBigChanges;

  /// Section title for today's habits
  ///
  /// In en, this message translates to:
  /// **'Today\'s Journey'**
  String get todaysJourney;

  /// Section title for upcoming habits
  ///
  /// In en, this message translates to:
  /// **'Upcoming Habits'**
  String get upcomingHabits;

  /// Progress card title
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get dailyProgress;

  /// Progress indicator
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} habits completed'**
  String habitsCompleted(int completed, int total);

  /// Congratulation message for 100% completion
  ///
  /// In en, this message translates to:
  /// **'Amazing work!'**
  String get amazingWork;

  /// Encouragement message
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Longest streak label
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// Streak count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak} =1{1 day} other{{count} days}}'**
  String streakDays(int count);

  /// Habit count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 habit} other{{count} habits}}'**
  String habitCount(int count);

  /// Section title for all habits
  ///
  /// In en, this message translates to:
  /// **'All Habits'**
  String get allHabits;

  /// Progress card subtitle
  ///
  /// In en, this message translates to:
  /// **'Your Progress Today'**
  String get yourProgressToday;

  /// Message for 100% completion
  ///
  /// In en, this message translates to:
  /// **'Perfect day! All habits built! 🎉'**
  String get perfectDay;

  /// Message for >50% completion
  ///
  /// In en, this message translates to:
  /// **'Great momentum! Keep building!'**
  String get greatMomentum;

  /// Message for <50% completion
  ///
  /// In en, this message translates to:
  /// **'Every step counts. Keep going!'**
  String get everyStepCounts;

  /// Message when no habits for today
  ///
  /// In en, this message translates to:
  /// **'Ready to build new habits?'**
  String get readyToBuildHabits;

  /// Habit title input label
  ///
  /// In en, this message translates to:
  /// **'Habit Title'**
  String get habitTitle;

  /// Habit title placeholder text
  ///
  /// In en, this message translates to:
  /// **'e.g., Morning Exercise'**
  String get habitTitlePlaceholder;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Optional description label
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// Description placeholder text
  ///
  /// In en, this message translates to:
  /// **'Add more details about your habit...'**
  String get descriptionPlaceholder;

  /// Icon selection label
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// Icon selector title
  ///
  /// In en, this message translates to:
  /// **'Choose an Icon'**
  String get chooseAnIcon;

  /// Fitness icon label
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get iconFitness;

  /// Reading icon label
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get iconReading;

  /// Hydration icon label
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get iconHydration;

  /// Sleep icon label
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get iconSleep;

  /// Eating icon label
  ///
  /// In en, this message translates to:
  /// **'Eating'**
  String get iconEating;

  /// Running icon label
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get iconRunning;

  /// Meditation icon label
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get iconMeditation;

  /// Yoga icon label
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get iconYoga;

  /// Art icon label
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get iconArt;

  /// Music icon label
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get iconMusic;

  /// Work icon label
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get iconWork;

  /// Study icon label
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get iconStudy;

  /// Health icon label
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get iconHealth;

  /// Walking icon label
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get iconWalking;

  /// Cycling icon label
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get iconCycling;

  /// Medicine icon label
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get iconMedication;

  /// Fitness category name
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// Reading category name
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get categoryBook;

  /// Hydration category name
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get categoryWater;

  /// Sleep category name
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get categorySleep;

  /// Restaurant/Nutrition category name
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get categoryRestaurant;

  /// Running category name
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get categoryRun;

  /// Meditation category name
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get categoryMeditation;

  /// Yoga category name
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get categoryYoga;

  /// Art category name
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get categoryArt;

  /// Music category name
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get categoryMusic;

  /// Work category name
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// School/Study category name
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get categorySchool;

  /// Heart/Health category name
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHeart;

  /// Walking category name
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get categoryWalk;

  /// Cycling category name
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get categoryBike;

  /// Medicine category name
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get categoryMedication;

  /// Other category name
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Color selection label
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// Color picker title
  ///
  /// In en, this message translates to:
  /// **'Choose a Color'**
  String get chooseColor;

  /// Frequency selection label
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Daily frequency option
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly frequency option
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Custom frequency option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Custom days selection label
  ///
  /// In en, this message translates to:
  /// **'Select Days'**
  String get selectDays;

  /// Time picker label
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// Optional time picker label
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time (optional)'**
  String get scheduledTimeOptional;

  /// Time picker button text
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// Public habit toggle label
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// Public habit toggle description
  ///
  /// In en, this message translates to:
  /// **'Make this habit visible to friends'**
  String get makeHabitPublic;

  /// Public habit subtitle
  ///
  /// In en, this message translates to:
  /// **'Let your friends see your progress'**
  String get letFriendsSeeProgress;

  /// Warning when changing habit frequency
  ///
  /// In en, this message translates to:
  /// **'Changing frequency will reset your streak and completion history.'**
  String get changingFrequencyWarning;

  /// Warning that category/icon cannot be changed
  ///
  /// In en, this message translates to:
  /// **'Category cannot be changed. Create a new habit to use a different category.'**
  String get cannotChangeCategory;

  /// Optional label
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Tooltip for clearing scheduled time
  ///
  /// In en, this message translates to:
  /// **'Clear time'**
  String get clearTime;

  /// Notification scheduled for tomorrow message
  ///
  /// In en, this message translates to:
  /// **'Note: Notification scheduled for tomorrow at {time}'**
  String notificationScheduledTomorrow(String time);

  /// Notification permissions denied message
  ///
  /// In en, this message translates to:
  /// **'Notification permissions denied. You won\'t receive reminders for this habit.'**
  String get notificationPermissionsDenied;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Edit habit screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// Delete habit confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// Delete habit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this habit? This action cannot be undone.'**
  String get deleteHabitConfirmation;

  /// Delete habit dialog question
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this habit?'**
  String get deleteHabitQuestion;

  /// Habit details screen title
  ///
  /// In en, this message translates to:
  /// **'Habit Details'**
  String get habitDetails;

  /// Button to mark habit complete
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// Button text to mark habit as complete
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// Status text when completing a habit
  ///
  /// In en, this message translates to:
  /// **'Completing... 🎉'**
  String get completing;

  /// Message shown when habit is already completed
  ///
  /// In en, this message translates to:
  /// **'Completed today! Great job! 🎉'**
  String get completedToday;

  /// Check in section title
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// Note input placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)...'**
  String get addNoteOptional;

  /// Add note button text
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// Note input label
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// Note placeholder text
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get notePlaceholder;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// Total completions label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Recent completions section title
  ///
  /// In en, this message translates to:
  /// **'Recent Completions'**
  String get recentCompletions;

  /// Empty state message for no completions
  ///
  /// In en, this message translates to:
  /// **'No completions yet.\nStart your streak today!'**
  String get noCompletionsYet;

  /// Monday
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Sunday
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Monday short
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Tuesday short
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Wednesday short
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Thursday short
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Friday short
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Saturday short
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Sunday short
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Empty state title for social feed
  ///
  /// In en, this message translates to:
  /// **'No Activity Yet'**
  String get noActivityYet;

  /// Empty state message for social feed
  ///
  /// In en, this message translates to:
  /// **'Connect with friends to see their progress\nand stay motivated together!'**
  String get connectWithFriends;

  /// Button to search for friends
  ///
  /// In en, this message translates to:
  /// **'Find Friends'**
  String get findFriends;

  /// Search users screen title
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// Search input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by username or email...'**
  String get searchByUsername;

  /// Add friend button text
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// Search users input placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchByName;

  /// Friend request sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to {name}'**
  String friendRequestSent(String name);

  /// Empty search state message
  ///
  /// In en, this message translates to:
  /// **'Search for friends to add them!'**
  String get searchForFriends;

  /// Empty search state message
  ///
  /// In en, this message translates to:
  /// **'Search for users to add as friends'**
  String get searchForUsers;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// You label
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Friend request pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Friends list title
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Friend requests screen title
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// Accept button text
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Reject button text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Send message button text
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// View profile button text
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// Remove friend button text
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// Remove friend dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Friend?'**
  String get removeFriendQuestion;

  /// Remove friend confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from your friends?'**
  String removeFriendConfirmation(String name);

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Friend removed confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} removed from friends'**
  String friendRemoved(String name);

  /// No friends empty state title
  ///
  /// In en, this message translates to:
  /// **'No Friends Yet'**
  String get noFriendsYet;

  /// No friends empty state message
  ///
  /// In en, this message translates to:
  /// **'Add friends to stay motivated together!\nShare progress and celebrate wins.'**
  String get addFriendsToStayMotivated;

  /// Streaks count label
  ///
  /// In en, this message translates to:
  /// **'{count} streaks'**
  String streaksCount(int count);

  /// New messages count
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String newMessages(int count);

  /// Chat screen title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Empty chat state message
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// Empty chat state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start a conversation!'**
  String get startConversation;

  /// Chat empty state greeting
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name}'**
  String sayHelloTo(String name);

  /// Failed to send message error
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSendMessage(String error);

  /// Performance chart section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get weeklyOverview;

  /// Completion rate label
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// This week label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Last 7 days label
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Total habits count label
  ///
  /// In en, this message translates to:
  /// **'Total Habits'**
  String get totalHabits;

  /// Active habits count label
  ///
  /// In en, this message translates to:
  /// **'Active Habits'**
  String get activeHabits;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// Empty state title for performance tab
  ///
  /// In en, this message translates to:
  /// **'No Performance Data Yet'**
  String get noPerformanceData;

  /// Empty state subtitle for performance tab
  ///
  /// In en, this message translates to:
  /// **'Start tracking habits to see your progress!'**
  String get startTrackingHabits;

  /// Completions label
  ///
  /// In en, this message translates to:
  /// **'Completions'**
  String get completions;

  /// Activity heatmap section title
  ///
  /// In en, this message translates to:
  /// **'Activity Heatmap'**
  String get activityHeatmap;

  /// Last 90 days label
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get last90Days;

  /// No activity message
  ///
  /// In en, this message translates to:
  /// **'No activity in the last 90 days'**
  String get noActivity90Days;

  /// Heatmap legend less label
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// Heatmap legend more label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// 30-day trend section title
  ///
  /// In en, this message translates to:
  /// **'30-Day Trend'**
  String get dayTrend30;

  /// Peak completions label
  ///
  /// In en, this message translates to:
  /// **'Peak: {count}'**
  String peak(int count);

  /// No completions message
  ///
  /// In en, this message translates to:
  /// **'No completions in the last 30 days'**
  String get noCompletions30Days;

  /// Streak insights section title
  ///
  /// In en, this message translates to:
  /// **'Streak Insights'**
  String get streakInsights;

  /// Average streak label
  ///
  /// In en, this message translates to:
  /// **'Avg Streak'**
  String get avgStreak;

  /// Active now label
  ///
  /// In en, this message translates to:
  /// **'Active Now'**
  String get activeNow;

  /// Top habits section title
  ///
  /// In en, this message translates to:
  /// **'Top Performing Habits'**
  String get topPerformingHabits;

  /// Completions count label
  ///
  /// In en, this message translates to:
  /// **'{count} completions'**
  String completionsCount(int count);

  /// Streak count label
  ///
  /// In en, this message translates to:
  /// **'{count} streak'**
  String streakCount(int count);

  /// Weekly pattern section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Pattern'**
  String get weeklyPattern;

  /// Tooltip for heatmap cells
  ///
  /// In en, this message translates to:
  /// **'{date}: {count} completions'**
  String completionsTooltip(String date, int count);

  /// Profile tab title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Edit profile button text
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Display name label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Display name hint
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterDisplayName;

  /// Display name validation error
  ///
  /// In en, this message translates to:
  /// **'Display name cannot be empty'**
  String get displayNameEmpty;

  /// Bio label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Bio hint
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get tellAboutYourself;

  /// Email read-only message
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// Photo change instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// Photo selected confirmation
  ///
  /// In en, this message translates to:
  /// **'New photo selected'**
  String get newPhotoSelected;

  /// Gallery picker option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Camera picker option
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// Remove photo option
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Profile update error message
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String errorUpdatingProfile(String error);

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Empty notifications message
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// Empty notifications title
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotificationsTitle;

  /// Mark all notifications read button
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No new notifications message
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get youreAllCaughtUp;

  /// No new notifications detailed message
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!\nWe\'ll notify you when something happens.'**
  String get youreAllCaughtUpMessage;

  /// Notification deleted confirmation
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// Tap to reply to message
  ///
  /// In en, this message translates to:
  /// **'Tap to reply'**
  String get tapToReply;

  /// Friend request accepted message
  ///
  /// In en, this message translates to:
  /// **'You and {name} are now friends!'**
  String nowFriends(String name);

  /// Friend request declined message
  ///
  /// In en, this message translates to:
  /// **'Friend request from {name} declined'**
  String friendRequestDeclined(String name);

  /// Error accepting friend request
  ///
  /// In en, this message translates to:
  /// **'Error accepting request: {error}'**
  String errorAcceptingRequest(String error);

  /// Error rejecting friend request
  ///
  /// In en, this message translates to:
  /// **'Error rejecting request: {error}'**
  String errorRejectingRequest(String error);

  /// Error opening chat
  ///
  /// In en, this message translates to:
  /// **'Error opening chat: {error}'**
  String errorOpeningChat(String error);

  /// Just now time label
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Weeks ago
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String weeksAgo(int count);

  /// Friend request notification
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a friend request'**
  String friendRequestFrom(String name);

  /// Friend request accepted notification
  ///
  /// In en, this message translates to:
  /// **'{name} accepted your friend request'**
  String friendRequestAccepted(String name);

  /// Friend habit completion notification
  ///
  /// In en, this message translates to:
  /// **'{name} completed \"{habit}\"'**
  String habitCompletedBy(String name, String habit);

  /// Reaction notification
  ///
  /// In en, this message translates to:
  /// **'{name} reacted {emoji}'**
  String reactionReceived(String name, String emoji);

  /// New message notification
  ///
  /// In en, this message translates to:
  /// **'{name} sent you a message'**
  String newMessage(String name);

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Now label
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// Notification title
  ///
  /// In en, this message translates to:
  /// **'Time for: {habitTitle}'**
  String notificationTimeFor(String habitTitle);

  /// Notification body when no description is provided
  ///
  /// In en, this message translates to:
  /// **'Your habit starts in 30 minutes. Get ready! 💪'**
  String get notificationHabitStartsSoon;

  /// Notification body with daily goal count
  ///
  /// In en, this message translates to:
  /// **'Daily goal: {count} times. Get ready! 💪'**
  String notificationDailyGoal(int count);

  /// Multiple scheduled times label
  ///
  /// In en, this message translates to:
  /// **'Scheduled Times (optional)'**
  String get scheduledTimesOptional;

  /// Subtitle for multiple scheduled times
  ///
  /// In en, this message translates to:
  /// **'Set a reminder time for each completion'**
  String get setTimeForEachCompletion;

  /// Completion number label
  ///
  /// In en, this message translates to:
  /// **'Completion #{number}'**
  String completionNumber(int number);

  /// Placeholder for unset time
  ///
  /// In en, this message translates to:
  /// **'Tap to set time'**
  String get tapToSetTime;

  /// Button to add another scheduled time
  ///
  /// In en, this message translates to:
  /// **'Add Another Time'**
  String get addAnotherTime;

  /// Notification settings title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Push notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get enablePushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive reminders for your habits'**
  String get receiveHabitReminders;

  /// Notification sound toggle
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get notificationSound;

  /// Sound following device
  ///
  /// In en, this message translates to:
  /// **'Following device settings'**
  String get followDeviceSettings;

  /// Sound always enabled
  ///
  /// In en, this message translates to:
  /// **'Sound always on'**
  String get soundAlwaysOn;

  /// Sound always disabled
  ///
  /// In en, this message translates to:
  /// **'Sound always off'**
  String get soundAlwaysOff;

  /// Switch to manual sound control
  ///
  /// In en, this message translates to:
  /// **'Use manual control'**
  String get useManualControl;

  /// Switch to device sound settings
  ///
  /// In en, this message translates to:
  /// **'Use device settings'**
  String get useDeviceSettings;

  /// Vibration toggle
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Vibration enabled description
  ///
  /// In en, this message translates to:
  /// **'Vibrate on notifications'**
  String get vibrateOnNotifications;

  /// Vibration disabled description
  ///
  /// In en, this message translates to:
  /// **'No vibration'**
  String get vibrationDisabled;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Undo button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// React button text
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get react;

  /// Reaction picker title
  ///
  /// In en, this message translates to:
  /// **'Choose a Reaction'**
  String get chooseReaction;

  /// Reaction count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reaction} other{{count} reactions}}'**
  String reactionCount(int count);

  /// Error loading users message
  ///
  /// In en, this message translates to:
  /// **'Could not load users'**
  String get couldNotLoadUsers;

  /// Fitness celebration title
  ///
  /// In en, this message translates to:
  /// **'Beast Mode! 💪'**
  String get celebrationFitnessTitle;

  /// Fitness celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'One step closer to your fitness goal!'**
  String get celebrationFitnessSubtitle;

  /// Book celebration title
  ///
  /// In en, this message translates to:
  /// **'Bookworm! 📚'**
  String get celebrationBookTitle;

  /// Book celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Knowledge is power!'**
  String get celebrationBookSubtitle;

  /// Water celebration title
  ///
  /// In en, this message translates to:
  /// **'Hydrated! 💧'**
  String get celebrationWaterTitle;

  /// Water celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Stay refreshed and healthy!'**
  String get celebrationWaterSubtitle;

  /// Sleep celebration title
  ///
  /// In en, this message translates to:
  /// **'Sweet Dreams! 😴'**
  String get celebrationSleepTitle;

  /// Sleep celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Rest well, you earned it!'**
  String get celebrationSleepSubtitle;

  /// Food celebration title
  ///
  /// In en, this message translates to:
  /// **'Delicious! 🍽️'**
  String get celebrationFoodTitle;

  /// Food celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Healthy eating habits!'**
  String get celebrationFoodSubtitle;

  /// Run celebration title
  ///
  /// In en, this message translates to:
  /// **'On the Move! 🏃'**
  String get celebrationRunTitle;

  /// Run celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Keep running towards your goals!'**
  String get celebrationRunSubtitle;

  /// Meditation celebration title
  ///
  /// In en, this message translates to:
  /// **'Inner Peace! 🧘'**
  String get celebrationMeditationTitle;

  /// Meditation celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Mindfulness achieved!'**
  String get celebrationMeditationSubtitle;

  /// Yoga celebration title
  ///
  /// In en, this message translates to:
  /// **'Namaste! 🧘‍♀️'**
  String get celebrationYogaTitle;

  /// Yoga celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Balance and flexibility!'**
  String get celebrationYogaSubtitle;

  /// Art celebration title
  ///
  /// In en, this message translates to:
  /// **'Creative! 🎨'**
  String get celebrationArtTitle;

  /// Art celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Express yourself!'**
  String get celebrationArtSubtitle;

  /// Music celebration title
  ///
  /// In en, this message translates to:
  /// **'Harmony! 🎵'**
  String get celebrationMusicTitle;

  /// Music celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Keep the rhythm going!'**
  String get celebrationMusicSubtitle;

  /// Work celebration title
  ///
  /// In en, this message translates to:
  /// **'Productive! 💼'**
  String get celebrationWorkTitle;

  /// Work celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Crushing those tasks!'**
  String get celebrationWorkSubtitle;

  /// School celebration title
  ///
  /// In en, this message translates to:
  /// **'Smart! 🎓'**
  String get celebrationSchoolTitle;

  /// School celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Learning never stops!'**
  String get celebrationSchoolSubtitle;

  /// Heart/health celebration title
  ///
  /// In en, this message translates to:
  /// **'Healthy! ❤️'**
  String get celebrationHeartTitle;

  /// Heart/health celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Taking care of yourself!'**
  String get celebrationHeartSubtitle;

  /// Walk celebration title
  ///
  /// In en, this message translates to:
  /// **'Step by Step! 🚶'**
  String get celebrationWalkTitle;

  /// Walk celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Every step counts!'**
  String get celebrationWalkSubtitle;

  /// Bike celebration title
  ///
  /// In en, this message translates to:
  /// **'Pedal Power! 🚴'**
  String get celebrationBikeTitle;

  /// Bike celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Rolling towards success!'**
  String get celebrationBikeSubtitle;

  /// Medication celebration title
  ///
  /// In en, this message translates to:
  /// **'Taken! 💊'**
  String get celebrationMedicationTitle;

  /// Medication celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Taking care of your health!'**
  String get celebrationMedicationSubtitle;

  /// Default celebration title
  ///
  /// In en, this message translates to:
  /// **'🎉 Great Job! 🎉'**
  String get celebrationDefaultTitle;

  /// Default celebration subtitle
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work!'**
  String get celebrationDefaultSubtitle;

  /// Habit completed message
  ///
  /// In en, this message translates to:
  /// **'{habit} completed! 🎉'**
  String habitCompleted(String habit);

  /// Habit marked incomplete message
  ///
  /// In en, this message translates to:
  /// **'{habit} marked as incomplete'**
  String habitMarkedIncomplete(String habit);

  /// Day count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dayCount(int count);

  /// Total count label
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// Consistency label
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// On fire status
  ///
  /// In en, this message translates to:
  /// **'On Fire! 🔥'**
  String get onFire;

  /// Keep building encouragement
  ///
  /// In en, this message translates to:
  /// **'Keep Building'**
  String get keepBuilding;

  /// Share progress title
  ///
  /// In en, this message translates to:
  /// **'Share Progress'**
  String get shareProgress;

  /// Share progress subtitle
  ///
  /// In en, this message translates to:
  /// **'Inspire your friends!'**
  String get inspireYourFriends;

  /// Day streak label
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// Completed label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Share as image option
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImage;

  /// Generating status
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// Progress report label
  ///
  /// In en, this message translates to:
  /// **'Progress Report'**
  String get progressReport;

  /// Default habit description
  ///
  /// In en, this message translates to:
  /// **'Building better habits'**
  String get buildingBetterHabits;

  /// Day streak label for share card
  ///
  /// In en, this message translates to:
  /// **'Day\nStreak'**
  String get dayStreakLabel;

  /// Best streak label for share card
  ///
  /// In en, this message translates to:
  /// **'Best\nStreak'**
  String get bestStreakLabel;

  /// Total done label for share card
  ///
  /// In en, this message translates to:
  /// **'Total\nDone'**
  String get totalDoneLabel;

  /// Share card footer message
  ///
  /// In en, this message translates to:
  /// **'💪  Keep building better habits!'**
  String get keepBuildingBetterHabits;

  /// Hashtag for sharing
  ///
  /// In en, this message translates to:
  /// **'#MyHabits'**
  String get myHabitsHashtag;

  /// Share text with habit name
  ///
  /// In en, this message translates to:
  /// **'🎯 My {habit} Progress! #MyHabits'**
  String myHabitProgress(String habit);

  /// Image generation error
  ///
  /// In en, this message translates to:
  /// **'Failed to generate image: {error}'**
  String failedToGenerateImage(String error);

  /// Daily goal section title
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// Times per day label
  ///
  /// In en, this message translates to:
  /// **'times per day'**
  String get timesPerDay;

  /// Target count picker question
  ///
  /// In en, this message translates to:
  /// **'How many times per day?'**
  String get howManyTimes;

  /// Time singular
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get timesSingular;

  /// Times plural
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get timesPlural;

  /// Progress indicator X of Y
  ///
  /// In en, this message translates to:
  /// **'{completed} of {target}'**
  String completedXOfY(int completed, int target);

  /// Message when daily goal is reached
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached! 🎉'**
  String get dailyGoalReached;

  /// Completion number of target
  ///
  /// In en, this message translates to:
  /// **'Completion {current} of {target}'**
  String completionXOfY(int current, int target);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
