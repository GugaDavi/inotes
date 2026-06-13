import 'package:equatable/equatable.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

sealed class NoteDetailState extends Equatable {
  const NoteDetailState();
}

final class NoteDetailInitial extends NoteDetailState {
  const NoteDetailInitial();

  @override
  List<Object?> get props => [];
}

final class NoteDetailTagsLoaded extends NoteDetailState {
  const NoteDetailTagsLoaded({required this.availableTags, required this.selectedTagIds, this.isPreviewMode = false});

  final List<TagEntity> availableTags;
  final List<String> selectedTagIds;
  final bool isPreviewMode;

  @override
  List<Object?> get props => [availableTags, selectedTagIds, isPreviewMode];
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

final class NoteDetailError extends NoteDetailState {
  const NoteDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
