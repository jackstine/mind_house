// Enhanced Search Interface Component
// Material Design 3 compliant search with advanced filtering and suggestions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/design_tokens.dart';

/// Search result item model
class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.tags = const [],
    this.metadata = const {},
    this.relevanceScore = 0.0,
    this.type,
    this.thumbnail,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final double relevanceScore;
  final String? type;
  final Widget? thumbnail;
}

/// Search filter configuration
class SearchFilter {
  const SearchFilter({
    required this.key,
    required this.label,
    required this.options,
    this.selectedOptions = const [],
    this.allowMultiple = true,
  });

  final String key;
  final String label;
  final List<String> options;
  final List<String> selectedOptions;
  final bool allowMultiple;
}

/// Search interface modes
enum SearchMode {
  /// Simple search with just a text input
  simple,

  /// Advanced search with filters and suggestions
  advanced,

  /// Full-screen search overlay
  fullscreen,
}

/// Callback definitions
typedef SearchCallback = Future<List<SearchResult>> Function(
  String query,
  Map<String, List<String>> filters,
);
typedef SuggestionCallback = Future<List<String>> Function(String query);

/// Enhanced search interface with comprehensive features
/// Supports advanced filtering, suggestions, and customizable appearance
class SearchInterface extends StatefulWidget {
  const SearchInterface({
    super.key,
    this.onSearch,
    this.onSuggestionTap,
    this.onResultTap,
    this.suggestionCallback,
    this.initialQuery = '',
    this.placeholder = 'Search...',
    this.mode = SearchMode.advanced,
    this.filters = const [],
    this.enableSuggestions = true,
    this.enableHistory = true,
    this.enableVoiceSearch = false,
    this.maxSuggestions = 10,
    this.maxHistory = 20,
    this.showResultCount = true,
    this.showClearButton = true,
    this.autofocus = false,
    this.isEnabled = true,
    this.resultBuilder,
    this.suggestionBuilder,
    this.filterBuilder,
    this.emptyStateBuilder,
    this.loadingBuilder,
    this.decoration,
    this.semanticLabel,
  });

  /// Callback when search is performed
  final SearchCallback? onSearch;

  /// Callback when suggestion is tapped
  final ValueChanged<String>? onSuggestionTap;

  /// Callback when result is tapped
  final ValueChanged<SearchResult>? onResultTap;

  /// Callback for fetching suggestions
  final SuggestionCallback? suggestionCallback;

  /// Initial search query
  final String initialQuery;

  /// Placeholder text for search input
  final String placeholder;

  /// Search interface mode
  final SearchMode mode;

  /// Available search filters
  final List<SearchFilter> filters;

  /// Whether to show suggestions
  final bool enableSuggestions;

  /// Whether to track search history
  final bool enableHistory;

  /// Whether voice search is available
  final bool enableVoiceSearch;

  /// Maximum number of suggestions to show
  final int maxSuggestions;

  /// Maximum number of history items to keep
  final int maxHistory;

  /// Whether to show result count
  final bool showResultCount;

  /// Whether to show clear button
  final bool showClearButton;

  /// Whether to autofocus the search input
  final bool autofocus;

  /// Whether search is enabled
  final bool isEnabled;

  /// Custom builder for search results
  final Widget Function(BuildContext, SearchResult, int)? resultBuilder;

  /// Custom builder for suggestions
  final Widget Function(BuildContext, String, int)? suggestionBuilder;

  /// Custom builder for filters
  final Widget Function(BuildContext, SearchFilter)? filterBuilder;

  /// Custom builder for empty state
  final Widget Function(BuildContext)? emptyStateBuilder;

  /// Custom builder for loading state
  final Widget Function(BuildContext)? loadingBuilder;

  /// Input decoration override
  final InputDecoration? decoration;

  /// Accessibility label
  final String? semanticLabel;

  @override
  State<SearchInterface> createState() => _SearchInterfaceState();
}

class _SearchInterfaceState extends State<SearchInterface>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<SearchResult> _results = [];
  List<String> _suggestions = [];
  List<String> _history = [];
  Map<String, List<String>> _activeFilters = {};

  bool _isSearching = false;
  bool _showSuggestions = false;
  bool _showFilters = false;
  bool _hasSearched = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: MindHouseDesignTokens.animationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MindHouseDesignTokens.easeStandard,
    ));

    _searchController.addListener(_onQueryChanged);
    _focusNode.addListener(_onFocusChanged);

    // Initialize filters
    for (final filter in widget.filters) {
      _activeFilters[filter.key] = List.from(filter.selectedOptions);
    }

    // Load search history
    _loadHistory();

    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _searchController.text;
    setState(() {
      _currentQuery = query;
    });

    if (widget.enableSuggestions && query.isNotEmpty && _focusNode.hasFocus) {
      _fetchSuggestions(query);
    } else {
      setState(() {
        _showSuggestions = false;
        _suggestions.clear();
      });
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
      if (widget.enableSuggestions && _currentQuery.isNotEmpty) {
        _fetchSuggestions(_currentQuery);
      } else if (_currentQuery.isEmpty && widget.enableHistory) {
        setState(() {
          _suggestions = List.from(_history);
          _showSuggestions = true;
        });
      }
    } else {
      _animationController.reverse();
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (widget.suggestionCallback == null) return;

    try {
      final suggestions = await widget.suggestionCallback!(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions.take(widget.maxSuggestions).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _performSearch(String query, [bool addToHistory = true]) async {
    if (query.trim().isEmpty || widget.onSearch == null) return;

    setState(() {
      _isSearching = true;
      _showSuggestions = false;
      _hasSearched = true;
    });

    if (addToHistory) {
      _addToHistory(query);
    }

    try {
      final results = await widget.onSearch!(query, _activeFilters);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error performing search: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _results = [];
        });
      }
    }
  }

  void _addToHistory(String query) {
    if (!widget.enableHistory || query.trim().isEmpty) return;

    setState(() {
      _history.remove(query); // Remove if exists
      _history.insert(0, query); // Add to beginning
      if (_history.length > widget.maxHistory) {
        _history.removeLast(); // Maintain max size
      }
    });

    _saveHistory();
  }

  void _loadHistory() {
    // This is a placeholder for actual storage integration
    // In a real app, you'd load from SharedPreferences or similar
    _history = [];
  }

  void _saveHistory() {
    // This is a placeholder for actual storage integration
    // In a real app, you'd save to SharedPreferences or similar
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentQuery = '';
      _results.clear();
      _hasSearched = false;
      _showSuggestions = false;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _updateFilter(String filterKey, List<String> selectedOptions) {
    setState(() {
      _activeFilters[filterKey] = selectedOptions;
    });

    // Re-perform search if we have a current query
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery, false);
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
    widget.onSuggestionTap?.call(suggestion);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel ?? 'Search interface',
      child: Column(
        children: [
          _buildSearchBar(theme),
          if (_showFilters && widget.filters.isNotEmpty) ...[
            SizedBox(height: MindHouseDesignTokens.spaceMD),
            _buildFiltersSection(theme),
          ],
          if (_showSuggestions) ...[
            SizedBox(height: MindHouseDesignTokens.spaceSM),
            _buildSuggestions(theme),
          ],
          if (_hasSearched) ...[
            SizedBox(height: MindHouseDesignTokens.spaceMD),
            _buildResults(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: MindHouseDesignTokens.inputBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: MindHouseDesignTokens.spaceMD),
            child: Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: MindHouseDesignTokens.iconSizeMedium,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              enabled: widget.isEnabled,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              style: theme.textTheme.bodyLarge,
              decoration: widget.decoration?.copyWith(
                hintText: widget.placeholder,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MindHouseDesignTokens.spaceMD,
                  vertical: MindHouseDesignTokens.spaceMD,
                ),
              ) ?? InputDecoration(
                hintText: widget.placeholder,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MindHouseDesignTokens.spaceMD,
                  vertical: MindHouseDesignTokens.spaceMD,
                ),
              ),
              onSubmitted: (query) => _performSearch(query),
            ),
          ),
          if (widget.showClearButton && _currentQuery.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: Icon(
                Icons.clear,
                size: MindHouseDesignTokens.iconSizeMedium,
              ),
              tooltip: 'Clear search',
            ),
          if (widget.filters.isNotEmpty)
            IconButton(
              onPressed: _toggleFilters,
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                size: MindHouseDesignTokens.iconSizeMedium,
              ),
              tooltip: 'Toggle filters',
            ),
          if (widget.enableVoiceSearch)
            IconButton(
              onPressed: _startVoiceSearch,
              icon: Icon(
                Icons.mic,
                size: MindHouseDesignTokens.iconSizeMedium,
              ),
              tooltip: 'Voice search',
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            padding: MindHouseDesignTokens.componentPaddingMedium,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: MindHouseDesignTokens.cardBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleSmall,
                ),
                SizedBox(height: MindHouseDesignTokens.spaceMD),
                ...widget.filters.map((filter) =>
                    widget.filterBuilder?.call(context, filter) ??
                    _buildDefaultFilter(theme, filter)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultFilter(ThemeData theme, SearchFilter filter) {
    return Padding(
      padding: EdgeInsets.only(bottom: MindHouseDesignTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filter.label,
            style: theme.textTheme.labelMedium,
          ),
          SizedBox(height: MindHouseDesignTokens.spaceXS),
          Wrap(
            spacing: MindHouseDesignTokens.spaceSM,
            children: filter.options.map((option) {
              final isSelected = _activeFilters[filter.key]?.contains(option) ?? false;
              
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  final currentSelected = _activeFilters[filter.key] ?? [];
                  List<String> newSelected;
                  
                  if (filter.allowMultiple) {
                    newSelected = List.from(currentSelected);
                    if (selected) {
                      newSelected.add(option);
                    } else {
                      newSelected.remove(option);
                    }
                  } else {
                    newSelected = selected ? [option] : [];
                  }
                  
                  _updateFilter(filter.key, newSelected);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: MindHouseDesignTokens.cardBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: MindHouseDesignTokens.elevation2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return widget.suggestionBuilder?.call(context, suggestion, index) ??
                    _buildDefaultSuggestion(theme, suggestion, index);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultSuggestion(ThemeData theme, String suggestion, int index) {
    final isHistory = _history.contains(suggestion);
    
    return ListTile(
      dense: true,
      leading: Icon(
        isHistory ? Icons.history : Icons.search,
        size: MindHouseDesignTokens.iconSizeSmall,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        suggestion,
        style: theme.textTheme.bodyMedium,
      ),
      onTap: () => _selectSuggestion(suggestion),
      hoverColor: theme.colorScheme.surfaceContainer,
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_isSearching) {
      return widget.loadingBuilder?.call(context) ?? _buildDefaultLoading(theme);
    }

    if (_results.isEmpty) {
      return widget.emptyStateBuilder?.call(context) ?? _buildDefaultEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showResultCount)
          Text(
            '${_results.length} result${_results.length == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        SizedBox(height: MindHouseDesignTokens.spaceMD),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final result = _results[index];
            return widget.resultBuilder?.call(context, result, index) ??
                _buildDefaultResult(theme, result, index);
          },
        ),
      ],
    );
  }

  Widget _buildDefaultLoading(ThemeData theme) {
    return Center(
      child: Padding(
        padding: MindHouseDesignTokens.componentPaddingLarge,
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDefaultEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: MindHouseDesignTokens.componentPaddingLarge,
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: MindHouseDesignTokens.iconSizeXLarge,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: MindHouseDesignTokens.spaceMD),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: MindHouseDesignTokens.spaceXS),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultResult(ThemeData theme, SearchResult result, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: MindHouseDesignTokens.spaceMD),
      child: ListTile(
        leading: result.thumbnail,
        title: Text(
          result.title,
          style: theme.textTheme.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: result.description != null
            ? Text(
                result.description!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () => widget.onResultTap?.call(result),
      ),
    );
  }

  void _startVoiceSearch() {
    // Placeholder for voice search implementation
    // This would integrate with speech_to_text package
    debugPrint('Voice search not implemented');
  }
}

/// Factory methods for common search interface configurations
extension SearchInterfaceFactory on SearchInterface {
  /// Create a simple search bar
  static SearchInterface simple({
    Key? key,
    SearchCallback? onSearch,
    String placeholder = 'Search...',
    bool autofocus = false,
    bool isEnabled = true,
  }) {
    return SearchInterface(
      key: key,
      onSearch: onSearch,
      placeholder: placeholder,
      autofocus: autofocus,
      isEnabled: isEnabled,
      mode: SearchMode.simple,
      enableSuggestions: false,
      enableHistory: false,
    );
  }

  /// Create a full-featured search interface
  static SearchInterface advanced({
    Key? key,
    SearchCallback? onSearch,
    SuggestionCallback? suggestionCallback,
    List<SearchFilter> filters = const [],
    String placeholder = 'Search...',
    bool enableVoiceSearch = false,
    bool isEnabled = true,
  }) {
    return SearchInterface(
      key: key,
      onSearch: onSearch,
      suggestionCallback: suggestionCallback,
      filters: filters,
      placeholder: placeholder,
      enableVoiceSearch: enableVoiceSearch,
      isEnabled: isEnabled,
      mode: SearchMode.advanced,
      enableSuggestions: true,
      enableHistory: true,
    );
  }
}