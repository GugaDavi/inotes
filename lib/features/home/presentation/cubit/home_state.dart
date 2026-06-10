import 'package:equatable/equatable.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.notes);

  final List<NoteEntity> notes;

  @override
  List<Object?> get props => [notes];
}

final class HomeError extends HomeState {
  const HomeError();

  @override
  List<Object?> get props => [];
}
