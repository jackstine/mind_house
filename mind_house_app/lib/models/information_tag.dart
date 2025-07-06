class InformationTag {
  final String informationId;
  final int tagId;
  final DateTime createdAt;

  InformationTag({
    required String informationId,
    required int tagId,
    DateTime? createdAt,
  })  : informationId = _validateInformationId(informationId),
        tagId = _validateTagId(tagId),
        createdAt = createdAt ?? DateTime.now();

  static String _validateInformationId(String informationId) {
    if (informationId.isEmpty) {
      throw ArgumentError('Information ID cannot be empty');
    }
    return informationId;
  }

  static int _validateTagId(int tagId) {
    if (tagId <= 0) {
      throw ArgumentError('Tag ID must be a positive integer');
    }
    return tagId;
  }

  Map<String, dynamic> toMap() {
    return {
      'information_id': informationId,
      'tag_id': tagId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory InformationTag.fromMap(Map<String, dynamic> map) {
    return InformationTag(
      informationId: map['information_id'] as String,
      tagId: map['tag_id'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  InformationTag copyWith({
    String? informationId,
    int? tagId,
    DateTime? createdAt,
  }) {
    return InformationTag(
      informationId: informationId ?? this.informationId,
      tagId: tagId ?? this.tagId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is InformationTag &&
        other.informationId == informationId &&
        other.tagId == tagId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return informationId.hashCode ^
        tagId.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'InformationTag(informationId: $informationId, tagId: $tagId, createdAt: $createdAt)';
  }
}