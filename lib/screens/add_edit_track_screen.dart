import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/disc.dart';
import '../models/track.dart';
import '../providers/disc_provider.dart';
import '../providers/track_provider.dart';
import '../services/database_service.dart';

class AddEditTrackScreen extends StatefulWidget {
  const AddEditTrackScreen({super.key, required this.defaultDiscId, this.track});
  final int defaultDiscId;
  final Track? track;
  @override
  State<AddEditTrackScreen> createState() => _AddEditTrackScreenState();
}

class _AddEditTrackScreenState extends State<AddEditTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _yearController;
  final Map<int, TextEditingController> _trackNumbers = {};
  final Set<int> _selectedDiscs = {};
  String? _coverPath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track?.title ?? '');
    _artistController = TextEditingController(text: widget.track?.artist ?? '');
    _yearController = TextEditingController(text: widget.track?.year?.toString() ?? '');
    _coverPath = widget.track?.coverPath;
    _selectedDiscs.add(widget.defaultDiscId);
    if (widget.track?.id != null) {
      DatabaseService.instance.getTrackNumbers(widget.track!.id!).then((v) {
        if (!mounted) return;
        setState(() {
          _selectedDiscs..clear()..addAll(v.keys);
          for (final e in v.entries) {
            _trackNumbers[e.key] = TextEditingController(text: e.value?.toString() ?? '');
          }
        });
      });
    }
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final dec = img.decodeImage(bytes);
    if (dec == null) return;
    final webp = img.encodeWebP(dec, quality: 80);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.webp');
    await file.writeAsBytes(webp);
    setState(() => _coverPath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedDiscs.isEmpty) return;
    final track = Track(id: widget.track?.id, title: _titleController.text.trim(), artist: _artistController.text.trim(), year: int.tryParse(_yearController.text.trim()), coverPath: _coverPath);
    final links = _selectedDiscs.map((d) => TrackDiscLink(discId: d, trackNumber: int.tryParse(_trackNumbers[d]?.text.trim() ?? ''))).toList();
    await context.read<TrackProvider>().saveTrack(track, links);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final discs = context.watch<DiscProvider>().discs;
    return Scaffold(appBar: AppBar(title: const Text('Ajouter / Modifier musique')), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titre'), validator: (v)=>v==null||v.trim().isEmpty?'Requis':null),
      TextFormField(controller: _artistController, decoration: const InputDecoration(labelText: 'Artiste')),
      TextFormField(controller: _yearController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Année')),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Choisir image (webp)')),
      if (_coverPath != null) Text('Image: $_coverPath', maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 12),
      const Text('Disques'),
      ...discs.map((Disc d){ _trackNumbers.putIfAbsent(d.id!, ()=>TextEditingController()); final checked=_selectedDiscs.contains(d.id); return Column(children:[CheckboxListTile(value: checked, title: Text(d.name), onChanged:(v){setState((){if(v==true){_selectedDiscs.add(d.id!);} else {_selectedDiscs.remove(d.id!);}});}), if(checked) TextField(controller:_trackNumbers[d.id], keyboardType: TextInputType.number, decoration: InputDecoration(labelText:'N° piste pour ${d.name}'))]);}),
      const SizedBox(height: 20),
      FilledButton(onPressed: _save, child: const Text('Enregistrer'))
    ]))));
  }
}
