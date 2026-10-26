import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { ObjectId } from 'mongodb';
import { getDatabase } from './mongodb';

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

        const db = await getDatabase();
        const user = await db.collection('users').findOne({
            _id: new ObjectId(payload.userId),
        });
        return user;
    } catch (err) {
        console.error('getAuthenticatedUser error:', err);
        return null;
    }
}
