// lib/screens/input_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/submission_provider.dart';
import '../models/submission.dart';
import 'list_page.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDueDate;
  Priority _selectedPriority = Priority.low;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubmissionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Task Manager'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ListPage()),
                  );
                },
              ),
              if (provider.submissionCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${provider.submissionCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Add a New Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF42A5F5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'Enter task description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => _controller.clear(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _selectedDueDate == null
                                ? 'No due date selected'
                                : 'Due: ${DateFormat('dd MMM yyyy, hh:mm a').format(_selectedDueDate!)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _pickDueDate(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Set Priority:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: Priority.values.map((priority) {
                            return ChoiceChip(
                              label: Text(
                                priority.toString().split('.').last.toUpperCase(),
                                style: TextStyle(
                                  color: _selectedPriority == priority ? Colors.white : null,
                                ),
                              ),
                              selected: _selectedPriority == priority,
                              selectedColor: _getPriorityColor(priority),
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              final newTask = Submission(
                                id: Random().nextInt(1000000), // A simple way to get a unique ID
                                text: _controller.text,
                                timestamp: DateTime.now(),
                                dueDate: _selectedDueDate,
                                priority: _selectedPriority,
                              );
                              provider.addSubmission(newTask);
                              _controller.clear();
                              setState(() {
                                _selectedDueDate = null;
                                _selectedPriority = Priority.low;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Task added successfully!')),
                              );
                            }
                          },
                          child: const Text('Submit Task'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.amber;
      case Priority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}