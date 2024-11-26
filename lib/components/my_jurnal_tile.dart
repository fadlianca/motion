import 'dart:io';
import 'package:flutter/material.dart';
import '../models/jurnal.dart';

class MyJournalTile extends StatelessWidget {
  final Journal journal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyJournalTile({
    super.key,
    required this.journal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          journal.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              journal.date.toLocal().toString(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              journal.content.length > 50
                  ? '${journal.content.substring(0, 50)}...'
                  : journal.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (journal.imagePath != null) ...[
              const SizedBox(height: 8),
              Image.file(
                File(journal.imagePath!),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
            ],
          ],
        ),
        onTap: onEdit,
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
