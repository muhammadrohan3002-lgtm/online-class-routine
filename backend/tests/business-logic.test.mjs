import test from 'node:test';
import assert from 'node:assert/strict';

// Core business logic to test:
function timeToMinutes(timeStr) {
  const [hours, minutes] = timeStr.split(':').map(Number);
  return (hours || 0) * 60 + (minutes || 0);
}

function isTimeRangeValid(startTime, endTime) {
  return timeToMinutes(startTime) < timeToMinutes(endTime);
}

function doIntervalsOverlap(startA, endA, startB, endB) {
  const startMinsA = timeToMinutes(startA);
  const endMinsA = timeToMinutes(endA);
  const startMinsB = timeToMinutes(startB);
  const endMinsB = timeToMinutes(endB);
  return Math.max(startMinsA, startMinsB) < Math.min(endMinsA, endMinsB);
}

function calculateAttendance(present, absent, late) {
  const total = present + absent + late;
  if (total === 0) return { total: 0, percentage: 100, isBelowThreshold: false };
  const rawPct = (present / total) * 100;
  const percentage = Math.round(rawPct * 10) / 10;
  return {
    total,
    percentage,
    isBelowThreshold: percentage < 75,
  };
}

test('Routine time validation: start before end', () => {
  assert.equal(isTimeRangeValid('09:00', '10:30'), true);
  assert.equal(isTimeRangeValid('10:30', '09:00'), false);
  assert.equal(isTimeRangeValid('10:00', '10:00'), false);
});

test('Routine conflict detection: overlapping time intervals', () => {
  // Overlapping cases:
  // Class A: 09:00 - 10:30
  // Class B: 10:00 - 11:30 (starts before A ends)
  assert.equal(doIntervalsOverlap('09:00', '10:30', '10:00', '11:30'), true);

  // Class B completely inside Class A: 09:15 - 10:00
  assert.equal(doIntervalsOverlap('09:00', '10:30', '09:15', '10:00'), true);

  // Class B engulfs Class A: 08:30 - 11:00
  assert.equal(doIntervalsOverlap('09:00', '10:30', '08:30', '11:00'), true);

  // Non-overlapping: adjacent back-to-back classes
  // Class A: 09:00 - 10:30, Class B: 10:30 - 12:00
  assert.equal(doIntervalsOverlap('09:00', '10:30', '10:30', '12:00'), false);

  // Non-overlapping: completely separated
  assert.equal(doIntervalsOverlap('09:00', '10:00', '11:00', '12:00'), false);
});

test('Attendance calculation and threshold detection', () => {
  // 3 present, 1 absent = 75%
  const res1 = calculateAttendance(3, 1, 0);
  assert.equal(res1.percentage, 75.0);
  assert.equal(res1.isBelowThreshold, false);

  // 2 present, 2 absent = 50% (below 75% threshold)
  const res2 = calculateAttendance(2, 2, 0);
  assert.equal(res2.percentage, 50.0);
  assert.equal(res2.isBelowThreshold, true);

  // 9 present, 1 absent = 90% (healthy)
  const res3 = calculateAttendance(9, 1, 0);
  assert.equal(res3.percentage, 90.0);
  assert.equal(res3.isBelowThreshold, false);

  // 0 classes recorded defaults to 100%
  const res4 = calculateAttendance(0, 0, 0);
  assert.equal(res4.percentage, 100);
  assert.equal(res4.isBelowThreshold, false);
});
