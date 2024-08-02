// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// class AppLocalizations {
//   final Locale locale;
//   AppLocalizations(this.locale);
//
//
//
//   // Singleton pattern to ensure only one instance is used
//   static AppLocalizations? _instance;
//
//   // Getter for the singleton instance
//   static AppLocalizations of(BuildContext context) {
//     final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
//     assert(instance != null, 'No AppLocalizations found in context');
//     return instance!;
//   }
//
//   static const LocalizationsDelegate<AppLocalizations> delegate =
//   _AppLocalizationsDelegate();
//
//   late Map<String, String> _localizedStrings;
//
//   Future<bool> load() async {
//     final jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}_${locale.countryCode}.json');
//     final Map<String, dynamic> jsonMap = json.decode(jsonString);
//     _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
//     return true;
//   }
//
//   String translate(String key) {
//     return _localizedStrings[key] ?? key;
//   }
// }
//
// class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();
//
//   @override
//   bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);
//
//   @override
//   Future<AppLocalizations> load(Locale locale) async {
//     final localizations = AppLocalizations(locale);
//     await localizations.load();
//     return localizations;
//   }
//
//   @override
//   bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
// }
