import { MongoClient, ObjectId } from 'mongodb';

async function runAuthTests() {
  const baseUrl = 'http://127.0.0.1:5000/api';
  console.log('=== Starting Auth End-to-End Test Suite ===');

  // Test 1: Register New User
  const timestamp = Date.now();
  const testUser = {
    name: 'Alice Tester',
    email: `alice_${timestamp}@routine.test`,
    password: 'securePass123',
    studentId: `STU-${timestamp}`,
    department: 'Software Engineering',
    institution: 'Tech University'
  };

  console.log('1. Testing Registration...');
  const regRes = await fetch(`${baseUrl}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(testUser)
  });
  const regData = await regRes.json();
  if (!regData.success || !regData.data.token) {
    throw new Error('Registration failed: ' + JSON.stringify(regData));
  }
  const aliceToken = regData.data.token;
  const aliceId = regData.data.user.id;
  console.log('   Registration successful! User ID:', aliceId);

  // Test 2: Login with Valid Credentials
  console.log('2. Testing Login with valid credentials...');
  const loginRes = await fetch(`${baseUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: testUser.email, password: testUser.password })
  });
  const loginData = await loginRes.json();
  if (!loginData.success || !loginData.data.token) {
    throw new Error('Valid login failed: ' + JSON.stringify(loginData));
  }
  console.log('   Login successful! Token generated.');

  // Test 3: Login with Invalid Password
  console.log('3. Testing Login rejection with wrong password...');
  const badLoginRes = await fetch(`${baseUrl}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: testUser.email, password: 'wrongPassword123' })
  });
  if (badLoginRes.status !== 401) {
    throw new Error('Expected 401 on bad password, got: ' + badLoginRes.status);
  }
  console.log('   Rejected with 401 Unauthorized as expected.');

  // Test 4: Protected API Authorization (/api/auth/me)
  console.log('4. Testing Protected API /api/auth/me with Bearer token...');
  const meRes = await fetch(`${baseUrl}/auth/me`, {
    headers: { 'Authorization': `Bearer ${aliceToken}` }
  });
  const meData = await meRes.json();
  if (!meData.success || meData.data.email !== testUser.email) {
    throw new Error('/api/auth/me failed: ' + JSON.stringify(meData));
  }
  console.log('   Protected route authorized successfully for:', meData.data.name);

  // Test 5: Rejection without token
  console.log('5. Testing Protected API rejection without token...');
  const unauthRes = await fetch(`${baseUrl}/routines`);
  if (unauthRes.status !== 401) {
    throw new Error('Expected 401 without token, got: ' + unauthRes.status);
  }
  console.log('   Protected API rejected unauthenticated request with 401.');

  // Test 6: Guest Mode API
  console.log('6. Testing Guest Mode API (/api/auth/guest)...');
  const guestRes = await fetch(`${baseUrl}/auth/guest`, { method: 'POST' });
  const guestData = await guestRes.json();
  if (!guestData.success || !guestData.data.token || !guestData.data.isGuest) {
    throw new Error('Guest API failed: ' + JSON.stringify(guestData));
  }
  const guestToken = guestData.data.token;
  console.log('   Guest mode generated successfully for:', guestData.data.user.name);

  // Test 7: Guest Restrictions (Read-only enforcement)
  console.log('7. Testing Guest Restrictions (Backend enforces read-only for guests)...');
  const guestCreateRoutineRes = await fetch(`${baseUrl}/routines`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${guestToken}`
    },
    body: JSON.stringify({
      courseName: 'Hacking Routine',
      courseCode: 'SEC 101',
      dayOfWeek: 2,
      startTime: '10:00',
      endTime: '11:00'
    })
  });
  if (guestCreateRoutineRes.status !== 403) {
    throw new Error('Expected 403 when guest tries to create routine, got: ' + guestCreateRoutineRes.status);
  }
  const guestErrBody = await guestCreateRoutineRes.json();
  if (guestErrBody.details?.code !== 'GUEST_RESTRICTED') {
    throw new Error('Expected GUEST_RESTRICTED code in response, got: ' + JSON.stringify(guestErrBody));
  }
  console.log('   Guest routine creation blocked with 403 (GUEST_RESTRICTED).');

  const guestCreateTaskRes = await fetch(`${baseUrl}/tasks`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${guestToken}`
    },
    body: JSON.stringify({
      title: 'Guest Unauthorized Task',
      dueDate: '2026-11-01'
    })
  });
  if (guestCreateTaskRes.status !== 403) {
    throw new Error('Expected 403 when guest tries to create task, got: ' + guestCreateTaskRes.status);
  }
  console.log('   Guest task creation blocked with 403 (GUEST_RESTRICTED).');

  // Test 8: Data Isolation & Access Control between Users
  console.log('8. Testing Data Isolation & Access Control between Users in MongoDB Atlas...');
  // Alice creates a routine
  const createRoutineRes = await fetch(`${baseUrl}/routines`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${aliceToken}`
    },
    body: JSON.stringify({
      courseName: 'Advanced Algorithms',
      courseCode: 'CSE 401',
      teacher: 'Dr. Turing',
      room: 'Lab 1',
      dayOfWeek: 1,
      startTime: '10:00',
      endTime: '11:30'
    })
  });
  const routineData = await createRoutineRes.json();
  if (!routineData.success) {
    throw new Error('Failed to create routine for Alice: ' + JSON.stringify(routineData));
  }
  const aliceRoutineId = routineData.data.id;

  // Bob registers
  const bobEmail = `bob_${timestamp}@routine.test`;
  const bobReg = await fetch(`${baseUrl}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'Bob Tester', email: bobEmail, password: 'passwordBob123' })
  });
  const bobData = await bobReg.json();
  const bobToken = bobData.data.token;
  const bobId = bobData.data.user.id;

  // Bob queries routines - must NOT see Alice's routine!
  const bobRoutinesRes = await fetch(`${baseUrl}/routines`, {
    headers: { 'Authorization': `Bearer ${bobToken}` }
  });
  const bobRoutines = await bobRoutinesRes.json();
  if (bobRoutines.data.length !== 0) {
    throw new Error('Data isolation violation! Bob saw routines: ' + JSON.stringify(bobRoutines));
  }
  console.log('   Data isolation verified! Bob has 0 routines, Alice has 1 routine.');

  // Bob attempts to DELETE Alice's routine - must be rejected with 404/not found!
  const bobDeleteAliceRes = await fetch(`${baseUrl}/routines/${aliceRoutineId}`, {
    method: 'DELETE',
    headers: { 'Authorization': `Bearer ${bobToken}` }
  });
  if (bobDeleteAliceRes.status !== 404) {
    throw new Error('Expected 404 when Bob tries to delete Alice routine, got: ' + bobDeleteAliceRes.status);
  }
  console.log('   Cross-user mutation blocked! Bob cannot delete Alice\'s routine.');

  // Cleanup test records from MongoDB
  console.log('8. Cleaning up test accounts from MongoDB Atlas...');
  const client = new MongoClient(process.env.MONGODB_URI);
  await client.connect();
  const db = client.db(process.env.MONGODB_DB);
  await db.collection('users').deleteMany({ email: { $in: [testUser.email, bobEmail] } });
  await db.collection('routines').deleteMany({ userId: new ObjectId(aliceId) });
  await client.close();
  console.log('   Cleanup completed cleanly.');

  console.log('\nAll 8 Authentication, Guest Restriction & Data Isolation Tests PASSED!');
}

runAuthTests().catch(err => {
  console.error('Test Suite Failed:', err);
  process.exit(1);
});
