// lib/providers/submission_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submission.dart';

enum SortOrder { newest, oldest }

class SubmissionProvider with ChangeNotifier {
  final List<Submission> _submissions = [];
  SortOrder _sortOrder = SortOrder.newest;
  String _searchQuery = '';

  SubmissionProvider() {
    _loadSubmissions();
  }

  String get searchQuery => _searchQuery;

  List<Submission> get submissions {
    // Apply search filter
    final filteredList = _submissions.where((sub) {
      return sub.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Apply sorting
    if (_sortOrder == SortOrder.oldest) {
      return filteredList;
    }
    return filteredList.reversed.toList();
  }

  int get submissionCount => _submissions.length;

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

  void addSubmission(String text) {
    _submissions.add(Submission(text: text, timestamp: DateTime.now()));
    _saveSubmissions();
    notifyListeners();
  }

  void updateSubmission(int index, String newText) {
    final originalIndex = _submissions.indexOf(submissions[index]);
    _submissions[originalIndex] = Submission(
      text: newText,
      timestamp: _submissions[originalIndex].timestamp,
    );
    _saveSubmissions();
    notifyListeners();
  }

  void removeSubmission(int index) {
    final originalIndex = _submissions.indexOf(submissions[index]);
    _submissions.removeAt(originalIndex);
    _saveSubmissions();
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