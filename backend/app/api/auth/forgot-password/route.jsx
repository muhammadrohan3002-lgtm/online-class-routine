import { getDatabase } from '@/lib/mongodb';
import { successResponse, errorResponse, serverErrorResponse } from '@/lib/api-response';
export async function POST(request) {
    try {
        const body = await request.json().catch(() => ({}));
        const { email } = body;
        if (!email) {
            return errorResponse('Email address is required');
        }
        const db = await getDatabase();
        const user = await db.collection('users').findOne({
            email: email.toLowerCase().trim(),
        });
        if (!user) {
            // Don't leak whether the email exists, return generic friendly message
            return successResponse({
                message: 'If the email exists in our system, password reset instructions have been generated.',
            });
        }
        // Generate a 6-digit OTP code for mobile reset convenience
        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 mins
        await db.collection('users').updateOne({ _id: user._id }, {
            $set: {
                resetToken: resetCode,
                resetTokenExpires: expiresAt,
                updatedAt: new Date(),
            },
        });
        return successResponse({
            message: 'Reset code generated successfully. Valid for 15 minutes.',
            // Provided for development/capstone demonstration ease
            resetCode,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
