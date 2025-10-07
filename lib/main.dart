import 'package:hive_flutter/hive_flutter.dart';
import 'player_profile.dart';
import 'all_players_screen.dart';
import 'package:flutter/material.dart';


/// Main entry point for the Badminton Queue app.
/// Initializes Hive for local storage and registers the PlayerProfile adapter.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter engine is initialized
  await Hive.initFlutter(); // Initializes Hive for Flutter
  Hive.registerAdapter(PlayerProfileAdapter()); // Registers the Hive adapter for PlayerProfile
  await Hive.openBox<PlayerProfile>('players'); // Opens the Hive box for player profiles
  runApp(const MyApp()); // Runs the main app widget
}


/// Root widget for the Badminton Queue app.
/// Sets up the theme and home screen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Badminton Queue',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AllPlayersScreen(), // Main screen showing all players
    );
  }
}
