import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// AddGameScreen allows creating a new game with schedules and cost settings.
class AddGameScreen extends StatefulWidget {
  const AddGameScreen({Key? key}) : super(key: key);

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _courtRateController = TextEditingController();
  final _shuttlePriceController = TextEditingController();
  bool _divideEqually = true;

  // Schedules: each entry is a map {"court": "1", "start": DateTime, "end": DateTime}
  final List<Map<String, dynamic>> _schedules = [];

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

  Future<void> _pickSchedule() async {
    // Pick start date/time then end date/time and a court number.
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final startTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (startTime == null) return;
    final endTime = await showTimePicker(context: context, initialTime: startTime.replacing(hour: (startTime.hour + 2) % 24));
    if (endTime == null) return;
    final start = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final end = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    final courtController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign court #'),
        content: TextField(controller: courtController, decoration: const InputDecoration(labelText: 'Court #')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
    if (ok != true) return;
    _schedules.add({'court': courtController.text.trim(), 'start': start, 'end': end});
    setState(() {});
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one schedule')));
      return;
    }
    final box = Hive.box('games');
    final game = {
      'title': _titleController.text.trim(),
      'courtName': _courtNameController.text.trim(),
      'courtRate': double.tryParse(_courtRateController.text) ?? 0.0,
      'shuttlePrice': double.tryParse(_shuttlePriceController.text) ?? 0.0,
      'divideEqually': _divideEqually,
      'schedules': _schedules.map((s) => {
        'court': s['court'],
        'start': (s['start'] as DateTime).toIso8601String(),
        'end': (s['end'] as DateTime).toIso8601String(),
      }).toList(),
      'playersCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await box.add(game);
    Navigator.pop(context, game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Game')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Game Title (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courtNameController,
                decoration: const InputDecoration(labelText: 'Court Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courtRateController,
                decoration: const InputDecoration(labelText: 'Court rate (per hour)'),
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
                decoration: const InputDecoration(labelText: 'Shuttle cock price (per game)'),
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
              const SizedBox(height: 12),
              const Text('Schedules', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._schedules.map((s) {
                final start = DateTime.parse(s['start'].toString());
                final end = DateTime.parse(s['end'].toString());
                return Card(
                  child: ListTile(
                    title: Text('Court ${s['court']}'),
                    subtitle: Text('${start.toLocal()} - ${end.toLocal()}'),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _pickSchedule, child: const Text('Add Schedule')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _save, child: const Text('Save Game')),
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
