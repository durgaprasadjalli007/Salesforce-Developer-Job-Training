import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FormWizard extends LightningElement {
    @track currentStep = 1;
    @track allData = {}; // store data from all steps

    get isStepOne() { return this.currentStep === 1; }
    get isStepTwo() { return this.currentStep === 2; }
    get isStepThree() { return this.currentStep === 3; }

    get step1Completed() { return this.currentStep > 1; }
    get step2Completed() { return this.currentStep > 2; }
    get step3Completed() { return this.currentStep > 3; }
    get currentStepString() { return String(this.currentStep); }

    handleStepNext(event) {
        const { stepNumber, data } = event.detail;
        this.allData = { ...this.allData, ...data }; // merge step data
        this.currentStep = stepNumber + 1;
    }

    handleStepPrevious(event) {
        const { stepNumber } = event.detail;
        this.currentStep = stepNumber - 1;
    }

    handleFormSubmitted(event) {
        this.allData = { ...event.detail.allData }; // collect final data

        // Show success toast
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Form submitted successfully!',
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);

        // Reset wizard after submission
        this.currentStep = 1;
        this.allData = {};
    }
}