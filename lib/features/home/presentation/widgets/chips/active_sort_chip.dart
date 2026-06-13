import 'package:flutter/cupertino.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';

class ActiveSortChip extends StatelessWidget {
  const ActiveSortChip({super.key, required this.sort, required this.onClear});

  final SortOption sort;
  final VoidCallback onClear;

  String get _fieldLabel => switch (sort.field) {
    SortField.createdAt => 'Created',
    SortField.updatedAt => 'Updated',
    SortField.title => 'Title',
  };

  IconData get _directionIcon =>
      sort.direction == SortDirection.asc ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.activeBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_fieldLabel, style: const TextStyle(fontSize: 14, color: CupertinoColors.activeBlue)),
          const SizedBox(width: 3),
          Icon(_directionIcon, size: 12, color: CupertinoColors.activeBlue),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onClear,
              child: const Icon(CupertinoIcons.xmark_circle_fill, size: 14, color: CupertinoColors.activeBlue),
            ),
          ),
        ],
      ),
    );
  }
}
