// lib/screens/list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/submission_provider.dart';
import '../models/submission.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<SubmissionProvider>(context, listen: false).setSearchQuery('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOrder result) {
              Provider.of<SubmissionProvider>(context, listen: false).setSortOrder(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOrder>>[
              const PopupMenuItem<SortOrder>(
                value: SortOrder.newest,
                child: Text('Newest to Oldest'),
              ),
              const PopupMenuItem<SortOrder>(
                value: SortOrder.oldest,
                child: Text('Oldest to Newest'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (query) {
                Provider.of<SubmissionProvider>(context, listen: false).setSearchQuery(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<SubmissionProvider>(
              builder: (context, provider, child) {
                final submissions = provider.submissions;
                if (submissions.isEmpty && provider.searchQuery.isEmpty) {
                  return const Center(child: Text('No tasks added yet.'));
                } else if (submissions.isEmpty && provider.searchQuery.isNotEmpty) {
                  return const Center(child: Text('No matching results.'));
                }

                return ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final submission = submissions[index];
                    return Dismissible(
                      key: ValueKey(submission.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        provider.removeSubmission(submission.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Task "${submission.text}" deleted')),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Checkbox(
                            value: submission.isCompleted,
                            onChanged: (bool? value) {
                              provider.toggleCompletion(submission.id, value ?? false);
                            },
                          ),
                          title: Text(
                            submission.text,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: submission.isCompleted ? TextDecoration.lineThrough : null,
                              color: submission.isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (submission.dueDate != null)
                                Text(
                                  'Due: ${DateFormat('dd MMM yyyy, hh:mm a').format(submission.dueDate!)}',
                                  style: TextStyle(
                                    color: (submission.dueDate!.isBefore(DateTime.now()) && !submission.isCompleted)
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                              Text(
                                'Priority: ${submission.priority.toString().split('.').last.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(submission.priority),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () => _showEditDialog(context, provider, submission),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  provider.removeSubmission(submission.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Task "${submission.text}" deleted')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, SubmissionProvider provider, Submission submission) {
    final TextEditingController editController = TextEditingController(text: submission.text);
    DateTime? tempDueDate = submission.dueDate;
    Priority tempPriority = submission.priority;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Update task here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tempDueDate == null
                            ? 'No due date selected'
                            : 'Due: ${DateFormat('dd MMM yyyy, hh:mm a').format(tempDueDate!)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempDueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(tempDueDate ?? DateTime.now()),
                            );
                            if (time != null) {
                              setState(() {
                                tempDueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              color: tempPriority == priority ? Colors.white : null,
                            ),
                          ),
                          selected: tempPriority == priority,
                          selectedColor: _getPriorityColor(priority),
                          onSelected: (bool selected) {
                            setState(() {
                              tempPriority = priority;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editController.text.isNotEmpty) {
                      provider.updateSubmission(submission.id, editController.text, tempDueDate, tempPriority);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}