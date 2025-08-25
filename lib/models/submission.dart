// lib/models/submission.dart
import 'dart:convert';

class Submission {
  final String text;
  final DateTime timestamp;

  Submission({required this.text, required this.timestamp});

  // Convert a Submission object to a JSON map
  Map<String, dynamic> toJson() => {
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  // Create a Submission object from a JSON map
  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}