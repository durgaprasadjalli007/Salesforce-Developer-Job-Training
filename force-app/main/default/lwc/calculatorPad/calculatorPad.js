import { LightningElement, track } from 'lwc';

export default class CalculatorPad extends LightningElement {
    @track display = '';      // Current display value
    number1 = null;           // First operand
    number2 = null;           // Second operand
    operator = null;          // Current operator
    numbers = ['1','2','3','4','5','6','7','8','9'];

    handleNumberClick(event) {
        const value = event.target.dataset.value;
        this.display += value;
    }

    handleOperationClick(event) {
        this.number1 = parseFloat(this.display);
        this.operator = event.target.dataset.op;
        this.display = '';  // Clear display for second number
    }

    handleEquals() {
        this.number2 = parseFloat(this.display);

        let result;
        switch(this.operator) {
            case '+':
                result = this.number1 + this.number2;
                break;
            case '-':
                result = this.number1 - this.number2;
                break;
            case '*':
                result = this.number1 * this.number2;
                break;
            case '/':
                result = this.number2 === 0 ? 'Error: Divide by 0' : this.number1 / this.number2;
                break;
        }
        this.display = result;
        // Reset operator for next calculation
        this.operator = null;
    }

    handleClear() {
        this.display = '';
        this.number1 = null;
        this.number2 = null;
        this.operator = null;
    }
}