import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _departmentController;
  late final TextEditingController _institutionController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _studentIdController = TextEditingController(text: user?.studentId ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
    _institutionController = TextEditingController(text: user?.institution ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _institutionController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (checkGuestRestricted(context, ref, action: 'save profile changes')) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          studentId: _studentIdController.text.trim(),
          department: _departmentController.text.trim(),
          institution: _institutionController.text.trim(),
          currentPassword: _changePassword ? _currentPasswordController.text : null,
          newPassword: _changePassword ? _newPasswordController.text : null,
        );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isGuest = user == null || user.isGuest || user.email == 'guest@cse.edu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isGuest) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Guest Mode: Profile editing is preview only. Create an account to save personal info.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name *',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _studentIdController,
                  label: 'Student ID',
                  hint: 'e.g. 2026-CSE-042',
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _departmentController,
                  label: 'Department',
                  hint: 'e.g. Computer Science & Engineering',
                  prefixIcon: Icons.code_rounded,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _institutionController,
                  label: 'University / Institution',
                  hint: 'e.g. University of Technology',
                  prefixIcon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 24),

                // Change Password Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Change Account Password', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Check to set a new password', style: TextStyle(fontSize: 12)),
                  value: _changePassword,
                  onChanged: (val) => setState(() => _changePassword = val),
                ),

                if (_changePassword) ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _currentPasswordController,
                    label: 'Current Password *',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (val) {
                      if (_changePassword && (val == null || val.isEmpty)) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'New Password *',
                    hint: 'Minimum 6 characters',
                    prefixIcon: Icons.lock_reset_rounded,
                    isPassword: true,
                    validator: (val) {
                      if (_changePassword) {
                        if (val == null || val.isEmpty) return 'New password is required';
                        if (val.length < 6) return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Save Profile Changes',
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
