import 'package:equatable/equatable.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

sealed class NoteDetailState extends Equatable {
  const NoteDetailState();
}

final class NoteDetailInitial extends NoteDetailState {
  const NoteDetailInitial();

  @override
  List<Object?> get props => [];
}

final class NoteDetailSaving extends NoteDetailState {
  const NoteDetailSaving();

  @override
  List<Object?> get props => [];
}

final class NoteDetailSaved extends NoteDetailState {
  const NoteDetailSaved(this.note);

  final NoteEntity note;

  @override
  List<Object?> get props => [note];
}

final class NoteDetailDeleting extends NoteDetailState {
  const NoteDetailDeleting();

  @override
  List<Object?> get props => [];
}

final class NoteDetailDeleted extends NoteDetailState {
  const NoteDetailDeleted();

  @override
  List<Object?> get props => [];
}

final class NoteDetailFetchingNote extends NoteDetailState {
  const NoteDetailFetchingNote();

  @override
  List<Object?> get props => [];
}

final class NoteDetailNoteReady extends NoteDetailState {
  const NoteDetailNoteReady(this.note);

  final NoteEntity note;

  @override
  List<Object?> get props => [note];
}

final class NoteDetailError extends NoteDetailState {
  const NoteDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
