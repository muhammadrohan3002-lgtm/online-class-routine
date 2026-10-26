import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../courses/providers/course_provider.dart';
import '../providers/exam_provider.dart';

class AddEditExamScreen extends ConsumerStatefulWidget {
  final String? examId;

  const AddEditExamScreen({super.key, this.examId});

  @override
  ConsumerState<AddEditExamScreen> createState() => _AddEditExamScreenState();
}

class _AddEditExamScreenState extends ConsumerState<AddEditExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  String _type = 'midterm';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _locationController = TextEditingController(text: 'Exam Hall A');
    _notesController = TextEditingController();

    if (widget.examId != null) {
      final exams = ref.read(examProvider).exams;
      final existing = exams.where((e) => e.id == widget.examId).firstOrNull;
      if (existing != null) {
        _subjectController.text = existing.subject;
        _type = existing.type;
        _selectedDate = DateTime.tryParse(existing.date) ?? _selectedDate;
        _selectedTime = DateTimeUtils.stringToTimeOfDay(existing.time);
        _locationController.text = existing.location;
        _notesController.text = existing.notes;
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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

    final notifier = ref.read(examProvider.notifier);
    final dateStr = DateTimeUtils.toIsoDateString(_selectedDate);
    final timeStr = DateTimeUtils.timeOfDayToString(_selectedTime);

    bool success;
    if (widget.examId != null) {
      success = await notifier.updateExam(
        widget.examId!,
        subject: _subjectController.text.trim(),
        type: _type,
        date: dateStr,
        time: timeStr,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
      );
    } else {
      success = await notifier.createExam(
        subject: _subjectController.text.trim(),
        type: _type,
        date: dateStr,
        time: timeStr,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
      );
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.examId != null;
    final courses = ref.watch(courseProvider).courses;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exam' : 'Schedule Exam / Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick autofill from course
                if (courses.isNotEmpty) ...[
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Select from Registered Courses',
                      prefixIcon: Icon(Icons.school_outlined, size: 20),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Custom / Manual Entry'),
                      ),
                      ...courses.map((c) => DropdownMenuItem(
                            value: '${c.code}: ${c.name}',
                            child: Text('${c.code} - ${c.name}'),
                          )),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        _subjectController.text = val;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Subject
                CustomTextField(
                  controller: _subjectController,
                  label: 'Subject / Course Title *',
                  hint: 'e.g. CSE 320: Operating Systems',
                  prefixIcon: Icons.menu_book_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Subject is required' : null,
                ),
                const SizedBox(height: 16),

                // Exam Type Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assessment Type *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppStrings.examTypes.map((t) {
                        final isSelected = _type == t;
                        return ChoiceChip(
                          label: Text(t.toUpperCase()),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _type = t),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Exam Date *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                          const Text('Exam Time *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                const SizedBox(height: 16),

                // Location / Hall
                CustomTextField(
                  controller: _locationController,
                  label: 'Hall / Room Location',
                  hint: 'e.g. Auditorium 2 or Room 405',
                  prefixIcon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Notes / Syllabus
                CustomTextField(
                  controller: _notesController,
                  label: 'Syllabus / Notes',
                  hint: 'Chapters 1 to 4, bring scientific calculator and student ID',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: isEditing ? 'Save Changes' : 'Schedule Assessment',
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
