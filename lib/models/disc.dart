import 'package:flutter/material.dart';

class Disc {
  final int? id;
  final String name;
  final String description;
  final int colorValue;
  final int? trackCount;

  const Disc({
    this.id,
    required this.name,
    this.description = '',
    this.colorValue = 0xFF2196F3,
    this.trackCount,
  });

  Color get color => Color(colorValue);

  factory Disc.fromMap(Map<String, dynamic> map) {
    return Disc(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      colorValue: (map['color_value'] as int?) ?? 0xFF2196F3,
      trackCount: map['track_count'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'color_value': colorValue,
    };
  }

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
}
