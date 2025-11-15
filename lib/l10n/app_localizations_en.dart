// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Hero';

  @override
  String get myHabitsTitle => 'My Habits';

  @override
  String get buildBetterHabits => 'Build Better Habits Together';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInToContinue => 'Sign in to continue your habit journey';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinMyHabits => 'Join My Habits';

  @override
  String get startBuildingHabits => 'Start building better habits with friends';

  @override
  String get fullName => 'Full Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterHabitTitle => 'Please enter a habit title';

  @override
  String get pleaseSelectAtLeastOneDay =>
      'Please select at least one day for custom habits';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get signupFailed => 'Signup failed. Please try again.';

  @override
  String get habits => 'Habits';

  @override
  String get social => 'Social';

  @override
  String get performance => 'Performance';

  @override
  String get profile => 'Profile';

  @override
  String get myHabits => 'My Habits';

  @override
  String get newHabit => 'New Habit';

  @override
  String get beginYourJourney => 'Begin Your Journey';

  @override
  String get everyGreatJourney =>
      'Every great journey begins with a single step.\n\nCreate your first habit and start building the life you want, one day at a time.';

  @override
  String get smallStepsBigChanges => 'Small steps, big changes';

  @override
  String get todaysJourney => 'Today\'s Journey';

  @override
  String get upcomingHabits => 'Upcoming Habits';

  @override
  String get dailyProgress => 'Daily Progress';

  @override
  String habitsCompleted(int completed, int total) {
    return '$completed of $total habits completed';
  }

  @override
  String get amazingWork => 'Amazing work!';

  @override
  String get keepGoing => 'Keep going!';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'No streak',
    );
    return '$_temp0';
  }

  @override
  String habitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits',
      one: '1 habit',
    );
    return '$_temp0';
  }

  @override
  String get allHabits => 'All Habits';

  @override
  String get yourProgressToday => 'Your Progress Today';

  @override
  String get perfectDay => 'Perfect day! All habits built! 🎉';

  @override
  String get greatMomentum => 'Great momentum! Keep building!';

  @override
  String get everyStepCounts => 'Every step counts. Keep going!';

  @override
  String get readyToBuildHabits => 'Ready to build new habits?';

  @override
  String get habitTitle => 'Habit Title';

  @override
  String get habitTitlePlaceholder => 'e.g., Morning Exercise';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get descriptionPlaceholder => 'Add more details about your habit...';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get chooseAnIcon => 'Choose an Icon';

  @override
  String get iconFitness => 'Fitness';

  @override
  String get iconReading => 'Reading';

  @override
  String get iconHydration => 'Hydration';

  @override
  String get iconSleep => 'Sleep';

  @override
  String get iconEating => 'Eating';

  @override
  String get iconRunning => 'Running';

  @override
  String get iconMeditation => 'Meditation';

  @override
  String get iconYoga => 'Yoga';

  @override
  String get iconArt => 'Art';

  @override
  String get iconMusic => 'Music';

  @override
  String get iconWork => 'Work';

  @override
  String get iconStudy => 'Study';

  @override
  String get iconHealth => 'Health';

  @override
  String get iconWalking => 'Walking';

  @override
  String get iconCycling => 'Cycling';

  @override
  String get iconMedication => 'Medicine';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categoryBook => 'Reading';

  @override
  String get categoryWater => 'Hydration';

  @override
  String get categorySleep => 'Sleep';

  @override
  String get categoryRestaurant => 'Nutrition';

  @override
  String get categoryRun => 'Running';

  @override
  String get categoryMeditation => 'Meditation';

  @override
  String get categoryYoga => 'Yoga';

  @override
  String get categoryArt => 'Art';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryWork => 'Work';

  @override
  String get categorySchool => 'Study';

  @override
  String get categoryHeart => 'Health';

  @override
  String get categoryWalk => 'Walking';

  @override
  String get categoryBike => 'Cycling';

  @override
  String get categoryMedication => 'Medicine';

  @override
  String get categoryOther => 'Other';

  @override
  String get selectColor => 'Select Color';

  @override
  String get chooseColor => 'Choose a Color';

  @override
  String get frequency => 'Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get custom => 'Custom';

  @override
  String get selectDays => 'Select Days';

  @override
  String get scheduledTime => 'Scheduled Time';

  @override
  String get scheduledTimeOptional => 'Scheduled Time (optional)';

  @override
  String get selectTime => 'Select Time';

  @override
  String get shareWithFriends => 'Share with Friends';

  @override
  String get makeHabitPublic => 'Make this habit visible to friends';

  @override
  String get letFriendsSeeProgress => 'Let your friends see your progress';

  @override
  String get changingFrequencyWarning =>
      'Changing frequency will reset your streak and completion history.';

  @override
  String get cannotChangeCategory =>
      'Category cannot be changed. Create a new habit to use a different category.';

  @override
  String get optional => 'Optional';

  @override
  String get clearTime => 'Clear time';

  @override
  String notificationScheduledTomorrow(String time) {
    return 'Note: Notification scheduled for tomorrow at $time';
  }

  @override
  String get notificationPermissionsDenied =>
      'Notification permissions denied. You won\'t receive reminders for this habit.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String get deleteHabitConfirmation =>
      'Are you sure you want to delete this habit? This action cannot be undone.';

  @override
  String get deleteHabitQuestion =>
      'Are you sure you want to delete this habit?';

  @override
  String get habitDetails => 'Habit Details';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get markAsComplete => 'Mark as Complete';

  @override
  String get completing => 'Completing... 🎉';

  @override
  String get completedToday => 'Completed today! Great job! 🎉';

  @override
  String get checkIn => 'Check In';

  @override
  String get addNoteOptional => 'Add a note (optional)...';

  @override
  String get addNote => 'Add Note';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get notePlaceholder => 'How did it go?';

  @override
  String get current => 'Current';

  @override
  String get best => 'Best';

  @override
  String get total => 'Total';

  @override
  String get recentCompletions => 'Recent Completions';

  @override
  String get noCompletionsYet =>
      'No completions yet.\nStart your streak today!';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get noActivityYet => 'No Activity Yet';

  @override
  String get connectWithFriends =>
      'Connect with friends to see their progress\nand stay motivated together!';

  @override
  String get findFriends => 'Find Friends';

  @override
  String get searchUsers => 'Search Users';

  @override
  String get searchByUsername => 'Search by username or email...';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get searchByName => 'Search by name or email...';

  @override
  String friendRequestSent(String name) {
    return 'Friend request sent to $name';
  }

  @override
  String get searchForFriends => 'Search for friends to add them!';

  @override
  String get searchForUsers => 'Search for users to add as friends';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get you => 'You';

  @override
  String get add => 'Add';

  @override
  String get pending => 'Pending';

  @override
  String get friends => 'Friends';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String get removeFriendQuestion => 'Remove Friend?';

  @override
  String removeFriendConfirmation(String name) {
    return 'Are you sure you want to remove $name from your friends?';
  }

  @override
  String get remove => 'Remove';

  @override
  String friendRemoved(String name) {
    return '$name removed from friends';
  }

  @override
  String get noFriendsYet => 'No Friends Yet';

  @override
  String get addFriendsToStayMotivated =>
      'Add friends to stay motivated together!\nShare progress and celebrate wins.';

  @override
  String streaksCount(int count) {
    return '$count streaks';
  }

  @override
  String newMessages(int count) {
    return '$count new';
  }

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get startConversation => 'Start a conversation!';

  @override
  String sayHelloTo(String name) {
    return 'Say hello to $name';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String get weeklyOverview => 'Weekly Overview';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get thisWeek => 'This Week';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalHabits => 'Total Habits';

  @override
  String get activeHabits => 'Active Habits';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get noPerformanceData => 'No Performance Data Yet';

  @override
  String get startTrackingHabits =>
      'Start tracking habits to see your progress!';

  @override
  String get completions => 'Completions';

  @override
  String get activityHeatmap => 'Activity Heatmap';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get noActivity90Days => 'No activity in the last 90 days';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get dayTrend30 => '30-Day Trend';

  @override
  String peak(int count) {
    return 'Peak: $count';
  }

  @override
  String get noCompletions30Days => 'No completions in the last 30 days';

  @override
  String get streakInsights => 'Streak Insights';

  @override
  String get avgStreak => 'Avg Streak';

  @override
  String get activeNow => 'Active Now';

  @override
  String get topPerformingHabits => 'Top Performing Habits';

  @override
  String completionsCount(int count) {
    return '$count completions';
  }

  @override
  String streakCount(int count) {
    return '$count streak';
  }

  @override
  String get weeklyPattern => 'Weekly Pattern';

  @override
  String completionsTooltip(String date, int count) {
    return '$date: $count completions';
  }

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get displayName => 'Display Name';

  @override
  String get enterDisplayName => 'Enter your display name';

  @override
  String get displayNameEmpty => 'Display name cannot be empty';

  @override
  String get bio => 'Bio';

  @override
  String get tellAboutYourself => 'Tell us about yourself...';

  @override
  String get emailCannotBeChanged => 'Email cannot be changed';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get newPhotoSelected => 'New photo selected';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String errorUpdatingProfile(String error) {
    return 'Error updating profile: $error';
  }

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsTitle => 'No Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get youreAllCaughtUp => 'You\'re all caught up!';

  @override
  String get youreAllCaughtUpMessage =>
      'You\'re all caught up!\nWe\'ll notify you when something happens.';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get tapToReply => 'Tap to reply';

  @override
  String nowFriends(String name) {
    return 'You and $name are now friends!';
  }

  @override
  String friendRequestDeclined(String name) {
    return 'Friend request from $name declined';
  }

  @override
  String errorAcceptingRequest(String error) {
    return 'Error accepting request: $error';
  }

  @override
  String errorRejectingRequest(String error) {
    return 'Error rejecting request: $error';
  }

  @override
  String errorOpeningChat(String error) {
    return 'Error opening chat: $error';
  }

  @override
  String get justNow => 'Just now';

  @override
  String weeksAgo(int count) {
    return '${count}w ago';
  }

  @override
  String friendRequestFrom(String name) {
    return '$name sent you a friend request';
  }

  @override
  String friendRequestAccepted(String name) {
    return '$name accepted your friend request';
  }

  @override
  String habitCompletedBy(String name, String habit) {
    return '$name completed \"$habit\"';
  }

  @override
  String reactionReceived(String name, String emoji) {
    return '$name reacted $emoji';
  }

  @override
  String newMessage(String name) {
    return '$name sent you a message';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get now => 'Now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String notificationTimeFor(String habitTitle) {
    return 'Time for: $habitTitle';
  }

  @override
  String get notificationHabitStartsSoon =>
      'Your habit starts in 30 minutes. Get ready! 💪';

  @override
  String notificationDailyGoal(int count) {
    return 'Daily goal: $count times. Get ready! 💪';
  }

  @override
  String get scheduledTimesOptional => 'Scheduled Times (optional)';

  @override
  String get setTimeForEachCompletion =>
      'Set a reminder time for each completion';

  @override
  String completionNumber(int number) {
    return 'Completion #$number';
  }

  @override
  String get tapToSetTime => 'Tap to set time';

  @override
  String get addAnotherTime => 'Add Another Time';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enablePushNotifications => 'Push Notifications';

  @override
  String get receiveHabitReminders => 'Receive reminders for your habits';

  @override
  String get notificationSound => 'Sound';

  @override
  String get followDeviceSettings => 'Following device settings';

  @override
  String get soundAlwaysOn => 'Sound always on';

  @override
  String get soundAlwaysOff => 'Sound always off';

  @override
  String get useManualControl => 'Use manual control';

  @override
  String get useDeviceSettings => 'Use device settings';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateOnNotifications => 'Vibrate on notifications';

  @override
  String get vibrationDisabled => 'No vibration';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get undo => 'Undo';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results found';

  @override
  String get react => 'React';

  @override
  String get chooseReaction => 'Choose a Reaction';

  @override
  String reactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: '1 reaction',
    );
    return '$_temp0';
  }

  @override
  String get couldNotLoadUsers => 'Could not load users';

  @override
  String get celebrationFitnessTitle => 'Beast Mode! 💪';

  @override
  String get celebrationFitnessSubtitle =>
      'One step closer to your fitness goal!';

  @override
  String get celebrationBookTitle => 'Bookworm! 📚';

  @override
  String get celebrationBookSubtitle => 'Knowledge is power!';

  @override
  String get celebrationWaterTitle => 'Hydrated! 💧';

  @override
  String get celebrationWaterSubtitle => 'Stay refreshed and healthy!';

  @override
  String get celebrationSleepTitle => 'Sweet Dreams! 😴';

  @override
  String get celebrationSleepSubtitle => 'Rest well, you earned it!';

  @override
  String get celebrationFoodTitle => 'Delicious! 🍽️';

  @override
  String get celebrationFoodSubtitle => 'Healthy eating habits!';

  @override
  String get celebrationRunTitle => 'On the Move! 🏃';

  @override
  String get celebrationRunSubtitle => 'Keep running towards your goals!';

  @override
  String get celebrationMeditationTitle => 'Inner Peace! 🧘';

  @override
  String get celebrationMeditationSubtitle => 'Mindfulness achieved!';

  @override
  String get celebrationYogaTitle => 'Namaste! 🧘‍♀️';

  @override
  String get celebrationYogaSubtitle => 'Balance and flexibility!';

  @override
  String get celebrationArtTitle => 'Creative! 🎨';

  @override
  String get celebrationArtSubtitle => 'Express yourself!';

  @override
  String get celebrationMusicTitle => 'Harmony! 🎵';

  @override
  String get celebrationMusicSubtitle => 'Keep the rhythm going!';

  @override
  String get celebrationWorkTitle => 'Productive! 💼';

  @override
  String get celebrationWorkSubtitle => 'Crushing those tasks!';

  @override
  String get celebrationSchoolTitle => 'Smart! 🎓';

  @override
  String get celebrationSchoolSubtitle => 'Learning never stops!';

  @override
  String get celebrationHeartTitle => 'Healthy! ❤️';

  @override
  String get celebrationHeartSubtitle => 'Taking care of yourself!';

  @override
  String get celebrationWalkTitle => 'Step by Step! 🚶';

  @override
  String get celebrationWalkSubtitle => 'Every step counts!';

  @override
  String get celebrationBikeTitle => 'Pedal Power! 🚴';

  @override
  String get celebrationBikeSubtitle => 'Rolling towards success!';

  @override
  String get celebrationMedicationTitle => 'Taken! 💊';

  @override
  String get celebrationMedicationSubtitle => 'Taking care of your health!';

  @override
  String get celebrationDefaultTitle => '🎉 Great Job! 🎉';

  @override
  String get celebrationDefaultSubtitle => 'Keep up the great work!';

  @override
  String habitCompleted(String habit) {
    return '$habit completed! 🎉';
  }

  @override
  String habitMarkedIncomplete(String habit) {
    return '$habit marked as incomplete';
  }

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String get consistency => 'Consistency';

  @override
  String get onFire => 'On Fire! 🔥';

  @override
  String get keepBuilding => 'Keep Building';

  @override
  String get shareProgress => 'Share Progress';

  @override
  String get inspireYourFriends => 'Inspire your friends!';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get completed => 'Completed';

  @override
  String get shareAsImage => 'Share as Image';

  @override
  String get generating => 'Generating...';

  @override
  String get progressReport => 'Progress Report';

  @override
  String get buildingBetterHabits => 'Building better habits';

  @override
  String get dayStreakLabel => 'Day\nStreak';

  @override
  String get bestStreakLabel => 'Best\nStreak';

  @override
  String get totalDoneLabel => 'Total\nDone';

  @override
  String get keepBuildingBetterHabits => '💪  Keep building better habits!';

  @override
  String get myHabitsHashtag => '#MyHabits';

  @override
  String myHabitProgress(String habit) {
    return '🎯 My $habit Progress! #MyHabits';
  }

  @override
  String failedToGenerateImage(String error) {
    return 'Failed to generate image: $error';
  }

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get timesPerDay => 'times per day';

  @override
  String get howManyTimes => 'How many times per day?';

  @override
  String get timesSingular => 'time';

  @override
  String get timesPlural => 'times';

  @override
  String completedXOfY(int completed, int target) {
    return '$completed of $target';
  }

  @override
  String get dailyGoalReached => 'Daily goal reached! 🎉';

  @override
  String completionXOfY(int current, int target) {
    return 'Completion $current of $target';
  }
}
