import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/home/presentation/cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubit/home_state.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

class DateFilterBar extends StatelessWidget {
  const DateFilterBar({super.key, required this.cubit});

  final HomeCubit cubit;

  void _openPicker(BuildContext context, DateRangeFilter? current) {
    showCupertinoModalPopup<DateRangeFilter?>(
      context: context,
      builder: (_) => _DateFilterPicker(initial: current),
    ).then((result) {
      if (result != null) cubit.applyDateFilter(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is! HomeLoaded || state.notes.isEmpty) return const SizedBox.shrink();

        final dateFilter = state.dateFilter;
        final isActive = dateFilter != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _openPicker(context, dateFilter),
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
                          size: 14,
                          color: isActive ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: AppSpacing.sm),
                _ActiveFilterChip(filter: dateFilter, onClear: () => cubit.applyDateFilter(null)),
              ],
            ],
          ),
        );
      },
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.activeBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_label(), style: const TextStyle(fontSize: 12, color: CupertinoColors.activeBlue)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: const Icon(CupertinoIcons.xmark_circle_fill, size: 14, color: CupertinoColors.activeBlue),
          ),
        ],
      ),
    );
  }
}

class _DateFilterPicker extends StatefulWidget {
  const _DateFilterPicker({this.initial});

  final DateRangeFilter? initial;

  @override
  State<_DateFilterPicker> createState() => _DateFilterPickerState();
}

class _DateFilterPickerState extends State<_DateFilterPicker> {
  late DateTime _from;
  late DateTime _to;
  bool _hasRange = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = widget.initial?.from ?? now;
    _to = widget.initial?.to ?? _from;
    _hasRange = widget.initial?.to != null;
  }

  void _apply() => Navigator.of(context).pop(DateRangeFilter(from: _from, to: _hasRange ? _to : null));

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: CupertinoColors.separator, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Text('Filter by Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  CupertinoButton(padding: EdgeInsets.zero, onPressed: _apply, child: const Text('Apply')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From', style: TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel)),
                  SizedBox(
                    height: 180,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _from,
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (d) => setState(() {
                        _from = d;
                        if (_to.isBefore(_from)) _to = _from;
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Date range', style: TextStyle(fontSize: 15)),
                      CupertinoSwitch(
                        value: _hasRange,
                        onChanged: (v) => setState(() {
                          _hasRange = v;
                          if (v && _to.isBefore(_from)) _to = _from;
                        }),
                      ),
                    ],
                  ),
                  if (_hasRange) ...[
                    const SizedBox(height: 8),
                    const Text('To', style: TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel)),
                    SizedBox(
                      height: 180,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: _to,
                        minimumDate: _from,
                        maximumDate: DateTime.now(),
                        onDateTimeChanged: (d) => setState(() => _to = d),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
