/// Data validation utilities for the Mind House application
/// 
/// This module provides comprehensive validation functions for all data types
/// used throughout the application. It focuses on tag validation, information
/// validation, and general data integrity checks to ensure the tags-first
/// approach works reliably.

/// Custom validation exception for data validation errors
class ValidationException implements Exception {
  final String message;
  final String? field;
  final dynamic value;
  
  const ValidationException(
    this.message, {
    this.field,
    this.value,
  });
  
  @override
  String toString() {
    final fieldInfo = field != null ? ' (field: $field)' : '';
    final valueInfo = value != null ? ' (value: $value)' : '';
    return 'ValidationException: $message$fieldInfo$valueInfo';
  }
}

/// Validation result wrapper
class ValidationResult {
  final bool isValid;
  final String? error;
  final dynamic sanitizedValue;
  
  const ValidationResult._({
    required this.isValid,
    this.error,
    this.sanitizedValue,
  });
  
  /// Create a successful validation result
  factory ValidationResult.success({dynamic sanitizedValue}) {
    return ValidationResult._(
      isValid: true,
      sanitizedValue: sanitizedValue,
    );
  }
  
  /// Create a failed validation result
  factory ValidationResult.failure(String error) {
    return ValidationResult._(
      isValid: false,
      error: error,
    );
  }
  
  /// Throw a ValidationException if this result is invalid
  void throwIfInvalid({String? field, dynamic value}) {
    if (!isValid) {
      throw ValidationException(error!, field: field, value: value);
    }
  }
}

/// Core validation utilities for the Mind House application
class ValidationUtils {
  
  // ============================================================================
  // STRING VALIDATION
  // ============================================================================
  
  /// Validate that a string is not null, not empty, and optionally meets length requirements
  static ValidationResult validateRequiredString(
    String? value, {
    String fieldName = 'field',
    int? minLength,
    int? maxLength,
    bool allowWhitespace = true,
  }) {
    if (value == null) {
      return ValidationResult.failure('$fieldName cannot be null');
    }
    
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.failure('$fieldName cannot be empty');
    }
    
    final checkValue = allowWhitespace ? value : trimmed;
    
    if (minLength != null && checkValue.length < minLength) {
      return ValidationResult.failure(
        '$fieldName must be at least $minLength characters long'
      );
    }
    
    if (maxLength != null && checkValue.length > maxLength) {
      return ValidationResult.failure(
        '$fieldName must be no more than $maxLength characters long'
      );
    }
    
    return ValidationResult.success(sanitizedValue: trimmed);
  }
  
  /// Validate optional string with length requirements
  static ValidationResult validateOptionalString(
    String? value, {
    String fieldName = 'field',
    int? minLength,
    int? maxLength,
    bool allowWhitespace = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(sanitizedValue: null);
    }
    
    return validateRequiredString(
      value,
      fieldName: fieldName,
      minLength: minLength,
      maxLength: maxLength,
      allowWhitespace: allowWhitespace,
    );
  }
  
  // ============================================================================
  // TAG VALIDATION (Core feature for tags-first approach)
  // ============================================================================
  
  /// Validate and sanitize tag name
  /// 
  /// Tag names must be non-empty, alphanumeric with limited special characters,
  /// and follow consistent formatting for the tags-first approach.
  static ValidationResult validateTagName(String? value) {
    final result = validateRequiredString(
      value, 
      fieldName: 'Tag name',
      minLength: 1,
      maxLength: 50,
      allowWhitespace: false,
    );
    
    if (!result.isValid) {
      return result;
    }
    
    final sanitized = result.sanitizedValue as String;
    
    // Check for valid tag name characters (alphanumeric, spaces, hyphens, underscores)
    final validTagRegex = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
    if (!validTagRegex.hasMatch(sanitized)) {
      return ValidationResult.failure(
        'Tag name can only contain letters, numbers, spaces, hyphens, and underscores'
      );
    }
    
    // Normalize the tag name (trim, lowercase for internal use)
    final normalized = sanitized.toLowerCase();
    
    return ValidationResult.success(sanitizedValue: normalized);
  }
  
  /// Validate tag display name
  static ValidationResult validateTagDisplayName(String? value) {
    return validateRequiredString(
      value,
      fieldName: 'Tag display name',
      minLength: 1,
      maxLength: 50,
    );
  }
  
  /// Validate tag description
  static ValidationResult validateTagDescription(String? value) {
    return validateOptionalString(
      value,
      fieldName: 'Tag description',
      maxLength: 500,
    );
  }
  
  // ============================================================================
  // INFORMATION VALIDATION
  // ============================================================================
  
  /// Validate information title
  static ValidationResult validateInformationTitle(String? value) {
    return validateRequiredString(
      value,
      fieldName: 'Information title',
      minLength: 1,
      maxLength: 200,
    );
  }
  
  /// Validate information content
  static ValidationResult validateInformationContent(String? value) {
    return validateRequiredString(
      value,
      fieldName: 'Information content',
      minLength: 1,
      maxLength: 50000, // Large content support
    );
  }
  
  /// Validate information source
  static ValidationResult validateInformationSource(String? value) {
    return validateOptionalString(
      value,
      fieldName: 'Information source',
      maxLength: 200,
    );
  }
  
  /// Validate importance level (0-10)
  static ValidationResult validateImportance(int? value) {
    if (value == null) {
      return ValidationResult.success(sanitizedValue: 0); // Default importance
    }
    
    if (value < 0 || value > 10) {
      return ValidationResult.failure(
        'Importance must be between 0 and 10 (inclusive)'
      );
    }
    
    return ValidationResult.success(sanitizedValue: value);
  }
  
  // ============================================================================
  // URL VALIDATION
  // ============================================================================
  
  /// Validate URL format and scheme
  static ValidationResult validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success(sanitizedValue: null);
    }
    
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    
    if (uri == null) {
      return ValidationResult.failure('Invalid URL format');
    }
    
    // Check for obvious malformed URLs first
    if (!trimmed.contains('://') && !trimmed.contains('.')){
      return ValidationResult.failure('Invalid URL format');
    }
    
    if (!uri.hasScheme) {
      return ValidationResult.failure('URL must include a scheme (http:// or https://)');
    }
    
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return ValidationResult.failure('URL must use http or https scheme');
    }
    
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return ValidationResult.failure('URL must include a domain');
    }
    
    return ValidationResult.success(sanitizedValue: trimmed);
  }
  
  // ============================================================================
  // COLOR VALIDATION
  // ============================================================================
  
  /// Validate hex color format
  static ValidationResult validateHexColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.failure('Color cannot be empty');
    }
    
    final trimmed = value.trim();
    final hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    
    if (!hexColorRegex.hasMatch(trimmed)) {
      return ValidationResult.failure(
        'Color must be a valid hex color format (e.g., #FF0000 or #F00)'
      );
    }
    
    // Normalize to 6-digit format
    String normalized = trimmed.toUpperCase();
    if (normalized.length == 4) {
      // Convert #RGB to #RRGGBB
      normalized = '#${normalized[1]}${normalized[1]}${normalized[2]}${normalized[2]}${normalized[3]}${normalized[3]}';
    }
    
    return ValidationResult.success(sanitizedValue: normalized);
  }
  
  // ============================================================================
  // UUID VALIDATION
  // ============================================================================
  
  /// Validate UUID format
  static ValidationResult validateUuid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.failure('UUID cannot be empty');
    }
    
    final trimmed = value.trim();
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    
    if (!uuidRegex.hasMatch(trimmed)) {
      return ValidationResult.failure('Invalid UUID format');
    }
    
    return ValidationResult.success(sanitizedValue: trimmed.toLowerCase());
  }
  
  // ============================================================================
  // NUMERIC VALIDATION
  // ============================================================================
  
  /// Validate non-negative integer
  static ValidationResult validateNonNegativeInt(int? value, {String fieldName = 'value'}) {
    if (value == null) {
      return ValidationResult.failure('$fieldName cannot be null');
    }
    
    if (value < 0) {
      return ValidationResult.failure('$fieldName cannot be negative');
    }
    
    return ValidationResult.success(sanitizedValue: value);
  }
  
  /// Validate positive integer
  static ValidationResult validatePositiveInt(int? value, {String fieldName = 'value'}) {
    if (value == null) {
      return ValidationResult.failure('$fieldName cannot be null');
    }
    
    if (value <= 0) {
      return ValidationResult.failure('$fieldName must be positive');
    }
    
    return ValidationResult.success(sanitizedValue: value);
  }
  
  /// Validate integer within range
  static ValidationResult validateIntRange(
    int? value, {
    required int min,
    required int max,
    String fieldName = 'value',
  }) {
    if (value == null) {
      return ValidationResult.failure('$fieldName cannot be null');
    }
    
    if (value < min || value > max) {
      return ValidationResult.failure(
        '$fieldName must be between $min and $max (inclusive)'
      );
    }
    
    return ValidationResult.success(sanitizedValue: value);
  }
  
  // ============================================================================
  // DATE VALIDATION
  // ============================================================================
  
  /// Validate date is not in the future
  static ValidationResult validatePastOrPresentDate(DateTime? value, {String fieldName = 'date'}) {
    if (value == null) {
      return ValidationResult.failure('$fieldName cannot be null');
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return ValidationResult.failure('$fieldName cannot be in the future');
    }
    
    return ValidationResult.success(sanitizedValue: value);
  }
  
  /// Validate date range
  static ValidationResult validateDateRange(
    DateTime? value, {
    DateTime? earliest,
    DateTime? latest,
    String fieldName = 'date',
  }) {
    if (value == null) {
      return ValidationResult.failure('$fieldName cannot be null');
    }
    
    if (earliest != null && value.isBefore(earliest)) {
      return ValidationResult.failure(
        '$fieldName cannot be before ${earliest.toIso8601String()}'
      );
    }
    
    if (latest != null && value.isAfter(latest)) {
      return ValidationResult.failure(
        '$fieldName cannot be after ${latest.toIso8601String()}'
      );
    }
    
    return ValidationResult.success(sanitizedValue: value);
  }
  
  // ============================================================================
  // COMPOUND VALIDATION METHODS
  // ============================================================================
  
  /// Validate complete tag data
  static Map<String, ValidationResult> validateTagData({
    String? name,
    String? displayName,
    String? description,
    String? color,
    int? usageCount,
  }) {
    return {
      'name': validateTagName(name),
      'displayName': validateTagDisplayName(displayName),
      'description': validateTagDescription(description),
      'color': validateHexColor(color),
      'usageCount': validateNonNegativeInt(usageCount, fieldName: 'usage count'),
    };
  }
  
  /// Validate complete information data
  static Map<String, ValidationResult> validateInformationData({
    String? title,
    String? content,
    String? source,
    String? url,
    int? importance,
  }) {
    return {
      'title': validateInformationTitle(title),
      'content': validateInformationContent(content),
      'source': validateInformationSource(source),
      'url': validateUrl(url),
      'importance': validateImportance(importance),
    };
  }
  
  /// Check if all validation results in a map are valid
  static bool areAllValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }
  
  /// Get all validation errors from a map of results
  static List<String> getAllErrors(Map<String, ValidationResult> results) {
    return results.entries
        .where((entry) => !entry.value.isValid)
        .map((entry) => '${entry.key}: ${entry.value.error}')
        .toList();
  }
  
  /// Throw ValidationException if any results are invalid
  static void throwIfAnyInvalid(Map<String, ValidationResult> results) {
    if (!areAllValid(results)) {
      final errors = getAllErrors(results);
      throw ValidationException(
        'Validation failed: ${errors.join(', ')}'
      );
    }
  }
}