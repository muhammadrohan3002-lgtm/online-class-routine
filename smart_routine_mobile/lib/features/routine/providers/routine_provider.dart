import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/date_time_utils.dart';
import '../data/routine_repository.dart';
import '../models/routine_model.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return RoutineRepository(api);
});

class RoutineState {
  final List<RoutineModel> routines;
  final int selectedDay; // 0=Sat..6=Fri
  final String? filterCourseId;
  final bool isWeeklyView;
  final bool isLoading;
  final String? error;

  const RoutineState({
    this.routines = const [],
    this.selectedDay = 0,
    this.filterCourseId,
    this.isWeeklyView = false,
    this.isLoading = false,
    this.error,
  });

  /// Routines filtered by selected day and course
  List<RoutineModel> get filteredRoutines {
    return routines.where((r) {
      if (!isWeeklyView && r.dayOfWeek != selectedDay) return false;
      if (filterCourseId != null && filterCourseId!.isNotEmpty && r.courseId != filterCourseId) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Map of routines grouped by dayOfWeek (for weekly view)
  Map<int, List<RoutineModel>> get weeklyGroupedRoutines {
    final map = <int, List<RoutineModel>>{};
    for (int day = 0; day < 7; day++) {
      map[day] = [];
    }
    for (final r in routines) {
      if (filterCourseId != null && filterCourseId!.isNotEmpty && r.courseId != filterCourseId) {
        continue;
      }
      map[r.dayOfWeek]?.add(r);
    }
    for (final key in map.keys) {
      map[key]!.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return map;
  }

  RoutineState copyWith({
    List<RoutineModel>? routines,
    int? selectedDay,
    String? filterCourseId,
    bool clearCourseFilter = false,
    bool? isWeeklyView,
    bool? isLoading,
    String? error,
  }) {
    return RoutineState(
      routines: routines ?? this.routines,
      selectedDay: selectedDay ?? this.selectedDay,
      filterCourseId: clearCourseFilter ? null : (filterCourseId ?? this.filterCourseId),
      isWeeklyView: isWeeklyView ?? this.isWeeklyView,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RoutineNotifier extends StateNotifier<RoutineState> {
  final RoutineRepository _repository;

  RoutineNotifier(this._repository)
      : super(RoutineState(selectedDay: DateTimeUtils.dateTimeToRoutineDay(DateTime.now()))) {
    fetchRoutines();
  }

  void selectDay(int day) {
    state = state.copyWith(selectedDay: day);
  }

  void setCourseFilter(String? courseId) {
    if (courseId == null) {
      state = state.copyWith(clearCourseFilter: true);
    } else {
      state = state.copyWith(filterCourseId: courseId);
    }
  }

  void toggleViewMode() {
    state = state.copyWith(isWeeklyView: !state.isWeeklyView);
  }

  Future<void> fetchRoutines() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getRoutines();
      state = state.copyWith(routines: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createRoutine({
    String? courseId,
    required String courseName,
    required String courseCode,
    required String teacher,
    required String room,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? colorHex,
  }) async {
    try {
      final newRoutine = await _repository.createRoutine(
        courseId: courseId,
        courseName: courseName,
        courseCode: courseCode,
        teacher: teacher,
        room: room,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        colorHex: colorHex,
      );
      state = state.copyWith(routines: [...state.routines, newRoutine]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateRoutine(
    String id, {
    String? courseId,
    String? courseName,
    String? courseCode,
    String? teacher,
    String? room,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? colorHex,
  }) async {
    try {
      final updated = await _repository.updateRoutine(
        id,
        courseId: courseId,
        courseName: courseName,
        courseCode: courseCode,
        teacher: teacher,
        room: room,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
        colorHex: colorHex,
      );
      state = state.copyWith(
        routines: state.routines.map((r) => r.id == id ? updated : r).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteRoutine(String id) async {
    try {
      await _repository.deleteRoutine(id);
      state = state.copyWith(
        routines: state.routines.where((r) => r.id != id).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final routineProvider = StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
  final repo = ref.watch(routineRepositoryProvider);
  return RoutineNotifier(repo);
});
