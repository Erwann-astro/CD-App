import 'package:flutter/material.dart';

import '../models/track.dart';
import '../services/database_service.dart';
import '../widgets/track_tile.dart';

class ArtistTracksScreen extends StatefulWidget {
  const ArtistTracksScreen({super.key, required this.artistName});
  final String artistName;

  @override
  State<ArtistTracksScreen> createState() => _ArtistTracksScreenState();
}

class _ArtistTracksScreenState extends State<ArtistTracksScreen> {
  List<Track> _tracks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _tracks = await DatabaseService.instance.getTracksForArtist(widget.artistName);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.artistName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tracks.length,
              itemBuilder: (_, i) => TrackTile(track: _tracks[i], showDiscs: true),
            ),
    );
  }
}
