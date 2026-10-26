import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const AddEditTaskScreen({super.key, this.taskId});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);
  String _priority = 'medium';
  String _category = 'Assignment';
  String _status = 'pending';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.taskId != null) {
      final tasks = ref.read(taskProvider).tasks;
      final existing = tasks.where((t) => t.id == widget.taskId).firstOrNull;
      if (existing != null) {
        _titleController.text = existing.title;
        _descriptionController.text = existing.description;
        _selectedDate = DateTime.tryParse(existing.dueDate) ?? _selectedDate;
        if (existing.dueTime.isNotEmpty) {
          _selectedTime = DateTimeUtils.stringToTimeOfDay(existing.dueTime);
        }
        _priority = existing.priority;
        _category = existing.category;
        _status = existing.status;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final notifier = ref.read(taskProvider.notifier);
    final dateStr = DateTimeUtils.toIsoDateString(_selectedDate);
    final timeStr = DateTimeUtils.timeOfDayToString(_selectedTime);

    bool success;
    if (widget.taskId != null) {
      success = await notifier.updateTask(
        widget.taskId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dateStr,
        dueTime: timeStr,
        priority: _priority,
        status: _status,
        category: _category,
      );
    } else {
      success = await notifier.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dateStr,
        dueTime: timeStr,
        priority: _priority,
        status: _status,
        category: _category,
      );
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task / Assignment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                CustomTextField(
                  controller: _titleController,
                  label: 'Task Title *',
                  hint: 'e.g. Complete Operating Systems Lab 3',
                  prefixIcon: Icons.task_alt_rounded,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description / Notes',
                  hint: 'Additional instructions, submission links, or group notes',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Category Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppStrings.taskCategories.map((cat) {
                        final isSelected = _category == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _category = cat),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Priority Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Priority Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityOption('low', 'Low', const Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        _buildPriorityOption('medium', 'Medium', AppColors.warning),
                        const SizedBox(width: 8),
                        _buildPriorityOption('high', 'High', AppColors.error),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Due Date & Due Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Due Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).colorScheme.outline),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateTimeUtils.formatReadableDate(
                                      DateTimeUtils.toIsoDateString(_selectedDate),
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Due Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).colorScheme.outline),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 18, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Save Button
                CustomButton(
                  text: isEditing ? 'Save Changes' : 'Create Task',
                  isLoading: _isSaving,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String key, String label, Color color) {
    final isSelected = _priority == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priority = key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
