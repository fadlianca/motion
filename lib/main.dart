import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bottom_nav.dart';
import 'database/habit_database.dart';
import 'database/jurnal_database.dart';
import 'models/app_settings.dart';
import 'models/habit.dart';
import 'models/jurnal.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive, register adapters, and initialize databases
  await _initializeHiveAndDatabases();

  // Run the app with MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitDatabase()),
        ChangeNotifierProvider(create: (_) => JournalDatabase()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialize Hive, register adapters, and initialize the databases
Future<void> _initializeHiveAndDatabases() async {
  try {
    await Hive.initFlutter();

    // Register Hive adapters only once
    await _registerHiveAdapters();

    // Initialize databases with proper error handling
    await _initializeHabitDatabase();
    await _initializeJournalDatabase();

    debugPrint(
        'Hive initialized, adapters registered, and databases initialized.');
  } catch (e) {
    debugPrint('Error during initialization: $e');
    rethrow;
  }
}

/// Register Hive adapters
Future<void> _registerHiveAdapters() async {
  if (!Hive.isAdapterRegistered(HabitAdapter().typeId)) {
    Hive.registerAdapter(HabitAdapter());
  }
  if (!Hive.isAdapterRegistered(AppSettingsAdapter().typeId)) {
    Hive.registerAdapter(AppSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(JournalAdapter().typeId)) {
    Hive.registerAdapter(JournalAdapter());
  }
}

/// Initialize the HabitDatabase with error handling
Future<void> _initializeHabitDatabase() async {
  final habitDatabase = HabitDatabase();
  await habitDatabase.init();
  await habitDatabase.saveFirstLaunchDate();
  debugPrint('HabitDatabase initialized successfully.');
}

/// Initialize the JournalDatabase with error handling
Future<void> _initializeJournalDatabase() async {
  final journalDatabase = JournalDatabase();
  await journalDatabase.init();
  debugPrint('JournalDatabase initialized successfully.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BottomNavBar(initialIndex: 0),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
