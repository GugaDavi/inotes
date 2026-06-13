import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_state.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_state.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({super.key, required this.homeCubit, required this.filterCubit});

  final HomeCubit homeCubit;
  final FilterCubit filterCubit;

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;

  void _toggle(FilterState currentFilter) {
    if (_entry != null) {
      _close();
      return;
    }
    _open(currentFilter);
  }

  void _open(FilterState currentFilter) {
    _entry = OverlayEntry(
      builder: (_) => _FilterOverlay(
        layerLink: _layerLink,
        initialDate: currentFilter.options?.dateFilter,
        initialTagIds: currentFilter.options?.tagFilter ?? [],
        availableTags: widget.filterCubit.availableTags,
        onApply: (date, tags) {
          widget.filterCubit.applyFilters(date, tags);
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

  String _fmtDate(DateRangeFilter filter) {
    final from = _fmt(filter.from);
    if (filter.to == null) return from;
    return '$from – ${_fmt(filter.to!)}';
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (context, homeState) {
        if (homeState is! HomeLoaded || homeState.notes.isEmpty) return const SizedBox.shrink();

        return BlocBuilder<FilterCubit, FilterState>(
          bloc: widget.filterCubit,
          builder: (context, filterState) {
            final dateFilter = filterState.options?.dateFilter;
            final tagFilter = filterState.options?.tagFilter ?? [];
            final activeTagEntities = widget.filterCubit.availableTags.where((t) => tagFilter.contains(t.id)).toList();

            return Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _toggle(filterState),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: filterState.isActive ? CupertinoColors.activeBlue : CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.slider_horizontal_3,
                                size: 16,
                                color: filterState.isActive ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: filterState.isActive ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (dateFilter != null)
                    _ActiveFilterChip(
                      label: _fmtDate(dateFilter),
                      onClear: () => widget.filterCubit.applyFilters(null, tagFilter),
                    ),
                  for (final tag in activeTagEntities)
                    _ActiveTagChip(
                      tag: tag,
                      onClear: () =>
                          widget.filterCubit.applyFilters(dateFilter, tagFilter.where((id) => id != tag.id).toList()),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Active filter chips ───────────────────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.activeBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: CupertinoColors.activeBlue)),
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

class _ActiveTagChip extends StatelessWidget {
  const _ActiveTagChip({required this.tag, required this.onClear});

  final TagEntity tag;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(tag.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tagColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            tag.label,
            style: TextStyle(fontSize: 14, color: tagColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onClear,
              child: Icon(CupertinoIcons.xmark_circle_fill, size: 14, color: tagColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter overlay ────────────────────────────────────────────────────────────

class _FilterOverlay extends StatefulWidget {
  const _FilterOverlay({
    required this.layerLink,
    required this.initialDate,
    required this.initialTagIds,
    required this.availableTags,
    required this.onApply,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final DateRangeFilter? initialDate;
  final List<String> initialTagIds;
  final List<TagEntity> availableTags;
  final void Function(DateRangeFilter?, List<String>) onApply;
  final VoidCallback onDismiss;

  @override
  State<_FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<_FilterOverlay> {
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  bool _hasRange = false;
  String? _fromError;
  String? _toError;
  late List<String> _selectedTagIds;

  static String _fmtInitial(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  void initState() {
    super.initState();
    _fromCtrl = TextEditingController(text: widget.initialDate != null ? _fmtInitial(widget.initialDate!.from) : '');
    _toCtrl = TextEditingController(text: widget.initialDate?.to != null ? _fmtInitial(widget.initialDate!.to!) : '');
    _hasRange = widget.initialDate?.to != null;
    _selectedTagIds = List.from(widget.initialTagIds);
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

  void _toggleTag(String tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
  }

  void _apply() {
    final fromText = _fromCtrl.text.trim();
    DateRangeFilter? dateFilter;

    if (fromText.isNotEmpty) {
      final from = _parse(fromText);
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
      dateFilter = DateRangeFilter(from: from!, to: to);
    } else {
      setState(() {
        _fromError = null;
        _toError = null;
      });
    }

    widget.onApply(dateFilter, List.from(_selectedTagIds));
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
            width: 320,
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
                        const Text('Filters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
                        const Text(
                          'DATE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.secondaryLabel,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DateField(
                          label: 'From',
                          controller: _fromCtrl,
                          error: _fromError,
                          onChanged: (_) => setState(() => _fromError = null),
                        ),
                        const SizedBox(height: 10),
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
                          const SizedBox(height: 10),
                          _DateField(
                            label: 'To',
                            controller: _toCtrl,
                            error: _toError,
                            onChanged: (_) => setState(() => _toError = null),
                          ),
                        ],
                        if (widget.availableTags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(height: 0.5, color: CupertinoColors.separator),
                          const SizedBox(height: 16),
                          const Text(
                            'TAGS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.secondaryLabel,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: widget.availableTags.map((tag) {
                              final isSelected = _selectedTagIds.contains(tag.id);
                              return _TagFilterChip(tag: tag, isSelected: isSelected, onTap: () => _toggleTag(tag.id));
                            }).toList(),
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

// ── Tag filter chip (inside overlay) ─────────────────────────────────────────

class _TagFilterChip extends StatelessWidget {
  const _TagFilterChip({required this.tag, required this.isSelected, required this.onTap});

  final TagEntity tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = Color(tag.color);
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
