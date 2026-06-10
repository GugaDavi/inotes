import 'package:flutter/cupertino.dart';
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
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFFE8E8ED) : CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(widget.note.createdAt),
                        style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                      ),
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.chevron_right, size: 12, color: CupertinoColors.tertiaryLabel),
                    ],
                  ),
                  const SizedBox(height: 3),
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
