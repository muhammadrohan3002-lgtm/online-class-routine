import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const db = await getDatabase();
        // Get last 7 days dates (including today)
        const days = [];
        const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const now = new Date();
        for (let i = 6; i >= 0; i--) {
            const d = new Date(now);
            d.setDate(d.getDate() - i);
            days.push(d.toISOString().split('T')[0]);
        }
        const startDate = days[0];
        const endDate = days[days.length - 1];
        const sessions = await db
            .collection('studySessions')
            .find({
            userId: user._id,
            date: { $gte: startDate, $lte: endDate },
        })
            .toArray();
        // Group by date
        const dailyMap = new Map();
        for (const d of days) {
            dailyMap.set(d, { completedMinutes: 0, targetMinutes: 0, count: 0 });
        }
        let totalCompletedMinutes = 0;
        let totalTargetMinutes = 0;
        for (const s of sessions) {
            const entry = dailyMap.get(s.date);
            if (entry) {
                entry.completedMinutes += s.completedMinutes || 0;
                entry.targetMinutes += s.targetMinutes || 0;
                entry.count++;
            }
            totalCompletedMinutes += s.completedMinutes || 0;
            totalTargetMinutes += s.targetMinutes || 0;
        }
        const weeklyBreakdown = days.map((dateStr) => {
            const dateObj = new Date(dateStr);
            const dayLabel = dayNames[dateObj.getDay()];
            const entry = dailyMap.get(dateStr);
            return {
                date: dateStr,
                day: dayLabel,
                completedMinutes: entry.completedMinutes,
                targetMinutes: entry.targetMinutes,
                percentage: entry.targetMinutes > 0
                    ? Math.min(100, Math.round((entry.completedMinutes / entry.targetMinutes) * 100))
                    : entry.completedMinutes > 0
                        ? 100
                        : 0,
            };
        });
        return successResponse({
            totalCompletedMinutes,
            totalTargetMinutes,
            overallProgressPercentage: totalTargetMinutes > 0
                ? Math.min(100, Math.round((totalCompletedMinutes / totalTargetMinutes) * 100))
                : 0,
            weeklyBreakdown,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
