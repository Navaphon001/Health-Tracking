import '../l10n/app_localizations.dart';

class AppMessages {
  final AppLocalizations _localizations;
  
  AppMessages(this._localizations);
  
  String get waterLogFailed => _localizations.waterLogFailed;
  
  String waterLogSuccess(String name, num amount) => _localizations.waterLogSuccess(name, amount);
  
  String exerciseLogSuccess(num minutes) => _localizations.exerciseLogSuccess(minutes);
  
  String get activitySavedSuccess => _localizations.activitySavedSuccess;
  
  String get activitySaveFailed => _localizations.activitySaveFailed;
  
  String get activityDeletedSuccess => _localizations.activityDeletedSuccess;
  
  String get activityDeleteFailed => _localizations.activityDeleteFailed;
  
  String get sleepLoggedSuccess => _localizations.sleepLoggedSuccess;
  
  String get sleepLogFailed => _localizations.sleepLogFailed;
}