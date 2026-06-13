import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/shared/widgets/date_mask_formatter.dart';

class DateField extends StatelessWidget {
  const DateField({super.key, required this.label, required this.controller, this.error, this.onChanged});

  final String label;
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          placeholder: 'MM/DD/YYYY',
          keyboardType: TextInputType.number,
          inputFormatters: [DateMaskFormatter()],
          onChanged: onChanged,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: error != null ? Border.all(color: CupertinoColors.destructiveRed, width: 1) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error!, style: const TextStyle(fontSize: 11, color: CupertinoColors.destructiveRed)),
        ],
      ],
    );
  }
}
