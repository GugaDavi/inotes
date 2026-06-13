import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';

class SortDirectionChip extends StatelessWidget {
  const SortDirectionChip({super.key, required this.icon, required this.isSelected, required this.onTap});

  final IconData icon;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.12) : CupertinoColors.systemFill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.separator,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Icon(icon, size: 14, color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.secondaryLabel),
        ),
      ),
    );
  }
}
