import 'package:flutter/material.dart';
import 'package:mind_house_app/models/information.dart';
import 'package:mind_house_app/models/tag.dart';
import 'package:mind_house_app/widgets/tag_chip.dart';

class InformationCard extends StatelessWidget {
  final Information information;
  final List<Tag>? tags;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const InformationCard({
    super.key,
    required this.information,
    this.tags,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.showActions = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content
                Text(
                  information.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (tags != null && tags!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags!.map((tag) => TagChip(
                      tag: tag,
                      margin: EdgeInsets.zero,
                    )).toList(),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Metadata and actions
                Row(
                  children: [
                    // Timestamps
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created: ${_formatDate(information.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (information.createdAt != information.updatedAt)
                            Text(
                              'Updated: ${_formatDate(information.updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    if (showActions) ...[
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: onEdit,
                          tooltip: 'Edit',
                          iconSize: 20,
                        ),
                      if (onShare != null)
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: onShare,
                          tooltip: 'Share',
                          iconSize: 20,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _showDeleteConfirmation(context),
                          tooltip: 'Delete',
                          iconSize: 20,
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Information'),
          content: const Text(
            'Are you sure you want to delete this information? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}