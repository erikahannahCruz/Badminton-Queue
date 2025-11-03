import 'package:flutter/material.dart';

/// Simple ViewGameScreen that displays details of a saved game map.
class ViewGameScreen extends StatelessWidget {
  final Map game;
  const ViewGameScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text((game['title'] ?? 'Game').toString())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Court: ${game['courtName'] ?? ''}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Court rate (per hour): ₱${(game['courtRate'] ?? 0.0).toString()}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Shuttle price: ₱${(game['shuttlePrice'] ?? 0.0).toString()}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            const Text('Schedules', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (game['schedules'] != null)
              ...((game['schedules'] as List).map((s) {
                final start = DateTime.parse(s['start']);
                final end = DateTime.parse(s['end']);
                return Card(
                  child: ListTile(
                    title: Text('Court ${s['court']}'),
                    subtitle: Text('${start.toLocal()} - ${end.toLocal()}'),
                  ),
                );
              }).toList()),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
