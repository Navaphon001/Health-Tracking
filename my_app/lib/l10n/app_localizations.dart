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

  /// No description provided for @openProfileSetupStep3.
  ///
  /// In en, this message translates to:
  /// **'Open Profile Setup Step 3'**
  String get openProfileSetupStep3;
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
