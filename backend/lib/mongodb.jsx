import { MongoClient } from 'mongodb';
import fs from 'fs';
import path from 'path';

/**
 * Resolves MongoDB URI and database name from environment variables.
 * Inspects process.env first, with safe fallback to local environment files.
 * Throws a credential-safe error if MONGODB_URI is not provided.
 */
function resolveMongoUri() {
    if (process.env.MONGODB_URI && process.env.MONGODB_URI.startsWith('mongodb')) {
        return process.env.MONGODB_URI;
    }

    const candidatePaths = [
        path.join(process.cwd(), '.env.local'),
        path.join(process.cwd(), '.env'),
        path.join(process.cwd(), 'backend', '.env.local'),
        path.join(process.cwd(), 'backend', '.env'),
        path.join(process.cwd(), '..', 'backend', '.env.local'),
        path.join(process.cwd(), '..', 'backend', '.env'),
        path.join(process.cwd(), '..', '.env.local'),
        path.join(process.cwd(), '..', '.env'),
    ];

    for (const filePath of candidatePaths) {
        try {
            if (fs.existsSync(filePath)) {
                const fileContent = fs.readFileSync(filePath, 'utf8');

                if (!process.env.MONGODB_URI) {
                    const uriMatch = fileContent.match(/^MONGODB_URI\s*=\s*(.+)$/m);
                    if (uriMatch) {
                        const uriVal = uriMatch[1].trim().replace(/^['"]|['"]$/g, '');
                        if (uriVal.startsWith('mongodb')) {
                            process.env.MONGODB_URI = uriVal;
                        }
                    }
                }

                if (!process.env.MONGODB_DB_NAME) {
                    const dbNameMatch = fileContent.match(/^MONGODB_DB_NAME\s*=\s*(.+)$/m);
                    if (dbNameMatch) {
                        process.env.MONGODB_DB_NAME = dbNameMatch[1].trim().replace(/^['"]|['"]$/g, '');
                    }
                }

                if (!process.env.MONGODB_DB) {
                    const dbMatch = fileContent.match(/^MONGODB_DB\s*=\s*(.+)$/m);
                    if (dbMatch) {
                        process.env.MONGODB_DB = dbMatch[1].trim().replace(/^['"]|['"]$/g, '');
                    }
                }

                if (process.env.MONGODB_URI && process.env.MONGODB_URI.startsWith('mongodb')) {
                    return process.env.MONGODB_URI;
                }
            }
        } catch (_) {}
    }

    if (!process.env.MONGODB_URI || !process.env.MONGODB_URI.startsWith('mongodb')) {
        throw new Error(
            'MongoDB configuration error: MONGODB_URI environment variable is missing or invalid. ' +
            'Please configure MONGODB_URI in your .env.local file or deployment environment settings.'
        );
    }

    return process.env.MONGODB_URI;
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
 * Reads database name from MONGODB_DB_NAME (or MONGODB_DB for backward compatibility).
 */
export async function getDatabase() {
    const connectedClient = await getClient();
    const dbName = process.env.MONGODB_DB_NAME || process.env.MONGODB_DB || 'smart_routine_db';
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
