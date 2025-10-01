// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Health Tracker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get signOut => 'Sign Out';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get thai => 'Thai';

  @override
  String get profile => 'Profile';

  @override
  String get profileSetup => 'Profile setup';

  @override
  String stepOf(num current, num total) {
    return 'Step $current of $total';
  }

  @override
  String get addProfilePhoto => 'Add Profile Photo';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Your name';

  @override
  String get dob => 'Date of Birth';

  @override
  String get dobHint => 'dd/mm/yyyy';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get next => 'Next';

  @override
  String get openProfileSetup => 'Open Profile Setup';

  @override
  String get physicalInfo => 'Physical Info';

  @override
  String get weight => 'Weight';

  @override
  String get weightHint => 'kg';

  @override
  String get height => 'Height';

  @override
  String get heightHint => 'cm';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get sedentary => 'Sedentary: Little to no exercise';

  @override
  String get lightlyActive => 'Lightly Active: Light exercise 1-3 days/week';

  @override
  String get moderatelyActive =>
      'Moderately Active: Moderate exercise 3-5 days/week';

  @override
  String get veryActive => 'Very Active: Hard exercise 6-7 days/week';

  @override
  String get openProfileSetupStep2 => 'Open Profile Setup Step 2';

  @override
  String get skip => 'SKIP';

  @override
  String get getStarted => 'Get Started';

  @override
  String get trackHealthTitle => 'Track Your Health';

  @override
  String get trackHealthDesc =>
      'Monitor your daily activities, workouts, and health metrics to stay on track with your wellness goals.';

  @override
  String get setGoalsTitle => 'Set Your Goals';

  @override
  String get setGoalsDesc =>
      'Define your fitness and health objectives to create a personalized plan that works best for you.';

  @override
  String get analyzeProgressTitle => 'Analyze Progress';

  @override
  String get analyzeProgressDesc =>
      'View detailed insights and charts to understand your health trends and celebrate your achievements.';

  @override
  String get aboutYourself => 'About Yourself';

  @override
  String get healthRatingQuestion =>
      'How would you describe your current health?';

  @override
  String get healthPoor => 'Poor';

  @override
  String get healthFair => 'Fair';

  @override
  String get healthGood => 'Good';

  @override
  String get healthGreat => 'Great';

  @override
  String get healthExcellent => 'Excellent';

  @override
  String get yourGoals => 'What are your main goals?';

  @override
  String get goalLoseWeight => 'Lose Weight';

  @override
  String get goalBuildMuscle => 'Build Muscle';

  @override
  String get goalImproveFitness => 'Improve Fitness';

  @override
  String get goalBetterSleep => 'Better Sleep';

  @override
  String get goalEatHealthier => 'Eat Healthier';

  @override
  String get goalAndAchievement => 'Goals & Achievements';

  @override
  String get openProfileSetupStep3 => 'Open Profile Setup Step 3';

  @override
  String get finish => 'Finish';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get waterIntakeTitle => 'Water Intake';

  @override
  String get dailyWaterLogSubtitle => 'Record your daily water intake';

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get dailyWaterLog => 'Daily Water Log';

  @override
  String get selectBeverage => 'Select Beverage';

  @override
  String get addBeverage => 'Add Beverage';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get pleaseSelectBeverage => 'Please select a beverage first';

  @override
  String get pleaseEnterAmount => 'Please enter amount (ml)';

  @override
  String get beverageAdded => 'Beverage added';

  @override
  String get ml => 'ml';

  @override
  String get exercise => 'Exercise';

  @override
  String get noActivitiesYet => 'No activities added yet';

  @override
  String get reset => 'Reset';

  @override
  String get stop => 'Stop';

  @override
  String get start => 'Start';

  @override
  String get selectDuration => 'Select Duration';

  @override
  String get use => 'Use';

  @override
  String get addActivity => 'Add Activity';

  @override
  String get editActivity => 'Edit Activity';

  @override
  String get activityName => 'Activity Name';

  @override
  String get duration => 'Duration';

  @override
  String get pick => 'Pick';

  @override
  String get startTime => 'Start Time';

  @override
  String get now => 'Now';

  @override
  String get done => 'Done';

  @override
  String get min => 'min';

  @override
  String get sleepLogged => 'Sleep Logged';

  @override
  String get mealsLogged => 'Meals Logged';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get home => 'Home';

  @override
  String get meal => 'Meal';

  @override
  String get water => 'Water';

  @override
  String get sleep => 'Sleep';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get username => 'Username';

  @override
  String get pleaseEnterUsername => 'Please enter a username';

  @override
  String get pleaseEnterAnEmail => 'Please enter an email';

  @override
  String get passwordMinimum6Chars => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAnAccount => 'Have an account? ';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get bedtime => 'Bedtime';

  @override
  String get wakeUpTime => 'Wake-up Time';

  @override
  String get logSleep => 'Log Sleep';

  @override
  String get lastNight => 'last night';

  @override
  String get addWater => 'Add Water';

  @override
  String get selectActivity => 'Select Activity';

  @override
  String get goodMorning => 'Good morning, Alex!';

  @override
  String date(String date) {
    return 'Date $date';
  }

  @override
  String get waterIntakeLabel => 'Water Intake';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get sleepLoggedLabel => 'Sleep Logged';

  @override
  String get mealsLoggedLabel => 'Meals Logged';

  @override
  String get todayMood => 'Today\'s Mood';

  @override
  String get todayProgress => 'Today\'s Progress';

  @override
  String get todayWeight => 'Today\'s Weight';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get share => 'Share';

  @override
  String get shareData => 'Share Data';

  @override
  String get exportToPDF => 'Export to PDF';

  @override
  String get saveDataAsPDF => 'Save data as PDF file';

  @override
  String get shareToOtherApps => 'Share to other apps';

  @override
  String get noDataToShare => 'No data to share';

  @override
  String errorOccurredMessage(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get noDataToPDF => 'No data to create PDF';

  @override
  String errorCreatingPDF(String error) {
    return 'Error creating PDF: $error';
  }

  @override
  String get copyText => 'Copy Text';

  @override
  String get copyToClipboard => 'Copy data to clipboard';

  @override
  String get noDataToCopy => 'No data to copy';

  @override
  String get copiedSuccessfully => 'Data copied successfully!';

  @override
  String errorCopying(String error) {
    return 'Error copying: $error';
  }

  @override
  String get shareAchievement => 'Share Achievement';

  @override
  String get newAchievement => 'New Achievement!';

  @override
  String get justCompletedChallenge =>
      'I just completed this challenge in Health Tracking App! 💪';

  @override
  String get volumeMl => 'Volume (ml)';

  @override
  String todayGlasses(num count) {
    return 'Today: $count glasses';
  }

  @override
  String get addBeverageTooltip => 'Add beverage';

  @override
  String get beverageNameHint => 'Beverage name (e.g. water, tea...)';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get chooseFromList => 'Choose from list';

  @override
  String get selectProfilePhoto => 'Select Profile Photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String errorOccurred2(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get goalDeletedSuccessfully => 'Goal deleted successfully';

  @override
  String get healthTrends => 'Health Trends';

  @override
  String get profileSetupCompleted => 'Profile setup completed!';

  @override
  String get uranusCode => 'Uranus Code';

  @override
  String confirmDeleteGoal(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get pleaseEnterGoalTitle => 'Please enter a goal title';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String get goalAddedSuccessfully => 'Goal added successfully!';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get youtubeChannel => 'Youtube Channel';

  @override
  String get noData => 'No data';

  @override
  String errorSelectingImage(String error) {
    return 'Error selecting image: $error';
  }

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get mealDataSavedSuccessfully => 'Meal data saved successfully';

  @override
  String errorOccurredWithDetails(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get activeGoals => 'Active Goals';

  @override
  String get achievements => 'Achievements';

  @override
  String get addYourFirstGoal => 'Add your first goal';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get drinkWater => 'Drink Water';

  @override
  String get sleepGoal => 'Sleep';

  @override
  String get weightGoal => 'Weight';

  @override
  String get glasses => 'glasses';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'hrs';

  @override
  String get kg => 'kg';

  @override
  String get general => 'General';

  @override
  String get goalTitle => 'Goal Title';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String targetValue(String unit) {
    return 'Target Value ($unit)';
  }

  @override
  String get goal => 'Goal';

  @override
  String get mealLogging => 'Meal Logging';

  @override
  String get selectMealTime => 'Select meal time';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get foodName => 'Food Name';

  @override
  String get enterFoodName => 'Enter food name';

  @override
  String get mealPhoto => 'Meal Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get mealDescription => 'Meal Description';

  @override
  String get enterMealDescription =>
      'Enter meal description, e.g., portion size, restaurant, cooking method, etc.';

  @override
  String get saveMeal => 'Save Meal';

  @override
  String get pleaseEnterFoodName => 'Please enter food name';

  @override
  String imageSelectionError(String error) {
    return 'Image selection error: $error';
  }

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsDescription =>
      'Customize your reminder preferences';

  @override
  String get healthReminders => 'Health Reminders';

  @override
  String get waterReminder => 'Water Reminder';

  @override
  String get waterReminderDescription =>
      'Remind me to stay hydrated throughout the day';

  @override
  String get exerciseReminder => 'Exercise Reminder';

  @override
  String get exerciseReminderDescription => 'Remind me to exercise regularly';

  @override
  String get sleepReminder => 'Sleep Reminder';

  @override
  String get sleepReminderDescription =>
      'Remind me to maintain healthy sleep schedule';

  @override
  String get mealLoggingReminder => 'Meal Logging Reminder';

  @override
  String get mealLoggingReminderDescription => 'Remind me to log my meals';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get resetNotificationConfirmation =>
      'Are you sure you want to reset all notification settings to default? This will enable all reminders.';

  @override
  String get notificationSettingsReset =>
      'Notification settings have been reset to default';

  @override
  String get statistics => 'Statistics';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get sleepHours => 'Sleep Hours';

  @override
  String get waterIntakeML => 'Water Intake (ml)';

  @override
  String get exerciseCalories => 'Exercise (cal)';

  @override
  String get latest => 'Latest';

  @override
  String get average => 'Average';

  @override
  String get goalLabel => 'Goal';

  @override
  String get milliliters => 'ml';

  @override
  String get calories => 'cal';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get addNewBeverage => 'Add New Beverage';

  @override
  String get beverageName => 'Beverage Name';

  @override
  String get beverageNameExample => 'e.g. Iced milk, Green tea';

  @override
  String get deleteBeverage => 'Delete Beverage';

  @override
  String deleteBeverageConfirm(String name) {
    return 'Do you want to delete \"$name\"?';
  }

  @override
  String beverageDeletedSuccess(String name) {
    return 'Deleted $name successfully';
  }

  @override
  String beverageAddedSuccess(String name) {
    return 'Added $name successfully';
  }

  @override
  String get dayNameSun => 'Sun';

  @override
  String get dayNameMon => 'Mon';

  @override
  String get dayNameTue => 'Tue';

  @override
  String get dayNameWed => 'Wed';

  @override
  String get dayNameThu => 'Thu';

  @override
  String get dayNameFri => 'Fri';

  @override
  String get dayNameSat => 'Sat';

  @override
  String get exerciseWalking => 'Walking';

  @override
  String get exerciseRunning => 'Running';

  @override
  String get exerciseCycling => 'Cycling';

  @override
  String get exerciseSwimming => 'Swimming';

  @override
  String get exerciseYoga => 'Yoga';

  @override
  String get exerciseWeightLifting => 'Weight Lifting';

  @override
  String get exerciseDancing => 'Dancing';

  @override
  String get exerciseFootball => 'Football';

  @override
  String get waterLogFailed => 'Failed to log water intake';

  @override
  String waterLogSuccess(String name, num amount) {
    return 'Added $name +$amount ml';
  }

  @override
  String exerciseLogSuccess(num minutes) {
    return 'Logged exercise +$minutes minutes';
  }

  @override
  String get activitySavedSuccess => 'Activity saved successfully';

  @override
  String get activitySaveFailed => 'Failed to save activity';

  @override
  String get activityDeletedSuccess => 'Activity deleted';

  @override
  String get activityDeleteFailed => 'Failed to delete activity';

  @override
  String get sleepLoggedSuccess => 'Sleep logged';

  @override
  String get sleepLogFailed => 'Failed to log sleep';

  @override
  String get achievementConsecutive3Days =>
      'Logged activities for 3 consecutive days';

  @override
  String get achievementConsecutive7Days =>
      'Logged activities for 7 consecutive days';

  @override
  String get achievementFirstWeightLog => 'First Weight Log';

  @override
  String get achievementFirstWeightLogDesc =>
      'Logged weight for the first time';

  @override
  String get achievementWeightConsecutive7Days =>
      'Logged weight for 7 consecutive days';

  @override
  String get chooseBeverage => 'Choose Beverage';

  @override
  String totalCalories(num calories) {
    return 'Total Calories: $calories cal';
  }

  @override
  String get nutrition => 'Nutrition';

  @override
  String get fullName => 'Full Name';

  @override
  String get nickname => 'Nickname';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterNickname => 'Enter your nickname';

  @override
  String get selectBirthDate => 'Select birth date';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterNickname => 'Please enter your nickname';

  @override
  String get pleaseSelectBirthDate => 'Please select your birth date';

  @override
  String get pleaseSelectGender => 'Please select your gender';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';
}
