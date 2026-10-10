import 'package:flutter/material.dart';

class AppLanguage {
  Locale locale;
  String language;

  AppLanguage({required this.locale, required this.language});
}

List<AppLanguage> languageList = [
  AppLanguage(locale: const Locale('en'), language: 'English - UK'),
  AppLanguage(locale: const Locale('pl'), language: 'Polski - PL'),
  AppLanguage(locale: const Locale('ru'), language: 'Russian - Ru'),
];
