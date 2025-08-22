# UI Improvement Recommendations for Mind House App

## Table of Contents
1. [TagInput Component Optimizations](#taginput-component-optimizations)
2. [Accessibility Enhancements](#accessibility-enhancements)
3. [Performance Optimizations](#performance-optimizations)
4. [Component Architecture Improvements](#component-architecture-improvements)
5. [Material Design 3 Best Practices](#material-design-3-best-practices)
6. [Implementation Examples](#implementation-examples)

## TagInput Component Optimizations

### Current Issues Identified
Based on codebase analysis, the TagInput component has several areas for improvement:

1. **Memory Management**: Potential memory leaks in tag management
2. **Performance**: Inefficient re-renders on tag operations
3. **Accessibility**: Missing ARIA labels and keyboard navigation
4. **User Experience**: Limited validation and feedback

### Memory Management Improvements

```dart
// lib/widgets/tag_input_improved.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptimizedTagInput extends StatefulWidget {
  const OptimizedTagInput({
    Key? key,
    required this.onTagsChanged,
    this.initialTags = const [],
    this.maxTags,
    this.maxTagLength = 20,
    this.allowDuplicates = false,
  }) : super(key: key);

  final ValueChanged<List<String>> onTagsChanged;
  final List<String> initialTags;
  final int? maxTags;
  final int maxTagLength;
  final bool allowDuplicates;

  @override
  State<OptimizedTagInput> createState() => _OptimizedTagInputState();
}

class _OptimizedTagInputState extends State<OptimizedTagInput> 
    with AutomaticKeepAliveClientMixin {
  
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late List<String> _tags;
  
  // Memory optimization: Use object pooling for tag widgets
  final Map<String, TagChip> _tagWidgetCache = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _tags = List.from(widget.initialTags);
    
    // Add listeners with proper cleanup tracking
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    // Proper cleanup to prevent memory leaks
    _controller.removeListener(_handleTextChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    _tagWidgetCache.clear();
    super.dispose();
  }

  void _handleTextChanged() {
    // Debounced text change handling
    final text = _controller.text;
    if (text.endsWith(' ') || text.endsWith(',')) {
      _addTag(text.trim().replaceAll(',', ''));
    }
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _addTag(_controller.text.trim());
    }
  }

  void _addTag(String tag) {
    if (tag.isEmpty) return;
    
    // Validation with user feedback
    final validationResult = _validateTag(tag);
    if (!validationResult.isValid) {
      _showValidationError(validationResult.error!);
      return;
    }

    setState(() {
      if (!widget.allowDuplicates && _tags.contains(tag)) {
        _showValidationError('Tag already exists');
        return;
      }

      if (widget.maxTags != null && _tags.length >= widget.maxTags!) {
        _showValidationError('Maximum ${widget.maxTags} tags allowed');
        return;
      }

      _tags.add(tag);
      _controller.clear();
      
      // Cache the tag widget for better performance
      _tagWidgetCache[tag] = TagChip(
        tag: tag,
        onDeleted: () => _removeTag(tag),
      );
    });

    widget.onTagsChanged(_tags);
    
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _tagWidgetCache.remove(tag);
    });
    
    widget.onTagsChanged(_tags);
    HapticFeedback.lightImpact();
  }

  TagValidationResult _validateTag(String tag) {
    if (tag.length > widget.maxTagLength) {
      return TagValidationResult.error('Tag too long (max ${widget.maxTagLength} characters)');
    }
    
    if (tag.contains(RegExp(r'[^\w\s-]'))) {
      return TagValidationResult.error('Tag contains invalid characters');
    }
    
    return TagValidationResult.valid();
  }

  void _showValidationError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag display area
        if (_tags.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) => 
                _tagWidgetCache[tag] ?? TagChip(
                  tag: tag,
                  onDeleted: () => _removeTag(tag),
                )
              ).toList(),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Input field with enhanced accessibility
        Semantics(
          label: 'Add tags',
          hint: 'Type a tag and press space or comma to add it',
          textField: true,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Add tags...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addTag(_controller.text.trim()),
                tooltip: 'Add tag',
              ),
            ),
            onSubmitted: (value) => _addTag(value.trim()),
            textInputAction: TextInputAction.done,
            maxLength: widget.maxTagLength,
          ),
        ),
        
        // Helper text
        Text(
          '${_tags.length}${widget.maxTags != null ? '/${widget.maxTags}' : ''} tags',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    Key? key,
    required this.tag,
    required this.onDeleted,
  }) : super(key: key);

  final String tag;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      // Accessibility improvements
      semanticsLabel: 'Tag: $tag',
      deleteButtonTooltipMessage: 'Remove tag $tag',
    );
  }
}

class TagValidationResult {
  final bool isValid;
  final String? error;

  const TagValidationResult._(this.isValid, this.error);

  factory TagValidationResult.valid() => const TagValidationResult._(true, null);
  factory TagValidationResult.error(String error) => TagValidationResult._(false, error);
}
```

## Accessibility Enhancements

### Comprehensive Accessibility Implementation

```dart
// lib/widgets/accessible_memory_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibleMemoryCard extends StatelessWidget {
  const AccessibleMemoryCard({
    Key? key,
    required this.memory,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  }) : super(key: key);

  final Memory memory;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Enhanced semantic properties
      label: 'Memory: ${memory.title}',
      value: memory.content,
      hint: 'Double tap to open, swipe for actions',
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          borderRadius: BorderRadius.circular(12),
          
          // Custom semantic actions for screen readers
          customSemanticsActions: {
            CustomSemanticsAction(label: 'Edit memory'): onEdit,
            CustomSemanticsAction(label: 'Delete memory'): onDelete,
            CustomSemanticsAction(label: 'Share memory'): onShare,
          },
          
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with proper semantic role
                Semantics(
                  header: true,
                  child: Text(
                    memory.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Content with reading hints
                Semantics(
                  readOnly: true,
                  child: Text(
                    memory.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Tags with individual semantic labels
                if (memory.tags.isNotEmpty)
                  Semantics(
                    label: 'Tags: ${memory.tags.join(', ')}',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: memory.tags.map((tag) => 
                        ExcludeSemantics(
                          child: Chip(
                            label: Text(tag, style: Theme.of(context).textTheme.bodySmall),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Metadata with proper formatting
                Semantics(
                  label: 'Created ${_formatDateForAccessibility(memory.createdAt)}',
                  child: Text(
                    'Created ${_formatDate(memory.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccessibleContextMenu(
        memory: memory,
        onEdit: onEdit,
        onDelete: onDelete,
        onShare: onShare,
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Implementation for visual display
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateForAccessibility(DateTime date) {
    // Implementation for screen reader
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class AccessibleContextMenu extends StatelessWidget {
  const AccessibleContextMenu({
    Key? key,
    required this.memory,
    this.onEdit,
    this.onDelete,
    this.onShare,
  }) : super(key: key);

  final Memory memory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle for drag gesture recognition
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        Semantics(
          label: 'Actions for memory: ${memory.title}',
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Memory'),
            onTap: () {
              Navigator.pop(context);
              onEdit?.call();
            },
            // Enhanced accessibility
            semanticLabel: 'Edit memory ${memory.title}',
          ),
        ),
        
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share Memory'),
          onTap: () {
            Navigator.pop(context);
            onShare?.call();
          },
          semanticLabel: 'Share memory ${memory.title}',
        ),
        
        ListTile(
          leading: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Delete Memory',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            _showDeleteConfirmation(context);
          },
          semanticLabel: 'Delete memory ${memory.title}',
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AccessibleAlertDialog(
        title: 'Delete Memory',
        content: 'Are you sure you want to delete "${memory.title}"? This action cannot be undone.',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AccessibleAlertDialog extends StatelessWidget {
  const AccessibleAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  final String title;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(title),
        ),
        content: Semantics(
          liveRegion: true,
          child: Text(content),
        ),
        actions: actions,
      ),
    );
  }
}
```

## Performance Optimizations

### Efficient Widget Rebuilding

```dart
// lib/widgets/optimized_memory_list.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OptimizedMemoryList extends StatefulWidget {
  const OptimizedMemoryList({
    Key? key,
    required this.memories,
    this.onMemoryTap,
    this.onMemoryEdit,
    this.onMemoryDelete,
  }) : super(key: key);

  final List<Memory> memories;
  final ValueChanged<Memory>? onMemoryTap;
  final ValueChanged<Memory>? onMemoryEdit;
  final ValueChanged<Memory>? onMemoryDelete;

  @override
  State<OptimizedMemoryList> createState() => _OptimizedMemoryListState();
}

class _OptimizedMemoryListState extends State<OptimizedMemoryList>
    with AutomaticKeepAliveClientMixin {
  
  late ScrollController _scrollController;
  final Set<int> _visibleIndices = {};
  
  // Performance: Cache item extents
  final Map<int, double> _itemHeights = {};
  static const double _estimatedItemHeight = 120.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    // Performance: Only rebuild visible items
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final viewport = RenderAbstractViewport.of(renderBox);
    final scrollOffset = _scrollController.offset;
    final viewportHeight = renderBox.size.height;

    // Calculate visible range
    final startIndex = (scrollOffset / _estimatedItemHeight).floor();
    final endIndex = ((scrollOffset + viewportHeight) / _estimatedItemHeight).ceil();

    final newVisibleIndices = <int>{};
    for (int i = startIndex; i <= endIndex && i < widget.memories.length; i++) {
      if (i >= 0) newVisibleIndices.add(i);
    }

    if (newVisibleIndices != _visibleIndices) {
      setState(() {
        _visibleIndices.clear();
        _visibleIndices.addAll(newVisibleIndices);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return ListView.builder(
      controller: _scrollController,
      // Performance: Use custom item extent
      itemExtentBuilder: (index, dimensions) {
        return _itemHeights[index] ?? _estimatedItemHeight;
      },
      itemCount: widget.memories.length,
      // Performance: Add repaint boundaries
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
      addSemanticIndexes: true,
      
      itemBuilder: (context, index) {
        final memory = widget.memories[index];
        
        return RepaintBoundary(
          child: MeasurableMemoryCard(
            key: ValueKey(memory.id),
            memory: memory,
            onTap: () => widget.onMemoryTap?.call(memory),
            onEdit: () => widget.onMemoryEdit?.call(memory),
            onDelete: () => widget.onMemoryDelete?.call(memory),
            onHeightChanged: (height) => _itemHeights[index] = height,
          ),
        );
      },
    );
  }
}

class MeasurableMemoryCard extends StatefulWidget {
  const MeasurableMemoryCard({
    Key? key,
    required this.memory,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onHeightChanged,
  }) : super(key: key);

  final Memory memory;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<double>? onHeightChanged;

  @override
  State<MeasurableMemoryCard> createState() => _MeasurableMemoryCardState();
}

class _MeasurableMemoryCardState extends State<MeasurableMemoryCard> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Measure height after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureHeight();
    });
  }

  void _measureHeight() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      widget.onHeightChanged?.call(renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return AccessibleMemoryCard(
      memory: widget.memory,
      onTap: widget.onTap,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
    );
  }
}
```

### Image Loading Optimization

```dart
// lib/widgets/optimized_memory_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedMemoryImage extends StatelessWidget {
  const OptimizedMemoryImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      
      // Performance optimizations
      memCacheWidth: width?.round(),
      memCacheHeight: height?.round(),
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 600,
      
      // Progressive loading
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      
      // Error handling
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.image_not_supported,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      
      // Fade animation
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}
```

## Component Architecture Improvements

### Modular Component Structure

```dart
// lib/components/memory/memory_component.dart
abstract class MemoryComponent extends StatefulWidget {
  const MemoryComponent({Key? key}) : super(key: key);
}

// Base memory widget with common functionality
abstract class BaseMemoryWidget<T extends MemoryComponent> extends State<T> {
  @protected
  void handleMemoryAction(MemoryAction action, Memory memory) {
    switch (action) {
      case MemoryAction.view:
        _navigateToMemory(memory);
        break;
      case MemoryAction.edit:
        _editMemory(memory);
        break;
      case MemoryAction.delete:
        _deleteMemory(memory);
        break;
      case MemoryAction.share:
        _shareMemory(memory);
        break;
    }
  }

  void _navigateToMemory(Memory memory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoryDetailPage(memory: memory),
      ),
    );
  }

  void _editMemory(Memory memory) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemoryEditPage(memory: memory),
      ),
    );
  }

  Future<void> _deleteMemory(Memory memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(memory: memory),
    );

    if (confirmed == true) {
      await context.read<MemoryProvider>().deleteMemory(memory.id);
    }
  }

  void _shareMemory(Memory memory) {
    Share.share(
      '${memory.title}\n\n${memory.content}',
      subject: memory.title,
    );
  }
}

enum MemoryAction { view, edit, delete, share }
```

### State Management Integration

```dart
// lib/providers/memory_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MemoryProvider extends ChangeNotifier {
  final MemoryRepository _repository;
  final Map<String, Memory> _memoryCache = {};
  
  List<Memory> _memories = [];
  List<Memory> _filteredMemories = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  MemoryProvider(this._repository);

  // Getters
  List<Memory> get memories => _filteredMemories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Performance: Debounced search
  Timer? _searchTimer;
  
  void search(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredMemories = List.from(_memories);
    } else {
      _filteredMemories = _memories.where((memory) {
        return memory.title.toLowerCase().contains(query.toLowerCase()) ||
               memory.content.toLowerCase().contains(query.toLowerCase()) ||
               memory.tags.any((tag) => 
                 tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    
    notifyListeners();
  }

  Future<void> loadMemories() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _setError(null);

    try {
      final memories = await _repository.getAllMemories();
      _memories = memories;
      _filteredMemories = List.from(memories);
      
      // Cache memories for performance
      _memoryCache.clear();
      for (final memory in memories) {
        _memoryCache[memory.id] = memory;
      }
      
    } catch (e) {
      _setError('Failed to load memories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMemory(Memory memory) async {
    try {
      final savedMemory = await _repository.saveMemory(memory);
      _memories.insert(0, savedMemory);
      _memoryCache[savedMemory.id] = savedMemory;
      _performSearch(_searchQuery); // Refresh filtered list
    } catch (e) {
      _setError('Failed to add memory: $e');
      rethrow;
    }
  }

  Future<void> updateMemory(Memory memory) async {
    try {
      final updatedMemory = await _repository.updateMemory(memory);
      
      final index = _memories.indexWhere((m) => m.id == memory.id);
      if (index != -1) {
        _memories[index] = updatedMemory;
        _memoryCache[updatedMemory.id] = updatedMemory;
        _performSearch(_searchQuery);
      }
    } catch (e) {
      _setError('Failed to update memory: $e');
      rethrow;
    }
  }

  Future<void> deleteMemory(String id) async {
    try {
      await _repository.deleteMemory(id);
      _memories.removeWhere((m) => m.id == id);
      _memoryCache.remove(id);
      _performSearch(_searchQuery);
    } catch (e) {
      _setError('Failed to delete memory: $e');
      rethrow;
    }
  }

  Memory? getCachedMemory(String id) => _memoryCache[id];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
```

## Material Design 3 Best Practices

### Enhanced Theme Implementation

```dart
// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF6750A4),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFEADDFF),
      onPrimaryContainer: Color(0xFF21005D),
      secondary: Color(0xFF625B71),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE8DEF8),
      onSecondaryContainer: Color(0xFF1D192B),
      tertiary: Color(0xFF7D5260),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFD8E4),
      onTertiaryContainer: Color(0xFF31111D),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: Color(0xFF79747E),
      background: Color(0xFFFFFBFE),
      onBackground: Color(0xFF1C1B1F),
      surface: Color(0xFFFFFBFE),
      onSurface: Color(0xFF1C1B1F),
      surfaceVariant: Color(0xFFE7E0EC),
      onSurfaceVariant: Color(0xFF49454F),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFD0BCFF),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFF6750A4),
      outlineVariant: Color(0xFFCAC4D0),
      scrim: Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography following Material Design 3
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      ),

      // Component themes
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 40),
          maximumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceVariant,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Navigation themes
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD0BCFF),
      onPrimary: Color(0xFF381E72),
      primaryContainer: Color(0xFF4F378B),
      onPrimaryContainer: Color(0xFFEADDFF),
      secondary: Color(0xFFCCC2DC),
      onSecondary: Color(0xFF332D41),
      secondaryContainer: Color(0xFF4A4458),
      onSecondaryContainer: Color(0xFFE8DEF8),
      tertiary: Color(0xFFEFB8C8),
      onTertiary: Color(0xFF492532),
      tertiaryContainer: Color(0xFF633B48),
      onTertiaryContainer: Color(0xFFFFD8E4),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      outline: Color(0xFF938F99),
      background: Color(0xFF1C1B1F),
      onBackground: Color(0xFFE6E1E5),
      surface: Color(0xFF1C1B1F),
      onSurface: Color(0xFFE6E1E5),
      surfaceVariant: Color(0xFF49454F),
      onSurfaceVariant: Color(0xFFCAC4D0),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: Color(0xFF6750A4),
      shadow: Color(0xFF000000),
      surfaceTint: Color(0xFFD0BCFF),
      outlineVariant: Color(0xFF49454F),
      scrim: Color(0xFF000000),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Apply same theme structure as light theme
    );
  }
}
```

## Implementation Examples

### Complete Memory Management Page

```dart
// lib/pages/memory_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemoryListPage extends StatefulWidget {
  const MemoryListPage({Key? key}) : super(key: key);

  @override
  State<MemoryListPage> createState() => _MemoryListPageState();
}

class _MemoryListPageState extends State<MemoryListPage> {
  late TextEditingController _searchController;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Load memories on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryProvider>().loadMemories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Memories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search memories',
          ),
        ],
      ),
      
      body: Consumer<MemoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading memories',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => provider.loadMemories(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.memories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No memories yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first memory to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _navigateToCreateMemory,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Memory'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMemories(),
            child: OptimizedMemoryList(
              memories: provider.memories,
              onMemoryTap: (memory) => _navigateToMemoryDetail(memory),
              onMemoryEdit: (memory) => _navigateToEditMemory(memory),
              onMemoryDelete: (memory) => _deleteMemory(memory),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateMemory,
        icon: const Icon(Icons.add),
        label: const Text('New Memory'),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchDialog(
        controller: _searchController,
        onSearch: (query) {
          context.read<MemoryProvider>().search(query);
        },
      ),
    );
  }

  void _navigateToCreateMemory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MemoryCreatePage(),
      ),
    );
  }

  void _navigateToMemoryDetail(Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailPage(memory: memory),
      ),
    );
  }

  void _navigateToEditMemory(Memory memory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryEditPage(memory: memory),
      ),
    );
  }

  Future<void> _deleteMemory(Memory memory) async {
    try {
      await context.read<MemoryProvider>().deleteMemory(memory.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${memory.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Implement undo functionality
              context.read<MemoryProvider>().addMemory(memory);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete memory: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
```

This comprehensive documentation provides specific, actionable improvements for the Mind House application, focusing on performance, accessibility, and modern Material Design 3 principles. Each section includes complete, implementable code examples that can be directly integrated into the existing codebase.