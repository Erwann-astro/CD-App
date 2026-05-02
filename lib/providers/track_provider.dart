import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../services/database_service.dart';

class TrackProvider extends ChangeNotifier {
  final DatabaseService _db;

  List<Track> _tracks = [];
  bool _loading = false;
  int? _currentDiscId;

  TrackProvider(this._db);

  List<Track> get tracks => _tracks;
  bool get loading => _loading;
  int? get currentDiscId => _currentDiscId;

  Future<void> loadTracksForDisc(int discId) async {
    _loading = true;
    _currentDiscId = discId;
    notifyListeners();
    try {
      _tracks = await _db.getTracksForDisc(discId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addTrack(Track track) async {
    await _db.insertTrack(track);
    if (_currentDiscId != null) await loadTracksForDisc(_currentDiscId!);
  }

  Future<void> updateTrack(Track track) async {
    await _db.updateTrack(track);
    if (_currentDiscId != null) await loadTracksForDisc(_currentDiscId!);
  }

  Future<void> deleteTrack(int id) async {
    await _db.deleteTrack(id);
    if (_currentDiscId != null) await loadTracksForDisc(_currentDiscId!);
  }
}
