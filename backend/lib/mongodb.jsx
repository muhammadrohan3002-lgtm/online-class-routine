import { MongoClient } from 'mongodb';
import fs from 'fs';
import path from 'path';

const ATLAS_FALLBACK_URI =
    'mongodb+srv://online_routine:gaubC9JzmXrM3WRe@cluster0.u9jjnjy.mongodb.net/smart_routine_db?retryWrites=true&w=majority';

function resolveMongoUri() {
    if (process.env.MONGODB_URI && process.env.MONGODB_URI.startsWith('mongodb')) {
        return process.env.MONGODB_URI;
    }

    const possiblePaths = [
        path.join(process.cwd(), 'backend', '.env'),
        path.join(process.cwd(), '.env'),
        path.join(process.cwd(), '..', 'backend', '.env'),
    ];

    for (const p of possiblePaths) {
        try {
            if (fs.existsSync(p)) {
                const content = fs.readFileSync(p, 'utf8');
                const match = content.match(/^MONGODB_URI\s*=\s*(.+)$/m);
                if (match) {
                    const foundUri = match[1].trim().replace(/^['"]|['"]$/g, '');
                    if (foundUri.startsWith('mongodb')) {
                        process.env.MONGODB_URI = foundUri;
                        return foundUri;
                    }
                }
            }
        } catch (_) {}
    }

    return ATLAS_FALLBACK_URI;
}

const clientOptions = {
    maxPoolSize: 10,
    minPoolSize: 1,
    serverSelectionTimeoutMS: 15000,
    connectTimeoutMS: 15000,
    socketTimeoutMS: 30000,
    retryWrites: true,
    retryReads: true,
};

const globalWithMongo = global;

/**
 * Returns an active, connected MongoClient instance with auto-reconnection.
 */
export async function getClient() {
    if (globalWithMongo._mongoClient) {
        try {
            return globalWithMongo._mongoClient;
        } catch (_) {}
    }

    if (!globalWithMongo._mongoClientPromise) {
        const uri = resolveMongoUri();
        const clientInstance = new MongoClient(uri, clientOptions);

        globalWithMongo._mongoClientPromise = clientInstance
            .connect()
            .then((connected) => {
                globalWithMongo._mongoClient = connected;
                return connected;
            })
            .catch((err) => {
                console.error('MongoDB Atlas Connection Error:', err.message);
                globalWithMongo._mongoClientPromise = null;
                globalWithMongo._mongoClient = null;
                throw err;
            });
    }

    return globalWithMongo._mongoClientPromise;
}

/**
 * Returns the connected MongoDB database instance.
 */
export async function getDatabase() {
    const connectedClient = await getClient();
    const dbName = process.env.MONGODB_DB || 'smart_routine_db';
    const db = connectedClient.db(dbName);

    // Initialize indexes once in a safe, non-blocking manner
    if (!globalWithMongo._indexesCreated) {
        ensureIndexes(db)
            .then(() => {
                globalWithMongo._indexesCreated = true;
            })
            .catch((err) => {
                console.warn('Index initialization note:', err.message);
                globalWithMongo._indexesCreated = true;
            });
    }

    return db;
}

/**
 * Sets up database indexes for queries & constraints.
 */
async function ensureIndexes(db) {
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('routines').createIndex({ userId: 1, dayOfWeek: 1 });
    await db.collection('routines').createIndex({ userId: 1, courseId: 1 });
    await db.collection('tasks').createIndex({ userId: 1, status: 1, dueDate: 1 });
    await db.collection('exams').createIndex({ userId: 1, date: 1 });
    await db.collection('attendance').createIndex({ userId: 1, courseId: 1, date: 1 });
    await db.collection('studySessions').createIndex({ userId: 1, date: 1 });
    await db.collection('courses').createIndex({ userId: 1, code: 1 });
}

export default getClient();
