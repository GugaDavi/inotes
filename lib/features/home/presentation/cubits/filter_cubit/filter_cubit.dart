import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inotes/core/result/result.dart';
import 'package:inotes/features/home/domain/entities/filter_options_entity.dart';
import 'package:inotes/features/home/presentation/cubits/filter_cubit/filter_state.dart';
import 'package:inotes/features/shared/filter/date_range_filter.dart';
import 'package:inotes/features/tags/domain/entities/tag_entity.dart';
import 'package:inotes/features/tags/domain/usecases/get_tags_use_case.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this._getTagsUseCase) : super(const FilterState());

  final GetTagsUseCase _getTagsUseCase;

  List<TagEntity> _availableTags = [];
  List<TagEntity> get availableTags => _availableTags;

  Future<void> loadTags() async {
    final result = await _getTagsUseCase.execute();
    if (result case Success(:final value)) _availableTags = value;
  }

  void applyFilters(DateRangeFilter? dateFilter, List<String> tagFilter) {
    emit(
      FilterState(
        options: FilterOptionsEntity(dateFilter: dateFilter, tagFilter: tagFilter),
      ),
    );
  }
}
