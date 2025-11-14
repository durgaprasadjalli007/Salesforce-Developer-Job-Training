import { LightningElement, api, track } from 'lwc';

export default class StudentInfoCard extends LightningElement {
    // Public properties
  @api studentId = 'STU' + Math.floor(Math.random() * 1000); // e.g., STU345
@api studentName = 'John Doe'; // random name
@api grade = 'A'; // default grade
@api subjects = ['Math', 'Science', 'English']; // default subjects
@api isActive = false; // must default to false for boolean
@api displayMode = 'detailed'; // default to detailed


    // Private properties
    enrollmentDate = new Date().toLocaleDateString();
    totalSubjects = 0;

    // Lifecycle hook to initialize computed values
    connectedCallback() {
        this.totalSubjects = this.subjects.length;
    }

    // Getter for student status
    get studentStatus() {
        return this.isActive ? 'Active' : 'Inactive';
    }

    // Getter for formatted subjects
    get subjectsList() {
        return this.subjects.join(', ');
    }

    // Helper getters for displayMode
    get isCompact() {
        return this.displayMode === 'compact';
    }

    get isDetailed() {
        return this.displayMode === 'detailed';
    }
}