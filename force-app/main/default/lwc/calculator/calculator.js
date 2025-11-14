import { LightningElement, track } from 'lwc';

export default class Calculator extends LightningElement {
    @track number1;
    @track number2;
    @track result;

    handleNumber1Change(event) {
        this.number1 = parseFloat(event.target.value);
    }

    handleNumber2Change(event) {
        this.number2 = parseFloat(event.target.value);
    }

    handleAdd() {
        this.result = this.number1 + this.number2;
    }

    handleMinus() {
        this.result = this.number1 - this.number2;
    }

    handleMultiply() {
        this.result = this.number1 * this.number2;
    }

    handleDivide() {
        if (this.number2 === 0) {
            this.result = 'Cannot divide by zero';
        } else {
            this.result = this.number1 / this.number2;
        }
    }
}