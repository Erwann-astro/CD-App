import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'artist_tracks_screen.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final _c = TextEditingController();
  List<Map<String, Object?>> _rows = [];

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    _rows = await DatabaseService.instance.searchArtists(_c.text.trim());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(controller: _c, onChanged: (_) => _search(), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher artiste...')),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _rows.length,
            itemBuilder: (_, i) {
              final r = _rows[i];
              final name = '${r['artist_name']}';
              return ListTile(
                title: Text(name),
                trailing: Text('${r['songs']}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtistTracksScreen(artistName: name))),
              );
            },
          ),
        )
      ]);
}
