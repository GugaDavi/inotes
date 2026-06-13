import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_state.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:inotes/features/home/presentation/cubits/home_cubit/home_state.dart';
import 'package:inotes/features/home/presentation/widgets/chips/active_filter_chip.dart';
import 'package:inotes/features/home/presentation/widgets/chips/active_sort_chip.dart';
import 'package:inotes/features/home/presentation/widgets/chips/active_tag_chip.dart';
import 'package:inotes/features/home/presentation/widgets/filter_overlay.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';

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
  int _openKey = 0;

  void _toggle(FilterState currentFilter) {
    if (_entry != null) {
      _close();
      return;
    }
    _open(currentFilter);
  }

  void _open(FilterState currentFilter) {
    _openKey++;
    _entry = OverlayEntry(
      builder: (_) => FilterOverlay(
        key: ValueKey(_openKey),
        layerLink: _layerLink,
        initialDate: currentFilter.options?.dateFilter,
        initialTagIds: currentFilter.options?.tagFilter ?? [],
        initialSort: currentFilter.options?.sortOption,
        availableTags: widget.filterCubit.availableTags,
        onApply: (date, tags, sort) {
          widget.filterCubit.applyFilters(date, tags, sortOption: sort);
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
            final sortOption = filterState.options?.sortOption;
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
                  if (sortOption != null)
                    ActiveSortChip(
                      sort: sortOption,
                      onClear: () => widget.filterCubit.applyFilters(dateFilter, tagFilter),
                    ),
                  if (dateFilter != null)
                    ActiveFilterChip(
                      label: _fmtDate(dateFilter),
                      onClear: () => widget.filterCubit.applyFilters(null, tagFilter, sortOption: sortOption),
                    ),
                  for (final tag in activeTagEntities)
                    ActiveTagChip(
                      tag: tag,
                      onClear: () => widget.filterCubit.applyFilters(
                        dateFilter,
                        tagFilter.where((id) => id != tag.id).toList(),
                        sortOption: sortOption,
                      ),
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
