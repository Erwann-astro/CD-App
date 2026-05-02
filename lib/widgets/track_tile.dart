import 'package:flutter/material.dart';

import '../models/track.dart';

class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TrackTile({
    super.key,
    required this.track,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: track.trackNumber != null
          ? SizedBox(
              width: 36,
              child: Text(
                '${track.trackNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : const Icon(Icons.music_note_outlined),
      title: Text(
        track.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: track.artist.isNotEmpty
          ? Text(track.artist, style: const TextStyle(fontSize: 14))
          : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined),
                SizedBox(width: 8),
                Text('Modifier'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Supprimer', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
