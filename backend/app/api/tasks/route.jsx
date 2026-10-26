import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser } from '@/lib/auth';
import { successResponse, errorResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const { searchParams } = new URL(request.url);
        const filter = searchParams.get('filter'); // 'all', 'pending', 'completed', 'overdue'
        const category = searchParams.get('category');
        const sortBy = searchParams.get('sortBy') || 'dueDate'; // 'dueDate', 'priority', 'createdAt'
        const sortOrder = searchParams.get('order') === 'desc' ? -1 : 1;
        const db = await getDatabase();
        const query = { userId: user._id };
        const todayStr = new Date().toISOString().split('T')[0];
        if (filter === 'pending') {
            query.status = 'pending';
        }
        else if (filter === 'completed') {
            query.status = 'completed';
        }
        else if (filter === 'overdue') {
            query.status = 'pending';
            query.dueDate = { $lt: todayStr };
        }
        if (category && ['Study', 'Assignment', 'Personal', 'Other'].includes(category)) {
            query.category = category;
        }
        let sortOption = { dueDate: 1, dueTime: 1 };
        if (sortBy === 'priority') {
            // Custom mapping for priority sorting: high -> medium -> low
            sortOption = { priority: sortOrder };
        }
        else if (sortBy === 'createdAt') {
            sortOption = { createdAt: sortOrder };
        }
        else {
            sortOption = { dueDate: sortOrder, dueTime: sortOrder };
        }
        const tasks = await db
            .collection('tasks')
            .find(query)
            .sort(sortOption)
            .toArray();
        const formatted = tasks.map((t) => ({
            id: t._id.toString(),
            title: t.title,
            description: t.description || '',
            dueDate: t.dueDate,
            dueTime: t.dueTime || '',
            priority: t.priority,
            status: t.status,
            category: t.category,
            completedAt: t.completedAt || null,
            createdAt: t.createdAt,
        }));
        return successResponse(formatted);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function POST(request) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const body = await request.json().catch(() => ({}));
        const { title, description, dueDate, dueTime, priority, status, category } = body;
        if (!title || typeof title !== 'string' || !title.trim()) {
            return errorResponse('Task title is required');
        }
        if (!dueDate || !/^\d{4}-\d{2}-\d{2}$/.test(dueDate)) {
            return errorResponse('Valid due date (YYYY-MM-DD) is required');
        }
        const validPriorities = ['low', 'medium', 'high'];
        const validStatuses = ['pending', 'completed'];
        const validCategories = ['Study', 'Assignment', 'Personal', 'Other'];
        const chosenPriority = validPriorities.includes(priority) ? priority : 'medium';
        const chosenStatus = validStatuses.includes(status) ? status : 'pending';
        const chosenCategory = validCategories.includes(category) ? category : 'Study';
        const db = await getDatabase();
        const now = new Date();
        const newTask = {
            userId: user._id,
            title: title.trim(),
            description: description?.trim() || '',
            dueDate: dueDate.trim(),
            dueTime: dueTime?.trim() || '',
            priority: chosenPriority,
            status: chosenStatus,
            category: chosenCategory,
            completedAt: chosenStatus === 'completed' ? now : undefined,
            createdAt: now,
            updatedAt: now,
        };
        const res = await db.collection('tasks').insertOne(newTask);
        return successResponse({
            id: res.insertedId.toString(),
            title: newTask.title,
            description: newTask.description,
            dueDate: newTask.dueDate,
            dueTime: newTask.dueTime,
            priority: newTask.priority,
            status: newTask.status,
            category: newTask.category,
            completedAt: newTask.completedAt || null,
            createdAt: newTask.createdAt,
        }, 201);
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
