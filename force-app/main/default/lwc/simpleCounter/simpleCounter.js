import { LightningElement, track } from 'lwc';

export default class SimpleCounter extends LightningElement {
    @track count = 0;
    @track customIncrement = 1;

    // Derived properties
    get showMessage() {
        return this.count === 10;
    }

    get isDecrementDisabled() {
        return this.count === 0;
    }

    get counterStyle() {
        if (this.count <= 5) {
            return 'background-color: lightgreen; padding: 20px; border-radius: 8px;';
        } else if (this.count <= 10) {
            return 'background-color: khaki; padding: 20px; border-radius: 8px;';
        } else {
            return 'background-color: lightcoral; padding: 20px; border-radius: 8px;';
        }
    }

    // Handlers
    handleIncrement() {
        this.count += 1;
    }

    handleDecrement() {
        if (this.count > 0) {
            this.count -= 1;
        }
    }

    handleAddFive() {
        this.count += 5;
    }

    handleReset() {
        this.count = 0;
    }

    handleDouble() {
        this.count *= 2;
    }

    handleCustomChange(event) {
        this.customIncrement = parseInt(event.target.value, 10) || 1;
    }

    handleCustomIncrement() {
        this.count += this.customIncrement;
    }
}