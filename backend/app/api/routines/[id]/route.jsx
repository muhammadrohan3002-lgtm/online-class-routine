import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser, requireRegisteredUser } from '@/lib/auth';
import { successResponse, errorResponse, notFoundResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
import { doIntervalsOverlap, isTimeRangeValid } from '@/lib/validation';
export async function GET(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid routine ID');
        const db = await getDatabase();
        const routine = await db.collection('routines').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!routine)
            return notFoundResponse('Routine not found');
        return successResponse({
            id: routine._id.toString(),
            courseId: routine.courseId ? routine.courseId.toString() : null,
            courseName: routine.courseName,
            courseCode: routine.courseCode,
            teacher: routine.teacher,
            room: routine.room,
            dayOfWeek: routine.dayOfWeek,
            startTime: routine.startTime,
            endTime: routine.endTime,
            colorHex: routine.colorHex,
            createdAt: routine.createdAt,
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
            return notFoundResponse('Invalid routine ID');
        const body = await request.json().catch(() => ({}));
        const { courseId, courseName, courseCode, teacher, room, dayOfWeek, startTime, endTime, colorHex, } = body;
        const db = await getDatabase();
        const existingRoutine = await db.collection('routines').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!existingRoutine)
            return notFoundResponse('Routine not found');
        const targetDay = dayOfWeek !== undefined ? Number(dayOfWeek) : existingRoutine.dayOfWeek;
        const targetStart = startTime ? startTime.trim() : existingRoutine.startTime;
        const targetEnd = endTime ? endTime.trim() : existingRoutine.endTime;
        if (!isTimeRangeValid(targetStart, targetEnd)) {
            return errorResponse('Start time must be before end time');
        }
        // Check overlap with other routines
        const others = await db
            .collection('routines')
            .find({
            userId: user._id,
            dayOfWeek: targetDay,
            _id: { $ne: existingRoutine._id },
        })
            .toArray();
        const overlapping = others.filter((r) => doIntervalsOverlap(targetStart, targetEnd, r.startTime, r.endTime));
        const conflictWarning = overlapping.length > 0
            ? `Overlaps with ${overlapping[0].courseCode} (${overlapping[0].startTime} - ${overlapping[0].endTime})`
            : null;
        const update = { updatedAt: new Date() };
        if (courseName)
            update.courseName = courseName.trim();
        if (courseCode)
            update.courseCode = courseCode.trim().toUpperCase();
        if (teacher !== undefined)
            update.teacher = teacher.trim();
        if (room !== undefined)
            update.room = room.trim();
        if (dayOfWeek !== undefined)
            update.dayOfWeek = targetDay;
        if (startTime)
            update.startTime = targetStart;
        if (endTime)
            update.endTime = targetEnd;
        if (colorHex)
            update.colorHex = colorHex.trim();
        if (courseId !== undefined) {
            update.courseId = courseId && ObjectId.isValid(courseId) ? new ObjectId(courseId) : null;
        }
        await db.collection('routines').updateOne({ _id: existingRoutine._id }, { $set: update });
        const updated = await db.collection('routines').findOne({
            _id: existingRoutine._id,
        });
        return successResponse({
            id: updated._id.toString(),
            courseId: updated.courseId ? updated.courseId.toString() : null,
            courseName: updated.courseName,
            courseCode: updated.courseCode,
            teacher: updated.teacher,
            room: updated.room,
            dayOfWeek: updated.dayOfWeek,
            startTime: updated.startTime,
            endTime: updated.endTime,
            colorHex: updated.colorHex,
            conflictWarning,
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
            return notFoundResponse('Invalid routine ID');
        const db = await getDatabase();
        const res = await db.collection('routines').deleteOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (res.deletedCount === 0)
            return notFoundResponse('Routine not found');
        return successResponse({ message: 'Routine deleted successfully' });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
