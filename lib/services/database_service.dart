import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/disc.dart';
import '../models/track.dart';

class DatabaseService {
  DatabaseService._();

  static final instance = DatabaseService._();
  static const _databaseName = 'cd_catalog.db';
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: 2,
      onOpen: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS track_disc_links');
        await db.execute('DROP TABLE IF EXISTS tracks');
        await _createTracksSchema(db);
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE discs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        color_value INTEGER NOT NULL DEFAULT 4280391411
      )
    ''');
    await _createTracksSchema(db);
  }

  Future<void> _createTracksSchema(Database db) async {
    await db.execute('''
      CREATE TABLE tracks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL DEFAULT '',
        year INTEGER,
        cover_path TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE track_disc_links (
        track_id INTEGER NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
        disc_id INTEGER NOT NULL REFERENCES discs(id) ON DELETE CASCADE,
        track_number INTEGER,
        PRIMARY KEY(track_id, disc_id)
      )
    ''');
  }

  Future<List<Disc>> getDiscs() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT d.*, COUNT(l.track_id) AS track_count
      FROM discs d LEFT JOIN track_disc_links l ON l.disc_id = d.id
      GROUP BY d.id ORDER BY d.name COLLATE NOCASE
    ''');
    return result.map(Disc.fromMap).toList();
  }

  Future<Disc?> getDisc(int id) async {
    final result = await (await database).rawQuery('''
      SELECT d.*, COUNT(l.track_id) AS track_count
      FROM discs d LEFT JOIN track_disc_links l ON l.disc_id = d.id
      WHERE d.id=? GROUP BY d.id
    ''', [id]);
    if (result.isEmpty) return null;
    return Disc.fromMap(result.first);
  }

  Future<int> insertDisc(Disc disc) async => (await database).insert('discs', disc.toMap()..remove('id'));
  Future<int> updateDisc(Disc disc) async => (await database).update('discs', disc.toMap()..remove('id'), where: 'id = ?', whereArgs: [disc.id]);
  Future<int> deleteDisc(int id) async => (await database).delete('discs', where: 'id = ?', whereArgs: [id]);

  Future<List<Track>> getTracksForDisc(int discId) async {
    final result = await (await database).rawQuery('''
      SELECT t.*, l.track_number FROM tracks t
      JOIN track_disc_links l ON l.track_id = t.id
      WHERE l.disc_id = ?
      ORDER BY l.track_number ASC NULLS LAST, t.title COLLATE NOCASE
    ''', [discId]);
    return result.map((r) => Track.fromMap(r)).toList();
  }

  Future<List<Track>> searchTracks(String query) async {
    final q = '%${query.toLowerCase()}%';
    final result = await (await database).rawQuery('''
      SELECT t.*, MIN(l.track_number) AS track_number, GROUP_CONCAT(DISTINCT d.name, ' • ') AS disc_names
      FROM tracks t
      LEFT JOIN track_disc_links l ON l.track_id = t.id
      LEFT JOIN discs d ON d.id = l.disc_id
      WHERE LOWER(t.title) LIKE ? OR LOWER(t.artist) LIKE ? OR CAST(t.year AS TEXT) LIKE ?
      GROUP BY t.id
      ORDER BY t.title COLLATE NOCASE
    ''', [q, q, q]);
    return result.map(Track.fromMap).toList();
  }

  Future<List<Track>> getTracksForArtist(String artistName) async {
    final result = await (await database).rawQuery('''
      SELECT t.*, MIN(l.track_number) AS track_number, GROUP_CONCAT(DISTINCT d.name, ' • ') AS disc_names
      FROM tracks t
      LEFT JOIN track_disc_links l ON l.track_id = t.id
      LEFT JOIN discs d ON d.id = l.disc_id
      WHERE LOWER(TRIM(t.artist)) = LOWER(TRIM(?))
      GROUP BY t.id
      ORDER BY t.title COLLATE NOCASE
    ''', [artistName]);
    return result.map(Track.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> searchArtists(String query) async {
    final q = '%${query.toLowerCase()}%';
    return (await database).rawQuery('''
      SELECT LOWER(TRIM(artist)) AS artist_key, MIN(TRIM(artist)) AS artist_name, COUNT(*) AS songs
      FROM tracks WHERE TRIM(artist) != '' AND LOWER(artist) LIKE ?
      GROUP BY LOWER(TRIM(artist)) ORDER BY artist_name COLLATE NOCASE
    ''', [q]);
  }

  Future<Map<int, int?>> getTrackNumbers(int trackId) async {
    final rows = await (await database).query('track_disc_links', where: 'track_id=?', whereArgs: [trackId]);
    return {for (final r in rows) r['disc_id'] as int: r['track_number'] as int?};
  }

  Future<int> insertTrack(Track track, List<TrackDiscLink> links) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('tracks', track.toMap()..remove('id'));
      for (final l in links) {
        await txn.insert('track_disc_links', {'track_id': id, 'disc_id': l.discId, 'track_number': l.trackNumber});
      }
      return id;
    });
  }

  Future<void> updateTrackWithLinks(Track track, List<TrackDiscLink> links) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('tracks', track.toMap()..remove('id'), where: 'id=?', whereArgs: [track.id]);
      await txn.delete('track_disc_links', where: 'track_id=?', whereArgs: [track.id]);
      for (final l in links) {
        await txn.insert('track_disc_links', {'track_id': track.id, 'disc_id': l.discId, 'track_number': l.trackNumber});
      }
    });
  }

  Future<int> deleteTrack(int id) async => (await database).delete('tracks', where: 'id = ?', whereArgs: [id]);

  Future<String> exportDataAsJson() async {
    final db = await database;
    final discs = await db.query('discs');
    final tracks = await db.query('tracks');
    final links = await db.query('track_disc_links');
    return jsonEncode({
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'discs': discs,
      'tracks': tracks,
      'track_disc_links': links,
    });
  }

  Future<void> importDataFromJson(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Fichier invalide');
    }

    final discs = (decoded['discs'] as List?)?.cast<Map>() ?? const [];
    final tracks = (decoded['tracks'] as List?)?.cast<Map>() ?? const [];
    final links = (decoded['track_disc_links'] as List?)?.cast<Map>() ?? const [];

    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('track_disc_links');
      await txn.delete('tracks');
      await txn.delete('discs');

      for (final raw in discs) {
        final row = Map<String, Object?>.from(raw.cast<String, Object?>());
        await txn.insert('discs', row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final raw in tracks) {
        final row = Map<String, Object?>.from(raw.cast<String, Object?>());
        await txn.insert('tracks', row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final raw in links) {
        final row = Map<String, Object?>.from(raw.cast<String, Object?>());
        await txn.insert('track_disc_links', row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
