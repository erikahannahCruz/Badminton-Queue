import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// A simple user settings screen to store default court name, court rate,
/// shuttle price, and whether to divide court equally among players.
class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courtNameController = TextEditingController();
  final _courtRateController = TextEditingController();
  final _shuttlePriceController = TextEditingController();
  bool _divideEqually = true;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    final map = box.get('defaults') as Map?;
    if (map != null) {
      _courtNameController.text = map['courtName'] ?? '';
      _courtRateController.text = (map['courtRate'] ?? '').toString();
      _shuttlePriceController.text = (map['shuttlePrice'] ?? '').toString();
      _divideEqually = map['divideEqually'] ?? true;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final box = Hive.box('settings');
    await box.put('defaults', {
      'courtName': _courtNameController.text.trim(),
      'courtRate': double.tryParse(_courtRateController.text) ?? 0.0,
      'shuttlePrice': double.tryParse(_shuttlePriceController.text) ?? 0.0,
      'divideEqually': _divideEqually,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _courtNameController,
                decoration: const InputDecoration(labelText: 'Default court name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courtRateController,
                decoration: const InputDecoration(labelText: 'Default court rate (per hour)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shuttlePriceController,
                decoration: const InputDecoration(labelText: 'Default shuttle cock price (per game)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _divideEqually, onChanged: (v) => setState(() => _divideEqually = v ?? true)),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Divide the court equally among players')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _save, child: const Text('Save Settings')),
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
