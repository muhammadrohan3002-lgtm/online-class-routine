import { NextResponse } from 'next/server';
import { getDatabase } from '@/lib/mongodb';
export async function GET() {
    try {
        const db = await getDatabase();
        await db.command({ ping: 1 });
        return NextResponse.json({
            status: 'healthy',
            database: 'connected',
            timestamp: new Date().toISOString(),
        });
    }
    catch (err) {
        return NextResponse.json({
            status: 'warning',
            database: 'disconnected',
            error: err.message,
            timestamp: new Date().toISOString(),
        }, { status: 200 });
    }
}
