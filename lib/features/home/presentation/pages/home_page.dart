import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/home/presentation/widgets/note_list_tile.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = Locator.get<HomeCubit>()..loadNotes();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openNote([NoteEntity? note]) {
    Navigator.of(context).pushNamed('/note', arguments: note).then((result) {
      if (result == true) _cubit.loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1128),
                child: CustomScrollView(
                  slivers: [
                    const SliverPadding(padding: EdgeInsets.only(top: 24)),
                    CupertinoSliverNavigationBar(
                      largeTitle: const Text('iNotes'),
                      backgroundColor: const Color(0xFFF2F2F7),
                      border: null,
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _openNote,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD60A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'New Note',
                            style: TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.fromLTRB(24, 24, 24, 24), child: CupertinoSearchTextField()),
                    ),
                    BlocBuilder<HomeCubit, HomeState>(
                      bloc: _cubit,
                      builder: (context, state) => switch (state) {
                        HomeInitial() ||
                        HomeLoading() => const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator())),
                        HomeLoaded(:final notes) when notes.isEmpty => SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(onCreateNote: _openNote),
                        ),
                        HomeLoaded(:final notes) => SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList.builder(
                            itemCount: notes.length,
                            itemBuilder: (context, index) =>
                                NoteListTile(note: notes[index], onTap: () => _openNote(notes[index])),
                          ),
                        ),
                        HomeError() => const SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'Could not load notes.',
                              style: TextStyle(color: CupertinoColors.secondaryLabel),
                            ),
                          ),
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _BottomBar(cubit: _cubit),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateNote});

  final VoidCallback onCreateNote;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onCreateNote,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: const Color(0xFFFFD60A), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(CupertinoIcons.square_pencil, size: 40, color: CupertinoColors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notes Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: CupertinoColors.label),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the icon to write your first note.',
              style: TextStyle(fontSize: 14, color: CupertinoColors.secondaryLabel),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.cubit});

  final HomeCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        border: Border(top: BorderSide(color: CupertinoColors.separator, width: 0.5)),
      ),
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1128),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SafeArea(
              top: false,
              child: BlocBuilder<HomeCubit, HomeState>(
                bloc: cubit,
                builder: (context, state) {
                  final count = state is HomeLoaded ? state.notes.length : 0;
                  return Text(
                    count == 1 ? '1 Note' : '$count Notes',
                    style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
