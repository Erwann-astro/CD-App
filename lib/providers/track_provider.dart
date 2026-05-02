import 'package:flutter/foundation.dart';

import '../models/track.dart';
import '../services/database_service.dart';

class TrackProvider extends ChangeNotifier {
  TrackProvider(this._databaseService);

  final DatabaseService _databaseService;
  int? _currentDiscId;
  List<Track> _tracks = [];
  bool _isLoading = false;

  List<Track> get tracks => _tracks;
  bool get isLoading => _isLoading;

  Future<void> loadTracksForDisc(int discId) async {
    _currentDiscId = discId;
    _isLoading = true;
    notifyListeners();
    _tracks = await _databaseService.getTracksForDisc(discId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveTrack(Track track, List<TrackDiscLink> links) async {
    if (track.id == null) {
      await _databaseService.insertTrack(track, links);
    } else {
      await _databaseService.updateTrackWithLinks(track, links);
    }
    if (_currentDiscId != null) {
      await loadTracksForDisc(_currentDiscId!);
    }
  }

  Future<void> deleteTrack(int id) async {
    await _databaseService.deleteTrack(id);
    if (_currentDiscId != null) {
      await loadTracksForDisc(_currentDiscId!);
    }
  }
}
