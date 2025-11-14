import { LightningElement, api } from 'lwc';

export default class StepThree extends LightningElement {
    @api allData;

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('stepprevious', { detail: { stepNumber: 3 } }));
    }

    handleSubmit() {
        this.dispatchEvent(new CustomEvent('formsubmitted', { detail: { allData: this.allData } }));
    }

    handleSubmit() {
    this.dispatchEvent(new CustomEvent('formsubmitted', { detail: { allData: this.allData } }));
}

}