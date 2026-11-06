import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../data/exam_repository.dart';
import '../models/exam_model.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ExamRepository(api);
});

class ExamState {
  final List<ExamModel> exams;
  final String selectedType; // 'all', 'midterm', 'final', 'quiz', 'lab', 'presentation'
  final bool showUpcomingOnly;
  final bool isLoading;
  final String? error;

  const ExamState({
    this.exams = const [],
    this.selectedType = 'all',
    this.showUpcomingOnly = false,
    this.isLoading = false,
    this.error,
  });

  List<ExamModel> get filteredExams {
    return exams.where((e) {
      if (selectedType != 'all' && e.type != selectedType) return false;
      if (showUpcomingOnly && e.isPast) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  ExamState copyWith({
    List<ExamModel>? exams,
    String? selectedType,
    bool? showUpcomingOnly,
    bool? isLoading,
    String? error,
  }) {
    return ExamState(
      exams: exams ?? this.exams,
      selectedType: selectedType ?? this.selectedType,
      showUpcomingOnly: showUpcomingOnly ?? this.showUpcomingOnly,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExamNotifier extends StateNotifier<ExamState> {
  final ExamRepository _repository;

  ExamNotifier(this._repository) : super(const ExamState()) {
    fetchExams();
  }

  void setTypeFilter(String type) {
    state = state.copyWith(selectedType: type);
  }

  void toggleUpcomingOnly() {
    state = state.copyWith(showUpcomingOnly: !state.showUpcomingOnly);
  }

  Future<void> fetchExams() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getExams();
      state = state.copyWith(exams: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createExam({
    required String subject,
    required String type,
    required String date,
    String? time,
    String? location,
    String? notes,
  }) async {
    try {
      final newExam = await _repository.createExam(
        subject: subject,
        type: type,
        date: date,
        time: time,
        location: location,
        notes: notes,
      );
      state = state.copyWith(exams: [...state.exams, newExam]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateExam(
    String id, {
    String? subject,
    String? type,
    String? date,
    String? time,
    String? location,
    String? notes,
  }) async {
    try {
      final updated = await _repository.updateExam(
        id,
        subject: subject,
        type: type,
        date: date,
        time: time,
        location: location,
        notes: notes,
      );
      state = state.copyWith(
        exams: state.exams.map((e) => e.id == id ? updated : e).toList(),
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

  Future<bool> deleteExam(String id) async {
    try {
      await _repository.deleteExam(id);
      state = state.copyWith(
        exams: state.exams.where((e) => e.id != id).toList(),
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

final examProvider = StateNotifierProvider<ExamNotifier, ExamState>((ref) {
  final repo = ref.watch(examRepositoryProvider);
  return ExamNotifier(repo);
});
