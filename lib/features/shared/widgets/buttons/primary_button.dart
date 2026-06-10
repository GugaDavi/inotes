import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.onAccent, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
