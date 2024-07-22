import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizedResources {
  final Locale locale;

  LocalizedResources(this.locale);

  static LocalizedResources? of(BuildContext context) {
    return Localizations.of<LocalizedResources>(context, LocalizedResources);
  }

  static const LocalizationsDelegate<LocalizedResources> delegate = _LocalizedResourcesDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '** $key not found';
  }
}

class _LocalizedResourcesDelegate extends LocalizationsDelegate<LocalizedResources> {
  const _LocalizedResourcesDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<LocalizedResources> load(Locale locale) async {
    LocalizedResources localizations = LocalizedResources(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_LocalizedResourcesDelegate old) => false;
}
