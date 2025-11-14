import { LightningElement, track, api } from 'lwc';

export default class StepTwo extends LightningElement {
    @track street = '';
    @track city = '';
    @track state = '';
    @track zip = '';

    @api stepData = {}; // prefill if needed

    handleChange(event) {
        this[event.target.name] = event.target.value;
    }

    handleNext() {
        if (!this.street || !this.city || !this.state || !this.zip) {
            alert('Please fill all fields');
            return;
        }
        const nextEvent = new CustomEvent('stepnext', {
            detail: {
                stepNumber: 2,
                data: { street: this.street, city: this.city, state: this.state, zip: this.zip }
            }
        });
        this.dispatchEvent(nextEvent);
    }

    handlePrevious() {
        const prevEvent = new CustomEvent('stepprevious', { detail: { stepNumber: 2 } });
        this.dispatchEvent(prevEvent);
    }
}