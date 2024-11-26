import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../components/my_jurnal_tile.dart';
import '../database/jurnal_database.dart';
import '../models/jurnal.dart';
import '../util/jurnal_util.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late JournalDatabase journalDatabase;

  @override
  void initState() {
    super.initState();
    journalDatabase = JournalDatabase();
    journalDatabase.init(); // Ensure that Hive is initialized correctly.
  }

  // Show bottom sheet to create or edit a journal entry
  void _showJournalForm({Journal? existingJournal}) {
    final titleController = TextEditingController(
      text: existingJournal?.title ?? '',
    );
    final contentController = TextEditingController(
      text: existingJournal?.content ?? '',
    );
    String? imagePath = existingJournal?.imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final pickedImagePath = await JournalUtils.pickImage();
                      if (pickedImagePath != null) {
                        setState(() {
                          imagePath = pickedImagePath;
                        });
                      }
                    },
                    child: const Text('Pick Image'),
                  ),
                  if (imagePath != null) ...[
                    const SizedBox(width: 10),
                    const Text('Image selected'),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!JournalUtils.validateInputs(
                      titleController.text, contentController.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  try {
                    if (existingJournal == null) {
                      // Create a new journal
                      await journalDatabase.createJournal(
                        titleController.text,
                        contentController.text,
                        imagePath: imagePath,
                      );
                    } else {
                      // Update an existing journal
                      final updatedJournal = existingJournal.copyWith(
                        title: titleController.text,
                        content: contentController.text,
                        imagePath: imagePath,
                      );

                      // Update the journal only if there's a real change
                      if (updatedJournal.content != existingJournal.content ||
                          updatedJournal.title != existingJournal.title ||
                          updatedJournal.imagePath !=
                              existingJournal.imagePath) {
                        await journalDatabase.updateJournal(
                          updatedJournal
                              .key!, // Use the correct key for updating
                          updatedJournal.content,
                          updatedJournal.title, // Update title as well
                          updatedJournal
                              .imagePath, // Update image path if changed
                        );
                      }
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Save Journal'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to build the journal list
  Widget _buildJournalList() {
    return ValueListenableBuilder<Box<Journal>>(
      valueListenable: Hive.box<Journal>('journals').listenable(),
      builder: (context, box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text('No journals available.'));
        }

        final journals = box.values.toList().cast<Journal>();
        return ListView.builder(
          itemCount: journals.length,
          itemBuilder: (context, index) {
            final journal = journals[index];
            return MyJournalTile(
              journal: journal,
              onEdit: () async {
                _showJournalForm(existingJournal: journal);
              },
              onDelete: () async {
                try {
                  await journalDatabase
                      .deleteJournal(journal.key!); // Use journal.key
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journal deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Entries')),
      body: _buildJournalList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJournalForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
