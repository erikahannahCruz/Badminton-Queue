import 'package:flutter/material.dart';
import 'all_players_screen.dart';
import 'all_games_screen.dart';
import 'user_settings_screen.dart';

/// HomeScreen contains the bottom navigation bar with three tabs:
/// Games, Players, and User Settings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AllGamesScreen(),
    const AllPlayersScreen(),
    const UserSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
