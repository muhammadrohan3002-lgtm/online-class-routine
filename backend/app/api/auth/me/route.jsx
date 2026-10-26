import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser, hashPassword, comparePassword } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user) {
            return unauthorizedResponse();
        }
        return successResponse({
            id: user._id.toString(),
            name: user.name,
            email: user.email,
            studentId: user.studentId || '',
            department: user.department || '',
            institution: user.institution || '',
            attendanceThreshold: user.attendanceThreshold ?? 75,
            createdAt: user.createdAt,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function PUT(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user) {
            return unauthorizedResponse();
        }
        const body = await request.json().catch(() => ({}));
        const { name, studentId, department, institution, attendanceThreshold, currentPassword, newPassword } = body;
        const db = await getDatabase();
        const updateFields = {
            updatedAt: new Date(),
        };
        if (name && typeof name === 'string')
            updateFields.name = name.trim();
        if (studentId !== undefined)
            updateFields.studentId = String(studentId).trim();
        if (department !== undefined)
            updateFields.department = String(department).trim();
        if (institution !== undefined)
            updateFields.institution = String(institution).trim();
        if (attendanceThreshold !== undefined) {
            const num = Number(attendanceThreshold);
            if (num >= 1 && num <= 100) {
                updateFields.attendanceThreshold = num;
            }
        }
        // Password change request
        if (newPassword) {
            if (!currentPassword) {
                return errorResponse('Current password is required to set a new password');
            }
            if (typeof newPassword !== 'string' || newPassword.length < 6) {
                return errorResponse('New password must be at least 6 characters long');
            }
            const isMatch = await comparePassword(currentPassword, user.passwordHash);
            if (!isMatch) {
                return errorResponse('Incorrect current password');
            }
            updateFields.passwordHash = await hashPassword(newPassword);
        }
        await db.collection('users').updateOne({ _id: user._id }, { $set: updateFields });
        const updated = await db.collection('users').findOne({ _id: user._id });
        return successResponse({
            id: updated._id.toString(),
            name: updated.name,
            email: updated.email,
            studentId: updated.studentId || '',
            department: updated.department || '',
            institution: updated.institution || '',
            attendanceThreshold: updated.attendanceThreshold ?? 75,
            updatedAt: updated.updatedAt,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
