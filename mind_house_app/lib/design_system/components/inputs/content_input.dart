// Enhanced Content Input Component
// Material Design 3 compliant rich text input with formatting and markdown support

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

/// Text formatting options for rich content
enum TextFormatting {
  bold,
  italic,
  underline,
  strikethrough,
  code,
  link,
  bulletList,
  numberedList,
  heading,
}

/// Content input mode for different use cases
enum ContentInputMode {
  /// Plain text input
  plain,

  /// Markdown-formatted input
  markdown,

  /// Rich text with toolbar
  rich,

  /// Code input with syntax highlighting hints
  code,
}

/// Size variants for different content types
enum ContentInputSize {
  compact,
  standard,
  expanded,
}

/// Enhanced content input widget with rich text support
/// Supports markdown, formatting toolbar, and customizable appearance
class ContentInput extends StatefulWidget {
  const ContentInput({
    super.key,
    this.initialContent = '',
    this.onContentChanged,
    this.onSubmitted,
    this.mode = ContentInputMode.plain,
    this.size = ContentInputSize.standard,
    this.placeholder = 'Start writing...',
    this.enableFormatting = true,
    this.enableMarkdown = false,
    this.enableAutoSave = false,
    this.autoSaveInterval = const Duration(seconds: 5),
    this.maxLength,
    this.maxLines,
    this.minLines = 3,
    this.textInputAction = TextInputAction.newline,
    this.keyboardType = TextInputType.multiline,
    this.isEnabled = true,
    this.autofocus = false,
    this.showWordCount = false,
    this.showCharacterCount = false,
    this.enableSpellCheck = true,
    this.enableSuggestions = true,
    this.customToolbarActions = const [],
    this.onFormatApplied,
    this.contentStyle,
    this.placeholderStyle,
    this.decoration,
    this.semanticLabel,
  });

  /// Initial content text
  final String initialContent;

  /// Callback when content changes
  final ValueChanged<String>? onContentChanged;

  /// Callback when user submits content
  final ValueChanged<String>? onSubmitted;

  /// Input mode for different content types
  final ContentInputMode mode;

  /// Size variant for different layouts
  final ContentInputSize size;

  /// Placeholder text when empty
  final String placeholder;

  /// Whether formatting toolbar is enabled
  final bool enableFormatting;

  /// Whether markdown syntax is supported
  final bool enableMarkdown;

  /// Whether to auto-save content periodically
  final bool enableAutoSave;

  /// Auto-save interval duration
  final Duration autoSaveInterval;

  /// Maximum content length
  final int? maxLength;

  /// Maximum number of lines (null for unlimited)
  final int? maxLines;

  /// Minimum number of lines
  final int minLines;

  /// Text input action for keyboard
  final TextInputAction textInputAction;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Whether input is enabled
  final bool isEnabled;

  /// Whether to autofocus
  final bool autofocus;

  /// Whether to show word count
  final bool showWordCount;

  /// Whether to show character count
  final bool showCharacterCount;

  /// Whether spell check is enabled
  final bool enableSpellCheck;

  /// Whether input suggestions are enabled
  final bool enableSuggestions;

  /// Custom toolbar actions
  final List<Widget> customToolbarActions;

  /// Callback when formatting is applied
  final ValueChanged<TextFormatting>? onFormatApplied;

  /// Custom text style
  final TextStyle? contentStyle;

  /// Custom placeholder style
  final TextStyle? placeholderStyle;

  /// Input decoration
  final InputDecoration? decoration;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<ContentInput> createState() => _ContentInputState();
}

class _ContentInputState extends State<ContentInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Timer? _autoSaveTimer;
  int _wordCount = 0;
  int _characterCount = 0;
  bool _isToolbarVisible = false;
  TextSelection _lastSelection = const TextSelection.collapsed(offset: 0);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
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

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _updateCounts();
    _startAutoSaveTimer();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _updateCounts();
    widget.onContentChanged?.call(_controller.text);
    _restartAutoSaveTimer();
  }

  void _onFocusChanged() {
    setState(() {
      _isToolbarVisible = _focusNode.hasFocus && 
          widget.enableFormatting && 
          widget.mode != ContentInputMode.plain;
    });

    if (_isToolbarVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _updateCounts() {
    final text = _controller.text;
    setState(() {
      _characterCount = text.length;
      _wordCount = text.isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  void _startAutoSaveTimer() {
    if (!widget.enableAutoSave) return;
    
    _autoSaveTimer = Timer.periodic(widget.autoSaveInterval, (_) {
      _performAutoSave();
    });
  }

  void _restartAutoSaveTimer() {
    if (!widget.enableAutoSave) return;
    
    _autoSaveTimer?.cancel();
    _startAutoSaveTimer();
  }

  void _performAutoSave() {
    // Auto-save logic would go here
    // This is a placeholder for integration with actual storage
    debugPrint('Auto-saving content: ${_controller.text.length} characters');
  }

  void _applyFormatting(TextFormatting formatting) {
    final selection = _controller.selection;
    final text = _controller.text;
    
    if (!selection.isValid) return;

    String prefix = '';
    String suffix = '';
    String replacement = '';

    switch (formatting) {
      case TextFormatting.bold:
        if (widget.mode == ContentInputMode.markdown) {
          prefix = '**';
          suffix = '**';
        } else {
          // For rich text mode, we'd apply actual formatting
          replacement = '**${selection.textInside(text)}**';
        }
        break;
      case TextFormatting.italic:
        if (widget.mode == ContentInputMode.markdown) {
          prefix = '*';
          suffix = '*';
        } else {
          replacement = '*${selection.textInside(text)}*';
        }
        break;
      case TextFormatting.underline:
        replacement = '<u>${selection.textInside(text)}</u>';
        break;
      case TextFormatting.strikethrough:
        replacement = '~~${selection.textInside(text)}~~';
        break;
      case TextFormatting.code:
        if (selection.isCollapsed) {
          prefix = '`';
          suffix = '`';
        } else {
          replacement = '`${selection.textInside(text)}`';
        }
        break;
      case TextFormatting.link:
        replacement = '[${selection.textInside(text)}](url)';
        break;
      case TextFormatting.bulletList:
        replacement = '• ${selection.textInside(text)}';
        break;
      case TextFormatting.numberedList:
        replacement = '1. ${selection.textInside(text)}';
        break;
      case TextFormatting.heading:
        replacement = '# ${selection.textInside(text)}';
        break;
    }

    if (replacement.isNotEmpty) {
      _controller.text = text.replaceRange(
        selection.start,
        selection.end,
        replacement,
      );
      _controller.selection = TextSelection.collapsed(
        offset: selection.start + replacement.length,
      );
    } else if (prefix.isNotEmpty || suffix.isNotEmpty) {
      final selectedText = selection.textInside(text);
      final newText = '$prefix$selectedText$suffix';
      
      _controller.text = text.replaceRange(
        selection.start,
        selection.end,
        newText,
      );
      
      if (selection.isCollapsed) {
        _controller.selection = TextSelection.collapsed(
          offset: selection.start + prefix.length,
        );
      } else {
        _controller.selection = TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.start + prefix.length + selectedText.length,
        );
      }
    }

    widget.onFormatApplied?.call(formatting);
    HapticFeedback.selectionClick();
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ContentInputSize.compact:
        return const EdgeInsets.all(12.0);
      case ContentInputSize.standard:
        return MindHouseDesignTokens.componentPaddingMedium;
      case ContentInputSize.expanded:
        return MindHouseDesignTokens.componentPaddingLarge;
    }
  }

  int _getMinLines() {
    switch (widget.size) {
      case ContentInputSize.compact:
        return 2;
      case ContentInputSize.standard:
        return widget.minLines;
      case ContentInputSize.expanded:
        return widget.minLines + 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? 'Content input',
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isToolbarVisible) ...[
            _buildFormattingToolbar(theme),
            SizedBox(height: MindHouseDesignTokens.spaceSM),
          ],
          _buildInputField(theme),
          if (widget.showWordCount || widget.showCharacterCount) ...[
            SizedBox(height: MindHouseDesignTokens.spaceXS),
            _buildCounters(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MindHouseDesignTokens.spaceSM,
              vertical: MindHouseDesignTokens.spaceXS,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(MindHouseDesignTokens.radiusMD),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 0.5,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._buildFormattingButtons(theme),
                  if (widget.customToolbarActions.isNotEmpty) ...[
                    SizedBox(width: MindHouseDesignTokens.spaceSM),
                    Container(
                      width: 1,
                      height: 24,
                      color: theme.colorScheme.outline,
                    ),
                    SizedBox(width: MindHouseDesignTokens.spaceSM),
                    ...widget.customToolbarActions,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFormattingButtons(ThemeData theme) {
    final buttons = <Widget>[];

    if (widget.mode == ContentInputMode.markdown || 
        widget.mode == ContentInputMode.rich) {
      buttons.addAll([
        _buildToolbarButton(
          theme,
          Icons.format_bold,
          'Bold',
          () => _applyFormatting(TextFormatting.bold),
        ),
        _buildToolbarButton(
          theme,
          Icons.format_italic,
          'Italic',
          () => _applyFormatting(TextFormatting.italic),
        ),
        _buildToolbarButton(
          theme,
          Icons.format_underlined,
          'Underline',
          () => _applyFormatting(TextFormatting.underline),
        ),
        _buildToolbarButton(
          theme,
          Icons.strikethrough_s,
          'Strikethrough',
          () => _applyFormatting(TextFormatting.strikethrough),
        ),
        _buildToolbarButton(
          theme,
          Icons.code,
          'Code',
          () => _applyFormatting(TextFormatting.code),
        ),
        _buildToolbarButton(
          theme,
          Icons.link,
          'Link',
          () => _applyFormatting(TextFormatting.link),
        ),
        _buildToolbarButton(
          theme,
          Icons.format_list_bulleted,
          'Bullet List',
          () => _applyFormatting(TextFormatting.bulletList),
        ),
        _buildToolbarButton(
          theme,
          Icons.format_list_numbered,
          'Numbered List',
          () => _applyFormatting(TextFormatting.numberedList),
        ),
        _buildToolbarButton(
          theme,
          Icons.title,
          'Heading',
          () => _applyFormatting(TextFormatting.heading),
        ),
      ]);
    }

    return buttons;
  }

  Widget _buildToolbarButton(
    ThemeData theme,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: MindHouseDesignTokens.spaceXS),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(MindHouseDesignTokens.radiusSM),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MindHouseDesignTokens.radiusSM),
              ),
              child: Icon(
                icon,
                size: MindHouseDesignTokens.iconSizeSmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(ThemeData theme) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.isEnabled,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: _getMinLines(),
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      enableSuggestions: widget.enableSuggestions,
      spellCheckConfiguration: widget.enableSpellCheck
          ? const SpellCheckConfiguration()
          : const SpellCheckConfiguration.disabled(),
      style: widget.contentStyle ?? theme.textTheme.bodyLarge,
      decoration: widget.decoration?.copyWith(
        hintText: widget.placeholder,
        hintStyle: widget.placeholderStyle ?? theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        contentPadding: _getPadding(),
        counterText: '', // Hide default counter
      ) ?? InputDecoration(
        hintText: widget.placeholder,
        hintStyle: widget.placeholderStyle ?? theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        contentPadding: _getPadding(),
        border: OutlineInputBorder(
          borderRadius: MindHouseDesignTokens.inputBorderRadius,
        ),
        counterText: '', // Hide default counter
      ),
      onFieldSubmitted: widget.onSubmitted,
      onChanged: (text) {
        _lastSelection = _controller.selection;
      },
    );
  }

  Widget _buildCounters(ThemeData theme) {
    final counters = <String>[];
    
    if (widget.showWordCount) {
      counters.add('$_wordCount words');
    }
    
    if (widget.showCharacterCount) {
      final remaining = widget.maxLength != null 
          ? '${widget.maxLength! - _characterCount}' 
          : '$_characterCount';
      counters.add('$remaining characters');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          counters.join(' • '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Factory methods for common content input configurations
extension ContentInputFactory on ContentInput {
  /// Create a simple text area for basic content
  static ContentInput textArea({
    Key? key,
    String initialContent = '',
    ValueChanged<String>? onContentChanged,
    String placeholder = 'Start writing...',
    int minLines = 3,
    int? maxLines,
    bool isEnabled = true,
  }) {
    return ContentInput(
      key: key,
      initialContent: initialContent,
      onContentChanged: onContentChanged,
      placeholder: placeholder,
      minLines: minLines,
      maxLines: maxLines,
      isEnabled: isEnabled,
      mode: ContentInputMode.plain,
      enableFormatting: false,
    );
  }

  /// Create a markdown editor with formatting support
  static ContentInput markdown({
    Key? key,
    String initialContent = '',
    ValueChanged<String>? onContentChanged,
    String placeholder = 'Write in Markdown...',
    bool showWordCount = true,
    bool isEnabled = true,
  }) {
    return ContentInput(
      key: key,
      initialContent: initialContent,
      onContentChanged: onContentChanged,
      placeholder: placeholder,
      isEnabled: isEnabled,
      mode: ContentInputMode.markdown,
      enableFormatting: true,
      enableMarkdown: true,
      showWordCount: showWordCount,
      size: ContentInputSize.expanded,
    );
  }

  /// Create a note input for quick thoughts
  static ContentInput note({
    Key? key,
    String initialContent = '',
    ValueChanged<String>? onContentChanged,
    String placeholder = 'Jot down your thoughts...',
    bool enableAutoSave = true,
    bool isEnabled = true,
  }) {
    return ContentInput(
      key: key,
      initialContent: initialContent,
      onContentChanged: onContentChanged,
      placeholder: placeholder,
      isEnabled: isEnabled,
      mode: ContentInputMode.plain,
      size: ContentInputSize.compact,
      enableAutoSave: enableAutoSave,
      minLines: 2,
      maxLines: 6,
    );
  }

  /// Create a code editor for technical content
  static ContentInput code({
    Key? key,
    String initialContent = '',
    ValueChanged<String>? onContentChanged,
    String placeholder = 'Enter your code...',
    bool showCharacterCount = true,
    bool isEnabled = true,
  }) {
    return ContentInput(
      key: key,
      initialContent: initialContent,
      onContentChanged: onContentChanged,
      placeholder: placeholder,
      isEnabled: isEnabled,
      mode: ContentInputMode.code,
      enableFormatting: false,
      enableSpellCheck: false,
      showCharacterCount: showCharacterCount,
      keyboardType: TextInputType.text,
      contentStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
      ),
    );
  }
}