import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'player_profile.dart';

/// EditGameScreen allows editing game details, selecting players, and assigning payers.
class EditGameScreen extends StatefulWidget {
  final Map game;
  final int gameIndex;
  const EditGameScreen({Key? key, required this.game, required this.gameIndex}) : super(key: key);

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _courtNameController;
  late TextEditingController _courtRateController;
  late TextEditingController _shuttlePriceController;
  late bool _divideEqually;
  late Set<dynamic> _selectedPlayerKeys;
  late Set<dynamic> _courtPayerKeys;
  late Set<dynamic> _shuttlePayerKeys;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.game['title'] ?? '');
    _courtNameController = TextEditingController(text: widget.game['courtName'] ?? '');
    _courtRateController = TextEditingController(text: (widget.game['courtRate'] ?? 0.0).toString());
    _shuttlePriceController = TextEditingController(text: (widget.game['shuttlePrice'] ?? 0.0).toString());
    _divideEqually = widget.game['divideEqually'] ?? true;
    _selectedPlayerKeys = Set.from((widget.game['playerKeys'] as List?)?.cast<dynamic>() ?? []);
    _courtPayerKeys = Set.from((widget.game['courtPayers'] as List?)?.cast<dynamic>() ?? []);
    _shuttlePayerKeys = Set.from((widget.game['shuttlePayers'] as List?)?.cast<dynamic>() ?? []);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final box = Hive.box('games');
    final updated = Map.from(widget.game);
    updated['title'] = _titleController.text.trim();
    updated['courtName'] = _courtNameController.text.trim();
    updated['courtRate'] = double.tryParse(_courtRateController.text) ?? 0.0;
    updated['shuttlePrice'] = double.tryParse(_shuttlePriceController.text) ?? 0.0;
    updated['divideEqually'] = _divideEqually;
    updated['playerKeys'] = _selectedPlayerKeys.toList();
    updated['courtPayers'] = _courtPayerKeys.toList();
    updated['shuttlePayers'] = _shuttlePayerKeys.toList();
    await box.putAt(widget.gameIndex, updated);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final playersBox = Hive.box<PlayerProfile>('players');
    final allPlayers = playersBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Game')),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _shuttlePriceController,
                decoration: const InputDecoration(labelText: 'Shuttle price (per game)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _divideEqually,
                    onChanged: (v) => setState(() => _divideEqually = v ?? true),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Divide the court equally among players')),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Select Players', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (allPlayers.isEmpty)
                const Text('No players available', style: TextStyle(color: Colors.grey))
              else
                ...allPlayers.map((p) {
                  final key = playersBox.keys.firstWhere((k) => playersBox.get(k) == p, orElse: () => null);
                  final isSelected = _selectedPlayerKeys.contains(key);
                  return CheckboxListTile(
                    title: Text(p.nickname),
                    subtitle: Text(p.fullName),
                    value: isSelected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedPlayerKeys.add(key);
                        } else {
                          _selectedPlayerKeys.remove(key);
                          _courtPayerKeys.remove(key);
                          _shuttlePayerKeys.remove(key);
                        }
                      });
                    },
                  );
                }).toList(),
              if (!_divideEqually && _selectedPlayerKeys.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Assign Court Payers', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._selectedPlayerKeys.map((key) {
                  final p = playersBox.get(key);
                  if (p == null) return const SizedBox.shrink();
                  final isPayer = _courtPayerKeys.contains(key);
                  return CheckboxListTile(
                    title: Text(p.nickname),
                    subtitle: const Text('Pays court fee'),
                    value: isPayer,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _courtPayerKeys.add(key);
                        } else {
                          _courtPayerKeys.remove(key);
                        }
                      });
                    },
                  );
                }).toList(),
                const SizedBox(height: 12),
                const Text('Assign Shuttle Payers', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._selectedPlayerKeys.map((key) {
                  final p = playersBox.get(key);
                  if (p == null) return const SizedBox.shrink();
                  final isPayer = _shuttlePayerKeys.contains(key);
                  return CheckboxListTile(
                    title: Text(p.nickname),
                    subtitle: const Text('Pays shuttle fee'),
                    value: isPayer,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _shuttlePayerKeys.add(key);
                        } else {
                          _shuttlePayerKeys.remove(key);
                        }
                      });
                    },
                  );
                }).toList(),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
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
