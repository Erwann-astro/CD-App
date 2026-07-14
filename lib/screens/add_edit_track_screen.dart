import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/disc.dart';
import '../models/track.dart';
import '../providers/disc_provider.dart';
import '../providers/track_provider.dart';

class AddEditTrackScreen extends StatefulWidget {
  const AddEditTrackScreen({
    super.key,
    required this.defaultDiscId,
    this.track,
  });

  final int defaultDiscId;
  final Track? track;

  @override
  State<AddEditTrackScreen> createState() => _AddEditTrackScreenState();
}

class _AddEditTrackScreenState extends State<AddEditTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _trackNumberController;
  late int _selectedDiscId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track?.title ?? '');
    _artistController = TextEditingController(text: widget.track?.artist ?? '');
    _trackNumberController = TextEditingController(
      text: widget.track?.trackNumber?.toString() ?? '',
    );
    _selectedDiscId = widget.track?.discId ?? widget.defaultDiscId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _trackNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final trackNumberText = _trackNumberController.text.trim();
    final track = Track(
      id: widget.track?.id,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      discId: _selectedDiscId,
      trackNumber: trackNumberText.isEmpty ? null : int.tryParse(trackNumberText),
    );
    await context.read<TrackProvider>().saveTrack(track);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final discs = context.watch<DiscProvider>().discs;
    final isEditing = widget.track != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Modifier le titre' : 'Ajouter un titre')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (discs.length > 1)
                  DropdownButtonFormField<int>(
                    initialValue: _selectedDiscId,
                    decoration: const InputDecoration(labelText: 'Disque'),
                    items: discs
                        .map(
                          (Disc disc) => DropdownMenuItem<int>(
                            value: disc.id,
                            child: Text(disc.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDiscId = value;
                        });
                      }
                    },
                  ),
                if (discs.length > 1) const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est requis.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artiste (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _trackNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Numéro de piste (optionnel)'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Enregistrer' : 'Ajouter le titre'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
