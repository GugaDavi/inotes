import 'package:flutter/cupertino.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

class ActiveTagChip extends StatelessWidget {
  const ActiveTagChip({super.key, required this.tag, required this.onClear});

  final TagEntity tag;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(tag.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tagColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            tag.label,
            style: TextStyle(fontSize: 14, color: tagColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onClear,
              child: Icon(CupertinoIcons.xmark_circle_fill, size: 14, color: tagColor),
            ),
          ),
        ],
      ),
    );
  }
}
