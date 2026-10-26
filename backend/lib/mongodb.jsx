import { MongoClient } from 'mongodb';

const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/smart_routine_db';
const dbName = process.env.MONGODB_DB || 'smart_routine_db';

const globalWithMongo = global;

let client;
let clientPromise;

if (process.env.NODE_ENV === 'development') {
    if (!globalWithMongo._mongoClientPromise) {
        client = new MongoClient(uri, {
            maxPoolSize: 10,
            serverSelectionTimeoutMS: 5000,
        });
        globalWithMongo._mongoClientPromise = client.connect();
    }
    clientPromise = globalWithMongo._mongoClientPromise;
} else {
    client = new MongoClient(uri, {
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
    });
    clientPromise = client.connect();
}

/**
 * Returns the connected MongoDB database instance.
 */
export async function getDatabase() {
    const connectedClient = await clientPromise;
    const db = connectedClient.db(dbName);

    // Initialize indexes once
    if (!globalWithMongo._indexesCreated) {
        try {
            await ensureIndexes(db);
            globalWithMongo._indexesCreated = true;
        } catch (err) {
            console.warn('Index creation notice:', err);
        }
    }

    return db;
}

/**
 * Automatically set up required database indexes for queries & constraints.
 */
async function ensureIndexes(db) {
    // Users: unique email
    await db.collection('users').createIndex({ email: 1 }, { unique: true });

    // Routines: user queries & day filtering
    await db.collection('routines').createIndex({ userId: 1, dayOfWeek: 1 });
    await db.collection('routines').createIndex({ userId: 1, courseId: 1 });

    // Tasks: user queries, status and due date
    await db.collection('tasks').createIndex({ userId: 1, status: 1, dueDate: 1 });

    // Exams: user queries & date order
    await db.collection('exams').createIndex({ userId: 1, date: 1 });

    // Attendance: user, course, date index and duplicate prevention
    await db.collection('attendance').createIndex({ userId: 1, courseId: 1, date: 1 }, { unique: true });

    // Study Sessions: user & date
    await db.collection('studySessions').createIndex({ userId: 1, date: 1 });

    // Courses: user & code
    await db.collection('courses').createIndex({ userId: 1, code: 1 });
}

export default clientPromise;
