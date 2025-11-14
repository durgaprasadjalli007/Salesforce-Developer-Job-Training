import { LightningElement, track } from 'lwc';

export default class StepOne extends LightningElement {
    @track name = '';
    @track email = '';
    @track phone = '';

    handleChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handleNext() {
        // Check if any field is empty
        if (!this.name || !this.email || !this.phone) {
            alert('Please fill all fields');
            return; // Stop execution, don’t go to next step
        }

        // Optional: validate email format and phone pattern
        const emailValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.email);
        const phoneValid = /^[0-9]{10}$/.test(this.phone);

        if (!emailValid) {
            alert('Please enter a valid email');
            return;
        }

        if (!phoneValid) {
            alert('Please enter a 10-digit phone number');
            return;
        }

        // All fields valid → dispatch next event
        const nextEvent = new CustomEvent('stepnext', {
            detail: {
                stepNumber: 1,
                data: {
                    name: this.name,
                    email: this.email,
                    phone: this.phone
                }
            }
        });
        this.dispatchEvent(nextEvent);
    }
}