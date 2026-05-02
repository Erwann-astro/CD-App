import 'package:flutter/foundation.dart';

import '../models/disc.dart';
import '../services/database_service.dart';

class DiscProvider extends ChangeNotifier {
  final DatabaseService _db;

  List<Disc> _discs = [];
  bool _loading = false;
  String? _error;

  DiscProvider(this._db);

  List<Disc> get discs => _discs;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadDiscs() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _discs = await _db.getDiscs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addDisc(Disc disc) async {
    await _db.insertDisc(disc);
    await loadDiscs();
  }

  Future<void> updateDisc(Disc disc) async {
    await _db.updateDisc(disc);
    await loadDiscs();
  }

  Future<void> deleteDisc(int id) async {
    await _db.deleteDisc(id);
    await loadDiscs();
  }
}
