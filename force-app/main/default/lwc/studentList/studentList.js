import { LightningElement } from 'lwc';

export default class StudentList extends LightningElement {
    students = [
        { id: 1, name: 'Alice Johnson', age: 20, grade: 'A', subject: 'Computer Science' },
        { id: 2, name: 'Bob Smith', age: 21, grade: 'B+', subject: 'Mathematics' },
        { id: 3, name: 'Carol Davis', age: 19, grade: 'A-', subject: 'Physics' },
        { id: 4, name: 'David Wilson', age: 22, grade: 'B', subject: 'Chemistry' },
        { id: 5, name: 'Eva Brown', age: 20, grade: 'A+', subject: 'Biology' },
        { id: 6, name: 'Frank Miller', age: 21, grade: 'C+', subject: 'English' }
    ];

    // Add studentNumber to each student
    get studentsWithNumber() {
        return this.students.map((student, index) => ({
            ...student,
            studentNumber: index + 1
        }));
    }
}