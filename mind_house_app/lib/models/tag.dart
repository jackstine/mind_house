class Tag {
  final int? id;
  final String name;
  final String? color;
  final int usageCount;
  final DateTime createdAt;

  Tag({
    this.id,
    required String name,
    this.color,
    this.usageCount = 0,
    DateTime? createdAt,
  })  : name = _validateAndTrimName(name),
        createdAt = createdAt ?? DateTime.now() {
    if (color != null) {
      _validateColor(color!);
    }
  }

  static String _validateAndTrimName(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    return trimmedName;
  }

  static void _validateColor(String color) {
    // Validate hex color format: #RGB, #RRGGBB, or #RRGGBBAA
    final hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!hexColorRegex.hasMatch(color)) {
      throw ArgumentError('Color must be in hex format (e.g., #FF5722, #000, #ffffff)');
    }
  }

  /// Returns normalized name for searching and comparison (lowercase, spaces preserved)
  String get normalizedName => name.toLowerCase();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'usage_count': usageCount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
      usageCount: map['usage_count'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Tag copyWith({
    int? id,
    String? name,
    String? color,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a copy with incremented usage count
  Tag incrementUsage() {
    return copyWith(usageCount: usageCount + 1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.usageCount == usageCount &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        color.hashCode ^
        usageCount.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, color: $color, usageCount: $usageCount, createdAt: $createdAt)';
  }
}