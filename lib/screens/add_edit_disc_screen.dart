import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/disc.dart';
import '../providers/disc_provider.dart';
import '../widgets/color_picker_row.dart';

class AddEditDiscScreen extends StatefulWidget {
  final Disc? disc;

  const AddEditDiscScreen({super.key, this.disc});

  @override
  State<AddEditDiscScreen> createState() => _AddEditDiscScreenState();
}

class _AddEditDiscScreenState extends State<AddEditDiscScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late int _colorValue;

  bool get _isEditing => widget.disc != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.disc?.name ?? '');
    _descCtrl = TextEditingController(text: widget.disc?.description ?? '');
    _colorValue = widget.disc?.colorValue ?? ColorPickerRow.palette.first.value;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<DiscProvider>();
    final disc = Disc(
      id: widget.disc?.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      colorValue: _colorValue,
    );

    if (_isEditing) {
      await provider.updateDisc(disc);
    } else {
      await provider.addDisc(disc);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le disque' : 'Nouveau disque'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nom du disque *',
                hintText: 'Ex: Hits des années 80',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Ex: Pour les longs trajets',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 28),
            const Text(
              'Couleur du disque',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            ColorPickerRow(
              selectedValue: _colorValue,
              onChanged: (v) => setState(() => _colorValue = v),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(_isEditing ? 'Enregistrer' : 'Créer le disque'),
            ),
          ],
        ),
      ),
    );
  }
}
