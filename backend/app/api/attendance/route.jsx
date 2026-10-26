import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, errorResponse, conflictResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const { searchParams } = new URL(request.url);
        const courseIdParam = searchParams.get('courseId');
        const dateParam = searchParams.get('date');
        const db = await getDatabase();
        const query = { userId: user._id };
        if (courseIdParam && ObjectId.isValid(courseIdParam)) {
            query.courseId = new ObjectId(courseIdParam);
        }
        if (dateParam && /^\d{4}-\d{2}-\d{2}$/.test(dateParam)) {
            query.date = dateParam;
        }
        const records = await db
            .collection('attendance')
            .find(query)
            .sort({ date: -1, createdAt: -1 })
            .toArray();
        const formatted = records.map((r) => ({
            id: r._id.toString(),
            courseId: r.courseId.toString(),
            courseName: r.courseName,
            date: r.date,
            status: r.status,
            notes: r.notes || '',
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
        const { courseId, courseName, date, status, notes } = body;
        if (!courseId || !ObjectId.isValid(courseId)) {
            return errorResponse('Valid courseId is required');
        }
        if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
            return errorResponse('Valid date (YYYY-MM-DD) is required');
        }
        const validStatuses = ['present', 'absent', 'late'];
        if (!status || !validStatuses.includes(status)) {
            return errorResponse("status must be 'present', 'absent', or 'late'");
        }
        const db = await getDatabase();
        const courseObjId = new ObjectId(courseId);
        // Verify course exists or get name
        const course = await db.collection('courses').findOne({
            _id: courseObjId,
            userId: user._id,
        });
        const finalCourseName = course ? course.name : (courseName || 'Unknown Course');
        // Duplicate check: Do not allow duplicate attendance records for the same class session / same course on the same date
        const existing = await db.collection('attendance').findOne({
            userId: user._id,
            courseId: courseObjId,
            date: date.trim(),
        });
        if (existing) {
            return conflictResponse(`Attendance for "${finalCourseName}" on ${date} has already been recorded (${existing.status.toUpperCase()}). You can edit or delete the existing record instead.`);
        }
        const now = new Date();
        const newRecord = {
            userId: user._id,
            courseId: courseObjId,
            courseName: finalCourseName,
            date: date.trim(),
            status,
            notes: notes?.trim() || '',
            createdAt: now,
            updatedAt: now,
        };
        const res = await db.collection('attendance').insertOne(newRecord);
        return successResponse({
            id: res.insertedId.toString(),
            courseId: newRecord.courseId.toString(),
            courseName: newRecord.courseName,
            date: newRecord.date,
            status: newRecord.status,
            notes: newRecord.notes,
            createdAt: newRecord.createdAt,
        }, 201);
    }
    catch (err) {
        if (err.code === 11000) {
            return conflictResponse('Attendance record already exists for this course on this date');
        }
        return serverErrorResponse(err);
    }
}
