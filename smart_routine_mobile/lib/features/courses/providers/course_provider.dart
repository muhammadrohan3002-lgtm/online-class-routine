import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../data/course_repository.dart';
import '../models/course_model.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return CourseRepository(api);
});

class CourseState {
  final List<CourseModel> courses;
  final bool isLoading;
  final String? error;

  const CourseState({
    this.courses = const [],
    this.isLoading = false,
    this.error,
  });

  CourseState copyWith({
    List<CourseModel>? courses,
    bool? isLoading,
    String? error,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CourseNotifier extends StateNotifier<CourseState> {
  final CourseRepository _repository;

  CourseNotifier(this._repository) : super(const CourseState()) {
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getCourses();
      state = state.copyWith(courses: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCourse({
    required String name,
    required String code,
    String? teacher,
    String? room,
    String? colorHex,
    int credits = 3,
  }) async {
    try {
      final newCourse = await _repository.createCourse(
        name: name,
        code: code,
        teacher: teacher,
        room: room,
        colorHex: colorHex,
        credits: credits,
      );
      state = state.copyWith(courses: [...state.courses, newCourse]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCourse(
    String id, {
    String? name,
    String? code,
    String? teacher,
    String? room,
    String? colorHex,
    int? credits,
  }) async {
    try {
      final updated = await _repository.updateCourse(
        id,
        name: name,
        code: code,
        teacher: teacher,
        room: room,
        colorHex: colorHex,
        credits: credits,
      );
      state = state.copyWith(
        courses: state.courses.map((c) => c.id == id ? updated : c).toList(),
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

  Future<bool> deleteCourse(String id) async {
    try {
      await _repository.deleteCourse(id);
      state = state.copyWith(
        courses: state.courses.where((c) => c.id != id).toList(),
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

final courseProvider = StateNotifierProvider<CourseNotifier, CourseState>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  return CourseNotifier(repo);
});
