class Disc {
  const Disc({
    this.id,
    required this.name,
    this.description = '',
    required this.colorValue,
    this.trackCount,
  });

  final int? id;
  final String name;
  final String description;
  final int colorValue;
  final int? trackCount;

  Disc copyWith({
    int? id,
    String? name,
    String? description,
    int? colorValue,
    int? trackCount,
  }) {
    return Disc(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      trackCount: trackCount ?? this.trackCount,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color_value': colorValue,
    };
  }

  factory Disc.fromMap(Map<String, Object?> map) {
    return Disc(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      colorValue: map['color_value'] as int,
      trackCount: map['track_count'] as int?,
    );
  }
}
