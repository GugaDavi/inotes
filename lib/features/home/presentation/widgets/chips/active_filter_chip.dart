import 'package:flutter/cupertino.dart';

class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({super.key, required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

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
          Text(label, style: const TextStyle(fontSize: 14, color: CupertinoColors.activeBlue)),
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
