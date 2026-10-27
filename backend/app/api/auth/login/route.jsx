import { getDatabase } from '@/lib/mongodb';
import { comparePassword, generateToken } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';

export async function POST(request) {
    try {
        const body = await request.json().catch(() => ({}));
        const { email, password } = body || {};

        const cleanEmail = typeof email === 'string' ? email.toLowerCase().trim() : '';
        const cleanPassword = typeof password === 'string' ? password : '';

        if (!cleanEmail || !cleanPassword) {
            return errorResponse('Email and password are required');
        }

        const db = await getDatabase();
        const user = await db.collection('users').findOne({
            email: cleanEmail,
        });

        if (!user) {
            return unauthorizedResponse('Invalid email or password');
        }

        const isMatch = await comparePassword(cleanPassword, user.passwordHash);
        if (!isMatch) {
            return unauthorizedResponse('Invalid email or password');
        }

        const token = generateToken({
            userId: user._id.toString(),
            email: user.email,
            name: user.name,
            isGuest: false,
        });

        const userSafe = {
            id: user._id.toString(),
            name: user.name,
            email: user.email,
            studentId: user.studentId || '',
            department: user.department || '',
            institution: user.institution || '',
            attendanceThreshold: user.attendanceThreshold ?? 75,
            isGuest: false,
            createdAt: user.createdAt,
        };

        return successResponse({ token, user: userSafe });
    } catch (err) {
        console.error('Login API Error:', err.message);
        return serverErrorResponse(err);
    }
}
