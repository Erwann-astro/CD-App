import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/disc.dart';
import '../providers/disc_provider.dart';
import '../widgets/color_picker_row.dart';

class AddEditDiscScreen extends StatefulWidget {
  const AddEditDiscScreen({super.key, this.disc});

  final Disc? disc;

  @override
  State<AddEditDiscScreen> createState() => _AddEditDiscScreenState();
}

class _AddEditDiscScreenState extends State<AddEditDiscScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late int _selectedColorValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.disc?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.disc?.description ?? '');
    _selectedColorValue = widget.disc?.colorValue ?? Colors.blue.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = context.read<DiscProvider>();
    final disc = Disc(
      id: widget.disc?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      colorValue: _selectedColorValue,
    );
    await provider.saveDisc(disc);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.disc != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Modifier le disque' : 'Nouveau disque')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom du disque'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est requis.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description (optionnel)'),
                ),
                const SizedBox(height: 16),
                const Text('Couleur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ColorPickerRow(
                  selectedColorValue: _selectedColorValue,
                  onChanged: (value) => setState(() => _selectedColorValue = value),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Enregistrer' : 'Créer le disque'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
