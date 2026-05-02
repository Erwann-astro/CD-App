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
  const DiscDetailScreen({super.key, required this.disc});

  final Disc disc;

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
      final discId = _disc.id;
      if (discId != null) {
        context.read<TrackProvider>().loadTracksForDisc(discId);
      }
    });
  }

  Future<void> _refreshDisc() async {
    final discId = _disc.id;
    if (discId == null) return;
    final updated = await DatabaseService.instance.getDisc(discId);
    if (updated != null && mounted) {
      setState(() {
        _disc = updated;
      });
    }
  }

  Future<void> _confirmDeleteDisc() async {
    final discProvider = context.read<DiscProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce disque ?'),
        content: const Text('Cette action supprimera aussi tous les titres associés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      final discId = _disc.id;
      if (discId != null) {
        await discProvider.deleteDisc(discId);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _deleteTrack(Track track) async {
    final trackProvider = context.read<TrackProvider>();
    final discProvider = context.read<DiscProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce titre ?'),
        content: Text('"${track.title}" sera supprimé définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (shouldDelete == true) {
      await trackProvider.deleteTrack(track.id!);
      if (!context.mounted) return;
      await discProvider.loadDiscs();
      await _refreshDisc();
    }
  }

  @override
  Widget build(BuildContext context) {
    final discColor = Color(_disc.colorValue);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: discColor,
        foregroundColor: Colors.white,
        title: Text(_disc.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditDiscScreen(disc: _disc)),
              );
              if (!context.mounted) return;
              await context.read<DiscProvider>().loadDiscs();
              await _refreshDisc();
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _confirmDeleteDisc),
        ],
      ),
      body: Consumer<TrackProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.tracks.isEmpty) {
            return const EmptyState(
              icon: Icons.music_note_outlined,
              message: 'Aucun titre sur ce disque.',
            );
          }
          return ListView.separated(
            itemCount: provider.tracks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final track = provider.tracks[index];
              return TrackTile(
                track: track,
                onEdit: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTrackScreen(
                        defaultDiscId: _disc.id!,
                        track: track,
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  await context.read<DiscProvider>().loadDiscs();
                  await _refreshDisc();
                },
                onDelete: () => _deleteTrack(track),
              );
            },
          );
        },
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTrackScreen(defaultDiscId: _disc.id!),
            ),
          );
          if (!context.mounted) return;
          await context.read<DiscProvider>().loadDiscs();
          await _refreshDisc();
        },
        style: FilledButton.styleFrom(backgroundColor: discColor, foregroundColor: Colors.white),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un titre'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
