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

  /// EditPlayerFormLayout is a custom widget for editing a player profile.
  /// It displays the PlayerForm and a full-width Delete Player button below.
  /// The delete button shows a confirmation dialog before deleting.
  @override
  State<EditPlayerFormLayout> createState() => EditPlayerFormLayoutState();
}

class EditPlayerFormLayoutState extends State<EditPlayerFormLayout> {
  // Holds the current player data for editing.
  late PlayerProfile _currentPlayer;

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
  }

  @override
  Widget build(BuildContext context) {
    // Card provides a styled container for the form and buttons.
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PlayerForm handles the input fields and update/cancel actions.
            PlayerForm(
              initialPlayer: _currentPlayer,
              actionButtonText: 'Update Player',
              onSubmit: (updatedPlayer) {
                // Call parent callback to update player profile.
                widget.onUpdate(updatedPlayer);
                // Show a snackbar for feedback.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player updated!')),
                );
                // Pop the edit screen after update.
                Navigator.pop(context);
              },
              onCancel: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            // Delete Player button with confirmation dialog.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // Show confirmation dialog before deleting.
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
                    // Call parent callback to delete player profile.
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