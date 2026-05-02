import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/disc.dart';
import '../models/track.dart';
import '../providers/disc_provider.dart';
import '../providers/track_provider.dart';
import '../services/database_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/track_tile.dart';
import 'add_edit_disc_screen.dart';
import 'add_edit_track_screen.dart';

class DiscDetailScreen extends StatefulWidget {
  final Disc disc;

  const DiscDetailScreen({super.key, required this.disc});

  @override
  State<DiscDetailScreen> createState() => _DiscDetailScreenState();
}

class _DiscDetailScreenState extends State<DiscDetailScreen> {
  late Disc _disc;

  @override
  void initState() {
    super.initState();
    _disc = widget.disc;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackProvider>().loadTracksForDisc(_disc.id!);
    });
  }

  Future<void> _confirmDeleteDisc() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce disque ?'),
        content: Text(
          'Le disque "${_disc.name}" et tous ses titres seront supprimés définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<DiscProvider>().deleteDisc(_disc.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _confirmDeleteTrack(Track track) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce titre ?'),
        content: Text('"${track.title}" sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TrackProvider>().deleteTrack(track.id!);
    }
  }

  void _openEditDisc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditDiscScreen(disc: _disc)),
    ).then((_) async {
      final updated = await DatabaseService.instance.getDisc(_disc.id!);
      if (updated != null && mounted) {
        setState(() => _disc = updated);
      }
    });
  }

  void _openAddTrack() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTrackScreen(discId: _disc.id!),
      ),
    );
  }

  void _openEditTrack(Track track) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTrackScreen(discId: _disc.id!, track: track),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discColor = _disc.color;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: discColor,
        foregroundColor: Colors.white,
        title: Text(
          _disc.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Modifier le disque',
            onPressed: _openEditDisc,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer le disque',
            onPressed: _confirmDeleteDisc,
          ),
        ],
      ),
      body: Consumer<TrackProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.tracks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tracks.isEmpty) {
            return const EmptyState(
              icon: Icons.music_note_outlined,
              message: 'Aucun titre sur ce disque.\nAppuyez sur + pour en ajouter.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.tracks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final track = provider.tracks[index];
              return TrackTile(
                track: track,
                onEdit: () => _openEditTrack(track),
                onDelete: () => _confirmDeleteTrack(track),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTrack,
        backgroundColor: discColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un titre', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
