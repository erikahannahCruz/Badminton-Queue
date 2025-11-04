import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_game_screen.dart';
import 'view_game_screen.dart';
import 'game_utils.dart';

/// AllGamesScreen lists all saved games, allows search, swipe-to-delete and adding.
class AllGamesScreen extends StatefulWidget {
  const AllGamesScreen({Key? key}) : super(key: key);

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  String searchQuery = '';

  List<Map> _gamesFromBox(Box box) {
    return box.values.cast<Map>().toList();
  }

  void _deleteGame(int index) async {
    final box = Hive.box('games');
    await box.deleteAt(index);
  }

  void _navigateToAddGame() async {
    final newGame = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGameScreen()),
    );
    if (newGame != null) {
      // UI will update because box listener is used
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('games');
    return Scaffold(
      appBar: AppBar(title: const Text('All Games')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by game title or date',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<dynamic> b, _) {
                final games = _gamesFromBox(b);
                final filtered = games.where((g) {
                  final title = (g['title'] ?? '').toString().toLowerCase();
                  return title.contains(searchQuery.toLowerCase()) || g['createdAt']?.toString().contains(searchQuery) == true;
                }).toList();
                if (filtered.isEmpty) return const Center(child: Text('No games'));
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final g = filtered[index];
                    final title = formatGameTitle(g);
                    final playerKeys = (g['playerKeys'] as List?)?.cast<dynamic>() ?? [];
                    final players = playerKeys.length;
                    // compute total cost: court cost(s) + shuttle price
                    double totalCourtCost = 0.0;
                    if (g['schedules'] != null) {
                      for (final s in g['schedules']) {
                        final start = DateTime.parse(s['start']);
                        final end = DateTime.parse(s['end']);
                        final hours = end.difference(start).inMinutes / 60.0;
                        totalCourtCost += (g['courtRate'] ?? 0.0) * hours;
                      }
                    }
                    final shuttle = (g['shuttlePrice'] ?? 0.0) as double;
                    final totalCost = totalCourtCost + shuttle;

                    return Dismissible(
                      key: Key((g['createdAt'] ?? index.toString()).toString() + index.toString()),
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
                            title: const Text('Delete Game'),
                            content: const Text('Are you sure you want to delete this game?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) => _deleteGame(index),
                      child: ListTile(
                        title: Text(title.toString()),
                        subtitle: Text('Players: $players  •  Total: ₱${totalCost.toStringAsFixed(2)}'),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewGameScreen(game: g, gameIndex: index))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGame,
        child: const Icon(Icons.add),
        tooltip: 'Add New Game',
      ),
    );
  }
}
