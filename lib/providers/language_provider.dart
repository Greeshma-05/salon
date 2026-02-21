import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  String getDisplayLanguage(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ml':
        return 'Malayalam';
      default:
        return 'English';
    }
  }
}
