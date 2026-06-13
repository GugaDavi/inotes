import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

class TagFilterChip extends StatelessWidget {
  const TagFilterChip({super.key, required this.tag, required this.isSelected, required this.onTap});

  final TagEntity tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(tag.color);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? tagColor.withAlpha(38) : CupertinoColors.systemFill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: isSelected ? tagColor : CupertinoColors.separator, width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                tag.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? tagColor : CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
