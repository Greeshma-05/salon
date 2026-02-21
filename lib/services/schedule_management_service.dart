import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/working_slot.dart';
import '../models/leave.dart';

class ScheduleManagementService extends ChangeNotifier {
  static final ScheduleManagementService _instance =
      ScheduleManagementService._internal();
  factory ScheduleManagementService() => _instance;
  ScheduleManagementService._internal() {
    _loadSchedules();
    _loadLeaves();
  }

  // Storage keys
  static const String _schedulesKey = 'stylist_schedules';
  static const String _leavesKey = 'stylist_leaves';

  // In-memory storage
  final Map<String, List<WorkingSlot>> _stylistSchedules = {};
  final List<Leave> _leaves = [];

  final _schedulesController =
      StreamController<Map<String, List<WorkingSlot>>>.broadcast();
  final _leavesController = StreamController<List<Leave>>.broadcast();

  Stream<Map<String, List<WorkingSlot>>> get schedulesStream =>
      _schedulesController.stream;
  Stream<List<Leave>> get leavesStream => _leavesController.stream;

  // Load schedules from SharedPreferences
  Future<void> _loadSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getString(_schedulesKey);

      if (schedulesJson != null) {
        final Map<String, dynamic> decoded = json.decode(schedulesJson);
        _stylistSchedules.clear();
        decoded.forEach((stylistId, slots) {
          _stylistSchedules[stylistId] = (slots as List)
              .map((slot) => WorkingSlot.fromJson(slot))
              .toList();
        });
        _schedulesController.add(_stylistSchedules);
      }
    } catch (e) {
      debugPrint('Error loading schedules: $e');
    }
  }

  // Load leaves from SharedPreferences
  Future<void> _loadLeaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leavesJson = prefs.getString(_leavesKey);

      if (leavesJson != null) {
        final List<dynamic> decoded = json.decode(leavesJson);
        _leaves.clear();
        _leaves.addAll(decoded.map((leave) => Leave.fromJson(leave)));
        _leavesController.add(_leaves);
      }
    } catch (e) {
      debugPrint('Error loading leaves: $e');
    }
  }

  // Save schedules to SharedPreferences
  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};
      _stylistSchedules.forEach((stylistId, slots) {
        toSave[stylistId] = slots.map((slot) => slot.toJson()).toList();
      });
      await prefs.setString(_schedulesKey, json.encode(toSave));
      _schedulesController.add(_stylistSchedules);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving schedules: $e');
    }
  }

  // Save leaves to SharedPreferences
  Future<void> _saveLeaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final leavesJson = _leaves.map((leave) => leave.toJson()).toList();
      await prefs.setString(_leavesKey, json.encode(leavesJson));
      _leavesController.add(_leaves);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving leaves: $e');
    }
  }

  // Set working hours for a stylist
  Future<void> setWorkingHours(
    String stylistId,
    List<WorkingSlot> workingHours,
  ) async {
    _stylistSchedules[stylistId] = workingHours;
    await _saveSchedules();
    debugPrint('Working hours set for stylist $stylistId: $workingHours');
  }

  // Get working hours for a stylist
  List<WorkingSlot> getWorkingHours(String stylistId) {
    return _stylistSchedules[stylistId] ?? [];
  }

  // Check if stylist is working on a specific day and time
  bool isStylistWorking(String stylistId, String day, String time) {
    final workingHours = _stylistSchedules[stylistId];
    if (workingHours == null || workingHours.isEmpty) {
      return true; // If no schedule set, assume available
    }

    final daySlot = workingHours.where((slot) => slot.day == day).firstOrNull;
    if (daySlot == null) {
      return false; // Not working on this day
    }

    return daySlot.isTimeInSlot(time);
  }

  // Add leave for a stylist
  Future<void> addLeave(Leave leave) async {
    _leaves.add(leave);
    await _saveLeaves();
    debugPrint('Leave added: $leave');
  }

  // Remove leave
  Future<void> removeLeave(String leaveId) async {
    _leaves.removeWhere((leave) => leave.id == leaveId);
    await _saveLeaves();
    debugPrint('Leave removed: $leaveId');
  }

  // Get all leaves for a stylist
  List<Leave> getStylistLeaves(String stylistId) {
    return _leaves.where((leave) => leave.stylistId == stylistId).toList();
  }

  // Check if stylist is on leave on a specific date
  bool isStylistOnLeave(String stylistId, DateTime date) {
    final stylistLeaves = getStylistLeaves(stylistId);
    return stylistLeaves.any(
      (leave) => leave.isApproved && leave.isDateOnLeave(date),
    );
  }

  // Check if stylist can accept booking (considers working hours and leaves)
  bool canAcceptBooking(String stylistId, DateTime date, String timeSlot) {
    // Check if on leave
    if (isStylistOnLeave(stylistId, date)) {
      return false;
    }

    // Get day name from date
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[date.weekday - 1];

    // Extract time from time slot (e.g., "09:00 AM - 10:00 AM" -> "09:00")
    String time = timeSlot;
    if (timeSlot.contains(' - ')) {
      time = timeSlot.split(' - ')[0].trim();
    }
    if (time.contains(' ')) {
      time = time.split(' ')[0].trim();
    }

    // Convert 12-hour to 24-hour format if needed
    if (timeSlot.toUpperCase().contains('PM') && !time.startsWith('12')) {
      final hour = int.parse(time.split(':')[0]);
      time = '${hour + 12}:${time.split(':')[1]}';
    } else if (timeSlot.toUpperCase().contains('AM') && time.startsWith('12')) {
      time = '00:${time.split(':')[1]}';
    }

    // Check working hours
    return isStylistWorking(stylistId, dayName, time);
  }

  // Get all leaves
  List<Leave> getAllLeaves() {
    return List.unmodifiable(_leaves);
  }

  // Get upcoming leaves
  List<Leave> getUpcomingLeaves() {
    final now = DateTime.now();
    return _leaves.where((leave) => leave.endDate.isAfter(now)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  // Get default working hours template
  List<WorkingSlot> getDefaultWorkingHours() {
    return [
      WorkingSlot(day: 'Monday', startTime: '09:00', endTime: '18:00'),
      WorkingSlot(day: 'Tuesday', startTime: '09:00', endTime: '18:00'),
      WorkingSlot(day: 'Wednesday', startTime: '09:00', endTime: '18:00'),
      WorkingSlot(day: 'Thursday', startTime: '09:00', endTime: '18:00'),
      WorkingSlot(day: 'Friday', startTime: '09:00', endTime: '18:00'),
      WorkingSlot(day: 'Saturday', startTime: '10:00', endTime: '16:00'),
    ];
  }

  @override
  void dispose() {
    _schedulesController.close();
    _leavesController.close();
    super.dispose();
  }
}
