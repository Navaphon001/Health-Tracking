// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Wellness Tracker';

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
}
