import 'package:flutter/material.dart';
import 'player_profile.dart';
import 'add_player_screen.dart';


class EditPlayerScreen extends StatelessWidget {
  final PlayerProfile player;
  final void Function(PlayerProfile) onUpdate;
  final void Function() onDelete;

  const EditPlayerScreen({
    Key? key,
    required this.player,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Player Profile')),
      body: Center(
        child: SingleChildScrollView(
          child: PlayerForm(
            initialPlayer: player,
            actionButtonText: 'Update Player',
            onSubmit: (updatedPlayer) {
              onUpdate(updatedPlayer);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Player updated!')),
              );
              Navigator.pop(context);
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
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
              if (confirm == true) {
                onDelete();
                Navigator.pop(context);
              }
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
