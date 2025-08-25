// lib/models/submission.dart
import 'dart:convert';

enum Priority { high, medium, low }

class Submission {
  final int id; // Unique ID for each task
  final String text;
  final DateTime timestamp;
  final DateTime? dueDate;
  final Priority priority;
  final bool isCompleted;

  Submission({
    required this.id,
    required this.text,
    required this.timestamp,
    this.dueDate,
    this.priority = Priority.low,
    this.isCompleted = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.index,
        'isCompleted': isCompleted,
      };

  // Create from JSON
  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as int,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: Priority.values[json['priority'] as int],
      isCompleted: json['isCompleted'] as bool,
    );
  }
}