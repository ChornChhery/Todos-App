// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/submission_provider.dart';
import 'screens/input_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SubmissionProvider(),
      child: MaterialApp(
        title: 'Flutter Provider App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const InputPage(),
      ),
    );
  }
}