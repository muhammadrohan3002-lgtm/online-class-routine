import { getDatabase } from '@/lib/mongodb';
import { hashPassword, generateToken } from '@/lib/auth';
import { isValidEmail } from '@/lib/validation';
import { successResponse, errorResponse, serverErrorResponse, conflictResponse } from '@/lib/api-response';

export async function POST(request) {
    try {
        const body = await request.json().catch(() => ({}));
        const { name, email, password, studentId, department, institution } = body || {};

        const cleanName = typeof name === 'string' ? name.trim() : '';
        const cleanEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';
        const cleanPassword = typeof password === 'string' ? password : '';

        if (!cleanName) {
            return errorResponse('Full name is required');
        }

        if (!cleanEmail || !isValidEmail(cleanEmail)) {
            return errorResponse('A valid email address is required');
        }

        if (!cleanPassword || cleanPassword.length < 6) {
            return errorResponse('Password must be at least 6 characters long');
        }

        const db = await getDatabase();

        // Check if user already exists in MongoDB Atlas
        const existing = await db.collection('users').findOne({ email: cleanEmail });
        if (existing) {
            return conflictResponse('An account with this email address already exists');
        }

        const passwordHash = await hashPassword(cleanPassword);
        const now = new Date();

        const newUser = {
            name: cleanName,
            email: cleanEmail,
            passwordHash,
            studentId: typeof studentId === 'string' ? studentId.trim() : '',
            department: typeof department === 'string' ? department.trim() : '',
            institution: typeof institution === 'string' ? institution.trim() : '',
            attendanceThreshold: 75,
            isGuest: false,
            createdAt: now,
            updatedAt: now,
        };

        const insertResult = await db.collection('users').insertOne(newUser);
        const userId = insertResult.insertedId.toString();

        const token = generateToken({
            userId,
            email: cleanEmail,
            name: newUser.name,
            isGuest: false,
        });

        const userSafe = {
            id: userId,
            name: newUser.name,
            email: newUser.email,
            studentId: newUser.studentId,
            department: newUser.department,
            institution: newUser.institution,
            attendanceThreshold: newUser.attendanceThreshold,
            isGuest: false,
            createdAt: newUser.createdAt,
        };

        return successResponse({ token, user: userSafe }, 201);
    } catch (err) {
        console.error('Registration API Error:', err.message);

        // Handle MongoDB unique index violation cleanly
        if (err?.code === 11000) {
            return conflictResponse('An account with this email address already exists');
        }

        return serverErrorResponse(err);
    }
}
