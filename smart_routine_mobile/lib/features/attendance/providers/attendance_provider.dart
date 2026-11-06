import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../data/attendance_repository.dart';
import '../models/attendance_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return AttendanceRepository(api);
});

class AttendanceState {
  final AttendanceSummaryModel? summary;
  final List<AttendanceRecordModel> history;
  final String? filterCourseId;
  final bool isLoading;
  final String? error;

  const AttendanceState({
    this.summary,
    this.history = const [],
    this.filterCourseId,
    this.isLoading = false,
    this.error,
  });

  AttendanceState copyWith({
    AttendanceSummaryModel? summary,
    List<AttendanceRecordModel>? history,
    String? filterCourseId,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceState(
      summary: summary ?? this.summary,
      history: history ?? this.history,
      filterCourseId: clearFilter ? null : (filterCourseId ?? this.filterCourseId),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(const AttendanceState()) {
    fetchData();
  }

  void setCourseFilter(String? courseId) {
    if (courseId == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterCourseId: courseId);
    }
    fetchHistory();
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _repository.getSummary();
      final history = await _repository.getHistory(courseId: state.filterCourseId);
      state = state.copyWith(
        summary: summary,
        history: history,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchHistory() async {
    try {
      final history = await _repository.getHistory(courseId: state.filterCourseId);
      state = state.copyWith(history: history);
    } catch (_) {}
  }

  Future<bool> recordAttendance({
    required String courseId,
    required String courseName,
    required String date,
    required String status,
    String? notes,
  }) async {
    try {
      await _repository.recordAttendance(
        courseId: courseId,
        courseName: courseName,
        date: date,
        status: status,
        notes: notes,
      );
      // Refresh both summary and history
      await fetchData();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    try {
      await _repository.deleteRecord(id);
      await fetchData();
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

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return AttendanceNotifier(repo);
});
