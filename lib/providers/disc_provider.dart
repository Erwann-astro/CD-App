import 'package:flutter/foundation.dart';

import '../models/disc.dart';
import '../services/database_service.dart';

class DiscProvider extends ChangeNotifier {
  DiscProvider(this._databaseService);

  final DatabaseService _databaseService;
  List<Disc> _discs = [];
  bool _isLoading = false;

  List<Disc> get discs => _discs;
  bool get isLoading => _isLoading;

  Future<void> loadDiscs() async {
    _isLoading = true;
    notifyListeners();
    _discs = await _databaseService.getDiscs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveDisc(Disc disc) async {
    if (disc.id == null) {
      await _databaseService.insertDisc(disc);
    } else {
      await _databaseService.updateDisc(disc);
    }
    await loadDiscs();
  }

  Future<void> deleteDisc(int id) async {
    await _databaseService.deleteDisc(id);
    await loadDiscs();
  }
}
