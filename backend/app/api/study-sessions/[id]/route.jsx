import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser, requireRegisteredUser } from '@/lib/auth';
import { successResponse, notFoundResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid session ID');
        const db = await getDatabase();
        const session = await db.collection('studySessions').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!session)
            return notFoundResponse('Study session not found');
        return successResponse({
            id: session._id.toString(),
            courseId: session.courseId ? session.courseId.toString() : null,
            courseName: session.courseName,
            date: session.date,
            targetMinutes: session.targetMinutes,
            completedMinutes: session.completedMinutes,
            notes: session.notes || '',
            createdAt: session.createdAt,
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
        const guestErr = requireRegisteredUser(user);
        if (guestErr) return guestErr;
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid session ID');
        const body = await request.json().catch(() => ({}));
        const { targetMinutes, completedMinutes, notes, date } = body;
        const db = await getDatabase();
        const existing = await db.collection('studySessions').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!existing)
            return notFoundResponse('Study session not found');
        const update = { updatedAt: new Date() };
        if (targetMinutes !== undefined)
            update.targetMinutes = Math.max(1, Number(targetMinutes));
        if (completedMinutes !== undefined)
            update.completedMinutes = Math.max(0, Number(completedMinutes));
        if (notes !== undefined)
            update.notes = String(notes).trim();
        if (date && /^\d{4}-\d{2}-\d{2}$/.test(date))
            update.date = date;
        await db.collection('studySessions').updateOne({ _id: existing._id }, { $set: update });
        const updated = await db.collection('studySessions').findOne({
            _id: existing._id,
        });
        return successResponse({
            id: updated._id.toString(),
            courseId: updated.courseId ? updated.courseId.toString() : null,
            courseName: updated.courseName,
            date: updated.date,
            targetMinutes: updated.targetMinutes,
            completedMinutes: updated.completedMinutes,
            notes: updated.notes,
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
        const guestErr = requireRegisteredUser(user);
        if (guestErr) return guestErr;
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid session ID');
        const db = await getDatabase();
        const res = await db.collection('studySessions').deleteOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (res.deletedCount === 0)
            return notFoundResponse('Study session not found');
        return successResponse({ message: 'Study session deleted successfully' });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
