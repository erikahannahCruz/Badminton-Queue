/// AllPlayersScreen displays a searchable, swipe-to-delete list of player profiles.
/// Users can add, edit, or delete players. Data is stored in Hive local storage.
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'player_profile.dart';
import 'add_player_screen.dart';
import 'edit_player_screen.dart';

class AllPlayersScreen extends StatefulWidget {
  /// Main screen widget for listing all players
  const AllPlayersScreen({Key? key}) : super(key: key);

  @override
  State<AllPlayersScreen> createState() => _AllPlayersScreenState();
}

class _AllPlayersScreenState extends State<AllPlayersScreen> {
  /// Current search query for filtering players
  String searchQuery = '';

  /// Returns filtered list of players from Hive box based on search query
  List<PlayerProfile> filteredPlayers(List<PlayerProfile> players) {
    if (searchQuery.isEmpty) return players;
    return players.where((p) =>
      p.nickname.toLowerCase().contains(searchQuery.toLowerCase()) ||
      p.fullName.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  /// Deletes a player from Hive box
  void _deletePlayer(int index, List<PlayerProfile> players) async {
    var box = Hive.box<PlayerProfile>('players');
    await box.deleteAt(index);
  }

  /// Navigates to AddPlayerScreen and adds new player to Hive box
  void _navigateToAddPlayer() async {
    final newPlayer = await Navigator.push<PlayerProfile>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPlayerScreen(),
      ),
    );
    if (newPlayer != null) {
      var box = Hive.box<PlayerProfile>('players');
      await box.add(newPlayer);
    }
  }

  /// Navigates to EditPlayerScreen and updates or deletes player in Hive box
  void _navigateToEditPlayer(PlayerProfile player, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlayerScreen(
          player: player,
          onUpdate: (p) async {
            var box = Hive.box<PlayerProfile>('players');
            await box.putAt(index, p);
          },
          onDelete: () async {
            var box = Hive.box<PlayerProfile>('players');
            await box.deleteAt(index);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  /// Builds the main UI: search bar, player list, and add button
  @override
  Widget build(BuildContext context) {
    // Scaffold provides the app bar, search bar, player list, and add button.
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Players', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _navigateToAddPlayer,
            tooltip: 'Add New Player',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or nick name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<PlayerProfile>('players').listenable(),
              builder: (context, Box<PlayerProfile> box, _) {
                final players = box.values.toList();
                final filtered = filteredPlayers(players);
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final player = filtered[index];
                    return Dismissible(
                      key: Key(player.nickname + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Player'),
                            content: const Text('Are you sure you want to delete this player?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) => _deletePlayer(index, filtered),
                      child: GestureDetector(
                        onTap: () => _navigateToEditPlayer(player, index),
                        child: Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                _buildAvatar(player.nickname, index),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(player.nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(player.fullName, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                      Text(_levelStrengthLabel(player), style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  /// Builds a colored avatar with the player's initial
  Widget _buildAvatar(String nickname, int index) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.pink, Colors.orange, Colors.purple];
    final color = colors[index % colors.length];
    return CircleAvatar(
      backgroundColor: color,
      child: Text(nickname.isNotEmpty ? nickname[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      radius: 22,
    );
  }

  /// Returns a formatted string for player's level and strength
  String _levelStrengthLabel(PlayerProfile player) {
    final levels = ['INTERMEDIATE', 'LEVEL G', 'LEVEL F', 'LEVEL E', 'LEVEL D', 'OPEN'];
    final strengths = ['W', 'M', 'S'];
    String level = levels[player.levelIndex % levels.length];
    String strength = strengths[player.strengthIndex % strengths.length];
    // Example: Strong F, Mid E
    return 'Strong $level, Mid $level'; // You can customize this to show both strength and level as needed
  }
}
