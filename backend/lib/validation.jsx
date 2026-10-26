/**
 * Checks if two time intervals on the same day overlap.
 * Format expected: "HH:mm" in 24-hour representation.
 */
export function timeToMinutes(timeStr) {
    const [hours, minutes] = timeStr.split(':').map(Number);
    return (hours || 0) * 60 + (minutes || 0);
}

export function isTimeRangeValid(startTime, endTime) {
    return timeToMinutes(startTime) < timeToMinutes(endTime);
}

export function doIntervalsOverlap(startA, endA, startB, endB) {
    const startMinsA = timeToMinutes(startA);
    const endMinsA = timeToMinutes(endA);
    const startMinsB = timeToMinutes(startB);
    const endMinsB = timeToMinutes(endB);
    // Two open intervals (A_start, A_end) and (B_start, B_end) overlap if:
    // max(startA, startB) < min(endA, endB)
    return Math.max(startMinsA, startMinsB) < Math.min(endMinsA, endMinsB);
}

export function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

export function isValidDateFormat(dateStr) {
    return /^\d{4}-\d{2}-\d{2}$/.test(dateStr);
}

export function isValidTimeFormat(timeStr) {
    return /^([01]\d|2[0-3]):([0-5]\d)$/.test(timeStr);
}
