import { NextResponse } from 'next/server';

export function successResponse(data, status = 200, meta) {
    const body = {
        success: true,
        data,
        ...(meta ? { meta } : {}),
    };
    return NextResponse.json(body, { status });
}

export function errorResponse(error, status = 400, details) {
    const body = {
        success: false,
        error,
        ...(details ? { details } : {}),
    };
    return NextResponse.json(body, { status });
}

export function unauthorizedResponse(error = 'Unauthorized access: Invalid or missing authentication token') {
    return errorResponse(error, 401);
}

export function forbiddenResponse(error = 'Forbidden: You do not have permission to access this resource') {
    return errorResponse(error, 403);
}

export function guestForbiddenResponse(error = 'Guest mode is read-only. Please create an account or sign in to save your personal routine and data.') {
    return errorResponse(error, 403, { code: 'GUEST_RESTRICTED', isGuest: true });
}

export function notFoundResponse(error = 'Resource not found') {
    return errorResponse(error, 404);
}

export function conflictResponse(error, details) {
    return errorResponse(error, 409, details);
}

export function serverErrorResponse(err) {
    console.error('API Error:', err);
    const message = err instanceof Error ? err.message : 'Internal server error occurred';
    return errorResponse(message, 500);
}
