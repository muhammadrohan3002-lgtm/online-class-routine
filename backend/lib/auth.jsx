import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { ObjectId } from 'mongodb';
import { getDatabase } from './mongodb';
import { unauthorizedResponse, guestForbiddenResponse } from './api-response';

const JWT_SECRET = process.env.JWT_SECRET || 'smart_routine_secure_jwt_secret_key_2026_xyz';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '30d';

export function hashPassword(password) {
    return bcrypt.hash(password, 10);
}

export function comparePassword(password, hash) {
    return bcrypt.compare(password, hash);
}

export function generateToken(payload) {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

export function verifyToken(token) {
    try {
        return jwt.verify(token, JWT_SECRET);
    } catch (error) {
        return null;
    }
}

/**
 * Checks whether a user is an unauthenticated/demo guest session
 */
export function isGuestUser(user) {
    if (!user) return false;
    return (
        user.isGuest === true ||
        user.email === 'guest@cse.edu' ||
        user._id?.toString() === 'guest_user_offline_id'
    );
}

/**
 * Guard that permits only authenticated registered student accounts.
 * Returns a 401 response if unauthenticated, or a 403 guestForbiddenResponse if guest.
 * Returns null if allowed.
 */
export function requireRegisteredUser(user) {
    if (!user) {
        return unauthorizedResponse('You must be signed in to perform this action.');
    }
    if (isGuestUser(user)) {
        return guestForbiddenResponse(
            'Guest mode is read-only. Please create an account or sign in to save your personal routine and data.'
        );
    }
    return null;
}

/**
 * Extracts and verifies the authenticated user from the Request Authorization header.
 * Never trusts client-supplied userIds.
 */
export async function getAuthenticatedUser(request) {
    try {
        const authHeader = request.headers.get('authorization') || request.headers.get('Authorization');
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return null;
        }
        const token = authHeader.substring(7).trim();
        if (!token) return null;

        const payload = verifyToken(token);
        if (!payload || !payload.userId) {
            return null;
        }

        // Handle offline guest token
        if (payload.userId === 'guest_user_offline_id') {
            return {
                _id: 'guest_user_offline_id',
                name: 'Guest Student',
                email: 'guest@cse.edu',
                studentId: 'GUEST-2026',
                department: 'Computer Science & Engineering',
                institution: 'University of Engineering & Technology',
                attendanceThreshold: 75,
                isGuest: true,
            };
        }

        const db = await getDatabase();
        if (!ObjectId.isValid(payload.userId)) {
            return null;
        }

        const user = await db.collection('users').findOne({
            _id: new ObjectId(payload.userId),
        });

        if (!user) return null;

        if (payload.isGuest || user.isGuest || user.email === 'guest@cse.edu') {
            user.isGuest = true;
        }

        return user;
    } catch (err) {
        console.error('getAuthenticatedUser error:', err);
        return null;
    }
}

