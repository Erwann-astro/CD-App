class Track {
  const Track({
    this.id,
    required this.title,
    this.artist = '',
    required this.discId,
    this.trackNumber,
  });

  final int? id;
  final String title;
  final String artist;
  final int discId;
  final int? trackNumber;

  Track copyWith({
    int? id,
    String? title,
    String? artist,
    int? discId,
    int? trackNumber,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      discId: discId ?? this.discId,
      trackNumber: trackNumber ?? this.trackNumber,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'disc_id': discId,
      'track_number': trackNumber,
    };
  }

  factory Track.fromMap(Map<String, Object?> map) {
    return Track(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: (map['artist'] as String?) ?? '',
      discId: map['disc_id'] as int,
      trackNumber: map['track_number'] as int?,
    );
  }
}
