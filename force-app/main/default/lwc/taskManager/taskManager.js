import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTaskPicklistOptions from '@salesforce/apex/TaskOptionController.getTaskPicklistOptions';

export default class TaskManager extends LightningElement {
    @track tasks = [];
    @track visibleTasks = [];
    @track categoryOptions = [];
    @track priorityOptions = [];
    @track title = '';
    @track description = '';
    @track category = '';
    @track priority = '';
    @track dueDate = '';
    @track isEditing = false;
    @track searchKey = '';
    @track selectedStatus = '';
    @track selectedCategory = '';
    @track selectedPriority = '';
    @track totalTasks = 0;
    @track completedTasks = 0;
    @track pendingTasks = 0;
    @track completionRate = 0;

    editId = null;
    STORAGE_KEY = 'lwc_todo_tasks_v2';

    connectedCallback() {
        this.loadTasks();
        this.loadPicklistOptions();
    }

    // --- Load Picklists from Apex ---
    async loadPicklistOptions() {
        try {
            const data = await getTaskPicklistOptions();
            if (data) {
                this.categoryOptions = data.Type.map(v => ({ label: v, value: v }));
                this.priorityOptions = data.Priority.map(v => ({ label: v, value: v }));
            }
        } catch (error) {
            this.showToast('Error', 'Failed to load picklist values', 'error');
        }
    }

    get formTitle() {
        return this.isEditing ? 'Edit Task' : 'Add Task';
    }

    get saveButtonLabel() {
        return this.isEditing ? 'Update Task' : 'Add New Task';
    }

    get isSaveDisabled() {
        return !this.title || !this.category || !this.priority ||
               this.title.length > 100 || (this.description && this.description.length > 500);
    }

    // --- Load Tasks ---
    loadTasks() {
        const saved = localStorage.getItem(this.STORAGE_KEY);
        this.tasks = saved ? JSON.parse(saved) : [];
        this.visibleTasks = [...this.tasks];
        this.updateStats();
    }

    // --- Handle Form Field Changes ---
    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleSave() {
        if (this.isSaveDisabled) {
            this.showToast('Validation', 'Please fill required fields correctly.', 'error');
            return;
        }

        if (this.isEditing) {
            this.tasks = this.tasks.map(task =>
                task.id === this.editId
                    ? { ...task, title: this.title, description: this.description, category: this.category, priority: this.priority, dueDate: this.dueDate }
                    : task
            );
        } else {
            const newTask = {
                id: Date.now(),
                title: this.title,
                description: this.description,
                category: this.category,
                priority: this.priority,
                dueDate: this.dueDate,
                isCompleted: false
            };
            this.tasks = [...this.tasks, newTask];
        }

        this.saveToLocal();
        this.clearForm();
        this.isEditing = false;
        this.editId = null;
    }

    clearForm() {
        this.title = '';
        this.description = '';
        this.category = '';
        this.priority = '';
        this.dueDate = '';
    }

    saveToLocal() {
        localStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.tasks));
        this.filterTasks();
        this.updateStats();
    }

    handleDelete(event) {
        const taskId = event.detail.id;
        this.tasks = this.tasks.filter(t => t.id !== taskId);
        this.saveToLocal();
    }

    handleEdit(event) {
        const taskId = event.detail.id;
        const task = this.tasks.find(t => t.id === taskId);
        if (task) {
            this.title = task.title;
            this.description = task.description;
            this.category = task.category;
            this.priority = task.priority;
            this.dueDate = task.dueDate;
            this.isEditing = true;
            this.editId = taskId;
        }
    }

    handleToggle(event) {
        const taskId = event.detail.id;
        this.tasks = this.tasks.map(task => task.id === taskId
            ? { ...task, isCompleted: !task.isCompleted }
            : task
        );
        this.saveToLocal();
    }

    // --- Filters ---
    handleSearchFilter(event) {
        this.searchKey = event.target.value.toLowerCase();
        this.filterTasks();
    }

    handleStatusFilter(event) {
        this.selectedStatus = event.detail.value;
        this.filterTasks();
    }

    handleCategoryFilter(event) {
        this.selectedCategory = event.detail.value;
        this.filterTasks();
    }

    handlePriorityFilter(event) {
        this.selectedPriority = event.detail.value;
        this.filterTasks();
    }

    filterTasks() {
        const searchKey = this.searchKey.toLowerCase();

        this.visibleTasks = this.tasks.filter(task => {
            const matchesSearch = !searchKey || task.title.toLowerCase().includes(searchKey) || (task.description && task.description.toLowerCase().includes(searchKey));
            const matchesCategory = !this.selectedCategory || this.selectedCategory === 'All Categories' || task.category === this.selectedCategory;
            const matchesPriority = !this.selectedPriority || this.selectedPriority === 'All Priorities' || task.priority === this.selectedPriority;
            const matchesStatus = !this.selectedStatus || this.selectedStatus === 'All Tasks' ||
                                  (this.selectedStatus === 'Completed' && task.isCompleted) ||
                                  (this.selectedStatus === 'Pending' && !task.isCompleted);

            return matchesSearch && matchesCategory && matchesPriority && matchesStatus;
        });
    }

    handleSortSelect(event) {
        const sortBy = event.detail.value;
        switch (sortBy) {
            case 'dateNewest':
                this.visibleTasks.sort((a,b) => b.id - a.id);
                break;
            case 'dateOldest':
                this.visibleTasks.sort((a,b) => a.id - b.id);
                break;
            case 'priority':
                const order = { High: 1, Medium: 2, Low: 3 };
                this.visibleTasks.sort((a,b) => (order[a.priority] || 99) - (order[b.priority] || 99));
                break;
            case 'dueDate':
                this.visibleTasks.sort((a,b) => new Date(a.dueDate) - new Date(b.dueDate));
                break;
        }
    }

    clearAllFilters() {
        this.searchKey = '';
        this.selectedStatus = '';
        this.selectedCategory = '';
        this.selectedPriority = '';
        this.visibleTasks = [...this.tasks];
    }

    updateStats() {
        this.totalTasks = this.tasks.length;
        this.completedTasks = this.tasks.filter(t => t.isCompleted).length;
        this.pendingTasks = this.totalTasks - this.completedTasks;
        this.completionRate = this.totalTasks > 0 ? Math.round((this.completedTasks / this.totalTasks) * 100) : 0;
    }

    get hasVisibleTasks() {
        return this.visibleTasks && this.visibleTasks.length > 0;
    }

    get taskCount() {
        return this.visibleTasks.length;
    }

    get statusOptions() {
        return [
            { label: 'All Tasks', value: 'All Tasks' },
            { label: 'Completed', value: 'Completed' },
            { label: 'Pending', value: 'Pending' }
        ];
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}