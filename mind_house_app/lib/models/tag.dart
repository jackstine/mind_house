import 'dart:math';
import 'package:uuid/uuid.dart';

/// Tag model class representing a tag in the Mind House app
/// 
/// This class follows the database schema defined in DatabaseHelper and provides
/// comprehensive validation, color management, usage tracking, and data management capabilities.
/// Tags are used to categorize and organize information items in a tags-first approach.
class Tag {
  /// Unique identifier (UUID)
  final String id;
  
  /// Internal name of the tag (normalized lowercase)
  final String name;
  
  /// Display name of the tag (human-readable)
  final String displayName;
  
  /// Optional description of the tag
  final String? description;
  
  /// Color of the tag (hex format, e.g., '#2196F3')
  final String color;
  
  /// Number of times this tag has been used
  final int usageCount;
  
  /// When this tag was created
  final DateTime createdAt;
  
  /// When this tag was last updated
  final DateTime updatedAt;
  
  /// When this tag was last used (optional)
  final DateTime? lastUsedAt;
  
  static const Uuid _uuid = Uuid();
  
  /// Default color for new tags (Material Design Blue)
  static const String defaultColor = '#2196F3';
  
  /// Predefined Material Design colors for tags
  static const List<String> materialColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue (default)
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#9E9E9E', // Grey
    '#607D8B', // Blue Grey
  ];
  
  /// Regular expression for valid hex color format
  static final RegExp _hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
  
  /// Create a new Tag instance
  /// 
  /// [name] and [displayName] are required and cannot be empty
  /// [name] will be normalized to lowercase for consistency
  /// [color] must be a valid hex color format
  /// [usageCount] must be non-negative
  Tag({
    String? id,
    required String name,
    required this.displayName,
    this.description,
    this.color = defaultColor,
    this.usageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastUsedAt,
  }) : 
    id = id ?? _uuid.v4(),
    name = name.toLowerCase().trim(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now() {
    
    // Validation
    if (this.name.isEmpty) {
      throw ArgumentError('Tag name cannot be empty');
    }
    
    if (displayName.trim().isEmpty) {
      throw ArgumentError('Tag display name cannot be empty');
    }
    
    if (usageCount < 0) {
      throw ArgumentError('Usage count cannot be negative');
    }
    
    if (!_hexColorRegex.hasMatch(color)) {
      throw ArgumentError('Color must be a valid hex color format (e.g., #FF0000 or #F00)');
    }
  }
  
  /// Create Tag from database JSON map
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: (json['display_name'] as String?) ?? (json['name'] as String),
      description: json['description'] as String?,
      color: (json['color'] as String?) ?? defaultColor,
      usageCount: (json['usage_count'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastUsedAt: json['last_used_at'] != null 
          ? DateTime.parse(json['last_used_at'] as String)
          : null,
    );
  }
  
  /// Convert Tag to database JSON map
  Map<String, dynamic> toJson() {
    // Note: Only include fields that exist in the current database schema
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    // Only include display_name and last_used_at if the database supports them
    // This will be updated when database schema migrations are implemented
    
    return json;
  }
  
  /// Create a copy of this Tag with updated fields
  /// 
  /// The [updatedAt] timestamp will be automatically set to the current time
  /// unless explicitly provided. The [id] and [createdAt] fields are immutable.
  Tag copyWith({
    String? name,
    String? displayName,
    String? description,
    String? color,
    int? usageCount,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
  }) {
    return Tag(
      id: id, // ID is immutable
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt, // createdAt is immutable
      updatedAt: updatedAt ?? DateTime.now(),
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
  
  /// Increment the usage count and update lastUsedAt timestamp
  /// 
  /// This method should be called whenever the tag is used/applied to information.
  /// It automatically updates the updatedAt timestamp as well.
  Tag incrementUsage() {
    final now = DateTime.now();
    return copyWith(
      usageCount: usageCount + 1,
      lastUsedAt: now,
      updatedAt: now,
    );
  }
  
  /// Get a random color from the predefined Material Design colors
  static String getRandomColor() {
    final random = Random();
    return materialColors[random.nextInt(materialColors.length)];
  }
  
  /// Check if this tag is frequently used (usage count >= threshold)
  bool isFrequentlyUsed({int threshold = 10}) {
    return usageCount >= threshold;
  }
  
  /// Check if this tag has been used recently (within specified days)
  bool isRecentlyUsed({int days = 7}) {
    if (lastUsedAt == null) return false;
    final threshold = DateTime.now().subtract(Duration(days: days));
    return lastUsedAt!.isAfter(threshold);
  }
  
  /// Two Tag instances are equal if they have the same ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tag) return false;
    return id == other.id;
  }
  
  /// Hash code is based on the ID
  @override
  int get hashCode => id.hashCode;
  
  /// String representation for debugging
  @override
  String toString() {
    return 'Tag(id: $id, name: "$name", displayName: "$displayName", '
           'color: $color, usageCount: $usageCount, createdAt: $createdAt)';
  }
}