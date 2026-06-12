import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';
import 'package:inotes/features/notes/presentation/widgets/tag_picker.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

class MockNoteDetailCubit extends MockCubit<NoteDetailState> implements NoteDetailCubit {}

const _tTags = [
  TagEntity(id: 'tag1', label: 'Work', color: 0xFF007AFF),
  TagEntity(id: 'tag2', label: 'Personal', color: 0xFF5E5CE6),
  TagEntity(id: 'tag3', label: 'Ideas', color: 0xFFFFCC00),
  TagEntity(id: 'tag4', label: 'Study', color: 0xFF30D158),
];

void main() {
  late MockNoteDetailCubit mockCubit;

  setUp(() {
    mockCubit = MockNoteDetailCubit();
    registerFallbackValue(0);
  });

  Widget wrap(Widget child) => CupertinoApp(
    home: CupertinoPageScaffold(
      child: BlocProvider<NoteDetailCubit>.value(value: mockCubit, child: child),
    ),
  );

  group('TagPicker', () {
    testWidgets('renders nothing when state is not NoteDetailTagsLoaded', (tester) async {
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: const NoteDetailInitial());

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));

      expect(find.text('Tags'), findsNothing);
    });

    testWidgets('renders nothing when available tags list is empty', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: [], selectedTagIds: []);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));

      expect(find.text('Tags'), findsNothing);
    });

    testWidgets('shows Tags label when tags are available', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: _tTags, selectedTagIds: []);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));

      expect(find.text('Tags'), findsOneWidget);
    });

    testWidgets('shows a chip for each available tag', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: _tTags, selectedTagIds: []);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Ideas'), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
    });

    testWidgets('shows maximum tags message when 3 are selected', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: _tTags, selectedTagIds: ['tag1', 'tag2', 'tag3']);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));

      expect(find.text('Maximum 3 tags selected'), findsOneWidget);
    });

    testWidgets('does not show maximum message when fewer than 3 are selected', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: _tTags, selectedTagIds: ['tag1', 'tag2']);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));

      expect(find.text('Maximum 3 tags selected'), findsNothing);
    });

    testWidgets('tapping an unselected chip calls toggleTag', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: _tTags, selectedTagIds: []);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);
      when(
        () => mockCubit.toggleTag(
          any(),
          label: any(named: 'label'),
          color: any(named: 'color'),
        ),
      ).thenReturn(null);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));
      await tester.tap(find.text('Work'));
      await tester.pump();

      verify(() => mockCubit.toggleTag('tag1', label: 'Work', color: 0xFF007AFF)).called(1);
    });

    testWidgets('tapping a disabled chip does not call toggleTag', (tester) async {
      const state = NoteDetailTagsLoaded(availableTags: _tTags, selectedTagIds: ['tag1', 'tag2', 'tag3']);
      whenListen(mockCubit, const Stream<NoteDetailState>.empty(), initialState: state);

      await tester.pumpWidget(wrap(TagPicker(cubit: mockCubit)));
      await tester.tap(find.text('Study'));
      await tester.pump();

      verifyNever(
        () => mockCubit.toggleTag(
          any(),
          label: any(named: 'label'),
          color: any(named: 'color'),
        ),
      );
    });
  });
}
