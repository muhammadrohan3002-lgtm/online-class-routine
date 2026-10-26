import { MongoClient, ObjectId } from 'mongodb';
import bcrypt from 'bcryptjs';

const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/smart_routine_db';
const dbName = process.env.MONGODB_DB || 'smart_routine_db';

async function seed() {
  console.log(`Connecting to MongoDB at: ${uri} (DB: ${dbName})`);
  const client = new MongoClient(uri);

  try {
    await client.connect();
    const db = client.db(dbName);

    console.log('Clearing existing demo data...');
    await db.collection('users').deleteMany({ email: 'student@cse.edu' });

    // 1. Create Demo User
    const passwordHash = await bcrypt.hash('student123', 10);
    const userId = new ObjectId();
    const now = new Date();

    const user = {
      _id: userId,
      name: 'Alex Morgan',
      email: 'student@cse.edu',
      passwordHash,
      studentId: '2026-CSE-042',
      department: 'Computer Science & Engineering',
      institution: 'University of Technology',
      attendanceThreshold: 75,
      createdAt: now,
      updatedAt: now,
    };
    await db.collection('users').insertOne(user);
    console.log('✓ Created demo student: student@cse.edu (password: student123)');

    // 2. Create Courses
    const course1Id = new ObjectId();
    const course2Id = new ObjectId();
    const course3Id = new ObjectId();
    const course4Id = new ObjectId();

    const courses = [
      {
        _id: course1Id,
        userId,
        name: 'Operating Systems & System Programming',
        code: 'CSE 320',
        teacher: 'Dr. John Doe',
        room: 'Lab 402',
        colorHex: '#2563EB',
        credits: 3,
        createdAt: now,
        updatedAt: now,
      },
      {
        _id: course2Id,
        userId,
        name: 'Database Management Systems',
        code: 'CSE 310',
        teacher: 'Prof. Sarah Jenkins',
        room: 'Room 305',
        colorHex: '#4F46E5',
        credits: 3,
        createdAt: now,
        updatedAt: now,
      },
      {
        _id: course3Id,
        userId,
        name: 'Computer Networks & Security',
        code: 'CSE 330',
        teacher: 'Dr. Alan Smith',
        room: 'Lab 201',
        colorHex: '#059669',
        credits: 4,
        createdAt: now,
        updatedAt: now,
      },
      {
        _id: course4Id,
        userId,
        name: 'Compiler Design & Automata',
        code: 'CSE 340',
        teacher: 'Dr. Emily Vance',
        room: 'Room 410',
        colorHex: '#D97706',
        credits: 3,
        createdAt: now,
        updatedAt: now,
      },
    ];
    await db.collection('courses').insertMany(courses);
    console.log(`✓ Created ${courses.length} CSE courses`);

    // 3. Create Routines (Saturday to Friday)
    // 0=Sat, 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri
    const routines = [
      // Saturday
      {
        userId,
        courseId: course1Id,
        courseName: 'Operating Systems & System Programming',
        courseCode: 'CSE 320',
        teacher: 'Dr. John Doe',
        room: 'Lab 402',
        dayOfWeek: 0,
        startTime: '09:00',
        endTime: '10:30',
        colorHex: '#2563EB',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course2Id,
        courseName: 'Database Management Systems',
        courseCode: 'CSE 310',
        teacher: 'Prof. Sarah Jenkins',
        room: 'Room 305',
        dayOfWeek: 0,
        startTime: '11:00',
        endTime: '12:30',
        colorHex: '#4F46E5',
        createdAt: now,
        updatedAt: now,
      },
      // Sunday
      {
        userId,
        courseId: course3Id,
        courseName: 'Computer Networks & Security',
        courseCode: 'CSE 330',
        teacher: 'Dr. Alan Smith',
        room: 'Lab 201',
        dayOfWeek: 1,
        startTime: '09:30',
        endTime: '11:00',
        colorHex: '#059669',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course4Id,
        courseName: 'Compiler Design & Automata',
        courseCode: 'CSE 340',
        teacher: 'Dr. Emily Vance',
        room: 'Room 410',
        dayOfWeek: 1,
        startTime: '11:30',
        endTime: '13:00',
        colorHex: '#D97706',
        createdAt: now,
        updatedAt: now,
      },
      // Monday
      {
        userId,
        courseId: course1Id,
        courseName: 'Operating Systems & System Programming',
        courseCode: 'CSE 320',
        teacher: 'Dr. John Doe',
        room: 'Lab 402',
        dayOfWeek: 2,
        startTime: '10:00',
        endTime: '11:30',
        colorHex: '#2563EB',
        createdAt: now,
        updatedAt: now,
      },
      // Tuesday
      {
        userId,
        courseId: course2Id,
        courseName: 'Database Management Systems',
        courseCode: 'CSE 310',
        teacher: 'Prof. Sarah Jenkins',
        room: 'Room 305',
        dayOfWeek: 3,
        startTime: '09:00',
        endTime: '10:30',
        colorHex: '#4F46E5',
        createdAt: now,
        updatedAt: now,
      },
      // Wednesday
      {
        userId,
        courseId: course3Id,
        courseName: 'Computer Networks & Security',
        courseCode: 'CSE 330',
        teacher: 'Dr. Alan Smith',
        room: 'Lab 201',
        dayOfWeek: 4,
        startTime: '11:00',
        endTime: '12:30',
        colorHex: '#059669',
        createdAt: now,
        updatedAt: now,
      },
      // Thursday
      {
        userId,
        courseId: course4Id,
        courseName: 'Compiler Design & Automata',
        courseCode: 'CSE 340',
        teacher: 'Dr. Emily Vance',
        room: 'Room 410',
        dayOfWeek: 5,
        startTime: '10:00',
        endTime: '11:30',
        colorHex: '#D97706',
        createdAt: now,
        updatedAt: now,
      },
    ];
    await db.collection('routines').insertMany(routines);
    console.log(`✓ Created ${routines.length} routine entries across Saturday to Thursday`);

    // 4. Create Tasks
    const today = new Date();
    const formatDate = (offsetDays) => {
      const d = new Date(today);
      d.setDate(d.getDate() + offsetDays);
      return d.toISOString().split('T')[0];
    };

    const tasks = [
      {
        userId,
        title: 'Operating Systems Lab 4: Semaphore Implementation',
        description: 'Complete producer-consumer problem using POSIX semaphores in C',
        dueDate: formatDate(1), // Tomorrow
        dueTime: '23:59',
        priority: 'high',
        status: 'pending',
        category: 'Assignment',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        title: 'Database Normalization Homework (3NF & BCNF)',
        description: 'Decompose relation schemas into BCNF with dependency preservation',
        dueDate: formatDate(3),
        dueTime: '17:00',
        priority: 'medium',
        status: 'pending',
        category: 'Study',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        title: 'Submit IEEE Student Chapter Registration',
        description: 'Renew annual membership and submit receipt',
        dueDate: formatDate(-1), // Overdue
        dueTime: '12:00',
        priority: 'low',
        status: 'pending',
        category: 'Personal',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        title: 'Networks Wireshark Packet Analysis',
        description: 'Captured TCP 3-way handshake and HTTP headers',
        dueDate: formatDate(-3),
        dueTime: '23:59',
        priority: 'high',
        status: 'completed',
        category: 'Assignment',
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      },
    ];
    await db.collection('tasks').insertMany(tasks);
    console.log(`✓ Created ${tasks.length} tasks`);

    // 5. Create Exams
    const exams = [
      {
        userId,
        subject: 'CSE 320: Operating Systems',
        type: 'midterm',
        date: formatDate(5),
        time: '10:00',
        location: 'Auditorium 1',
        notes: 'Processes, CPU Scheduling, Memory Management, and Virtual Memory',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        subject: 'CSE 310: Database Systems',
        type: 'quiz',
        date: formatDate(2),
        time: '11:00',
        location: 'Room 305',
        notes: 'SQL Queries, Joins, and Relational Algebra',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        subject: 'CSE 330: Networks Lab Exam',
        type: 'lab',
        date: formatDate(10),
        time: '14:00',
        location: 'Lab 201',
        notes: 'Socket Programming in Python and Packet Tracing',
        createdAt: now,
        updatedAt: now,
      },
    ];
    await db.collection('exams').insertMany(exams);
    console.log(`✓ Created ${exams.length} exams`);

    // 6. Create Attendance Records
    const attendance = [
      {
        userId,
        courseId: course1Id,
        courseName: 'Operating Systems & System Programming',
        date: formatDate(-7),
        status: 'present',
        notes: 'Process control blocks lecture',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course1Id,
        courseName: 'Operating Systems & System Programming',
        date: formatDate(-5),
        status: 'present',
        notes: 'CPU scheduling algorithms',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course1Id,
        courseName: 'Operating Systems & System Programming',
        date: formatDate(-2),
        status: 'late',
        notes: 'Arrived 10 minutes late',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course2Id,
        courseName: 'Database Management Systems',
        date: formatDate(-6),
        status: 'present',
        notes: 'ER Modeling',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course2Id,
        courseName: 'Database Management Systems',
        date: formatDate(-4),
        status: 'absent',
        notes: 'Doctor appointment',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course3Id,
        courseName: 'Computer Networks & Security',
        date: formatDate(-7),
        status: 'present',
        notes: 'OSI vs TCP/IP model',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course3Id,
        courseName: 'Computer Networks & Security',
        date: formatDate(-3),
        status: 'present',
        notes: 'Subnetting and CIDR',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course4Id,
        courseName: 'Compiler Design & Automata',
        date: formatDate(-6),
        status: 'absent',
        notes: 'Missed class',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course4Id,
        courseName: 'Compiler Design & Automata',
        date: formatDate(-2),
        status: 'absent',
        notes: 'Missed class',
        createdAt: now,
        updatedAt: now,
      },
    ];
    await db.collection('attendance').insertMany(attendance);
    console.log(`✓ Created ${attendance.length} attendance records`);

    // 7. Create Study Sessions
    const studySessions = [
      {
        userId,
        courseId: course1Id,
        courseName: 'Operating Systems',
        date: formatDate(-3),
        targetMinutes: 60,
        completedMinutes: 55,
        notes: 'Reviewed Round Robin and Priority scheduling',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course2Id,
        courseName: 'Database Systems',
        date: formatDate(-2),
        targetMinutes: 45,
        completedMinutes: 45,
        notes: 'Solved B-Tree index practice problems',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course3Id,
        courseName: 'Computer Networks',
        date: formatDate(-1),
        targetMinutes: 60,
        completedMinutes: 70,
        notes: 'Completed subnetting worksheet',
        createdAt: now,
        updatedAt: now,
      },
      {
        userId,
        courseId: course4Id,
        courseName: 'Compiler Design',
        date: formatDate(0), // Today
        targetMinutes: 90,
        completedMinutes: 60,
        notes: 'Studied LL(1) parsing tables',
        createdAt: now,
        updatedAt: now,
      },
    ];
    await db.collection('studySessions').insertMany(studySessions);
    console.log(`✓ Created ${studySessions.length} study sessions`);

    console.log('\n===========================================');
    console.log('🎉 Seeding successfully completed!');
    console.log('Login credentials for Flutter App:');
    console.log('Email:    student@cse.edu');
    console.log('Password: student123');
    console.log('===========================================\n');
  } finally {
    await client.close();
  }
}

seed().catch((err) => {
  console.error('Seeding error:', err);
  process.exit(1);
});
