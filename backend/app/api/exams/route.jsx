import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser, requireRegisteredUser } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const { searchParams } = new URL(request.url);
        const typeParam = searchParams.get('type');
        const upcomingOnly = searchParams.get('upcoming') === 'true';
        const db = await getDatabase();
        const query = { userId: user._id };
        const todayStr = new Date().toISOString().split('T')[0];
        if (upcomingOnly) {
            query.date = { $gte: todayStr };
        }
        if (typeParam && ['midterm', 'final', 'quiz', 'lab', 'presentation'].includes(typeParam)) {
            query.type = typeParam;
        }
        const exams = await db
            .collection('exams')
            .find(query)
            .sort({ date: 1, time: 1 })
            .toArray();
        const nowTime = new Date().getTime();
        const formatted = exams.map((e) => {
            // Calculate countdown in milliseconds / days
            const examDateTime = new Date(`${e.date}T${e.time || '00:00'}:00`).getTime();
            const diffMs = examDateTime - nowTime;
            const daysRemaining = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
            return {
                id: e._id.toString(),
                subject: e.subject,
                type: e.type,
                date: e.date,
                time: e.time,
                location: e.location,
                notes: e.notes || '',
                daysRemaining: isNaN(daysRemaining) ? 0 : daysRemaining,
                isPast: diffMs < 0,
                createdAt: e.createdAt,
            };
        });
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
        const guestErr = requireRegisteredUser(user);
        if (guestErr) return guestErr;
        const body = await request.json().catch(() => ({}));
        const { subject, type, date, time, location, notes } = body;
        if (!subject || !subject.trim()) {
            return errorResponse('Subject is required');
        }
        if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
            return errorResponse('Valid date (YYYY-MM-DD) is required');
        }
        const validTypes = ['midterm', 'final', 'quiz', 'lab', 'presentation'];
        const chosenType = validTypes.includes(type) ? type : 'quiz';
        const db = await getDatabase();
        const now = new Date();
        const newExam = {
            userId: user._id,
            subject: subject.trim(),
            type: chosenType,
            date: date.trim(),
            time: time?.trim() || '10:00',
            location: location?.trim() || 'Room TBA',
            notes: notes?.trim() || '',
            createdAt: now,
            updatedAt: now,
        };
        const res = await db.collection('exams').insertOne(newExam);
        const examDateTime = new Date(`${newExam.date}T${newExam.time}:00`).getTime();
        const daysRemaining = Math.ceil((examDateTime - Date.now()) / (1000 * 60 * 60 * 24));
        return successResponse({
            id: res.insertedId.toString(),
            subject: newExam.subject,
            type: newExam.type,
            date: newExam.date,
            time: newExam.time,
            location: newExam.location,
            notes: newExam.notes,
            daysRemaining,
            isPast: daysRemaining < 0,
            createdAt: newExam.createdAt,
        }, 201);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
