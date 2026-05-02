import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/disc.dart';
import '../models/track.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'cd_catalog.db'),
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE discs (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        description TEXT    NOT NULL DEFAULT '',
        color_value INTEGER NOT NULL DEFAULT ${0xFF2196F3}
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

    await db.execute(
      'CREATE INDEX idx_tracks_disc_id ON tracks(disc_id)',
    );
  }

  // Discs

  Future<List<Disc>> getDiscs() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT d.*, COUNT(t.id) AS track_count
      FROM discs d
      LEFT JOIN tracks t ON t.disc_id = d.id
      GROUP BY d.id
      ORDER BY d.name COLLATE NOCASE
    ''');
    return rows.map(Disc.fromMap).toList();
  }

  Future<Disc?> getDisc(int id) async {
    final db = await database;
    final rows = await db.query('discs', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Disc.fromMap(rows.first);
  }

  Future<int> insertDisc(Disc disc) async {
    final db = await database;
    return db.insert('discs', disc.toMap());
  }

  Future<void> updateDisc(Disc disc) async {
    final db = await database;
    await db.update(
      'discs',
      disc.toMap(),
      where: 'id = ?',
      whereArgs: [disc.id],
    );
  }

  Future<void> deleteDisc(int id) async {
    final db = await database;
    await db.delete('discs', where: 'id = ?', whereArgs: [id]);
  }

  // Tracks

  Future<List<Track>> getTracksForDisc(int discId) async {
    final db = await database;
    final rows = await db.query(
      'tracks',
      where: 'disc_id = ?',
      whereArgs: [discId],
      orderBy: 'track_number ASC, title COLLATE NOCASE ASC',
    );
    return rows.map(Track.fromMap).toList();
  }

  Future<int> insertTrack(Track track) async {
    final db = await database;
    return db.insert('tracks', track.toMap());
  }

  Future<void> updateTrack(Track track) async {
    final db = await database;
    await db.update(
      'tracks',
      track.toMap(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  Future<void> deleteTrack(int id) async {
    final db = await database;
    await db.delete('tracks', where: 'id = ?', whereArgs: [id]);
  }
}
