import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, notFoundResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid course ID');
        const db = await getDatabase();
        const course = await db.collection('courses').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!course)
            return notFoundResponse('Course not found');
        return successResponse({
            id: course._id.toString(),
            name: course.name,
            code: course.code,
            teacher: course.teacher,
            room: course.room,
            colorHex: course.colorHex,
            credits: course.credits,
            createdAt: course.createdAt,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function PUT(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid course ID');
        const body = await request.json().catch(() => ({}));
        const { name, code, teacher, room, colorHex, credits } = body;
        const db = await getDatabase();
        const update = { updatedAt: new Date() };
        if (name)
            update.name = name.trim();
        if (code)
            update.code = code.trim().toUpperCase();
        if (teacher !== undefined)
            update.teacher = teacher.trim();
        if (room !== undefined)
            update.room = room.trim();
        if (colorHex)
            update.colorHex = colorHex.trim();
        if (credits !== undefined)
            update.credits = Number(credits);
        const result = await db.collection('courses').updateOne({ _id: new ObjectId(params.id), userId: user._id }, { $set: update });
        if (result.matchedCount === 0)
            return notFoundResponse('Course not found');
        const updated = await db.collection('courses').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        return successResponse({
            id: updated._id.toString(),
            name: updated.name,
            code: updated.code,
            teacher: updated.teacher,
            room: updated.room,
            colorHex: updated.colorHex,
            credits: updated.credits,
            updatedAt: updated.updatedAt,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function DELETE(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid course ID');
        const db = await getDatabase();
        const result = await db.collection('courses').deleteOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (result.deletedCount === 0)
            return notFoundResponse('Course not found');
        return successResponse({ message: 'Course deleted successfully' });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
