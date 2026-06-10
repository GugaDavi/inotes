import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/home/presentation/widgets/note_list_tile.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/shared/widgets/buttons/primary_button.dart';

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
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'iNotes',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.41,
                                color: CupertinoColors.label,
                              ),
                            ),
                            PrimaryButton(label: 'New Note', onPressed: _openNote),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: CupertinoSearchTextField()),
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
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: const Icon(CupertinoIcons.square_pencil, size: 40, color: CupertinoColors.white),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No Notes Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: CupertinoColors.label),
            ),
            const SizedBox(height: AppSpacing.sm),
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
        color: AppColors.background,
        border: Border(top: BorderSide(color: CupertinoColors.separator, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
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
