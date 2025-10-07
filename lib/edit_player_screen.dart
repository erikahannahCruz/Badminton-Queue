import 'package:flutter/material.dart';
import 'player_profile.dart';
import 'add_player_screen.dart';
import '_edit_player_form_layout.dart';


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
          child: EditPlayerFormLayout(
            player: player,
            onUpdate: onUpdate,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }
}
