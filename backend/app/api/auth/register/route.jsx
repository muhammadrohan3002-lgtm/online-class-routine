import { getDatabase } from '@/lib/mongodb';
import { hashPassword, generateToken } from '@/lib/auth';
import { isValidEmail } from '@/lib/validation';
import { successResponse, errorResponse, serverErrorResponse, conflictResponse } from '@/lib/api-response';
export async function POST(request) {
    try {
        const body = await request.json().catch(() => ({}));
        const { name, email, password, studentId, department, institution } = body;
        if (!name || typeof name !== 'string' || name.trim().length === 0) {
            return errorResponse('Full name is required');
        }
        if (!email || !isValidEmail(email)) {
            return errorResponse('A valid email address is required');
        }
        if (!password || typeof password !== 'string' || password.length < 6) {
            return errorResponse('Password must be at least 6 characters long');
        }
        const db = await getDatabase();
        const normalizedEmail = email.toLowerCase().trim();
        // Check if user already exists
        const existing = await db.collection('users').findOne({ email: normalizedEmail });
        if (existing) {
            return conflictResponse('An account with this email address already exists');
        }
        const passwordHash = await hashPassword(password);
        const now = new Date();
        const newUser = {
            name: name.trim(),
            email: normalizedEmail,
            passwordHash,
            studentId: studentId?.trim() || '',
            department: department?.trim() || '',
            institution: institution?.trim() || '',
            attendanceThreshold: 75,
            createdAt: now,
            updatedAt: now,
        };
        const insertResult = await db.collection('users').insertOne(newUser);
        const userId = insertResult.insertedId.toString();
        const token = generateToken({
            userId,
            email: normalizedEmail,
            name: newUser.name,
        });
        const userSafe = {
            id: userId,
            name: newUser.name,
            email: newUser.email,
            studentId: newUser.studentId,
            department: newUser.department,
            institution: newUser.institution,
            attendanceThreshold: newUser.attendanceThreshold,
            createdAt: newUser.createdAt,
        };
        return successResponse({ token, user: userSafe }, 201);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
