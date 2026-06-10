import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

class NoteListTile extends StatefulWidget {
  const NoteListTile({super.key, required this.note, required this.onTap});

  final NoteEntity note;
  final VoidCallback onTap;

  @override
  State<NoteListTile> createState() => _NoteListTileState();
}

class _NoteListTileState extends State<NoteListTile> {
  bool _hovered = false;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(noteDay).inDays;

    if (diff == 0) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.tileHovered : CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.note.title.isEmpty ? 'New Note' : widget.note.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: CupertinoColors.label,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatDate(widget.note.createdAt),
                        style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(CupertinoIcons.chevron_right, size: 12, color: CupertinoColors.tertiaryLabel),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    widget.note.content.isEmpty ? 'No additional text' : widget.note.content,
                    style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
