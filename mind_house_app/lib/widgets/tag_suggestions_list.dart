import 'package:flutter/material.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/widgets/tag_chip.dart';

class TagSuggestionsList extends StatelessWidget {
  final List<Tag> suggestions;
  final ValueChanged<String>? onTagSelected;
  final int maxItems;

  const TagSuggestionsList({
    super.key,
    required this.suggestions,
    this.onTagSelected,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final limitedSuggestions = suggestions.take(maxItems).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (limitedSuggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Suggestions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: limitedSuggestions.length,
              itemBuilder: (context, index) {
                final tag = limitedSuggestions[index];
                return _SuggestionItem(
                  tag: tag,
                  onTap: () => onTagSelected?.call(tag.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  final Tag tag;
  final VoidCallback? onTap;

  const _SuggestionItem({
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            TagChip(
              tag: tag,
              margin: EdgeInsets.zero,
            ),
            const SizedBox(width: 8),
            if (tag.usageCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tag.usageCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Icon(
              Icons.add_circle_outline,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}