import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../courses/providers/course_provider.dart';
import '../providers/study_session_provider.dart';

class StudyTimerScreen extends ConsumerStatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  ConsumerState<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends ConsumerState<StudyTimerScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;

  int _targetMinutes = 25; // Default 25 min Pomodoro
  String? _selectedCourseId;
  String? _selectedCourseName;

  @override
  void initState() {
    super.initState();
    final courses = ref.read(courseProvider).courses;
    if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
      _selectedCourseName = courses.first.name;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsElapsed = 0;
    });
  }

  Future<void> _saveSession() async {
    _pauseTimer();
    final completedMinutes = (_secondsElapsed / 60).ceil();

    if (completedMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study for at least 1 minute before saving.')),
      );
      return;
    }

    final success = await ref.read(studyPlannerProvider.notifier).createSession(
          courseId: _selectedCourseId,
          courseName: _selectedCourseName ?? 'General CSE Study',
          date: DateTimeUtils.toIsoDateString(DateTime.now()),
          targetMinutes: _targetMinutes,
          completedMinutes: completedMinutes,
          notes: 'Completed via Focus Study Timer',
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Awesome! Saved $completedMinutes mins of study for $_selectedCourseName.'),
          backgroundColor: AppColors.success,
        ),
      );
      _resetTimer();
    }
  }

  String _formatTime() {
    final mins = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(courseProvider).courses;
    final totalTargetSeconds = _targetMinutes * 60;
    final progress = totalTargetSeconds > 0
        ? (_secondsElapsed / totalTargetSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Study Timer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Linked Course Selector
              if (courses.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: const InputDecoration(
                    labelText: 'Studying Course',
                    prefixIcon: Icon(Icons.school_outlined, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('General CSE Study'),
                    ),
                    ...courses.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.code} - ${c.name}'),
                        )),
                  ],
                  onChanged: (val) {
                    final c = courses.where((e) => e.id == val).firstOrNull;
                    setState(() {
                      _selectedCourseId = val;
                      _selectedCourseName = c?.name ?? 'General CSE Study';
                    });
                  },
                ),
              const SizedBox(height: 24),

              // Pomodoro Preset Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [15, 25, 45, 60].map((mins) {
                  final isSelected = _targetMinutes == mins;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('${mins}m Target'),
                      selected: isSelected,
                      onSelected: _isRunning
                          ? null
                          : (_) => setState(() => _targetMinutes = mins),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Circular Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? 'FOCUS MODE ACTIVE' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: _isRunning ? AppColors.success : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Timer Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reset',
                    onPressed: _secondsElapsed > 0 ? _resetTimer : null,
                  ),
                  const SizedBox(width: 20),
                  // Play / Pause Primary Button
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? AppColors.warning : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Save Button
                  IconButton.filledTonal(
                    iconSize: 28,
                    icon: const Icon(Icons.check_rounded),
                    tooltip: 'Save Session',
                    onPressed: _secondsElapsed >= 60 ? _saveSession : null,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Motivational Text
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: Stay focused for 25 minutes, then take a 5-minute break to maximize memory retention.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
