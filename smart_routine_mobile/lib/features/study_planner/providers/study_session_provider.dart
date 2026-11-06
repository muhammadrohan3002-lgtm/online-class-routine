import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../data/study_session_repository.dart';
import '../models/study_session_model.dart';

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return StudySessionRepository(api);
});

class StudyPlannerState {
  final List<StudySessionModel> sessions;
  final StudyProgressModel? progress;
  final bool isLoading;
  final String? error;

  const StudyPlannerState({
    this.sessions = const [],
    this.progress,
    this.isLoading = false,
    this.error,
  });

  StudyPlannerState copyWith({
    List<StudySessionModel>? sessions,
    StudyProgressModel? progress,
    bool? isLoading,
    String? error,
  }) {
    return StudyPlannerState(
      sessions: sessions ?? this.sessions,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudyPlannerNotifier extends StateNotifier<StudyPlannerState> {
  final StudySessionRepository _repository;

  StudyPlannerNotifier(this._repository) : super(const StudyPlannerState()) {
    fetchData();
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _repository.getSessions();
      final progress = await _repository.getProgress();
      state = state.copyWith(
        sessions: sessions,
        progress: progress,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createSession({
    String? courseId,
    required String courseName,
    required String date,
    required int targetMinutes,
    int completedMinutes = 0,
    String? notes,
  }) async {
    try {
      final newSession = await _repository.createSession(
        courseId: courseId,
        courseName: courseName,
        date: date,
        targetMinutes: targetMinutes,
        completedMinutes: completedMinutes,
        notes: notes,
      );
      state = state.copyWith(sessions: [newSession, ...state.sessions]);
      // Refresh progress
      _refreshProgress();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateSession(
    String id, {
    int? targetMinutes,
    int? completedMinutes,
    String? notes,
    String? date,
  }) async {
    try {
      final updated = await _repository.updateSession(
        id,
        targetMinutes: targetMinutes,
        completedMinutes: completedMinutes,
        notes: notes,
        date: date,
      );
      state = state.copyWith(
        sessions: state.sessions.map((s) => s.id == id ? updated : s).toList(),
      );
      _refreshProgress();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteSession(String id) async {
    try {
      await _repository.deleteSession(id);
      state = state.copyWith(
        sessions: state.sessions.where((s) => s.id != id).toList(),
      );
      _refreshProgress();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> _refreshProgress() async {
    try {
      final progress = await _repository.getProgress();
      state = state.copyWith(progress: progress);
    } catch (_) {}
  }
}

final studyPlannerProvider =
    StateNotifierProvider<StudyPlannerNotifier, StudyPlannerState>((ref) {
  final repo = ref.watch(studySessionRepositoryProvider);
  return StudyPlannerNotifier(repo);
});
