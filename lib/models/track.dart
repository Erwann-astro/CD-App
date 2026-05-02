class Track {
  const Track({
    this.id,
    required this.title,
    this.artist = '',
    this.year,
    this.coverPath,
    this.trackNumber,
  });

  final int? id;
  final String title;
  final String artist;
  final int? year;
  final String? coverPath;
  final int? trackNumber;

  Track copyWith({
    int? id,
    String? title,
    String? artist,
    int? year,
    String? coverPath,
    int? trackNumber,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      coverPath: coverPath ?? this.coverPath,
      trackNumber: trackNumber ?? this.trackNumber,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'cover_path': coverPath,
      'track_number': trackNumber,
    };
  }

  factory Track.fromMap(Map<String, Object?> map) {
    return Track(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: (map['artist'] as String?) ?? '',
      year: map['year'] as int?,
      coverPath: map['cover_path'] as String?,
      trackNumber: map['track_number'] as int?,
    );
  }
}

class TrackDiscLink {
  const TrackDiscLink({required this.discId, this.trackNumber});
  final int discId;
  final int? trackNumber;
}
