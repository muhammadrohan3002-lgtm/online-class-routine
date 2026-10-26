import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const { searchParams } = new URL(request.url);
        const dateParam = searchParams.get('date');
        const courseIdParam = searchParams.get('courseId');
        const db = await getDatabase();
        const query = { userId: user._id };
        if (dateParam && /^\d{4}-\d{2}-\d{2}$/.test(dateParam)) {
            query.date = dateParam;
        }
        if (courseIdParam && ObjectId.isValid(courseIdParam)) {
            query.courseId = new ObjectId(courseIdParam);
        }
        const sessions = await db
            .collection('studySessions')
            .find(query)
            .sort({ date: -1, createdAt: -1 })
            .toArray();
        const formatted = sessions.map((s) => ({
            id: s._id.toString(),
            courseId: s.courseId ? s.courseId.toString() : null,
            courseName: s.courseName,
            date: s.date,
            targetMinutes: s.targetMinutes || 60,
            completedMinutes: s.completedMinutes || 0,
            notes: s.notes || '',
            createdAt: s.createdAt,
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
        const { courseId, courseName, date, targetMinutes, completedMinutes, notes } = body;
        const chosenDate = date && /^\d{4}-\d{2}-\d{2}$/.test(date) ? date : new Date().toISOString().split('T')[0];
        const db = await getDatabase();
        let finalCourseName = courseName ? courseName.trim() : 'General Study';
        let courseObjId;
        if (courseId && ObjectId.isValid(courseId)) {
            courseObjId = new ObjectId(courseId);
            const course = await db.collection('courses').findOne({
                _id: courseObjId,
                userId: user._id,
            });
            if (course) {
                finalCourseName = course.name;
            }
        }
        const now = new Date();
        const newSession = {
            userId: user._id,
            courseId: courseObjId,
            courseName: finalCourseName,
            date: chosenDate,
            targetMinutes: Math.max(1, Number(targetMinutes) || 60),
            completedMinutes: Math.max(0, Number(completedMinutes) || 0),
            notes: notes?.trim() || '',
            createdAt: now,
            updatedAt: now,
        };
        const res = await db.collection('studySessions').insertOne(newSession);
        return successResponse({
            id: res.insertedId.toString(),
            courseId: newSession.courseId ? newSession.courseId.toString() : null,
            courseName: newSession.courseName,
            date: newSession.date,
            targetMinutes: newSession.targetMinutes,
            completedMinutes: newSession.completedMinutes,
            notes: newSession.notes,
            createdAt: newSession.createdAt,
        }, 201);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
