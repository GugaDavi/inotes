import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

List<NoteEntity> _filterNotes((List<NoteEntity>, String) args) {
  final (notes, query) = args;
  if (query.isEmpty) return notes;
  final q = query.toLowerCase();
  return notes.where((n) => n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q)).toList();
}

class NoteSearcher {
  NoteSearcher({required this._onResult, this.debounce = const Duration(milliseconds: 300)});

  final void Function(List<NoteEntity>, String) _onResult;
  final Duration debounce;
  Timer? _timer;

  void search(List<NoteEntity> notes, String query) {
    _timer?.cancel();
    _timer = Timer(debounce, () => _perform(notes, query));
  }

  Future<void> _perform(List<NoteEntity> notes, String query) async {
    final filtered = await compute(_filterNotes, (notes, query));
    _onResult(filtered, query);
  }

  void dispose() => _timer?.cancel();
}
