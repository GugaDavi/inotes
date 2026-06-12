import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

class DateFilterBar extends StatefulWidget {
  const DateFilterBar({super.key, required this.cubit});

  final HomeCubit cubit;

  @override
  State<DateFilterBar> createState() => _DateFilterBarState();
}

class _DateFilterBarState extends State<DateFilterBar> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;

  void _toggle(DateRangeFilter? current) {
    if (_entry != null) {
      _close();
      return;
    }
    _open(current);
  }

  void _open(DateRangeFilter? current) {
    _entry = OverlayEntry(
      builder: (_) => _DropdownOverlay(
        layerLink: _layerLink,
        initial: current,
        onApply: (filter) {
          widget.cubit.applyDateFilter(filter);
          _close();
        },
        onDismiss: _close,
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state is! HomeLoaded || state.notes.isEmpty) return const SizedBox.shrink();

        final dateFilter = state.dateFilter;
        final isActive = dateFilter != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              CompositedTransformTarget(
                link: _layerLink,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _toggle(dateFilter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? CupertinoColors.activeBlue : CupertinoColors.systemBackground,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 16,
                            color: isActive ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isActive ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: AppSpacing.sm),
                _ActiveFilterChip(filter: dateFilter, onClear: () => widget.cubit.applyDateFilter(null)),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Active filter chip ────────────────────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.filter, required this.onClear});

  final DateRangeFilter filter;
  final VoidCallback onClear;

  String _label() {
    final from = _fmt(filter.from);
    if (filter.to == null) return from;
    return '$from – ${_fmt(filter.to!)}';
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.activeBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_label(), style: const TextStyle(fontSize: 14, color: CupertinoColors.activeBlue)),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onClear,
              child: const Icon(CupertinoIcons.xmark_circle_fill, size: 14, color: CupertinoColors.activeBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown overlay ──────────────────────────────────────────────────────────

class _DropdownOverlay extends StatefulWidget {
  const _DropdownOverlay({
    required this.layerLink,
    required this.initial,
    required this.onApply,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final DateRangeFilter? initial;
  final void Function(DateRangeFilter?) onApply;
  final VoidCallback onDismiss;

  @override
  State<_DropdownOverlay> createState() => _DropdownOverlayState();
}

class _DropdownOverlayState extends State<_DropdownOverlay> {
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  bool _hasRange = false;
  String? _fromError;
  String? _toError;

  static String _fmtInitial(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  void initState() {
    super.initState();
    _fromCtrl = TextEditingController(text: widget.initial != null ? _fmtInitial(widget.initial!.from) : '');
    _toCtrl = TextEditingController(text: widget.initial?.to != null ? _fmtInitial(widget.initial!.to!) : '');
    _hasRange = widget.initial?.to != null;
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  DateTime? _parse(String text) {
    final parts = text.split('/');
    if (parts.length != 3) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null || year < 1000) return null;
    try {
      final d = DateTime(year, month, day);
      // Guard against DateTime auto-correcting invalid dates (e.g. Feb 30).
      if (d.month != month || d.day != day) return null;
      return d;
    } catch (_) {
      return null;
    }
  }

  void _apply() {
    final from = _parse(_fromCtrl.text);
    final to = _hasRange ? _parse(_toCtrl.text) : null;

    setState(() {
      _fromError = from == null ? 'Invalid date' : null;
      _toError = _hasRange && to == null
          ? 'Invalid date'
          : (_hasRange && to != null && to.isBefore(from ?? to))
          ? '"To" must be after "From"'
          : null;
    });

    if (_fromError != null || _toError != null) return;
    widget.onApply(DateRangeFilter(from: from!, to: to));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: widget.onDismiss),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: SizedBox(
            width: 280,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4)),
                  BoxShadow(color: Color(0x0A000000), blurRadius: 32, offset: Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter by Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: widget.onDismiss,
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 20,
                            color: CupertinoColors.tertiaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 0.5, color: CupertinoColors.separator),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateField(
                          label: 'From',
                          controller: _fromCtrl,
                          error: _fromError,
                          onChanged: (_) => setState(() => _fromError = null),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Date range', style: TextStyle(fontSize: 14)),
                            CupertinoSwitch(
                              value: _hasRange,
                              activeTrackColor: AppColors.accent,
                              onChanged: (v) => setState(() {
                                _hasRange = v;
                                _toError = null;
                              }),
                            ),
                          ],
                        ),
                        if (_hasRange) ...[
                          const SizedBox(height: 12),
                          _DateField(
                            label: 'To',
                            controller: _toCtrl,
                            error: _toError,
                            onChanged: (_) => setState(() => _toError = null),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onPressed: _apply,
                            child: const Text('Apply', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Date text field ───────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.controller, this.error, this.onChanged});

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
          inputFormatters: [_DateMaskFormatter()],
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

class _DateMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
