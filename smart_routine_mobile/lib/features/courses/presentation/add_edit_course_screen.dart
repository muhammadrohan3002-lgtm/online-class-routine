import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../providers/course_provider.dart';

class AddEditCourseScreen extends ConsumerStatefulWidget {
  final String? courseId;

  const AddEditCourseScreen({super.key, this.courseId});

  @override
  ConsumerState<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends ConsumerState<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _teacherController;
  late final TextEditingController _roomController;
  late final TextEditingController _creditsController;

  Color _selectedColor = AppColors.coursePalette[0];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _teacherController = TextEditingController();
    _roomController = TextEditingController();
    _creditsController = TextEditingController(text: '3');

    if (widget.courseId != null) {
      final courses = ref.read(courseProvider).courses;
      final existing = courses.where((c) => c.id == widget.courseId).firstOrNull;
      if (existing != null) {
        _nameController.text = existing.name;
        _codeController.text = existing.code;
        _teacherController.text = existing.teacher;
        _roomController.text = existing.room;
        _creditsController.text = existing.credits.toString();
        _selectedColor = AppColors.hexToColor(existing.colorHex);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (checkGuestRestricted(
      context,
      ref,
      action: widget.courseId != null ? 'edit courses' : 'add semester courses',
    )) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final notifier = ref.read(courseProvider.notifier);
    final colorHex = AppColors.colorToHex(_selectedColor);
    final credits = int.tryParse(_creditsController.text) ?? 3;

    bool success;
    if (widget.courseId != null) {
      success = await notifier.updateCourse(
        widget.courseId!,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        teacher: _teacherController.text.trim(),
        room: _roomController.text.trim(),
        credits: credits,
        colorHex: colorHex,
      );
    } else {
      success = await notifier.createCourse(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        teacher: _teacherController.text.trim(),
        room: _roomController.text.trim(),
        credits: credits,
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
    final isEditing = widget.courseId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add New Course'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Course Code
                CustomTextField(
                  controller: _codeController,
                  label: 'Course Code *',
                  hint: 'e.g. CSE 320',
                  prefixIcon: Icons.code_rounded,
                  textCapitalization: TextCapitalization.characters,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Course code is required' : null,
                ),
                const SizedBox(height: 16),

                // Course Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Course Name *',
                  hint: 'e.g. Operating Systems & Algorithms',
                  prefixIcon: Icons.menu_book_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Course name is required' : null,
                ),
                const SizedBox(height: 16),

                // Credits & Room
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _creditsController,
                        label: 'Credits',
                        hint: '3',
                        prefixIcon: Icons.grade_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _roomController,
                        label: 'Default Room',
                        hint: 'Lab 402',
                        prefixIcon: Icons.meeting_room_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Teacher
                CustomTextField(
                  controller: _teacherController,
                  label: 'Instructor / Professor',
                  hint: 'e.g. Dr. John Doe',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),

                // Color Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Tag Color',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppColors.coursePalette.map((color) {
                        final isSelected = _selectedColor.value == color.value;
                        return InkWell(
                          onTap: () => setState(() => _selectedColor = color),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
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
                                ? const Icon(Icons.check, size: 20, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: isEditing ? 'Save Changes' : 'Create Course',
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
