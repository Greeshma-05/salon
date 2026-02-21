import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_settings.dart';

class NotificationSettingsService extends ChangeNotifier {
  static final NotificationSettingsService _instance =
      NotificationSettingsService._internal();
  factory NotificationSettingsService() => _instance;
  NotificationSettingsService._internal() {
    _loadSettings();
  }

  static const String _settingsKey = 'notification_settings';

  NotificationSettings _settings = NotificationSettings.defaultSettings();

  NotificationSettings get settings => _settings;

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = NotificationSettings.fromMap(settingsMap);
      } else {
        // Use default settings if none exist
        _settings = NotificationSettings.defaultSettings();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      _settings = NotificationSettings.defaultSettings();
    }
  }

  /// Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toMap());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  /// Toggle day before reminder setting
  Future<void> toggleDayBefore(bool value) async {
    _settings = _settings.copyWith(dayBeforeReminder: value);
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle two hours before reminder setting
  Future<void> toggleTwoHoursBefore(bool value) async {
    _settings = _settings.copyWith(twoHoursBeforeReminder: value);
    notifyListeners();
    await _saveSettings();
  }

  /// Get current settings
  NotificationSettings getSettings() {
    return _settings;
  }

  /// Reset to default settings
  Future<void> resetToDefault() async {
    _settings = NotificationSettings.defaultSettings();
    notifyListeners();
    await _saveSettings();
  }

  /// Check if any reminder is enabled
  bool get hasAnyReminderEnabled {
    return _settings.dayBeforeReminder || _settings.twoHoursBeforeReminder;
  }

  /// Get summary of enabled reminders
  String get enabledRemindersSummary {
    List<String> enabled = [];

    if (_settings.dayBeforeReminder) {
      enabled.add('Day before');
    }
    if (_settings.twoHoursBeforeReminder) {
      enabled.add('2 hours before');
    }

    if (enabled.isEmpty) {
      return 'No reminders enabled';
    } else if (enabled.length == 1) {
      return enabled[0];
    } else {
      return enabled.join(', ');
    }
  }
}
