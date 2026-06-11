import 'dart:ui';

import 'package:go_router/go_router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.noteId, this.note});

  final String noteId;
  final NoteEntity? note;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final NoteDetailCubit _cubit;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  NoteEntity? _loadedNote;

  bool get _isNew => widget.noteId == 'new';
  bool get _isEditing => !_isNew;

  NoteEntity? get _effectiveNote => widget.note ?? _loadedNote;

  @override
  void initState() {
    super.initState();
    _cubit = Locator.get<NoteDetailCubit>();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');

    if (_isEditing && widget.note == null) {
      _cubit.loadNote(id: widget.noteId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    _cubit.save(
      id: _isEditing ? (_effectiveNote?.id ?? widget.noteId) : null,
      title: _titleController.text,
      content: _contentController.text,
    );
  }

  void _confirmDelete() {
    final id = _effectiveNote?.id ?? widget.noteId;
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _cubit.delete(id: id);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteDetailCubit, NoteDetailState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is NoteDetailNoteReady) {
          _loadedNote = state.note;
          _titleController.text = state.note.title;
          _contentController.text = state.note.content;
        }
        if (state is NoteDetailSaved || state is NoteDetailDeleted) {
          context.pop(true);
        }
        if (state is NoteDetailError && (state is! NoteDetailFetchingNote)) {
          showCupertinoDialog<void>(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(state.message),
              actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
            ),
          );
        }
      },
      builder: (context, state) {
        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.pop(false),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: const ColoredBox(color: AppColors.scrim),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: AppSpacing.maxModalWidth),
                      child: state is NoteDetailFetchingNote
                          ? const _LoadingCard()
                          : _NoteDetailCard(
                              cubit: _cubit,
                              isEditing: _isEditing,
                              titleController: _titleController,
                              contentController: _contentController,
                              onSave: _save,
                              onCancel: () => context.pop(false),
                              onDelete: _isEditing ? _confirmDelete : null,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }
}

class _NoteDetailCard extends StatelessWidget {
  const _NoteDetailCard({
    required this.cubit,
    required this.isEditing,
    required this.titleController,
    required this.contentController,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  final NoteDetailCubit cubit;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(cubit: cubit, isEditing: isEditing, onSave: onSave, onCancel: onCancel, onDelete: onDelete),
          Container(height: 0.5, color: CupertinoColors.separator),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 12, AppSpacing.md, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoTextField(
                  controller: titleController,
                  placeholder: 'Title',
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: CupertinoColors.label),
                  placeholderStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.placeholderText,
                  ),
                  decoration: null,
                ),
                const SizedBox(height: AppSpacing.sm),
                CupertinoTextField(
                  controller: contentController,
                  placeholder: 'Start typing…',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 6,
                  minLines: 3,
                  style: const TextStyle(fontSize: 15, color: CupertinoColors.label),
                  placeholderStyle: const TextStyle(fontSize: 15, color: CupertinoColors.placeholderText),
                  decoration: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.cubit,
    required this.isEditing,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  final NoteDetailCubit cubit;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            onPressed: onCancel,
            child: const Text('Cancel', style: TextStyle(color: CupertinoColors.secondaryLabel)),
          ),
          Text(
            isEditing ? 'Edit Note' : 'New Note',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CupertinoColors.label),
          ),
          BlocBuilder<NoteDetailCubit, NoteDetailState>(
            bloc: cubit,
            builder: (context, state) {
              final isBusy = state is NoteDetailSaving || state is NoteDetailDeleting;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onDelete != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: isBusy ? null : onDelete,
                      child: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed, size: 20),
                    ),
                  CupertinoButton(
                    onPressed: isBusy ? null : onSave,
                    child: isBusy
                        ? const CupertinoActivityIndicator()
                        : const Text(
                            'Done',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
