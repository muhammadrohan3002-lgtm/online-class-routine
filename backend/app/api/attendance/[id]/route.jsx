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
            return notFoundResponse('Invalid attendance ID');
        const db = await getDatabase();
        const record = await db.collection('attendance').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!record)
            return notFoundResponse('Attendance record not found');
        return successResponse({
            id: record._id.toString(),
            courseId: record.courseId.toString(),
            courseName: record.courseName,
            date: record.date,
            status: record.status,
            notes: record.notes || '',
            createdAt: record.createdAt,
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
            return notFoundResponse('Invalid attendance ID');
        const body = await request.json().catch(() => ({}));
        const { status, notes } = body;
        const db = await getDatabase();
        const existing = await db.collection('attendance').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!existing)
            return notFoundResponse('Attendance record not found');
        const update = { updatedAt: new Date() };
        const validStatuses = ['present', 'absent', 'late'];
        if (status && validStatuses.includes(status)) {
            update.status = status;
        }
        if (notes !== undefined) {
            update.notes = String(notes).trim();
        }
        await db.collection('attendance').updateOne({ _id: existing._id }, { $set: update });
        const updated = await db.collection('attendance').findOne({
            _id: existing._id,
        });
        return successResponse({
            id: updated._id.toString(),
            courseId: updated.courseId.toString(),
            courseName: updated.courseName,
            date: updated.date,
            status: updated.status,
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
            return notFoundResponse('Invalid attendance ID');
        const db = await getDatabase();
        const res = await db.collection('attendance').deleteOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (res.deletedCount === 0)
            return notFoundResponse('Attendance record not found');
        return successResponse({ message: 'Attendance record deleted successfully' });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
