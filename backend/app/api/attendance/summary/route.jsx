import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const db = await getDatabase();
        const threshold = user.attendanceThreshold ?? 75;
        // Get all user courses
        const courses = await db
            .collection('courses')
            .find({ userId: user._id })
            .toArray();
        // Get all attendance logs for user
        const records = await db
            .collection('attendance')
            .find({ userId: user._id })
            .toArray();
        // Compute stats per course
        const courseStatsMap = new Map();
        for (const c of courses) {
            const cid = c._id.toString();
            courseStatsMap.set(cid, {
                courseId: cid,
                courseName: c.name,
                courseCode: c.code,
                colorHex: c.colorHex || '#3B82F6',
                present: 0,
                absent: 0,
                late: 0,
                total: 0,
                percentage: 100, // No records yet
                isBelowThreshold: false,
            });
        }
        let totalPresent = 0;
        let totalAbsent = 0;
        let totalLate = 0;
        let grandTotal = 0;
        for (const r of records) {
            grandTotal++;
            if (r.status === 'present')
                totalPresent++;
            else if (r.status === 'absent')
                totalAbsent++;
            else if (r.status === 'late')
                totalLate++;
            const cid = r.courseId.toString();
            let stat = courseStatsMap.get(cid);
            if (!stat) {
                stat = {
                    courseId: cid,
                    courseName: r.courseName || 'Unknown Course',
                    courseCode: '',
                    colorHex: '#64748B',
                    present: 0,
                    absent: 0,
                    late: 0,
                    total: 0,
                    percentage: 100,
                    isBelowThreshold: false,
                };
                courseStatsMap.set(cid, stat);
            }
            stat.total++;
            if (r.status === 'present')
                stat.present++;
            else if (r.status === 'absent')
                stat.absent++;
            else if (r.status === 'late')
                stat.late++;
        }
        // Calculate percentages
        for (const stat of courseStatsMap.values()) {
            if (stat.total > 0) {
                // Attendance formula: (present + late * 0.5) / total * 100 or standard present / total * 100
                // Standard in CSE universities: (present + late) count towards attended or present counts directly
                const rawPct = (stat.present / stat.total) * 100;
                stat.percentage = Math.round(rawPct * 10) / 10;
                stat.isBelowThreshold = stat.percentage < threshold;
            }
        }
        const overallPercentage = grandTotal > 0 ? Math.round(((totalPresent) / grandTotal) * 1000) / 10 : 100;
        return successResponse({
            threshold,
            overall: {
                totalClasses: grandTotal,
                present: totalPresent,
                absent: totalAbsent,
                late: totalLate,
                percentage: overallPercentage,
                isBelowThreshold: overallPercentage < threshold,
            },
            courses: Array.from(courseStatsMap.values()),
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
