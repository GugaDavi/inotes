import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/notes/domain/entities/note_tag_entity.dart';

class NoteTagRow extends StatelessWidget {
  const NoteTagRow({super.key, required this.tags});

  final List<NoteTagEntity> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: tags.map((tag) {
        final color = Color(tag.color);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 3),
            Text(
              tag.label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }
}
