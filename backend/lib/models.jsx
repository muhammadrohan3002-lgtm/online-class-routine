/**
 * Collection constants and validation lists for Smart Routine DB
 */
export const COLLECTIONS = {
  USERS: 'users',
  COURSES: 'courses',
  ROUTINES: 'routines',
  TASKS: 'tasks',
  EXAMS: 'exams',
  ATTENDANCE: 'attendance',
  STUDY_SESSIONS: 'studySessions',
};

export const TASK_PRIORITIES = ['low', 'medium', 'high'];
export const TASK_STATUSES = ['pending', 'completed'];
export const TASK_CATEGORIES = ['Study', 'Assignment', 'Personal', 'Other'];
export const EXAM_TYPES = ['midterm', 'final', 'quiz', 'lab', 'presentation'];
export const ATTENDANCE_STATUSES = ['present', 'absent', 'late'];

export default {
  COLLECTIONS,
  TASK_PRIORITIES,
  TASK_STATUSES,
  TASK_CATEGORIES,
  EXAM_TYPES,
  ATTENDANCE_STATUSES,
};
