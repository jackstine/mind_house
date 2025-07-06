import 'package:flutter/material.dart';
import 'package:mind_house_app/models/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final bool showDeleteButton;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final EdgeInsetsGeometry? margin;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.showDeleteButton = false,
    this.onTap,
    this.onDeleted,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color? backgroundColor;
    Color? foregroundColor;
    
    if (tag.color != null) {
      try {
        backgroundColor = Color(int.parse(tag.color!, radix: 16) | 0xFF000000);
        // Calculate contrast for foreground color
        final luminance = backgroundColor.computeLuminance();
        foregroundColor = luminance > 0.5 ? Colors.black87 : Colors.white;
      } catch (e) {
        // Fallback to theme colors if color parsing fails
        backgroundColor = isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
        foregroundColor = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
      }
    } else {
      backgroundColor = isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest;
      foregroundColor = isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(
            tag.name,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          backgroundColor: backgroundColor,
          deleteIcon: showDeleteButton ? Icon(
            Icons.close,
            size: 18,
            color: foregroundColor,
          ) : null,
          onDeleted: showDeleteButton ? onDeleted : null,
          elevation: isSelected ? 2 : 0,
          shadowColor: colorScheme.shadow.withOpacity(0.2),
          side: isSelected ? BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ) : null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class FilterTagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final EdgeInsetsGeometry? margin;

  const FilterTagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    this.onSelected,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    
    if (tag.color != null) {
      try {
        backgroundColor = Color(int.parse(tag.color!, radix: 16) | 0xFF000000);
      } catch (e) {
        backgroundColor = null;
      }
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2),
      child: FilterChip(
        label: Text(tag.name),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: backgroundColor,
        showCheckmark: false,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}