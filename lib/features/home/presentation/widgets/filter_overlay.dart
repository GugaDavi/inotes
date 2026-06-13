import 'package:flutter/cupertino.dart';
import 'package:inotes/core/ui/ui.dart';
import 'package:inotes/features/home/presentation/widgets/chips/sort_direction_chip.dart';
import 'package:inotes/features/home/presentation/widgets/chips/sort_field_chip.dart';
import 'package:inotes/features/home/presentation/widgets/chips/tag_filter_chip.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/shared/sort/sort_option.dart';
import 'package:inotes/features/shared/widgets/date_field.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';

// ── Positioning wrapper ───────────────────────────────────────────────────────

class FilterOverlay extends StatelessWidget {
  const FilterOverlay({
    super.key,
    required this.layerLink,
    required this.initialDate,
    required this.initialTagIds,
    required this.initialSort,
    required this.availableTags,
    required this.onApply,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final DateRangeFilter? initialDate;
  final List<String> initialTagIds;
  final SortOption? initialSort;
  final List<TagEntity> availableTags;
  final void Function(DateRangeFilter?, List<String>, SortOption?) onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: onDismiss),
        ),
        CompositedTransformFollower(
          link: layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 8),
          child: SizedBox(
            width: 320,
            child: FilterOverlayContent(
              initialDate: initialDate,
              initialTagIds: initialTagIds,
              initialSort: initialSort,
              availableTags: availableTags,
              onApply: onApply,
              onDismiss: onDismiss,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stateful form content ─────────────────────────────────────────────────────

class FilterOverlayContent extends StatefulWidget {
  const FilterOverlayContent({
    super.key,
    required this.initialDate,
    required this.initialTagIds,
    required this.initialSort,
    required this.availableTags,
    required this.onApply,
    required this.onDismiss,
  });

  final DateRangeFilter? initialDate;
  final List<String> initialTagIds;
  final SortOption? initialSort;
  final List<TagEntity> availableTags;
  final void Function(DateRangeFilter?, List<String>, SortOption?) onApply;
  final VoidCallback onDismiss;

  @override
  State<FilterOverlayContent> createState() => _FilterOverlayContentState();
}

class _FilterOverlayContentState extends State<FilterOverlayContent> {
  late final TextEditingController _fromCtrl;
  late final TextEditingController _toCtrl;
  bool _hasRange = false;
  String? _fromError;
  String? _toError;
  late List<String> _selectedTagIds;
  SortField? _sortField;
  SortDirection _sortDirection = SortDirection.desc;

  static String _fmtInitial(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  void initState() {
    super.initState();
    _fromCtrl = TextEditingController(text: widget.initialDate != null ? _fmtInitial(widget.initialDate!.from) : '');
    _toCtrl = TextEditingController(text: widget.initialDate?.to != null ? _fmtInitial(widget.initialDate!.to!) : '');
    _hasRange = widget.initialDate?.to != null;
    _selectedTagIds = List.from(widget.initialTagIds);
    _sortField = widget.initialSort?.field;
    _sortDirection = widget.initialSort?.direction ?? SortDirection.desc;
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

  void _selectSortField(SortField field) {
    setState(() => _sortField = _sortField == field ? null : field);
  }

  SortOption? get _sortOption => _sortField != null ? SortOption(field: _sortField!, direction: _sortDirection) : null;

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

    widget.onApply(dateFilter, List.from(_selectedTagIds), _sortOption);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  child: const Icon(CupertinoIcons.xmark_circle_fill, size: 20, color: CupertinoColors.tertiaryLabel),
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
                _sectionLabel('SORT BY'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    SortFieldChip(
                      label: 'Created',
                      isSelected: _sortField == SortField.createdAt,
                      onTap: () => _selectSortField(SortField.createdAt),
                    ),
                    SortFieldChip(
                      label: 'Updated',
                      isSelected: _sortField == SortField.updatedAt,
                      onTap: () => _selectSortField(SortField.updatedAt),
                    ),
                    SortFieldChip(
                      label: 'Title',
                      isSelected: _sortField == SortField.title,
                      onTap: () => _selectSortField(SortField.title),
                    ),
                  ],
                ),
                if (_sortField != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SortDirectionChip(
                        icon: CupertinoIcons.arrow_up,
                        isSelected: _sortDirection == SortDirection.asc,
                        onTap: () => setState(() => _sortDirection = SortDirection.asc),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      SortDirectionChip(
                        icon: CupertinoIcons.arrow_down,
                        isSelected: _sortDirection == SortDirection.desc,
                        onTap: () => setState(() => _sortDirection = SortDirection.desc),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(height: 0.5, color: CupertinoColors.separator),
                const SizedBox(height: 16),
                _sectionLabel('DATE'),
                const SizedBox(height: 10),
                DateField(
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
                  DateField(
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
                  _sectionLabel('TAGS'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: widget.availableTags.map((tag) {
                      final isSelected = _selectedTagIds.contains(tag.id);
                      return TagFilterChip(tag: tag, isSelected: isSelected, onTap: () => _toggleTag(tag.id));
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
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.secondaryLabel,
      letterSpacing: 0.5,
    ),
  );
}
