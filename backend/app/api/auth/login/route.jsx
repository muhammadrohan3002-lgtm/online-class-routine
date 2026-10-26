import { getDatabase } from '@/lib/mongodb';
import { comparePassword, generateToken } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function POST(request) {
    try {
        const body = await request.json().catch(() => ({}));
        const { email, password } = body;
        if (!email || !password) {
            return errorResponse('Email and password are required');
        }
        const db = await getDatabase();
        const user = await db.collection('users').findOne({
            email: email.toLowerCase().trim(),
        });
        if (!user) {
            return unauthorizedResponse('Invalid email or password');
        }
        const isMatch = await comparePassword(password, user.passwordHash);
        if (!isMatch) {
            return unauthorizedResponse('Invalid email or password');
        }
        const token = generateToken({
            userId: user._id.toString(),
            email: user.email,
            name: user.name,
        });
        const userSafe = {
            id: user._id.toString(),
            name: user.name,
            email: user.email,
            studentId: user.studentId || '',
            department: user.department || '',
            institution: user.institution || '',
            attendanceThreshold: user.attendanceThreshold ?? 75,
            createdAt: user.createdAt,
        };
        return successResponse({ token, user: userSafe });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
