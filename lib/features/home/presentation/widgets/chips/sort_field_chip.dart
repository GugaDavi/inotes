import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';

class SortFieldChip extends StatelessWidget {
  const SortFieldChip({super.key, required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.12) : CupertinoColors.systemFill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.separator,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
