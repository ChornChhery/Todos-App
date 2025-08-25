// lib/providers/submission_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import '../models/submission.dart';

enum SortOrder { newest, oldest }

class SubmissionProvider with ChangeNotifier {
  final List<Submission> _submissions = [];
  SortOrder _sortOrder = SortOrder.newest;
  String _searchQuery = '';
  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = fln.FlutterLocalNotificationsPlugin();

  SubmissionProvider() {
    _initNotifications();
    _loadSubmissions();
  }

  // --- Notification Logic ---
  Future<void> _initNotifications() async {
    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    final fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Submission submission) async {
    if (submission.dueDate == null) return;

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      submission.dueDate!,
      tz.local,
    );

    const fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
        fln.AndroidNotificationDetails(
      'due_date_channel',
      'Due Date Reminders',
      channelDescription: 'Reminders for your university tasks.',
      importance: fln.Importance.max,
      priority: fln.Priority.high,
    );

    const fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      submission.id,
      'Task Due Soon!',
      submission.text,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // --- Task Management Logic ---
  String get searchQuery => _searchQuery;

  List<Submission> get submissions {
    final filteredList = _submissions.where((sub) {
      return sub.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filteredList.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return (a.dueDate ?? a.timestamp).compareTo(b.dueDate ?? b.timestamp);
    });

    if (_sortOrder == SortOrder.oldest) {
      return filteredList;
    }
    return filteredList.reversed.toList();
  }

  int get submissionCount => _submissions.where((sub) => !sub.isCompleted).length;

  Future<void> _loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final submissionsJson = prefs.getStringList('submissions') ?? [];
    _submissions.clear();
    for (var jsonString in submissionsJson) {
      _submissions.add(Submission.fromJson(jsonDecode(jsonString)));
    }
    notifyListeners();
  }

  Future<void> _saveSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final submissionsJson = _submissions.map((sub) => jsonEncode(sub.toJson())).toList();
    await prefs.setStringList('submissions', submissionsJson);
  }

  void addSubmission(Submission submission) {
    _submissions.add(submission);
    _saveSubmissions();
    _scheduleNotification(submission);
    notifyListeners();
  }

  void updateSubmission(int id, String newText, DateTime? newDueDate, Priority newPriority) {
    final originalIndex = _submissions.indexWhere((sub) => sub.id == id);
    if (originalIndex != -1) {
      final oldSubmission = _submissions[originalIndex];
      _submissions[originalIndex] = Submission(
        id: oldSubmission.id,
        text: newText,
        timestamp: oldSubmission.timestamp,
        dueDate: newDueDate,
        priority: newPriority,
        isCompleted: oldSubmission.isCompleted,
      );
      _saveSubmissions();
      flutterLocalNotificationsPlugin.cancel(id);
      _scheduleNotification(_submissions[originalIndex]);
      notifyListeners();
    }
  }

  void toggleCompletion(int id, bool value) {
    final originalIndex = _submissions.indexWhere((sub) => sub.id == id);
    if (originalIndex != -1) {
      final oldSubmission = _submissions[originalIndex];
      _submissions[originalIndex] = Submission(
        id: oldSubmission.id,
        text: oldSubmission.text,
        timestamp: oldSubmission.timestamp,
        dueDate: oldSubmission.dueDate,
        priority: oldSubmission.priority,
        isCompleted: value,
      );
      _saveSubmissions();
      flutterLocalNotificationsPlugin.cancel(id);
      notifyListeners();
    }
  }

  void removeSubmission(int id) {
    _submissions.removeWhere((sub) => sub.id == id);
    _saveSubmissions();
    flutterLocalNotificationsPlugin.cancel(id);
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}