import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const db = await getDatabase();
        const courses = await db
            .collection('courses')
            .find({ userId: user._id })
            .sort({ code: 1, name: 1 })
            .toArray();
        const formatted = courses.map((c) => ({
            id: c._id.toString(),
            name: c.name,
            code: c.code,
            teacher: c.teacher || '',
            room: c.room || '',
            colorHex: c.colorHex || '#4F46E5',
            credits: c.credits || 3,
            createdAt: c.createdAt,
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
        const { name, code, teacher, room, colorHex, credits } = body;
        if (!name || typeof name !== 'string' || !name.trim()) {
            return errorResponse('Course name is required');
        }
        if (!code || typeof code !== 'string' || !code.trim()) {
            return errorResponse('Course code is required (e.g. CSE 320)');
        }
        const db = await getDatabase();
        const now = new Date();
        const newCourse = {
            userId: user._id,
            name: name.trim(),
            code: code.trim().toUpperCase(),
            teacher: teacher?.trim() || '',
            room: room?.trim() || '',
            colorHex: colorHex?.trim() || '#3B82F6',
            credits: Number(credits) || 3,
            createdAt: now,
            updatedAt: now,
        };
        const res = await db.collection('courses').insertOne(newCourse);
        return successResponse({
            id: res.insertedId.toString(),
            name: newCourse.name,
            code: newCourse.code,
            teacher: newCourse.teacher,
            room: newCourse.room,
            colorHex: newCourse.colorHex,
            credits: newCourse.credits,
            createdAt: newCourse.createdAt,
        }, 201);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
