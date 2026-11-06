import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const db = await getDatabase();
        const now = new Date();
        // Determine dayOfWeek in Saturday(0) to Friday(6) convention
        const jsDay = now.getDay();
        const routineDay = (jsDay === 6 ? 0 : jsDay + 1);
        const currentHours = String(now.getHours()).padStart(2, '0');
        const currentMins = String(now.getMinutes()).padStart(2, '0');
        const currentTimeStr = `${currentHours}:${currentMins}`;
        const todayStr = now.toISOString().split('T')[0];
        // Determine greeting
        const hour = now.getHours();
        let greeting = 'Good evening';
        if (hour >= 5 && hour < 12)
            greeting = 'Good morning';
        else if (hour >= 12 && hour < 17)
            greeting = 'Good afternoon';
        // 1. Today's classes
        const todayRoutines = await db
            .collection('routines')
            .find({ userId: user._id, dayOfWeek: routineDay })
            .sort({ startTime: 1 })
            .toArray();
        // Next upcoming class: one whose endTime is still in the future today
        const nextClassDoc = todayRoutines.find((r) => r.endTime > currentTimeStr);
        let nextClass = null;
        if (nextClassDoc) {
            const isOngoing = nextClassDoc.startTime <= currentTimeStr && nextClassDoc.endTime > currentTimeStr;
            nextClass = {
                id: nextClassDoc._id.toString(),
                courseName: nextClassDoc.courseName,
                courseCode: nextClassDoc.courseCode,
                room: nextClassDoc.room,
                teacher: nextClassDoc.teacher,
                startTime: nextClassDoc.startTime,
                endTime: nextClassDoc.endTime,
                colorHex: nextClassDoc.colorHex,
                isOngoing,
            };
        }
        // 2. Pending tasks
        const pendingTasks = await db
            .collection('tasks')
            .find({ userId: user._id, status: 'pending' })
            .sort({ dueDate: 1, dueTime: 1 })
            .limit(5)
            .toArray();
        const pendingTasksCount = await db
            .collection('tasks')
            .countDocuments({ userId: user._id, status: 'pending' });
        // 3. Upcoming exams
        const upcomingExams = await db
            .collection('exams')
            .find({ userId: user._id, date: { $gte: todayStr } })
            .sort({ date: 1, time: 1 })
            .limit(3)
            .toArray();
        // 4. Attendance overview
        const attendanceRecords = await db
            .collection('attendance')
            .find({ userId: user._id })
            .toArray();
        const totalAttendance = attendanceRecords.length;
        const presentCount = attendanceRecords.filter((a) => a.status === 'present').length;
        const absentCount = attendanceRecords.filter((a) => a.status === 'absent').length;
        const lateCount = attendanceRecords.filter((a) => a.status === 'late').length;
        const threshold = user.attendanceThreshold ?? 75;
        const overallPercentage = totalAttendance > 0
            ? Math.round((presentCount / totalAttendance) * 1000) / 10
            : 100;
        return successResponse({
            user: {
                id: user._id.toString(),
                name: user.name,
                email: user.email,
                studentId: user.studentId || '',
                department: user.department || '',
            },
            greeting,
            todayDate: todayStr,
            todayDayOfWeek: routineDay,
            todayClassesCount: todayRoutines.length,
            nextClass,
            todayClasses: todayRoutines.map((r) => ({
                id: r._id.toString(),
                courseName: r.courseName,
                courseCode: r.courseCode,
                room: r.room,
                teacher: r.teacher,
                startTime: r.startTime,
                endTime: r.endTime,
                colorHex: r.colorHex,
            })),
            pendingTasksCount,
            pendingTasksPreview: pendingTasks.map((t) => ({
                id: t._id.toString(),
                title: t.title,
                dueDate: t.dueDate,
                dueTime: t.dueTime,
                priority: t.priority,
                category: t.category,
            })),
            upcomingExams: upcomingExams.map((e) => {
                const examDateTime = new Date(`${e.date}T${e.time || '00:00'}:00`).getTime();
                const daysRemaining = Math.ceil((examDateTime - now.getTime()) / (1000 * 60 * 60 * 24));
                return {
                    id: e._id.toString(),
                    subject: e.subject,
                    type: e.type,
                    date: e.date,
                    time: e.time,
                    location: e.location,
                    daysRemaining: isNaN(daysRemaining) ? 0 : daysRemaining,
                };
            }),
            attendanceOverview: {
                totalRecorded: totalAttendance,
                present: presentCount,
                absent: absentCount,
                late: lateCount,
                percentage: overallPercentage,
                threshold,
                isBelowThreshold: overallPercentage < threshold,
            },
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
