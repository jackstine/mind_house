// Enhanced Tag Input Component
// Material Design 3 compliant input with real-time suggestions and visual feedback

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

/// Callback for tag validation
typedef TagValidator = String? Function(String tag);

/// Callback for tag suggestions
typedef TagSuggestionCallback = Future<List<String>> Function(String query);

/// Enhanced tag input widget with comprehensive features
/// Supports real-time suggestions, validation, and customizable appearance
class TagInput extends StatefulWidget {
  const TagInput({
    super.key,
    this.initialTags = const [],
    this.onTagsChanged,
    this.onTagAdded,
    this.onTagRemoved,
    this.tagValidator,
    this.suggestionCallback,
    this.maxTags,
    this.maxTagLength = 50,
    this.allowDuplicates = false,
    this.caseSensitive = false,
    this.enableSuggestions = true,
    this.suggestionsLimit = 10,
    this.hintText = 'Enter tags...',
    this.tagStyle,
    this.tagDeleteIcon,
    this.suggestionBuilder,
    this.inputDecoration,
    this.separator = ',',
    this.submitKeys = const [LogicalKeyboardKey.enter, LogicalKeyboardKey.comma],
    this.isEnabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.semanticLabel,
  });

  /// Initial list of tags
  final List<String> initialTags;

  /// Callback when the tag list changes
  final ValueChanged<List<String>>? onTagsChanged;

  /// Callback when a tag is added
  final ValueChanged<String>? onTagAdded;

  /// Callback when a tag is removed
  final ValueChanged<String>? onTagRemoved;

  /// Validator for individual tags
  final TagValidator? tagValidator;

  /// Callback for fetching tag suggestions
  final TagSuggestionCallback? suggestionCallback;

  /// Maximum number of tags allowed
  final int? maxTags;

  /// Maximum length for individual tags
  final int maxTagLength;

  /// Whether duplicate tags are allowed
  final bool allowDuplicates;

  /// Whether tag comparison is case sensitive
  final bool caseSensitive;

  /// Whether to show suggestions
  final bool enableSuggestions;

  /// Maximum number of suggestions to show
  final int suggestionsLimit;

  /// Hint text for the input field
  final String hintText;

  /// Custom styling for tags
  final TextStyle? tagStyle;

  /// Custom delete icon for tags
  final Icon? tagDeleteIcon;

  /// Custom builder for suggestion items
  final Widget Function(BuildContext context, String suggestion)? suggestionBuilder;

  /// Input field decoration
  final InputDecoration? inputDecoration;

  /// Character separator for tags
  final String separator;

  /// Keys that submit the current input as a tag
  final List<LogicalKeyboardKey> submitKeys;

  /// Whether the input is enabled
  final bool isEnabled;

  /// Whether to autofocus the input
  final bool autofocus;

  /// Text input action for the keyboard
  final TextInputAction textInputAction;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<String> _tags = [];
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  String _currentInput = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _textController = TextEditingController();
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: MindHouseDesignTokens.animationFast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    
    // Check for separator
    if (text.contains(widget.separator)) {
      final parts = text.split(widget.separator);
      if (parts.length > 1) {
        final tag = parts[0].trim();
        if (tag.isNotEmpty) {
          _addTag(tag);
        }
        _textController.text = parts.sublist(1).join(widget.separator);
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
      return;
    }

    setState(() {
      _currentInput = text;
    });

    if (widget.enableSuggestions && text.isNotEmpty) {
      _fetchSuggestions(text);
    } else {
      _hideSuggestions();
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (widget.enableSuggestions && _currentInput.isNotEmpty) {
        _fetchSuggestions(_currentInput);
      }
    } else {
      _hideSuggestions();
      if (_currentInput.isNotEmpty) {
        _addTag(_currentInput);
      }
    }
  }

  void _addTag(String tagText) {
    final tag = tagText.trim();
    if (tag.isEmpty) return;

    // Validate tag length
    if (tag.length > widget.maxTagLength) {
      _showError('Tag too long (max ${widget.maxTagLength} characters)');
      return;
    }

    // Check max tags limit
    if (widget.maxTags != null && _tags.length >= widget.maxTags!) {
      _showError('Maximum ${widget.maxTags} tags allowed');
      return;
    }

    // Check for duplicates
    if (!widget.allowDuplicates && _containsTag(tag)) {
      _showError('Tag already exists');
      return;
    }

    // Validate with custom validator
    if (widget.tagValidator != null) {
      final error = widget.tagValidator!(tag);
      if (error != null) {
        _showError(error);
        return;
      }
    }

    setState(() {
      _tags.add(tag);
      _textController.clear();
      _currentInput = '';
    });

    _hideSuggestions();
    widget.onTagAdded?.call(tag);
    widget.onTagsChanged?.call(List.from(_tags));

    // Trigger success animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  void _removeTag(int index) {
    if (index < 0 || index >= _tags.length) return;

    final tag = _tags[index];
    setState(() {
      _tags.removeAt(index);
    });

    widget.onTagRemoved?.call(tag);
    widget.onTagsChanged?.call(List.from(_tags));

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  bool _containsTag(String tag) {
    return _tags.any((existingTag) =>
        widget.caseSensitive
            ? existingTag == tag
            : existingTag.toLowerCase() == tag.toLowerCase());
  }

  Future<void> _fetchSuggestions(String query) async {
    if (widget.suggestionCallback == null || query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await widget.suggestionCallback!(query);
      setState(() {
        _suggestions = suggestions
            .where((suggestion) => !_containsTag(suggestion))
            .take(widget.suggestionsLimit)
            .toList();
        _showSuggestions = _suggestions.isNotEmpty;
        _isLoading = false;
      });

      if (_showSuggestions) {
        _showSuggestionsOverlay();
      } else {
        _hideSuggestions();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showSuggestions = false;
      });
      _hideSuggestions();
    }
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildSuggestionsOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    setState(() {
      _showSuggestions = false;
    });
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectSuggestion(String suggestion) {
    _addTag(suggestion);
  }

  bool _onKeyPressed(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    if (widget.submitKeys.contains(event.logicalKey)) {
      if (_currentInput.isNotEmpty) {
        _addTag(_currentInput);
        return true;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _currentInput.isEmpty &&
        _tags.isNotEmpty) {
      _removeTag(_tags.length - 1);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? 'Tag input',
      textField: true,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(theme),
            if (_tags.isNotEmpty) ...[
              SizedBox(height: MindHouseDesignTokens.spaceSM),
              _buildTagsList(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) => _onKeyPressed(event),
      child: TextFormField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.isEnabled,
        autofocus: widget.autofocus,
        textInputAction: widget.textInputAction,
        decoration: widget.inputDecoration?.copyWith(
          hintText: widget.hintText,
          suffixIcon: _isLoading
              ? Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : null,
        ) ?? InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: MindHouseDesignTokens.inputBorderRadius,
          ),
          suffixIcon: _isLoading
              ? Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : null,
        ),
        onFieldSubmitted: (_) {
          if (_currentInput.isNotEmpty) {
            _addTag(_currentInput);
          }
        },
      ),
    );
  }

  Widget _buildTagsList(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Wrap(
          spacing: MindHouseDesignTokens.spaceSM,
          runSpacing: MindHouseDesignTokens.spaceXS,
          children: _tags.asMap().entries.map((entry) {
            final index = entry.key;
            final tag = entry.value;
            return _buildTagChip(theme, tag, index);
          }).toList(),
        );
      },
    );
  }

  Widget _buildTagChip(ThemeData theme, String tag, int index) {
    return Chip(
      label: Text(
        tag,
        style: widget.tagStyle ?? theme.textTheme.labelMedium,
      ),
      deleteIcon: widget.tagDeleteIcon ?? const Icon(Icons.close, size: 18),
      onDeleted: widget.isEnabled ? () => _removeTag(index) : null,
      backgroundColor: theme.colorScheme.primaryContainer,
      deleteIconColor: theme.colorScheme.onPrimaryContainer,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSuggestionsOverlay() {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0, 60),
      child: Material(
        elevation: MindHouseDesignTokens.elevation3,
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return widget.suggestionBuilder?.call(context, suggestion) ??
                  _buildDefaultSuggestionItem(suggestion);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultSuggestionItem(String suggestion) {
    final theme = Theme.of(context);
    
    return ListTile(
      dense: true,
      title: Text(
        suggestion,
        style: theme.textTheme.bodyMedium,
      ),
      leading: Icon(
        Icons.label_outline,
        size: MindHouseDesignTokens.iconSizeSmall,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => _selectSuggestion(suggestion),
      hoverColor: theme.colorScheme.surfaceContainer,
    );
  }
}

/// Factory methods for common tag input configurations
extension TagInputFactory on TagInput {
  /// Create a simple tag input for basic use cases
  static TagInput simple({
    Key? key,
    List<String> initialTags = const [],
    ValueChanged<List<String>>? onTagsChanged,
    String hintText = 'Enter tags...',
    bool isEnabled = true,
  }) {
    return TagInput(
      key: key,
      initialTags: initialTags,
      onTagsChanged: onTagsChanged,
      hintText: hintText,
      isEnabled: isEnabled,
      enableSuggestions: false,
    );
  }

  /// Create a tag input with predefined suggestions
  static TagInput withSuggestions({
    Key? key,
    List<String> initialTags = const [],
    required List<String> suggestions,
    ValueChanged<List<String>>? onTagsChanged,
    String hintText = 'Enter tags...',
    bool isEnabled = true,
  }) {
    return TagInput(
      key: key,
      initialTags: initialTags,
      onTagsChanged: onTagsChanged,
      hintText: hintText,
      isEnabled: isEnabled,
      enableSuggestions: true,
      suggestionCallback: (query) async {
        return suggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      },
    );
  }

  /// Create a tag input for categories with validation
  static TagInput categories({
    Key? key,
    List<String> initialTags = const [],
    ValueChanged<List<String>>? onTagsChanged,
    int maxTags = 5,
    String hintText = 'Add categories...',
    bool isEnabled = true,
  }) {
    return TagInput(
      key: key,
      initialTags: initialTags,
      onTagsChanged: onTagsChanged,
      hintText: hintText,
      isEnabled: isEnabled,
      maxTags: maxTags,
      allowDuplicates: false,
      caseSensitive: false,
      tagValidator: (tag) {
        if (tag.length < 2) return 'Category must be at least 2 characters';
        if (tag.contains(' ')) return 'Categories cannot contain spaces';
        return null;
      },
    );
  }
}