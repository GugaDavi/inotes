import 'package:equatable/equatable.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

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
  const HomeLoaded({
    required this.notes,
    required this.filteredNotes,
    required this.sessionCode,
    this.query = '',
    this.dateFilter,
  });

  final List<NoteEntity> notes;
  final List<NoteEntity> filteredNotes;
  final String sessionCode;
  final String query;
  final DateRangeFilter? dateFilter;

  @override
  List<Object?> get props => [notes, filteredNotes, sessionCode, query, dateFilter];
}

final class HomeError extends HomeState {
  const HomeError();

  @override
  List<Object?> get props => [];
}

final class HomeLoggedOut extends HomeState {
  const HomeLoggedOut();

  @override
  List<Object?> get props => [];
}
