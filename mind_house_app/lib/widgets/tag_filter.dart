import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_bloc.dart';
import 'package:mind_house_app/blocs/tag/tag_event.dart';
import 'package:mind_house_app/blocs/tag/tag_state.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/widgets/tag_chip.dart';

class TagFilter extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>>? onTagsChanged;
  final bool showAllTags;
  final int maxVisibleTags;

  const TagFilter({
    super.key,
    required this.selectedTags,
    this.onTagsChanged,
    this.showAllTags = false,
    this.maxVisibleTags = 10,
  });

  @override
  State<TagFilter> createState() => _TagFilterState();
}

class _TagFilterState extends State<TagFilter> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
    
    // Load tags if not already loaded
    context.read<TagBloc>().add(
      widget.showAllTags 
        ? LoadAllTags() 
        : LoadMostUsedTags(limit: widget.maxVisibleTags),
    );
  }

  @override
  void didUpdateWidget(TagFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTags != oldWidget.selectedTags) {
      _selectedTags = List.from(widget.selectedTags);
    }
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_selectedTags.contains(tagName)) {
        _selectedTags.remove(tagName);
      } else {
        _selectedTags.add(tagName);
      }
    });
    widget.onTagsChanged?.call(_selectedTags);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTags.clear();
    });
    widget.onTagsChanged?.call(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagBloc, TagState>(
      builder: (context, state) {
        if (state is TagLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (state is TagLoaded && state.tags.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter by tags',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedTags.isNotEmpty)
                      TextButton(
                        onPressed: _clearAllFilters,
                        child: const Text('Clear all'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: state.tags.map((tag) {
                    final isSelected = _selectedTags.contains(tag.name);
                    return FilterTagChip(
                      tag: tag,
                      isSelected: isSelected,
                      onSelected: (_) => _toggleTag(tag.name),
                    );
                  }).toList(),
                ),
                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Active filters: ${_selectedTags.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (state is TagError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading tags: ${state.message}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}