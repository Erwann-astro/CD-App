import 'package:flutter/material.dart';

import '../models/track.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onEdit,
    required this.onDelete,
  });

  final Track track;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: track.trackNumber != null
          ? Text(
              '${track.trackNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : Icon(
              Icons.music_note,
              color: Theme.of(context).colorScheme.primary,
            ),
      title: Text(
        track.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: track.artist.isNotEmpty
          ? Text(track.artist, style: const TextStyle(fontSize: 15))
          : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Modifier')),
          PopupMenuItem(
            value: 'delete',
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
