import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../calendar/models/exam_model.dart';
import '../../routine/models/routine_model.dart';
import '../../tasks/models/task_model.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardModel> getDashboardData() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.dashboard);
      return DashboardModel.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      // Graceful fallback for Guest Access or Offline Demo mode
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final in2DaysStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 2).toString().padLeft(2, '0')}';
      final in4DaysStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 4).toString().padLeft(2, '0')}';
      final in7DaysStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 7).toString().padLeft(2, '0')}';

      return DashboardModel(
        greeting: 'Welcome, Guest Student',
        todayDate: todayStr,
        todayDayOfWeek: 0,
        todayClassesCount: 2,
        nextClass: NextClassModel(
          id: 'demo_c1',
          courseName: 'Database Management Systems',
          courseCode: 'CSE 311',
          room: 'Lab 402',
          teacher: 'Dr. Alan Turing',
          startTime: '09:00',
          endTime: '10:30',
          colorHex: '#4F46E5',
          isOngoing: false,
        ),
        todayClasses: [
          RoutineModel(
            id: 'demo_r1',
            courseId: 'demo_c1',
            courseCode: 'CSE 311',
            courseName: 'Database Management Systems',
            dayOfWeek: 0,
            startTime: '09:00',
            endTime: '10:30',
            room: 'Lab 402',
            teacher: 'Dr. Alan Turing',
            colorHex: '#4F46E5',
          ),
          RoutineModel(
            id: 'demo_r2',
            courseId: 'demo_c2',
            courseCode: 'CSE 313',
            courseName: 'Operating Systems',
            dayOfWeek: 0,
            startTime: '10:45',
            endTime: '12:15',
            room: 'Room 501',
            teacher: 'Prof. Dennis Ritchie',
            colorHex: '#0EA5E9',
          ),
        ],
        pendingTasksCount: 2,
        pendingTasksPreview: [
          TaskModel(
            id: 'demo_t1',
            title: 'Design SQL Schema for Library',
            description: 'Create normalized tables up to 3NF with keys',
            dueDate: in2DaysStr,
            priority: 'high',
            category: 'Assignment',
            status: 'pending',
          ),
          TaskModel(
            id: 'demo_t2',
            title: 'Read OS Process Scheduling Chapter',
            description: 'Review Round Robin, SJF, and Multi-Level Queue',
            dueDate: in4DaysStr,
            priority: 'medium',
            category: 'Study',
            status: 'pending',
          ),
        ],
        upcomingExams: [
          ExamModel(
            id: 'demo_e1',
            subject: 'CSE 311 - Database Systems',
            type: 'midterm',
            date: in7DaysStr,
            time: '10:00',
            location: 'Auditorium Hall B',
            notes: 'Topics: ER diagrams, Relational Algebra, SQL, Normalization',
          ),
        ],
        attendanceOverview: AttendanceOverviewModel(
          totalRecorded: 16,
          present: 14,
          absent: 2,
          late: 0,
          percentage: 87.5,
          threshold: 75,
          isBelowThreshold: false,
        ),
      );
    }
  }
}
