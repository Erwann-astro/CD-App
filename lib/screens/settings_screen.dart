import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/disc_provider.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBusy = false;

  Future<void> _exportData() async {
    setState(() => _isBusy = true);
    try {
      final json = await DatabaseService.instance.exportDataAsJson();
      final tmpDir = await getTemporaryDirectory();
      final file = File('${tmpDir.path}/cdmusic_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Export CD Music');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export prêt. Partagez le fichier pour l’envoyer vers un autre appareil.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur export: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importData() async {
    final selected = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (selected == null || selected.files.single.path == null) return;

    setState(() => _isBusy = true);
    try {
      final file = File(selected.files.single.path!);
      final json = await file.readAsString();
      await DatabaseService.instance.importDataFromJson(json);
      if (!mounted) return;
      await context.read<DiscProvider>().loadDiscs();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import terminé avec succès.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur import: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètre')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Sauvegarde & transfert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Exportez vos disques/musiques puis importez le fichier JSON sur un autre appareil.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isBusy ? null : _exportData,
            icon: const Icon(Icons.upload_file),
            label: const Text('Exporter mes données'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _importData,
            icon: const Icon(Icons.download_for_offline_outlined),
            label: const Text('Importer des données'),
          ),
          if (_isBusy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
