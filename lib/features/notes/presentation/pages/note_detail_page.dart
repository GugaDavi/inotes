import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/di/locator.dart';
import 'package:inotes/features/notes/domain/entities/note_entity.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';

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
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
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
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteDetailCubit, NoteDetailState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is NoteDetailSaved) {
          Navigator.of(context).pop(true);
        }
        if (state is NoteDetailError) {
          showCupertinoDialog<void>(
            context: context,
            builder: (_) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(state.message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
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
                onTap: () => Navigator.of(context).pop(false),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: const Color(0x4D000000)),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: _NoteDetailCard(
                      cubit: _cubit,
                      isEditing: _isEditing,
                      titleController: _titleController,
                      contentController: _contentController,
                      onSave: _save,
                      onCancel: () => Navigator.of(context).pop(false),
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
  });

  final NoteDetailCubit cubit;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            cubit: cubit,
            isEditing: isEditing,
            onSave: onSave,
            onCancel: onCancel,
          ),
          Container(height: 0.5, color: CupertinoColors.separator),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoTextField(
                  controller: titleController,
                  placeholder: 'Title',
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                  placeholderStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.placeholderText,
                  ),
                  decoration: null,
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: contentController,
                  placeholder: 'Start typing…',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 6,
                  minLines: 3,
                  style: const TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.label,
                  ),
                  placeholderStyle: const TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.placeholderText,
                  ),
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
  });

  final NoteDetailCubit cubit;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            onPressed: onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          ),
          Text(
            isEditing ? 'Edit Note' : 'New Note',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          BlocBuilder<NoteDetailCubit, NoteDetailState>(
            bloc: cubit,
            builder: (context, state) {
              final isSaving = state is NoteDetailSaving;
              return CupertinoButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const CupertinoActivityIndicator()
                    : const Text(
                        'Done',
                        style: TextStyle(
                          color: Color(0xFFFFD60A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
