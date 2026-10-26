import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/conflict_detector.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../courses/providers/course_provider.dart';
import '../providers/routine_provider.dart';

class AddEditRoutineScreen extends ConsumerStatefulWidget {
  final String? routineId;
  final int? initialDay;

  const AddEditRoutineScreen({
    super.key,
    this.routineId,
    this.initialDay,
  });

  @override
  ConsumerState<AddEditRoutineScreen> createState() => _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends ConsumerState<AddEditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _courseNameController;
  late final TextEditingController _courseCodeController;
  late final TextEditingController _teacherController;
  late final TextEditingController _roomController;

  int _selectedDay = 0; // 0=Sat..6=Fri
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  Color _selectedColor = AppColors.coursePalette[0];
  String? _selectedCourseId;

  bool _isSaving = false;
  String? _conflictWarning;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
    _courseCodeController = TextEditingController();
    _teacherController = TextEditingController();
    _roomController = TextEditingController();

    if (widget.initialDay != null) {
      _selectedDay = widget.initialDay!;
    }

    if (widget.routineId != null) {
      final routines = ref.read(routineProvider).routines;
      final existing = routines.where((r) => r.id == widget.routineId).firstOrNull;
      if (existing != null) {
        _courseNameController.text = existing.courseName;
        _courseCodeController.text = existing.courseCode;
        _teacherController.text = existing.teacher;
        _roomController.text = existing.room;
        _selectedDay = existing.dayOfWeek;
        _startTime = DateTimeUtils.stringToTimeOfDay(existing.startTime);
        _endTime = DateTimeUtils.stringToTimeOfDay(existing.endTime);
        _selectedColor = AppColors.hexToColor(existing.colorHex);
        _selectedCourseId = existing.courseId;
      }
    }

    // Check conflict initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForConflict();
    });
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _checkForConflict() {
    final startStr = DateTimeUtils.timeOfDayToString(_startTime);
    final endStr = DateTimeUtils.timeOfDayToString(_endTime);
    final existingRoutines = ref.read(routineProvider).routines;

    final result = ConflictDetector.checkRoutineConflict(
      existingRoutines: existingRoutines,
      dayOfWeek: _selectedDay,
      startTime: startStr,
      endTime: endStr,
      excludeRoutineId: widget.routineId,
    );

    setState(() {
      _conflictWarning = result.warningMessage;
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
      _checkForConflict();
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
      _checkForConflict();
    }
  }

  void _onCourseSelected(String? courseId) {
    setState(() {
      _selectedCourseId = courseId;
    });

    if (courseId != null) {
      final course = ref.read(courseProvider).courses.where((c) => c.id == courseId).firstOrNull;
      if (course != null) {
        _courseNameController.text = course.name;
        _courseCodeController.text = course.code;
        if (course.teacher.isNotEmpty) _teacherController.text = course.teacher;
        if (course.room.isNotEmpty) _roomController.text = course.room;
        _selectedColor = AppColors.hexToColor(course.colorHex);
        _checkForConflict();
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final startStr = DateTimeUtils.timeOfDayToString(_startTime);
    final endStr = DateTimeUtils.timeOfDayToString(_endTime);

    if (DateTimeUtils.timeToMinutes(startStr) >= DateTimeUtils.timeToMinutes(endStr)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time must be before end time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_conflictWarning != null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              SizedBox(width: 8),
              Text('Schedule Conflict'),
            ],
          ),
          content: Text('$_conflictWarning\n\nDo you still wish to schedule this class?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Change Time'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Proceed Anyway', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isSaving = true);

    final notifier = ref.read(routineProvider.notifier);
    final colorHex = AppColors.colorToHex(_selectedColor);

    bool success;
    if (widget.routineId != null) {
      success = await notifier.updateRoutine(
        widget.routineId!,
        courseId: _selectedCourseId,
        courseName: _courseNameController.text.trim(),
        courseCode: _courseCodeController.text.trim(),
        teacher: _teacherController.text.trim(),
        room: _roomController.text.trim(),
        dayOfWeek: _selectedDay,
        startTime: startStr,
        endTime: endStr,
        colorHex: colorHex,
      );
    } else {
      success = await notifier.createRoutine(
        courseId: _selectedCourseId,
        courseName: _courseNameController.text.trim(),
        courseCode: _courseCodeController.text.trim(),
        teacher: _teacherController.text.trim(),
        room: _roomController.text.trim(),
        dayOfWeek: _selectedDay,
        startTime: startStr,
        endTime: endStr,
        colorHex: colorHex,
      );
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routineId != null;
    final courses = ref.watch(courseProvider).courses;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Class Schedule' : 'Add Class Schedule'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick autofill from registered courses
                if (courses.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Autofill from Course',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () => context.push('/courses/add'),
                        child: const Text('+ Add Course', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String?>(
                    value: _selectedCourseId,
                    decoration: const InputDecoration(
                      hintText: 'Select a course to auto-fill details',
                      prefixIcon: Icon(Icons.school_outlined, size: 20),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Custom / Manual Entry'),
                      ),
                      ...courses.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.code} - ${c.name}'),
                          )),
                    ],
                    onChanged: _onCourseSelected,
                  ),
                  const SizedBox(height: 16),
                ],

                // Course Code
                CustomTextField(
                  controller: _courseCodeController,
                  label: 'Course Code *',
                  hint: 'e.g. CSE 320',
                  prefixIcon: Icons.code_rounded,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => _checkForConflict(),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Course code is required' : null,
                ),
                const SizedBox(height: 16),

                // Course Name
                CustomTextField(
                  controller: _courseNameController,
                  label: 'Course Name *',
                  hint: 'e.g. Operating Systems & Algorithms',
                  prefixIcon: Icons.menu_book_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Course name is required' : null,
                ),
                const SizedBox(height: 16),

                // Day of Week Picker (Saturday to Friday)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Day of Week *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(AppStrings.daysOfWeek.length, (index) {
                        final isSelected = _selectedDay == index;
                        return ChoiceChip(
                          label: Text(AppStrings.daysOfWeekShort[index]),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedDay = index);
                            _checkForConflict();
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time Pickers (Start and End Time)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickStartTime,
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
                                  const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _startTime.format(context),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
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
                          const Text(
                            'End Time *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickEndTime,
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
                                  const Icon(Icons.access_time_filled_rounded, size: 18, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    _endTime.format(context),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
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
                const SizedBox(height: 14),

                // Overlap Conflict Warning Banner
                if (_conflictWarning != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warningText, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time Conflict Detected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.warningText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _conflictWarning!,
                                style: const TextStyle(fontSize: 11, color: AppColors.warningText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Room / Lab
                CustomTextField(
                  controller: _roomController,
                  label: 'Room / Lab',
                  hint: 'e.g. Lab 402 or Room 305',
                  prefixIcon: Icons.meeting_room_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Teacher
                CustomTextField(
                  controller: _teacherController,
                  label: 'Teacher / Instructor',
                  hint: 'e.g. Dr. John Doe',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Color Swatches
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color Tag',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppColors.coursePalette.map((color) {
                        final isSelected = _selectedColor.value == color.value;
                        return InkWell(
                          onTap: () => setState(() => _selectedColor = color),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Save Button
                CustomButton(
                  text: isEditing ? 'Save Changes' : 'Schedule Class',
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
}
