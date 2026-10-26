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
            return notFoundResponse('Invalid exam ID');
        const db = await getDatabase();
        const exam = await db.collection('exams').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!exam)
            return notFoundResponse('Exam not found');
        const examDateTime = new Date(`${exam.date}T${exam.time || '00:00'}:00`).getTime();
        const daysRemaining = Math.ceil((examDateTime - Date.now()) / (1000 * 60 * 60 * 24));
        return successResponse({
            id: exam._id.toString(),
            subject: exam.subject,
            type: exam.type,
            date: exam.date,
            time: exam.time,
            location: exam.location,
            notes: exam.notes || '',
            daysRemaining,
            isPast: daysRemaining < 0,
            createdAt: exam.createdAt,
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
            return notFoundResponse('Invalid exam ID');
        const body = await request.json().catch(() => ({}));
        const { subject, type, date, time, location, notes } = body;
        const db = await getDatabase();
        const existing = await db.collection('exams').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!existing)
            return notFoundResponse('Exam not found');
        const update = { updatedAt: new Date() };
        if (subject)
            update.subject = subject.trim();
        if (type) {
            const validTypes = ['midterm', 'final', 'quiz', 'lab', 'presentation'];
            if (validTypes.includes(type))
                update.type = type;
        }
        if (date)
            update.date = date.trim();
        if (time)
            update.time = time.trim();
        if (location !== undefined)
            update.location = location.trim();
        if (notes !== undefined)
            update.notes = notes.trim();
        await db.collection('exams').updateOne({ _id: existing._id }, { $set: update });
        const updated = await db.collection('exams').findOne({ _id: existing._id });
        return successResponse({
            id: updated._id.toString(),
            subject: updated.subject,
            type: updated.type,
            date: updated.date,
            time: updated.time,
            location: updated.location,
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
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid exam ID');
        const db = await getDatabase();
        const res = await db.collection('exams').deleteOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (res.deletedCount === 0)
            return notFoundResponse('Exam not found');
        return successResponse({ message: 'Exam deleted successfully' });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
