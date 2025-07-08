import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Enumeration of different information types
enum InformationType {
  note('note'),
  bookmark('bookmark'),
  reminder('reminder'),
  task('task');

  const InformationType(this.value);
  
  final String value;
  
  /// Create InformationType from string value
  static InformationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'note':
        return InformationType.note;
      case 'bookmark':
        return InformationType.bookmark;
      case 'reminder':
        return InformationType.reminder;
      case 'task':
        return InformationType.task;
      default:
        throw ArgumentError('Invalid InformationType: $value');
    }
  }
}

/// Information model class representing a single piece of information in the Mind House app
/// 
/// This class follows the database schema defined in DatabaseHelper and provides
/// comprehensive validation, serialization, and data management capabilities.
class Information {
  /// Unique identifier (UUID)
  final String id;
  
  /// Title of the information item
  final String title;
  
  /// Main content/body of the information
  final String content;
  
  /// Type of information (note, bookmark, reminder, task)
  final InformationType type;
  
  /// Source of the information (optional)
  final String? source;
  
  /// Associated URL (optional, must be valid if provided)
  final String? url;
  
  /// Importance level (0-10, default 0)
  final int importance;
  
  /// Whether this information is marked as favorite
  final bool isFavorite;
  
  /// Whether this information is archived
  final bool isArchived;
  
  /// When this information was created
  final DateTime createdAt;
  
  /// When this information was last updated
  final DateTime updatedAt;
  
  /// When this information was last accessed (optional)
  final DateTime? accessedAt;
  
  /// Additional metadata as key-value pairs (optional)
  final Map<String, dynamic>? metadata;
  
  static const Uuid _uuid = Uuid();
  
  /// Create a new Information instance
  /// 
  /// [title] and [content] are required and cannot be empty
  /// [type] specifies the information type
  /// [importance] must be between 0-10 (inclusive)
  /// [url] must be a valid URL format if provided
  Information({
    String? id,
    required this.title,
    required this.content,
    required this.type,
    this.source,
    this.url,
    this.importance = 0,
    this.isFavorite = false,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.accessedAt,
    this.metadata,
  }) : 
    id = id ?? _uuid.v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now() {
    
    // Validation
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    
    if (content.trim().isEmpty) {
      throw ArgumentError('Content cannot be empty');
    }
    
    if (importance < 0 || importance > 10) {
      throw ArgumentError('Importance must be between 0 and 10');
    }
    
    if (url != null && url!.isNotEmpty) {
      final uri = Uri.tryParse(url!);
      if (uri == null || (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
        throw ArgumentError('URL must be a valid http or https URL');
      }
    }
  }
  
  /// Create Information from database JSON map
  factory Information.fromJson(Map<String, dynamic> json) {
    // Parse metadata from JSON string if present
    Map<String, dynamic>? metadata;
    if (json['metadata'] != null && json['metadata'] is String) {
      try {
        metadata = jsonDecode(json['metadata'] as String) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, leave metadata as null
        metadata = null;
      }
    }
    
    return Information(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: InformationType.fromString(json['type'] as String),
      source: json['source'] as String?,
      url: json['url'] as String?,
      importance: (json['importance'] as int?) ?? 0,
      isFavorite: (json['is_favorite'] as int?) == 1,
      isArchived: (json['is_archived'] as int?) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      accessedAt: json['accessed_at'] != null 
          ? DateTime.parse(json['accessed_at'] as String) 
          : null,
      metadata: metadata,
    );
  }
  
  /// Convert Information to database JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.value,
      'source': source,
      'url': url,
      'importance': importance,
      'is_favorite': isFavorite ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'accessed_at': accessedAt?.toIso8601String(),
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }
  
  /// Create a copy of this Information with updated fields
  /// 
  /// The [updatedAt] timestamp will be automatically set to the current time
  /// unless explicitly provided. The [id] and [createdAt] fields are immutable.
  Information copyWith({
    String? title,
    String? content,
    InformationType? type,
    String? source,
    String? url,
    int? importance,
    bool? isFavorite,
    bool? isArchived,
    DateTime? updatedAt,
    DateTime? accessedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Information(
      id: id, // ID is immutable
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      source: source ?? this.source,
      url: url ?? this.url,
      importance: importance ?? this.importance,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt, // createdAt is immutable
      updatedAt: updatedAt ?? DateTime.now(),
      accessedAt: accessedAt ?? this.accessedAt,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Mark this information as accessed by updating the accessedAt timestamp
  Information markAsAccessed() {
    return copyWith(
      accessedAt: DateTime.now(),
      updatedAt: updatedAt, // Don't update the main updatedAt for access tracking
    );
  }
  
  /// Two Information instances are equal if they have the same ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Information) return false;
    return id == other.id;
  }
  
  /// Hash code is based on the ID
  @override
  int get hashCode => id.hashCode;
  
  /// String representation for debugging
  @override
  String toString() {
    return 'Information(id: $id, title: "$title", type: ${type.value}, '
           'importance: $importance, isFavorite: $isFavorite, '
           'isArchived: $isArchived, createdAt: $createdAt)';
  }
}