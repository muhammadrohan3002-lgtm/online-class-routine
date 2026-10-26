import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
import { doIntervalsOverlap, isTimeRangeValid } from '@/lib/validation';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const { searchParams } = new URL(request.url);
        const dayParam = searchParams.get('day');
        const courseIdParam = searchParams.get('courseId');
        const db = await getDatabase();
        const query = { userId: user._id };
        if (dayParam !== null && dayParam !== undefined && dayParam !== '') {
            query.dayOfWeek = Number(dayParam);
        }
        if (courseIdParam && ObjectId.isValid(courseIdParam)) {
            query.courseId = new ObjectId(courseIdParam);
        }
        const routines = await db
            .collection('routines')
            .find(query)
            .sort({ dayOfWeek: 1, startTime: 1 })
            .toArray();
        const formatted = routines.map((r) => ({
            id: r._id.toString(),
            courseId: r.courseId ? r.courseId.toString() : null,
            courseName: r.courseName,
            courseCode: r.courseCode,
            teacher: r.teacher,
            room: r.room,
            dayOfWeek: r.dayOfWeek,
            startTime: r.startTime,
            endTime: r.endTime,
            colorHex: r.colorHex || '#3B82F6',
            createdAt: r.createdAt,
        }));
        return successResponse(formatted);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function POST(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const body = await request.json().catch(() => ({}));
        const { courseId, courseName, courseCode, teacher, room, dayOfWeek, startTime, endTime, colorHex, } = body;
        if (!courseName || !courseCode || !startTime || !endTime || dayOfWeek === undefined) {
            return errorResponse('courseName, courseCode, dayOfWeek, startTime, and endTime are required');
        }
        const dayNum = Number(dayOfWeek);
        if (dayNum < 0 || dayNum > 6) {
            return errorResponse('dayOfWeek must be between 0 (Saturday) and 6 (Friday)');
        }
        if (!isTimeRangeValid(startTime, endTime)) {
            return errorResponse('Start time must be before end time');
        }
        const db = await getDatabase();
        // Check for overlapping routines on the same day for this user
        const existing = await db
            .collection('routines')
            .find({ userId: user._id, dayOfWeek: dayNum })
            .toArray();
        const overlapping = existing.filter((r) => doIntervalsOverlap(startTime, endTime, r.startTime, r.endTime));
        const conflictWarning = overlapping.length > 0
            ? `Overlaps with ${overlapping[0].courseCode} (${overlapping[0].startTime} - ${overlapping[0].endTime})`
            : null;
        const now = new Date();
        const newRoutine = {
            userId: user._id,
            courseId: courseId && ObjectId.isValid(courseId) ? new ObjectId(courseId) : undefined,
            courseName: courseName.trim(),
            courseCode: courseCode.trim().toUpperCase(),
            teacher: teacher?.trim() || '',
            room: room?.trim() || '',
            dayOfWeek: dayNum,
            startTime: startTime.trim(),
            endTime: endTime.trim(),
            colorHex: colorHex?.trim() || '#3B82F6',
            createdAt: now,
            updatedAt: now,
        };
        const res = await db.collection('routines').insertOne(newRoutine);
        return successResponse({
            id: res.insertedId.toString(),
            courseId: newRoutine.courseId ? newRoutine.courseId.toString() : null,
            courseName: newRoutine.courseName,
            courseCode: newRoutine.courseCode,
            teacher: newRoutine.teacher,
            room: newRoutine.room,
            dayOfWeek: newRoutine.dayOfWeek,
            startTime: newRoutine.startTime,
            endTime: newRoutine.endTime,
            colorHex: newRoutine.colorHex,
            conflictWarning,
            createdAt: newRoutine.createdAt,
        }, 201);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
