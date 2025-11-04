import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'player_profile.dart';
import 'edit_game_screen.dart';
import 'game_utils.dart';

/// ViewGameScreen displays game details, players, payment calculations, edit/delete buttons.
class ViewGameScreen extends StatefulWidget {
  final Map game;
  final int gameIndex;
  const ViewGameScreen({Key? key, required this.game, required this.gameIndex}) : super(key: key);

  @override
  State<ViewGameScreen> createState() => _ViewGameScreenState();
}

class _ViewGameScreenState extends State<ViewGameScreen> {
  late Map _game;

  @override
  void initState() {
    super.initState();
    _game = Map.from(widget.game);
  }

  void _refreshGame() {
    final box = Hive.box('games');
    if (widget.gameIndex < box.length) {
      setState(() {
        _game = Map.from(box.getAt(widget.gameIndex) as Map);
      });
    }
  }

  void _deleteGame() async {
    final confirm = await showDialog<bool>(
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
    if (confirm == true) {
      final box = Hive.box('games');
      await box.deleteAt(widget.gameIndex);
      Navigator.pop(context);
    }
  }

  void _editGame() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => EditGameScreen(game: _game, gameIndex: widget.gameIndex)),
    );
    if (updated == true) {
      _refreshGame();
    }
  }

  double _calculateTotalCourtCost() {
    double total = 0.0;
    if (_game['schedules'] != null) {
      for (final s in _game['schedules']) {
        final start = DateTime.parse(s['start']);
        final end = DateTime.parse(s['end']);
        final hours = end.difference(start).inMinutes / 60.0;
        total += (_game['courtRate'] ?? 0.0) * hours;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final divideEqually = _game['divideEqually'] ?? true;
    final playerKeys = (_game['playerKeys'] as List?)?.cast<dynamic>() ?? [];
    final playersBox = Hive.box<PlayerProfile>('players');
    final players = playerKeys.map((k) => playersBox.get(k)).whereType<PlayerProfile>().toList();
    final playerCount = players.length;

    final courtCost = _calculateTotalCourtCost();
    final shuttleCost = (_game['shuttlePrice'] ?? 0.0) as double;
    final totalCost = courtCost + shuttleCost;

    // Payment logic
    String paymentInfo = '';
    if (playerCount == 0) {
      paymentInfo = 'No players assigned';
    } else if (divideEqually) {
      final perPlayer = totalCost / playerCount;
      paymentInfo = 'Each player pays: ₱${perPlayer.toStringAsFixed(2)}';
    } else {
      // Specific payers for court and shuttle
      final courtPayers = (_game['courtPayers'] as List?)?.cast<dynamic>() ?? [];
      final shuttlePayers = (_game['shuttlePayers'] as List?)?.cast<dynamic>() ?? [];
      final courtPayerNames = courtPayers.map((k) {
        final p = playersBox.get(k);
        return p?.nickname ?? 'Unknown';
      }).join(', ');
      final shuttlePayerNames = shuttlePayers.map((k) {
        final p = playersBox.get(k);
        return p?.nickname ?? 'Unknown';
      }).join(', ');
      paymentInfo = 'Court (₱${courtCost.toStringAsFixed(2)}): ${courtPayerNames.isEmpty ? 'None' : courtPayerNames}\n'
          'Shuttle (₱${shuttleCost.toStringAsFixed(2)}): ${shuttlePayerNames.isEmpty ? 'None' : shuttlePayerNames}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(formatGameTitle(_game)),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editGame, tooltip: 'Edit'),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteGame, tooltip: 'Delete'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Court: ${_game['courtName'] ?? ''}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Court rate (per hour): ₱${(_game['courtRate'] ?? 0.0).toString()}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Shuttle price: ₱${(_game['shuttlePrice'] ?? 0.0).toString()}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(value: divideEqually, onChanged: null), // non-editable
                const Text('Divide the court equally among players'),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Schedules', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_game['schedules'] != null)
              ...(((_game['schedules'] as List).map((s) {
                final start = DateTime.parse(s['start']);
                final end = DateTime.parse(s['end']);
                return Card(
                  child: ListTile(
                    title: Text('Court ${s['court']}'),
                    subtitle: Text('${start.toLocal()} - ${end.toLocal()}'),
                  ),
                );
              }).toList())),
            const SizedBox(height: 12),
            const Text('Players', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (players.isEmpty)
              const Text('No players assigned', style: TextStyle(color: Colors.grey))
            else
              ...players.map((p) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(p.nickname),
                subtitle: Text(p.fullName),
              )).toList(),
            const SizedBox(height: 12),
            const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(paymentInfo, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
