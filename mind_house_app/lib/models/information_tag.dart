/// InformationTag association model representing the many-to-many relationship
/// between Information and Tag entities in the Mind House app
/// 
/// This class corresponds to the information_tags junction table and provides
/// association metadata such as when the tag was assigned and by whom.
class InformationTag {
  /// ID of the associated information item
  final String informationId;
  
  /// ID of the associated tag
  final String tagId;
  
  /// When this tag was assigned to the information
  final DateTime assignedAt;
  
  /// Who assigned this tag (defaults to 'system')
  final String assignedBy;
  
  /// Create a new InformationTag association
  /// 
  /// [informationId] and [tagId] are required and cannot be empty
  /// [assignedBy] defaults to 'system' if not specified
  InformationTag({
    required this.informationId,
    required this.tagId,
    DateTime? assignedAt,
    this.assignedBy = 'system',
  }) : assignedAt = assignedAt ?? DateTime.now() {
    
    // Validation
    if (informationId.trim().isEmpty) {
      throw ArgumentError('Information ID cannot be empty');
    }
    
    if (tagId.trim().isEmpty) {
      throw ArgumentError('Tag ID cannot be empty');
    }
    
    if (assignedBy.trim().isEmpty) {
      throw ArgumentError('AssignedBy cannot be empty');
    }
  }
  
  /// Create InformationTag from database JSON map
  factory InformationTag.fromJson(Map<String, dynamic> json) {
    return InformationTag(
      informationId: json['information_id'] as String,
      tagId: json['tag_id'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      assignedBy: (json['assigned_by'] as String?) ?? 'system',
    );
  }
  
  /// Convert InformationTag to database JSON map
  Map<String, dynamic> toJson() {
    return {
      'information_id': informationId,
      'tag_id': tagId,
      'assigned_at': assignedAt.toIso8601String(),
      'assigned_by': assignedBy,
    };
  }
  
  /// Create a copy of this InformationTag with updated fields
  /// 
  /// Note: informationId and tagId are immutable as they form the primary key
  InformationTag copyWith({
    DateTime? assignedAt,
    String? assignedBy,
  }) {
    return InformationTag(
      informationId: informationId, // immutable
      tagId: tagId, // immutable
      assignedAt: assignedAt ?? this.assignedAt,
      assignedBy: assignedBy ?? this.assignedBy,
    );
  }
  
  /// Two InformationTag instances are equal if they have the same informationId and tagId
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InformationTag) return false;
    return informationId == other.informationId && tagId == other.tagId;
  }
  
  /// Hash code is based on the combination of informationId and tagId
  @override
  int get hashCode => Object.hash(informationId, tagId);
  
  /// String representation for debugging
  @override
  String toString() {
    return 'InformationTag(informationId: $informationId, tagId: $tagId, '
           'assignedAt: $assignedAt, assignedBy: "$assignedBy")';
  }
}