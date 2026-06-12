import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';
import 'package:inotes/features/notes/presentation/widgets/tag_picker.dart';

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, this.note});

  final NoteEntity? note;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final NoteDetailCubit _cubit;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _cubit = Locator.get<NoteDetailCubit>();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _cubit.loadTags(initialTags: widget.note?.tags ?? []);
  }

  @override
  void dispose() {
    _cubit.close();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    _cubit.save(id: widget.note?.id, title: _titleController.text, content: _contentController.text);
  }

  void _confirmDelete() {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.pop();
              _cubit.delete(id: widget.note!.id);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(onPressed: () => context.pop(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteDetailCubit, NoteDetailState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is NoteDetailSaved || state is NoteDetailDeleted) {
          context.pop(true);
        }
        if (state is NoteDetailError) {
          showCupertinoDialog<void>(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(state.message),
              actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => context.pop())],
            ),
          );
        }
      },
      child: SizedBox.expand(
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
                    child: _NoteDetailCard(
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
      ),
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
                const SizedBox(height: AppSpacing.md),
                TagPicker(cubit: cubit),
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
