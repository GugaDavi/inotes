import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_cubit.dart';
import 'package:inotes/features/notes/presentation/cubit/note_detail_state.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

class TagPicker extends StatelessWidget {
  const TagPicker({super.key, required this.cubit});

  final NoteDetailCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteDetailCubit, NoteDetailState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is! NoteDetailTagsLoaded || state.availableTags.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CupertinoColors.secondaryLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: state.availableTags.map((tag) {
                final isSelected = state.selectedTagIds.contains(tag.id);
                final isDisabled = !isSelected && state.selectedTagIds.length >= 3;
                return _TagChip(
                  tag: tag,
                  isSelected: isSelected,
                  isDisabled: isDisabled,
                  onTap: isDisabled ? null : () => cubit.toggleTag(tag.id, label: tag.label, color: tag.color),
                );
              }).toList(),
            ),
            if (state.selectedTagIds.length == 3) ...[
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Maximum 3 tags selected',
                style: TextStyle(fontSize: 11, color: CupertinoColors.tertiaryLabel),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag, required this.isSelected, required this.isDisabled, this.onTap});

  final TagEntity tag;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(tag.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.35 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? tagColor.withAlpha(38) : CupertinoColors.systemFill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: isSelected ? tagColor : CupertinoColors.separator, width: isSelected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                tag.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? tagColor : CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
