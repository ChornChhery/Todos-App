// lib/screens/list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add to pubspec.yaml
import '../providers/submission_provider.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitted Items'),
        actions: [
          Consumer<SubmissionProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<SortOrder>(
                icon: const Icon(Icons.sort),
                onSelected: (SortOrder result) {
                  provider.setSortOrder(result);
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
              );
            },
          ),
        ],
      ),
      body: Consumer<SubmissionProvider>(
        builder: (context, provider, child) {
          if (provider.submissions.isEmpty) {
            return const Center(child: Text('No submissions yet.'));
          }

          return ListView.builder(
            itemCount: provider.submissions.length,
            itemBuilder: (context, index) {
              final submission = provider.submissions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(submission.text),
                  subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(submission.timestamp)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, provider, index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, SubmissionProvider provider, int index) {
    final TextEditingController editController = TextEditingController(text: provider.submissions[index].text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Submission'),
          content: TextField(
            controller: editController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  provider.updateSubmission(index, editController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}