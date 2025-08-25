// lib/providers/submission_provider.dart
import 'package:flutter/material.dart';
import '../models/submission.dart';

enum SortOrder { newest, oldest }

class SubmissionProvider with ChangeNotifier {
  final List<Submission> _submissions = [];
  SortOrder _sortOrder = SortOrder.newest;

  List<Submission> get submissions {
    if (_sortOrder == SortOrder.oldest) {
      return List.from(_submissions); // Return a copy
    }
    return _submissions.reversed.toList();
  }

  int get submissionCount => _submissions.length;

  void addSubmission(String text) {
    _submissions.add(Submission(text: text, timestamp: DateTime.now()));
    notifyListeners();
  }

  void updateSubmission(int index, String newText) {
    if (index >= 0 && index < _submissions.length) {
      // Need to find the correct index based on the current sort order
      final sortedList = submissions;
      final originalIndex = _submissions.indexOf(sortedList[index]);
      
      _submissions[originalIndex] = Submission(
        text: newText,
        timestamp: _submissions[originalIndex].timestamp,
      );
      notifyListeners();
    }
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }
}