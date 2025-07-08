/// Utility class for tag name normalization and validation
/// 
/// This class provides comprehensive tag name normalization functionality
/// to ensure consistent tag naming across the Mind House application.
/// It handles case normalization, special character replacement, whitespace
/// management, and validation of tag names.
class TagNormalization {
  /// Maximum allowed length for tag names
  static const int maxTagLength = 100;
  
  /// Regular expression for special characters to be replaced with spaces
  static final RegExp _specialCharsRegex = RegExp(r'[_\-/\\&@#$%^*+=<>[\]{}|;:,.]');
  
  /// Regular expression for excessive punctuation to be removed
  static final RegExp _excessivePunctuationRegex = RegExp(r'[!?]{2,}|\.{2,}|\-{2,}');
  
  /// Regular expression for multiple whitespace characters
  static final RegExp _multipleWhitespaceRegex = RegExp(r'\s+');
  
  /// Regular expression for hashtag extraction
  static final RegExp _hashtagRegex = RegExp(r'#(\w+(?:[_\-]\w+)*)');
  
  /// Regular expression for slug generation (non-alphanumeric except dashes)
  static final RegExp _slugRegex = RegExp(r'[^a-z0-9\-]');
  
  /// Regular expression for multiple dashes in slugs
  static final RegExp _multipleDashRegex = RegExp(r'-+');
  
  /// Normalize a tag name for internal storage
  /// 
  /// This method performs comprehensive normalization:
  /// - Converts to lowercase
  /// - Trims whitespace
  /// - Replaces special characters with spaces
  /// - Removes excessive punctuation
  /// - Collapses multiple spaces into single spaces
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.normalizeName('Mobile-App_Development!!!') 
  /// // returns 'mobile app development'
  /// ```
  static String normalizeName(String input) {
    if (input.isEmpty) return '';
    
    String normalized = input;
    
    // Convert to lowercase
    normalized = normalized.toLowerCase();
    
    // Trim whitespace
    normalized = normalized.trim();
    
    // Replace special characters with spaces
    normalized = normalized.replaceAll(_specialCharsRegex, ' ');
    
    // Remove excessive punctuation
    normalized = normalized.replaceAll(_excessivePunctuationRegex, '');
    
    // Replace multiple whitespace with single space
    normalized = normalized.replaceAll(_multipleWhitespaceRegex, ' ');
    
    // Final trim
    normalized = normalized.trim();
    
    return normalized;
  }
  
  /// Normalize a tag name for display purposes
  /// 
  /// Similar to [normalizeName] but preserves original casing
  /// for better user experience in the UI.
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.normalizeForDisplay('Mobile-App_Development!!!') 
  /// // returns 'Mobile App Development'
  /// ```
  static String normalizeForDisplay(String input) {
    if (input.isEmpty) return '';
    
    String normalized = input;
    
    // Trim whitespace
    normalized = normalized.trim();
    
    // Replace special characters with spaces
    normalized = normalized.replaceAll(_specialCharsRegex, ' ');
    
    // Remove excessive punctuation
    normalized = normalized.replaceAll(_excessivePunctuationRegex, '');
    
    // Replace multiple whitespace with single space
    normalized = normalized.replaceAll(_multipleWhitespaceRegex, ' ');
    
    // Final trim
    normalized = normalized.trim();
    
    return normalized;
  }
  
  /// Check if two tag names are equivalent after normalization
  /// 
  /// This is useful for preventing duplicate tags with different
  /// formatting or casing.
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.areEquivalent('Flutter', 'flutter') // returns true
  /// TagNormalization.areEquivalent('Mobile-App', 'mobile app') // returns true
  /// ```
  static bool areEquivalent(String name1, String name2) {
    return normalizeName(name1) == normalizeName(name2);
  }
  
  /// Validate if a tag name is valid
  /// 
  /// A valid tag name must:
  /// - Not be empty after normalization
  /// - Not exceed the maximum length
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.isValid('flutter') // returns true
  /// TagNormalization.isValid('') // returns false
  /// TagNormalization.isValid('   ') // returns false
  /// ```
  static bool isValid(String input) {
    final normalized = normalizeName(input);
    
    // Check if empty after normalization
    if (normalized.isEmpty) return false;
    
    // Check length
    if (normalized.length > maxTagLength) return false;
    
    return true;
  }
  
  /// Generate a URL-safe slug from a tag name
  /// 
  /// This is useful for creating URLs or file names based on tag names.
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.generateSlug('Flutter App Development') 
  /// // returns 'flutter-app-development'
  /// ```
  static String generateSlug(String input) {
    if (input.isEmpty) return '';
    
    // Start with normalized name
    String slug = normalizeName(input);
    
    // Replace spaces with dashes
    slug = slug.replaceAll(' ', '-');
    
    // Remove any remaining non-alphanumeric characters (except dashes)
    slug = slug.replaceAll(_slugRegex, '');
    
    // Replace multiple dashes with single dash
    slug = slug.replaceAll(_multipleDashRegex, '-');
    
    // Trim leading and trailing dashes
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');
    
    return slug;
  }
  
  /// Extract and normalize hashtags from text
  /// 
  /// This method finds hashtags in text, normalizes them, and returns
  /// a unique list of normalized tag names.
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.extractHashtags('Learning #flutter and #dart for #mobile development')
  /// // returns ['flutter', 'dart', 'mobile']
  /// ```
  static List<String> extractHashtags(String text) {
    final matches = _hashtagRegex.allMatches(text);
    final hashtags = <String>{};
    
    for (final match in matches) {
      final hashtag = match.group(1);
      if (hashtag != null) {
        final normalized = normalizeName(hashtag);
        if (normalized.isNotEmpty) {
          hashtags.add(normalized);
        }
      }
    }
    
    return hashtags.toList()..sort();
  }
  
  /// Get suggestions for tag name corrections
  /// 
  /// This method provides suggestions for correcting common tag naming issues.
  /// 
  /// Example:
  /// ```dart
  /// TagNormalization.getSuggestions('flutter-app_dev!!!')
  /// // returns ['flutter app dev', 'flutter-app-dev', 'flutterappdev']
  /// ```
  static List<String> getSuggestions(String input) {
    if (input.isEmpty) return [];
    
    final suggestions = <String>[];
    
    // Add normalized version
    final normalized = normalizeName(input);
    if (normalized.isNotEmpty) {
      suggestions.add(normalized);
    }
    
    // Add slug version
    final slug = generateSlug(input);
    if (slug.isNotEmpty && slug != normalized) {
      suggestions.add(slug);
    }
    
    // Add version without spaces
    final noSpaces = normalized.replaceAll(' ', '');
    if (noSpaces.isNotEmpty && noSpaces != normalized && noSpaces != slug) {
      suggestions.add(noSpaces);
    }
    
    // Add camelCase version for display
    final displayVersion = normalizeForDisplay(input);
    if (displayVersion.isNotEmpty && displayVersion.toLowerCase() == normalized) {
      suggestions.add(displayVersion);
    }
    
    return suggestions;
  }
  
  /// Check if a tag name contains only valid characters
  /// 
  /// This is a more strict validation that checks for potentially
  /// problematic characters that might cause issues in the UI or database.
  static bool hasValidCharacters(String input) {
    // Allow letters, numbers, spaces, and basic punctuation
    final validCharsRegex = RegExp(r'^[a-zA-Z0-9\s\-_.,!?]+$');
    return validCharsRegex.hasMatch(input);
  }
  
  /// Get the character count after normalization
  /// 
  /// This helps users understand how their input will be processed.
  static int getNormalizedLength(String input) {
    return normalizeName(input).length;
  }
}