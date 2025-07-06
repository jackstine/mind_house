import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: 24),
              customAction!,
            ] else if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    required this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: 'No results found',
      subtitle: 'No information found for "$query".\nTry adjusting your search terms.',
      actionText: 'Clear Search',
      onActionPressed: onClearSearch,
    );
  }
}

class EmptyInformationState extends StatelessWidget {
  final VoidCallback? onCreateFirst;

  const EmptyInformationState({
    super.key,
    this.onCreateFirst,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.article_outlined,
      title: 'No information yet',
      subtitle: 'Start building your knowledge base by creating your first information entry.',
      actionText: 'Create Information',
      onActionPressed: onCreateFirst,
    );
  }
}

class EmptyTagsState extends StatelessWidget {
  final VoidCallback? onCreateFirst;

  const EmptyTagsState({
    super.key,
    this.onCreateFirst,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.label_outline,
      title: 'No tags yet',
      subtitle: 'Tags help organize your information. Create some information with tags to get started.',
      actionText: 'Add Information',
      onActionPressed: onCreateFirst,
    );
  }
}