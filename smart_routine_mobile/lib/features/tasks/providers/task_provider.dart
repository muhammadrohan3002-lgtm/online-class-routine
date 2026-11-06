import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../data/task_repository.dart';
import '../models/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return TaskRepository(api);
});

class TaskState {
  final List<TaskModel> tasks;
  final String activeFilter; // 'all', 'pending', 'completed', 'overdue'
  final String selectedCategory; // 'All', 'Study', 'Assignment', 'Personal', 'Other'
  final String sortBy; // 'dueDate', 'priority'
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.activeFilter = 'pending',
    this.selectedCategory = 'All',
    this.sortBy = 'dueDate',
    this.isLoading = false,
    this.error,
  });

  List<TaskModel> get filteredTasks {
    var result = tasks.where((t) {
      if (activeFilter == 'pending' && t.isCompleted) return false;
      if (activeFilter == 'completed' && !t.isCompleted) return false;
      if (activeFilter == 'overdue' && !t.isOverdue) return false;
      if (selectedCategory != 'All' && t.category != selectedCategory) return false;
      return true;
    }).toList();

    if (sortBy == 'priority') {
      const priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      result.sort((a, b) {
        final orderA = priorityOrder[a.priority.toLowerCase()] ?? 1;
        final orderB = priorityOrder[b.priority.toLowerCase()] ?? 1;
        return orderA.compareTo(orderB);
      });
    } else {
      // Due Date sorting
      result.sort((a, b) {
        final dateCmp = a.dueDate.compareTo(b.dueDate);
        if (dateCmp != 0) return dateCmp;
        return a.dueTime.compareTo(b.dueTime);
      });
    }

    return result;
  }

  TaskState copyWith({
    List<TaskModel>? tasks,
    String? activeFilter,
    String? selectedCategory,
    String? sortBy,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const TaskState()) {
    fetchTasks();
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getTasks();
      state = state.copyWith(tasks: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTask({
    required String title,
    String? description,
    required String dueDate,
    String? dueTime,
    String priority = 'medium',
    String status = 'pending',
    String category = 'Study',
  }) async {
    try {
      final newTask = await _repository.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        status: status,
        category: category,
      );
      state = state.copyWith(tasks: [...state.tasks, newTask]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> toggleTaskStatus(String id) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return false;

    final currentTask = state.tasks[taskIndex];
    final newStatus = currentTask.isCompleted ? 'pending' : 'completed';

    // Optimistic UI update
    final updatedList = List<TaskModel>.from(state.tasks);
    updatedList[taskIndex] = currentTask.copyWith(
      status: newStatus,
      completedAt: newStatus == 'completed' ? DateTime.now() : null,
    );
    state = state.copyWith(tasks: updatedList);

    try {
      final serverTask = await _repository.updateTask(id, status: newStatus);
      final finalTasks = state.tasks.map((t) => t.id == id ? serverTask : t).toList();
      state = state.copyWith(tasks: finalTasks);
      return true;
    } catch (e) {
      // Rollback on failure
      final rollback = List<TaskModel>.from(state.tasks);
      rollback[taskIndex] = currentTask;
      state = state.copyWith(tasks: rollback, error: 'Failed to update task status');
      return false;
    }
  }

  Future<bool> updateTask(
    String id, {
    String? title,
    String? description,
    String? dueDate,
    String? dueTime,
    String? priority,
    String? status,
    String? category,
  }) async {
    try {
      final updated = await _repository.updateTask(
        id,
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        priority: priority,
        status: status,
        category: category,
      );
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
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

  Future<bool> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != id).toList(),
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

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo);
});
