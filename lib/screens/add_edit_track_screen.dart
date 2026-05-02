import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../providers/disc_provider.dart';
import '../providers/track_provider.dart';

class AddEditTrackScreen extends StatefulWidget {
  final int discId;
  final Track? track;

  const AddEditTrackScreen({super.key, required this.discId, this.track});

  @override
  State<AddEditTrackScreen> createState() => _AddEditTrackScreenState();
}

class _AddEditTrackScreenState extends State<AddEditTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _artistCtrl;
  late final TextEditingController _numberCtrl;
  late int _selectedDiscId;

  bool get _isEditing => widget.track != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.track?.title ?? '');
    _artistCtrl = TextEditingController(text: widget.track?.artist ?? '');
    _numberCtrl = TextEditingController(
      text: widget.track?.trackNumber?.toString() ?? '',
    );
    _selectedDiscId = widget.track?.discId ?? widget.discId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final trackProvider = context.read<TrackProvider>();
    final number = int.tryParse(_numberCtrl.text.trim());

    final track = Track(
      id: widget.track?.id,
      title: _titleCtrl.text.trim(),
      artist: _artistCtrl.text.trim(),
      discId: _selectedDiscId,
      trackNumber: number,
    );

    if (_isEditing) {
      await trackProvider.updateTrack(track);
    } else {
      await trackProvider.addTrack(track);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final discs = context.watch<DiscProvider>().discs;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le titre' : 'Nouveau titre'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre de la chanson *',
                hintText: 'Ex: Hotel California',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le titre est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _artistCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Artiste (optionnel)',
                hintText: 'Ex: Eagles',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'N° de piste (optionnel)',
                hintText: 'Ex: 3',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            if (discs.length > 1) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedDiscId,
                decoration: const InputDecoration(
                  labelText: 'Disque',
                  border: OutlineInputBorder(),
                ),
                items: discs.map((d) {
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text(d.name, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDiscId = v);
                },
              ),
            ],
            const SizedBox(height: 40),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(_isEditing ? 'Enregistrer' : 'Ajouter le titre'),
            ),
          ],
        ),
      ),
    );
  }
}
