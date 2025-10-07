import 'package:flutter/material.dart';
import 'player_profile.dart';


class PlayerForm extends StatefulWidget {
  final PlayerProfile? initialPlayer;
  final String actionButtonText;
  final void Function(PlayerProfile player) onSubmit;
  final void Function()? onDelete;
  final void Function()? onCancel;

  const PlayerForm({
    Key? key,
    this.initialPlayer,
    required this.actionButtonText,
    required this.onSubmit,
    this.onDelete,
    this.onCancel,
  }) : super(key: key);

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _fullNameController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _remarksController;
  int _levelIndex = 1;
  int _strengthIndex = 1;

  final List<String> levels = [
    'INTERMEDIATE', 'LEVEL G', 'LEVEL F', 'LEVEL E', 'LEVEL D', 'OPEN'
  ];
  final List<String> strengths = ['W', 'M', 'S'];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialPlayer?.nickname ?? '');
    _fullNameController = TextEditingController(text: widget.initialPlayer?.fullName ?? '');
    _contactController = TextEditingController(text: widget.initialPlayer?.contactNumber ?? '');
    _emailController = TextEditingController(text: widget.initialPlayer?.email ?? '');
    _addressController = TextEditingController(text: widget.initialPlayer?.address ?? '');
    _remarksController = TextEditingController(text: widget.initialPlayer?.remarks ?? '');
    _levelIndex = widget.initialPlayer?.levelIndex ?? 1;
    _strengthIndex = widget.initialPlayer?.strengthIndex ?? 1;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final player = PlayerProfile(
        nickname: _nicknameController.text,
        fullName: _fullNameController.text,
        contactNumber: _contactController.text,
        email: _emailController.text,
        address: _addressController.text,
        remarks: _remarksController.text,
        levelIndex: _levelIndex,
        strengthIndex: _strengthIndex,
      );
      widget.onSubmit(player);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nicknameController, 'NICKNAME', Icons.person, (v) => v == null || v.isEmpty ? 'Required' : null),
              _buildTextField(_fullNameController, 'FULL NAME', Icons.person_outline, (v) => v == null || v.isEmpty ? 'Required' : null),
              _buildTextField(_contactController, 'MOBILE NUMBER', Icons.phone, (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!RegExp(r'^\d+$').hasMatch(v)) {
                  return 'Numbers only';
                }
                return null;
              }, keyboardType: TextInputType.number),
              _buildTextField(_emailController, 'EMAIL ADDRESS', Icons.email, (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!RegExp(r'^[\w-.]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v)) {
                  return 'Invalid email';
                }
                return null;
              }, keyboardType: TextInputType.emailAddress),
              _buildTextField(_addressController, 'HOME ADDRESS', Icons.location_on, null, maxLines: 2),
              _buildTextField(_remarksController, 'REMARKS', Icons.menu_book, null, maxLines: 2),
              const SizedBox(height: 16),
              _buildLevelSlider(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.actionButtonText),
                  ),
                  if (widget.onCancel != null)
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: widget.onDelete,
                      child: const Text('Delete Player', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? Function(String?)? validator, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildLevelSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LEVEL', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _levelIndex.toDouble(),
                min: 0,
                max: (levels.length - 1).toDouble(),
                divisions: levels.length - 1,
                label: levels[_levelIndex],
                onChanged: (value) {
                  setState(() {
                    _levelIndex = value.round();
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(levels.length, (i) => Text(levels[i], style: const TextStyle(fontSize: 10))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(levels.length, (i) => Text(strengths.join(' '), style: const TextStyle(fontSize: 10, color: Colors.blue))),
        ),
        // Strength selection for current level
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Strength: '),
            DropdownButton<int>(
              value: _strengthIndex,
              items: List.generate(strengths.length, (i) => DropdownMenuItem(
                value: i,
                child: Text(strengths[i]),
              )),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _strengthIndex = value;
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class AddPlayerScreen extends StatelessWidget {
  const AddPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Player')),
      body: Center(
        child: SingleChildScrollView(
          child: PlayerForm(
            actionButtonText: 'Save Player',
            onSubmit: (player) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Player saved!')),
              );
              Navigator.pop(context, player);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
