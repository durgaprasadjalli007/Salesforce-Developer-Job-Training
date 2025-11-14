import { LightningElement, api } from 'lwc';

export default class TaskCard extends LightningElement {
    _task = null;

    @api
    get task() {
        return this._task;
    }
    set task(val) {
        if (!val) {
            this._task = null;
            return;
        }
        this._task = {
            id: val.id || null,
            title: val.title || '',
            description: val.description || '',
            category: val.category || 'Other',
            priority: val.priority || 'Low',
            dueDate: val.dueDate ? new Date(val.dueDate).toISOString() : null,
            isCompleted: typeof val.isCompleted === 'boolean' ? val.isCompleted : false,
            createdDate: val.createdDate || new Date().toISOString()
        };
    }

    // --- CSS Classes ---
    get titleClass() {
        return this._task?.isCompleted ? 'task-title completed' : 'task-title';
    }

    get descClass() {
        return this._task?.isCompleted ? 'task-desc completed' : 'task-desc';
    }

    get categoryClass() {
        switch (this._task?.category) {
            case 'Work': return 'badge badge-cat-work';
            case 'Personal': return 'badge badge-cat-personal';
            case 'Shopping': return 'badge badge-cat-shopping';
            case 'Health': return 'badge badge-cat-health';
            default: return 'badge badge-cat-other';
        }
    }

    get priorityClass() {
        switch (this._task?.priority) {
            case 'High': return 'badge badge-priority-high';
            case 'Medium': return 'badge badge-priority-medium';
            case 'Low': return 'badge badge-priority-low';
            default: return 'badge';
        }
    }

    get dueDateClass() {
        if (!this._task?.dueDate) return 'badge badge-due-none';
        const today = new Date(); today.setHours(0,0,0,0);
        const due = new Date(this._task.dueDate); due.setHours(0,0,0,0);
        const diff = Math.round((due - today) / (1000*60*60*24));
        if (diff < 0) return 'badge badge-due-overdue';
        if (diff === 0) return 'badge badge-due-today';
        if (diff === 1) return 'badge badge-due-tomorrow';
        if (diff <= 3) return 'badge badge-due-soon';
        return 'badge badge-due-future';
    }

    get dueDateLabel() {
        if (!this._task?.dueDate) return 'No Due Date';
        const today = new Date(); today.setHours(0,0,0,0);
        const due = new Date(this._task.dueDate); due.setHours(0,0,0,0);
        const diff = Math.round((due - today) / (1000*60*60*24));
        if (diff < 0) return `Overdue by ${Math.abs(diff)} day(s)`;
        if (diff === 0) return 'Due Today';
        if (diff === 1) return 'Due Tomorrow';
        return `Due in ${diff} day(s)`;
    }

    get checkboxWrapperClass() {
        return `checkbox-wrapper ${this._task?.isCompleted ? 'checked' : ''}`;
    }

    // --- Actions ---
    handleToggle() {
        if (!this._task) return;
        this.dispatchEvent(new CustomEvent('toggle', { 
            detail: { id: this._task.id, isCompleted: !this._task.isCompleted }
        }));
    }

    handleEdit() {
        if (!this._task) return;
        this.dispatchEvent(new CustomEvent('edit', { detail: { ...this._task } }));
    }

    handleDelete() {
        if (!this._task) return;
        this.dispatchEvent(new CustomEvent('delete', { detail: { id: this._task.id } }));
    }
}