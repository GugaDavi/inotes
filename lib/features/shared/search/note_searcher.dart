import 'dart:async';

import 'package:inotes/features/notes/domain/entities/note_entity.dart';

class NoteSearcher {
  NoteSearcher({required this._onResult, this.debounce = const Duration(milliseconds: 300)});

  final void Function(List<NoteEntity>, String) _onResult;
  final Duration debounce;
  Timer? _timer;

  void search(List<NoteEntity> notes, String query) {
    _timer?.cancel();
    _timer = Timer(debounce, () => _perform(notes, query));
  }

  void _perform(List<NoteEntity> notes, String query) {
    if (query.isEmpty) {
      _onResult(notes, query);
      return;
    }
    final q = query.toLowerCase();
    final filtered = notes
        .where((n) => n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q))
        .toList();
    _onResult(filtered, query);
  }

  void dispose() => _timer?.cancel();
}
