import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../courses/providers/course_provider.dart';
import '../providers/attendance_provider.dart';

class RecordAttendanceDialog extends ConsumerStatefulWidget {
  final String? initialCourseId;
  final String? initialCourseName;

  const RecordAttendanceDialog({
    super.key,
    this.initialCourseId,
    this.initialCourseName,
  });

  @override
  ConsumerState<RecordAttendanceDialog> createState() => _RecordAttendanceDialogState();
}

class _RecordAttendanceDialogState extends ConsumerState<RecordAttendanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedCourseId;
  String? _selectedCourseName;
  DateTime _selectedDate = DateTime.now();
  String _status = 'present'; // 'present', 'absent', 'late'
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourseId;
    _selectedCourseName = widget.initialCourseName;

    if (_selectedCourseId == null) {
      final courses = ref.read(courseProvider).courses;
      if (courses.isNotEmpty) {
        _selectedCourseId = courses.first.id;
        _selectedCourseName = courses.first.name;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 120)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (checkGuestRestricted(context, ref, action: 'record attendance')) return;
    if (_selectedCourseId == null || _selectedCourseId!.isEmpty) {
      setState(() => _errorMessage = 'Please select a course');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final notifier = ref.read(attendanceProvider.notifier);
    final dateStr = DateTimeUtils.toIsoDateString(_selectedDate);

    final success = await notifier.recordAttendance(
      courseId: _selectedCourseId!,
      courseName: _selectedCourseName ?? 'Unknown Course',
      date: dateStr,
      status: _status,
      notes: _notesController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else {
      final state = ref.read(attendanceProvider);
      setState(() {
        _errorMessage = state.error ?? 'Failed to record attendance';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(courseProvider).courses;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Record Attendance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.errorText),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Course Selection
                if (courses.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    decoration: const InputDecoration(
                      labelText: 'Course *',
                      prefixIcon: Icon(Icons.school_outlined, size: 20),
                    ),
                    items: courses.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text('${c.code} - ${c.name}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final c = courses.where((element) => element.id == val).firstOrNull;
                      setState(() {
                        _selectedCourseId = val;
                        _selectedCourseName = c?.name;
                      });
                    },
                  )
                else
                  const Text(
                    'No registered courses found. Please add courses first.',
                    style: TextStyle(color: AppColors.error),
                  ),
                const SizedBox(height: 16),

                // Date Picker
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              DateTimeUtils.formatReadableDate(
                                DateTimeUtils.toIsoDateString(_selectedDate),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Selector (Present, Absent, Late)
                const Text('Status *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip('present', 'Present', AppColors.success, AppColors.successContainer),
                    const SizedBox(width: 8),
                    _buildStatusChip('late', 'Late', AppColors.warning, AppColors.warningContainer),
                    const SizedBox(width: 8),
                    _buildStatusChip('absent', 'Absent', AppColors.error, AppColors.errorContainer),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes (Optional)
                CustomTextField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  hint: 'e.g. Left 15 minutes early, quiz was held',
                  prefixIcon: Icons.notes_rounded,
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Save Attendance Log',
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

  Widget _buildStatusChip(String key, String label, Color color, Color containerColor) {
    final isSelected = _status == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _status = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? containerColor : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
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
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
