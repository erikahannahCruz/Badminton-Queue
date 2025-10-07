import 'package:flutter/material.dart';
import 'player_profile.dart';
import 'add_player_screen.dart';

class EditPlayerFormLayout extends StatefulWidget {
  final PlayerProfile player;
  final void Function(PlayerProfile) onUpdate;
  final void Function() onDelete;

  const EditPlayerFormLayout({
    Key? key,
    required this.player,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<EditPlayerFormLayout> createState() => EditPlayerFormLayoutState();
}

class EditPlayerFormLayoutState extends State<EditPlayerFormLayout> {
  late PlayerProfile _currentPlayer;

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlayerForm(
              initialPlayer: _currentPlayer,
              actionButtonText: 'Update Player',
              onSubmit: (updatedPlayer) {
                widget.onUpdate(updatedPlayer);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player updated!')),
                );
                Navigator.pop(context);
              },
              onCancel: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
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
                    widget.onDelete();
                  }
                },
                child: const Text('Delete Player'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}