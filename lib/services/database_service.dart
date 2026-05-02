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
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE discs (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            name        TEXT    NOT NULL,
            description TEXT    NOT NULL DEFAULT '',
            color_value INTEGER NOT NULL DEFAULT 4280391411
          )
        ''');
        await db.execute('''
          CREATE TABLE tracks (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            title        TEXT    NOT NULL,
            artist       TEXT    NOT NULL DEFAULT '',
            disc_id      INTEGER NOT NULL REFERENCES discs(id) ON DELETE CASCADE,
            track_number INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_tracks_disc_id ON tracks(disc_id)');
      },
    );
  }

  Future<List<Disc>> getDiscs() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT d.*, COUNT(t.id) AS track_count
      FROM discs d
      LEFT JOIN tracks t ON t.disc_id = d.id
      GROUP BY d.id
      ORDER BY d.name COLLATE NOCASE
    ''');
    return result.map(Disc.fromMap).toList();
  }

  Future<Disc?> getDisc(int id) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT d.*, COUNT(t.id) AS track_count
      FROM discs d
      LEFT JOIN tracks t ON t.disc_id = d.id
      WHERE d.id = ?
      GROUP BY d.id
    ''', [id]);
    if (result.isEmpty) {
      return null;
    }
    return Disc.fromMap(result.first);
  }

  Future<int> insertDisc(Disc disc) async {
    final db = await database;
    return db.insert('discs', disc.toMap()..remove('id'));
  }

  Future<int> updateDisc(Disc disc) async {
    final db = await database;
    return db.update(
      'discs',
      disc.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [disc.id],
    );
  }

  Future<int> deleteDisc(int id) async {
    final db = await database;
    return db.delete('discs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Track>> getTracksForDisc(int discId) async {
    final db = await database;
    final result = await db.query(
      'tracks',
      where: 'disc_id = ?',
      whereArgs: [discId],
      orderBy: 'track_number ASC NULLS LAST, title COLLATE NOCASE ASC',
    );
    return result.map(Track.fromMap).toList();
  }

  Future<List<Disc>> getDiscOptions() async {
    return getDiscs();
  }

  Future<int> insertTrack(Track track) async {
    final db = await database;
    return db.insert('tracks', track.toMap()..remove('id'));
  }

  Future<int> updateTrack(Track track) async {
    final db = await database;
    return db.update(
      'tracks',
      track.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  Future<int> deleteTrack(int id) async {
    final db = await database;
    return db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }
}
