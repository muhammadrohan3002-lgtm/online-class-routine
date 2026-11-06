import { getDatabase } from '@/lib/mongodb';
import { hashPassword } from '@/lib/auth';
import { successResponse, errorResponse, serverErrorResponse } from '@/lib/api-response';
export async function POST(request) {
    try {
        const body = await request.json().catch(() => ({}));
        const { email, resetCode, newPassword } = body;
        if (!email || !resetCode || !newPassword) {
            return errorResponse('Email, reset code, and new password are required');
        }
        if (typeof newPassword !== 'string' || newPassword.length < 6) {
            return errorResponse('New password must be at least 6 characters long');
        }
        const db = await getDatabase();
        const user = await db.collection('users').findOne({
            email: email.toLowerCase().trim(),
        });
        if (!user || !user.resetToken || user.resetToken !== resetCode.trim()) {
            return errorResponse('Invalid or expired reset code');
        }
        if (user.resetTokenExpires && new Date() > new Date(user.resetTokenExpires)) {
            return errorResponse('Reset code has expired. Please request a new one.');
        }
        const passwordHash = await hashPassword(newPassword);
        await db.collection('users').updateOne({ _id: user._id }, {
            $set: {
                passwordHash,
                updatedAt: new Date(),
            },
            $unset: {
                resetToken: '',
                resetTokenExpires: '',
            },
        });
        return successResponse({
            message: 'Password reset successfully. You can now log in with your new password.',
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
