import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const CupertinoSliverNavigationBar(
                  largeTitle: Text('iNotes'),
                  backgroundColor: Color(0xFFF2F2F7),
                  border: null,
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: CupertinoSearchTextField(),
                  ),
                ),
                BlocBuilder<HomeCubit, HomeState>(
                  bloc: _cubit,
                  builder: (context, state) => switch (state) {
                    HomeInitial() || HomeLoading() => const SliverFillRemaining(
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                    HomeLoaded(:final notes) when notes.isEmpty =>
                      const SliverFillRemaining(child: _EmptyState()),
                    HomeLoaded(:final notes) => SliverList.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) =>
                          _NoteListTile(note: notes[index]),
                    ),
                    HomeError() => const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Could not load notes.',
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                  },
                ),
              ],
            ),
          ),
          _BottomBar(cubit: _cubit),
        ],
      ),
    );
  }
}

class _NoteListTile extends StatelessWidget {
  const _NoteListTile({required this.note});

  final NoteEntity note;

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
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? 'New Note' : note.title,
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
                        _formatDate(note.createdAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 12,
                        color: CupertinoColors.tertiaryLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    note.content.isEmpty ? 'No additional text' : note.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 20),
              color: CupertinoColors.separator,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD60A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.square_pencil,
                size: 40,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notes Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the compose button to write your first note.',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
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
        border: Border(
          top: BorderSide(color: CupertinoColors.separator, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SafeArea(
        top: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          bloc: cubit,
          builder: (context, state) {
            final count = state is HomeLoaded ? state.notes.length : 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 44),
                Text(
                  count == 1 ? '1 Note' : '$count Notes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: const Icon(
                    CupertinoIcons.square_pencil,
                    size: 26,
                    color: Color(0xFFFFD60A),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
