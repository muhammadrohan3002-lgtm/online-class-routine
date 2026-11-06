import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
import { doIntervalsOverlap, isTimeRangeValid } from '@/lib/validation';
export async function POST(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const body = await request.json().catch(() => ({}));
        const { dayOfWeek, startTime, endTime, excludeId } = body;
        if (dayOfWeek === undefined || !startTime || !endTime) {
            return errorResponse('dayOfWeek, startTime and endTime are required');
        }
        if (!isTimeRangeValid(startTime, endTime)) {
            return errorResponse('Start time must be before end time');
        }
        const db = await getDatabase();
        const query = {
            userId: user._id,
            dayOfWeek: Number(dayOfWeek),
        };
        if (excludeId && ObjectId.isValid(excludeId)) {
            query._id = { $ne: new ObjectId(excludeId) };
        }
        const existingRoutines = await db.collection('routines').find(query).toArray();
        const conflicting = existingRoutines.filter((r) => doIntervalsOverlap(startTime, endTime, r.startTime, r.endTime));
        const hasConflict = conflicting.length > 0;
        return successResponse({
            hasConflict,
            conflicts: conflicting.map((c) => ({
                id: c._id.toString(),
                courseName: c.courseName,
                courseCode: c.courseCode,
                room: c.room,
                startTime: c.startTime,
                endTime: c.endTime,
            })),
            warning: hasConflict
                ? `This class overlaps with ${conflicting[0].courseCode} (${conflicting[0].startTime} - ${conflicting[0].endTime})`
                : null,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
