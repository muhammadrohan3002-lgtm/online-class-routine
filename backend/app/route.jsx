import { NextResponse } from 'next/server';

export async function GET() {
    return NextResponse.json({
        success: true,
        message: 'Smart Routine Backend is Running!',
        status: 'Active',
        version: '1.0.0',
    });
}

