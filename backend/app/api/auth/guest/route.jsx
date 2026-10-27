import { getDatabase } from '@/lib/mongodb';
import { hashPassword, generateToken } from '@/lib/auth';
import { successResponse, serverErrorResponse } from '@/lib/api-response';
import { ObjectId } from 'mongodb';
export async function POST(request) {
    try {
        let db;
        try {
            db = await getDatabase();
        }
        catch {
            // MongoDB not connected yet; return stateless demo guest
            const demoToken = generateToken({
                userId: 'guest_user_offline_id',
                email: 'guest@cse.edu',
                name: 'Guest CSE Student',
            });
            return successResponse({
                token: demoToken,
                isGuest: true,
                user: {
                    id: 'guest_user_offline_id',
                    name: 'Guest Student',
                    email: 'guest@cse.edu',
                    studentId: 'GUEST-2026',
                    department: 'Computer Science & Engineering',
                    institution: 'University of Engineering & Technology',
                    attendanceThreshold: 75,
                    createdAt: new Date().toISOString(),
                },
            });
        }
        const usersColl = db.collection('users');
        let guestUser = await usersColl.findOne({ email: 'guest@cse.edu' });
        if (!guestUser) {
            const passwordHash = await hashPassword('guest123');
            const now = new Date().toISOString();
            const insertResult = await usersColl.insertOne({
                name: 'Guest Student',
                email: 'guest@cse.edu',
                passwordHash,
                studentId: 'GUEST-CSE-01',
                department: 'Computer Science & Engineering',
                institution: 'University of Engineering & Technology',
                attendanceThreshold: 75,
                isGuest: true,
                createdAt: now,
                updatedAt: now,
            });
            const userId = insertResult.insertedId;
            guestUser = await usersColl.findOne({ _id: userId });
            // Seed initial sample data for guest
            if (guestUser && guestUser._id) {
                const c1Id = new ObjectId();
                const c2Id = new ObjectId();
                const c3Id = new ObjectId();
                await db.collection('courses').insertMany([
                    {
                        _id: c1Id,
                        userId,
                        code: 'CSE 311',
                        name: 'Database Management Systems',
                        teacher: 'Dr. Alan Turing',
                        credit: 3.0,
                        colorHex: '#4F46E5',
                        createdAt: now,
                        updatedAt: now,
                    },
                    {
                        _id: c2Id,
                        userId,
                        code: 'CSE 313',
                        name: 'Operating Systems',
                        teacher: 'Prof. Dennis Ritchie',
                        credit: 3.0,
                        colorHex: '#0EA5E9',
                        createdAt: now,
                        updatedAt: now,
                    },
                    {
                        _id: c3Id,
                        userId,
                        code: 'CSE 315',
                        name: 'Computer Networks',
                        teacher: 'Dr. Vint Cerf',
                        credit: 3.0,
                        colorHex: '#10B981',
                        createdAt: now,
                        updatedAt: now,
                    },
                ]);
                await db.collection('routines').insertMany([
                    {
                        userId,
                        courseId: c1Id,
                        courseCode: 'CSE 311',
                        courseName: 'Database Management Systems',
                        day: 'Sunday',
                        startTime: '09:00',
                        endTime: '10:30',
                        room: 'Lab 402',
                        teacher: 'Dr. Alan Turing',
                        colorHex: '#4F46E5',
                        createdAt: now,
                        updatedAt: now,
                    },
                    {
                        userId,
                        courseId: c2Id,
                        courseCode: 'CSE 313',
                        courseName: 'Operating Systems',
                        day: 'Sunday',
                        startTime: '10:45',
                        endTime: '12:15',
                        room: 'Room 501',
                        teacher: 'Prof. Dennis Ritchie',
                        colorHex: '#0EA5E9',
                        createdAt: now,
                        updatedAt: now,
                    },
                ]);
                await db.collection('tasks').insertMany([
                    {
                        userId,
                        courseId: c1Id,
                        title: 'Design SQL Schema for Library',
                        description: 'Create normalized tables up to 3NF with primary and foreign keys',
                        dueDate: new Date(Date.now() + 2 * 86400000).toISOString(),
                        priority: 'high',
                        category: 'Assignment',
                        status: 'pending',
                        createdAt: now,
                        updatedAt: now,
                    },
                    {
                        userId,
                        courseId: c2Id,
                        title: 'Read OS Process Scheduling Chapter',
                        description: 'Review Round Robin, SJF, and Multi-Level Feedback Queue',
                        dueDate: new Date(Date.now() + 5 * 86400000).toISOString(),
                        priority: 'medium',
                        category: 'Study',
                        status: 'pending',
                        createdAt: now,
                        updatedAt: now,
                    },
                ]);
                await db.collection('exams').insertOne({
                    userId,
                    courseId: c1Id,
                    title: 'DBMS Midterm Examination',
                    type: 'Midterm Exam',
                    date: new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0],
                    time: '10:00 AM',
                    location: 'Auditorium Hall B',
                    notes: 'Topics: ER diagrams, Relational Algebra, SQL DDL/DML, Normalization',
                    createdAt: now,
                    updatedAt: now,
                });
                await db.collection('attendance').insertMany([
                    {
                        userId,
                        courseId: c1Id,
                        date: new Date(Date.now() - 86400000).toISOString().split('T')[0],
                        status: 'present',
                        createdAt: now,
                    },
                    {
                        userId,
                        courseId: c2Id,
                        date: new Date(Date.now() - 86400000).toISOString().split('T')[0],
                        status: 'present',
                        createdAt: now,
                    },
                ]);
                await db.collection('studySessions').insertOne({
                    userId,
                    courseId: c1Id,
                    durationMinutes: 90,
                    date: new Date().toISOString().split('T')[0],
                    notes: 'Completed practice SQL queries on JOINs and subqueries',
                    createdAt: now,
                });
            }
        }
        const token = generateToken({
            userId: guestUser._id.toString(),
            email: guestUser.email,
            name: guestUser.name,
            isGuest: true,
        });
        const userSafe = {
            id: guestUser._id.toString(),
            name: guestUser.name,
            email: guestUser.email,
            studentId: guestUser.studentId || 'GUEST-CSE-01',
            department: guestUser.department || 'Computer Science & Engineering',
            institution: guestUser.institution || 'University of Engineering & Technology',
            attendanceThreshold: guestUser.attendanceThreshold ?? 75,
            isGuest: true,
            createdAt: guestUser.createdAt,
        };
        return successResponse({ token, user: userSafe, isGuest: true });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
