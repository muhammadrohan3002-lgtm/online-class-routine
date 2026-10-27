import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/guest_mode_banner.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/task_provider.dart';
import 'widgets/task_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final notifier = ref.read(taskProvider.notifier);

    final filtered = taskState.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks & Assignments'),
        actions: [
          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort by',
            onSelected: (val) => notifier.setSortBy(val),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'dueDate',
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: taskState.sortBy == 'dueDate' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by Due Date',
                      style: TextStyle(
                        fontWeight: taskState.sortBy == 'dueDate' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'priority',
                child: Row(
                  children: [
                    Icon(
                      Icons.priority_high_rounded,
                      size: 18,
                      color: taskState.sortBy == 'priority' ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by Priority',
                      style: TextStyle(
                        fontWeight: taskState.sortBy == 'priority' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchTasks(),
        child: Column(
          children: [
            const GuestModeBanner(),
            if (taskState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorBanner(
                  message: taskState.error!,
                  onRetry: () => notifier.fetchTasks(),
                ),
              ),

            // Status Filter Chips (Pending, Completed, Overdue, All)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    label: 'Pending',
                    filterKey: 'pending',
                    currentFilter: taskState.activeFilter,
                    onTap: () => notifier.setFilter('pending'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Overdue',
                    filterKey: 'overdue',
                    currentFilter: taskState.activeFilter,
                    onTap: () => notifier.setFilter('overdue'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Completed',
                    filterKey: 'completed',
                    currentFilter: taskState.activeFilter,
                    onTap: () => notifier.setFilter('completed'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'All Tasks',
                    filterKey: 'all',
                    currentFilter: taskState.activeFilter,
                    onTap: () => notifier.setFilter('all'),
                  ),
                ],
              ),
            ),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  _buildCategoryChip(
                    context,
                    category: 'All',
                    selected: taskState.selectedCategory == 'All',
                    onTap: () => notifier.setCategory('All'),
                  ),
                  ...AppStrings.taskCategories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _buildCategoryChip(
                        context,
                        category: cat,
                        selected: taskState.selectedCategory == cat,
                        onTap: () => notifier.setCategory(cat),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: taskState.isLoading && taskState.tasks.isEmpty
                  ? const LoadingIndicator(message: 'Loading tasks...')
                  : filtered.isEmpty
                      ? EmptyStateView(
                          icon: Icons.task_alt_rounded,
                          title: 'No Tasks Found',
                          subtitle: taskState.activeFilter == 'pending'
                              ? 'You have completed all pending tasks! Great job.'
                              : 'No tasks match the active filters.',
                          buttonText: 'Create New Task',
                          onButtonPressed: () {
                            if (checkGuestRestricted(context, ref, action: 'create new tasks')) return;
                            context.push('/tasks/add');
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            return TaskCard(
                              task: task,
                              onToggleStatus: () {
                                if (checkGuestRestricted(context, ref, action: 'update task completion status')) return;
                                notifier.toggleTaskStatus(task.id);
                              },
                              onEdit: () {
                                if (checkGuestRestricted(context, ref, action: 'edit tasks')) return;
                                context.push('/tasks/edit/${task.id}');
                              },
                              onDelete: () {
                                if (checkGuestRestricted(context, ref, action: 'delete tasks')) return;
                                _confirmDelete(context, ref, task.id, task.title);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_fab',
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        onPressed: () {
          if (checkGuestRestricted(context, ref, action: 'create new tasks')) return;
          context.push('/tasks/add');
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterKey,
    required String currentFilter,
    required VoidCallback onTap,
  }) {
    final isSelected = currentFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: Theme.of(context).cardColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : null,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String category,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(category),
      onPressed: onTap,
      backgroundColor: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      labelStyle: TextStyle(
        fontSize: 11,
        color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
        fontWeight: selected ? FontWeight.bold : null,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(taskProvider.notifier).deleteTask(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
