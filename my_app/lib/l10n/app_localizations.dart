import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Wellness Tracker'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get thai;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Profile setup'**
  String get profileSetup;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(num current, num total);

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Photo'**
  String get addProfilePhoto;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob;

  /// No description provided for @dobHint.
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get dobHint;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @openProfileSetup.
  ///
  /// In en, this message translates to:
  /// **'Open Profile Setup'**
  String get openProfileSetup;

  /// No description provided for @physicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Physical Info'**
  String get physicalInfo;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get weightHint;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @heightHint.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get heightHint;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary: Little to no exercise'**
  String get sedentary;

  /// No description provided for @lightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active: Light exercise 1-3 days/week'**
  String get lightlyActive;

  /// No description provided for @moderatelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active: Moderate exercise 3-5 days/week'**
  String get moderatelyActive;

  /// No description provided for @veryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active: Hard exercise 6-7 days/week'**
  String get veryActive;

  /// No description provided for @openProfileSetupStep2.
  ///
  /// In en, this message translates to:
  /// **'Open Profile Setup Step 2'**
  String get openProfileSetupStep2;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @trackHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Health'**
  String get trackHealthTitle;

  /// No description provided for @trackHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor your daily activities, workouts, and health metrics to stay on track with your wellness goals.'**
  String get trackHealthDesc;

  /// No description provided for @setGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Goals'**
  String get setGoalsTitle;

  /// No description provided for @setGoalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Define your fitness and health objectives to create a personalized plan that works best for you.'**
  String get setGoalsDesc;

  /// No description provided for @analyzeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze Progress'**
  String get analyzeProgressTitle;

  /// No description provided for @analyzeProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'View detailed insights and charts to understand your health trends and celebrate your achievements.'**
  String get analyzeProgressDesc;

  /// No description provided for @aboutYourself.
  ///
  /// In en, this message translates to:
  /// **'About Yourself'**
  String get aboutYourself;

  /// No description provided for @healthRatingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you describe your current health?'**
  String get healthRatingQuestion;

  /// No description provided for @healthPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get healthPoor;

  /// No description provided for @healthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthFair;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthGood;

  /// No description provided for @healthGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get healthGreat;

  /// No description provided for @healthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthExcellent;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'What are your main goals?'**
  String get yourGoals;

  /// No description provided for @goalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get goalLoseWeight;

  /// No description provided for @goalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get goalBuildMuscle;

  /// No description provided for @goalImproveFitness.
  ///
  /// In en, this message translates to:
  /// **'Improve Fitness'**
  String get goalImproveFitness;

  /// No description provided for @goalBetterSleep.
  ///
  /// In en, this message translates to:
  /// **'Better Sleep'**
  String get goalBetterSleep;

  /// No description provided for @goalEatHealthier.
  ///
  /// In en, this message translates to:
  /// **'Eat Healthier'**
  String get goalEatHealthier;

  /// No description provided for @goalAndAchievement.
  ///
  /// In en, this message translates to:
  /// **'Goals & Achievements'**
  String get goalAndAchievement;

  /// No description provided for @openProfileSetupStep3.
  ///
  /// In en, this message translates to:
  /// **'Open Profile Setup Step 3'**
  String get openProfileSetupStep3;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @waterIntakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntakeTitle;

  /// No description provided for @dailyWaterLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record your daily water intake'**
  String get dailyWaterLogSubtitle;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @dailyWaterLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Log'**
  String get dailyWaterLog;

  /// No description provided for @selectBeverage.
  ///
  /// In en, this message translates to:
  /// **'Select Beverage'**
  String get selectBeverage;

  /// No description provided for @addBeverage.
  ///
  /// In en, this message translates to:
  /// **'Add Beverage'**
  String get addBeverage;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @pleaseSelectBeverage.
  ///
  /// In en, this message translates to:
  /// **'Please select a beverage first'**
  String get pleaseSelectBeverage;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount (ml)'**
  String get pleaseEnterAmount;

  /// No description provided for @beverageAdded.
  ///
  /// In en, this message translates to:
  /// **'Beverage added'**
  String get beverageAdded;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @noActivitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No activities added yet'**
  String get noActivitiesYet;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get editActivity;

  /// No description provided for @activityName.
  ///
  /// In en, this message translates to:
  /// **'Activity Name'**
  String get activityName;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @pick.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get pick;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @sleepLogged.
  ///
  /// In en, this message translates to:
  /// **'Sleep Logged'**
  String get sleepLogged;

  /// No description provided for @mealsLogged.
  ///
  /// In en, this message translates to:
  /// **'Meals Logged'**
  String get mealsLogged;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get meal;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterAnEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterAnEmail;

  /// No description provided for @passwordMinimum6Chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinimum6Chars;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @haveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get haveAnAccount;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @wakeUpTime.
  ///
  /// In en, this message translates to:
  /// **'Wake-up Time'**
  String get wakeUpTime;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Log Sleep'**
  String get logSleep;

  /// No description provided for @lastNight.
  ///
  /// In en, this message translates to:
  /// **'last night'**
  String get lastNight;

  /// No description provided for @addWater.
  ///
  /// In en, this message translates to:
  /// **'Add Water'**
  String get addWater;

  /// No description provided for @selectActivity.
  ///
  /// In en, this message translates to:
  /// **'Select Activity'**
  String get selectActivity;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, Alex!'**
  String get goodMorning;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date {date}'**
  String date(String date);

  /// No description provided for @waterIntakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntakeLabel;

  /// No description provided for @exerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseLabel;

  /// No description provided for @sleepLoggedLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep Logged'**
  String get sleepLoggedLabel;

  /// No description provided for @mealsLoggedLabel.
  ///
  /// In en, this message translates to:
  /// **'Meals Logged'**
  String get mealsLoggedLabel;

  /// No description provided for @todayMood.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Mood'**
  String get todayMood;

  /// No description provided for @todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todayProgress;

  /// No description provided for @todayWeight.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Weight'**
  String get todayWeight;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareData.
  ///
  /// In en, this message translates to:
  /// **'Share Data'**
  String get shareData;

  /// No description provided for @exportToPDF.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPDF;

  /// No description provided for @saveDataAsPDF.
  ///
  /// In en, this message translates to:
  /// **'Save data as PDF file'**
  String get saveDataAsPDF;

  /// No description provided for @shareToOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Share to other apps'**
  String get shareToOtherApps;

  /// No description provided for @noDataToShare.
  ///
  /// In en, this message translates to:
  /// **'No data to share'**
  String get noDataToShare;

  /// No description provided for @errorOccurredMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurredMessage(String error);

  /// No description provided for @noDataToPDF.
  ///
  /// In en, this message translates to:
  /// **'No data to create PDF'**
  String get noDataToPDF;

  /// No description provided for @errorCreatingPDF.
  ///
  /// In en, this message translates to:
  /// **'Error creating PDF: {error}'**
  String errorCreatingPDF(String error);

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy data to clipboard'**
  String get copyToClipboard;

  /// No description provided for @noDataToCopy.
  ///
  /// In en, this message translates to:
  /// **'No data to copy'**
  String get noDataToCopy;

  /// No description provided for @copiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data copied successfully!'**
  String get copiedSuccessfully;

  /// No description provided for @errorCopying.
  ///
  /// In en, this message translates to:
  /// **'Error copying: {error}'**
  String errorCopying(String error);

  /// No description provided for @shareAchievement.
  ///
  /// In en, this message translates to:
  /// **'Share Achievement'**
  String get shareAchievement;

  /// No description provided for @newAchievement.
  ///
  /// In en, this message translates to:
  /// **'New Achievement!'**
  String get newAchievement;

  /// No description provided for @justCompletedChallenge.
  ///
  /// In en, this message translates to:
  /// **'I just completed this challenge in Health Tracking App! 💪'**
  String get justCompletedChallenge;

  /// No description provided for @volumeMl.
  ///
  /// In en, this message translates to:
  /// **'Volume (ml)'**
  String get volumeMl;

  /// No description provided for @todayGlasses.
  ///
  /// In en, this message translates to:
  /// **'Today: {count} glasses'**
  String todayGlasses(num count);

  /// No description provided for @addBeverageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add beverage'**
  String get addBeverageTooltip;

  /// No description provided for @beverageNameHint.
  ///
  /// In en, this message translates to:
  /// **'Beverage name (e.g. water, tea...)'**
  String get beverageNameHint;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @chooseFromList.
  ///
  /// In en, this message translates to:
  /// **'Choose from list'**
  String get chooseFromList;

  /// No description provided for @selectProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Profile Photo'**
  String get selectProfilePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @errorOccurred2.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred2(String error);

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @goalDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalDeletedSuccessfully;

  /// No description provided for @healthTrends.
  ///
  /// In en, this message translates to:
  /// **'Health Trends'**
  String get healthTrends;

  /// No description provided for @profileSetupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Profile setup completed!'**
  String get profileSetupCompleted;

  /// No description provided for @uranusCode.
  ///
  /// In en, this message translates to:
  /// **'Uranus Code'**
  String get uranusCode;

  /// No description provided for @confirmDeleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteGoal(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pleaseEnterGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a goal title'**
  String get pleaseEnterGoalTitle;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @goalAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goal added successfully!'**
  String get goalAddedSuccessfully;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @youtubeChannel.
  ///
  /// In en, this message translates to:
  /// **'Youtube Channel'**
  String get youtubeChannel;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image: {error}'**
  String errorSelectingImage(String error);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @mealDataSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal data saved successfully'**
  String get mealDataSavedSuccessfully;

  /// No description provided for @errorOccurredWithDetails.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurredWithDetails(String error);

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get activeGoals;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @addYourFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Add your first goal'**
  String get addYourFirstGoal;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @drinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get drinkWater;

  /// No description provided for @sleepGoal.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepGoal;

  /// No description provided for @weightGoal.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightGoal;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get hours;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target Value ({unit})'**
  String targetValue(String unit);

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @mealLogging.
  ///
  /// In en, this message translates to:
  /// **'Meal Logging'**
  String get mealLogging;

  /// No description provided for @selectMealTime.
  ///
  /// In en, this message translates to:
  /// **'Select meal time'**
  String get selectMealTime;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @enterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get enterFoodName;

  /// No description provided for @mealPhoto.
  ///
  /// In en, this message translates to:
  /// **'Meal Photo'**
  String get mealPhoto;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @mealDescription.
  ///
  /// In en, this message translates to:
  /// **'Meal Description'**
  String get mealDescription;

  /// No description provided for @enterMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter meal description, e.g., portion size, restaurant, cooking method, etc.'**
  String get enterMealDescription;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get saveMeal;

  /// No description provided for @pleaseEnterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Please enter food name'**
  String get pleaseEnterFoodName;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Image selection error: {error}'**
  String imageSelectionError(String error);

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize your reminder preferences'**
  String get notificationSettingsDescription;

  /// No description provided for @healthReminders.
  ///
  /// In en, this message translates to:
  /// **'Health Reminders'**
  String get healthReminders;

  /// No description provided for @waterReminder.
  ///
  /// In en, this message translates to:
  /// **'Water Reminder'**
  String get waterReminder;

  /// No description provided for @waterReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Remind me to stay hydrated throughout the day'**
  String get waterReminderDescription;

  /// No description provided for @exerciseReminder.
  ///
  /// In en, this message translates to:
  /// **'Exercise Reminder'**
  String get exerciseReminder;

  /// No description provided for @exerciseReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Remind me to exercise regularly'**
  String get exerciseReminderDescription;

  /// No description provided for @sleepReminder.
  ///
  /// In en, this message translates to:
  /// **'Sleep Reminder'**
  String get sleepReminder;

  /// No description provided for @sleepReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Remind me to maintain healthy sleep schedule'**
  String get sleepReminderDescription;

  /// No description provided for @mealLoggingReminder.
  ///
  /// In en, this message translates to:
  /// **'Meal Logging Reminder'**
  String get mealLoggingReminder;

  /// No description provided for @mealLoggingReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Remind me to log my meals'**
  String get mealLoggingReminderDescription;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @resetNotificationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all notification settings to default? This will enable all reminders.'**
  String get resetNotificationConfirmation;

  /// No description provided for @notificationSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Notification settings have been reset to default'**
  String get notificationSettingsReset;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @sleepHours.
  ///
  /// In en, this message translates to:
  /// **'Sleep Hours'**
  String get sleepHours;

  /// No description provided for @waterIntakeML.
  ///
  /// In en, this message translates to:
  /// **'Water Intake (ml)'**
  String get waterIntakeML;

  /// No description provided for @exerciseCalories.
  ///
  /// In en, this message translates to:
  /// **'Exercise (cal)'**
  String get exerciseCalories;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @milliliters.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get milliliters;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'cal'**
  String get calories;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname'**
  String get enterNickname;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select birth date'**
  String get selectBirthDate;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterNickname.
  ///
  /// In en, this message translates to:
  /// **'Please enter your nickname'**
  String get pleaseEnterNickname;

  /// No description provided for @pleaseSelectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please select your birth date'**
  String get pleaseSelectBirthDate;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get pleaseSelectGender;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;
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
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
