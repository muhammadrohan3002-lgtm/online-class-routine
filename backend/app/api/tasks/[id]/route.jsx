import { ObjectId } from 'mongodb';
import { getDatabase } from '@/lib/mongodb';
import { getAuthenticatedUser, requireRegisteredUser } from '@/lib/auth';
import { successResponse, notFoundResponse, unauthorizedResponse, serverErrorResponse } from '@/lib/api-response';
export async function GET(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid task ID');
        const db = await getDatabase();
        const task = await db.collection('tasks').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!task)
            return notFoundResponse('Task not found');
        return successResponse({
            id: task._id.toString(),
            title: task.title,
            description: task.description || '',
            dueDate: task.dueDate,
            dueTime: task.dueTime || '',
            priority: task.priority,
            status: task.status,
            category: task.category,
            completedAt: task.completedAt || null,
            createdAt: task.createdAt,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function PUT(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const guestErr = requireRegisteredUser(user);
        if (guestErr) return guestErr;
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid task ID');
        const body = await request.json().catch(() => ({}));
        const { title, description, dueDate, dueTime, priority, status, category } = body;
        const db = await getDatabase();
        const existing = await db.collection('tasks').findOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (!existing)
            return notFoundResponse('Task not found');
        const update = { updatedAt: new Date() };
        if (title !== undefined)
            update.title = title.trim();
        if (description !== undefined)
            update.description = description.trim();
        if (dueDate !== undefined)
            update.dueDate = dueDate.trim();
        if (dueTime !== undefined)
            update.dueTime = dueTime.trim();
        const validPriorities = ['low', 'medium', 'high'];
        if (priority && validPriorities.includes(priority)) {
            update.priority = priority;
        }
        const validCategories = ['Study', 'Assignment', 'Personal', 'Other'];
        if (category && validCategories.includes(category)) {
            update.category = category;
        }
        if (status && (status === 'pending' || status === 'completed')) {
            update.status = status;
            if (status === 'completed' && existing.status !== 'completed') {
                update.completedAt = new Date();
            }
            else if (status === 'pending') {
                update.completedAt = null;
            }
        }
        await db.collection('tasks').updateOne({ _id: existing._id }, { $set: update });
        const updated = await db.collection('tasks').findOne({ _id: existing._id });
        return successResponse({
            id: updated._id.toString(),
            title: updated.title,
            description: updated.description || '',
            dueDate: updated.dueDate,
            dueTime: updated.dueTime || '',
            priority: updated.priority,
            status: updated.status,
            category: updated.category,
            completedAt: updated.completedAt || null,
            updatedAt: updated.updatedAt,
        });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
export async function DELETE(request, { params }) {
    try {
        const user = await getAuthenticatedUser(request);
        if (!user)
            return unauthorizedResponse();
        const guestErr = requireRegisteredUser(user);
        if (guestErr) return guestErr;
        if (!ObjectId.isValid(params.id))
            return notFoundResponse('Invalid task ID');
        const db = await getDatabase();
        const res = await db.collection('tasks').deleteOne({
            _id: new ObjectId(params.id),
            userId: user._id,
        });
        if (res.deletedCount === 0)
            return notFoundResponse('Task not found');
        return successResponse({ message: 'Task deleted successfully' });
    }
    catch (err) {
        return serverErrorResponse(err);
    }
}
