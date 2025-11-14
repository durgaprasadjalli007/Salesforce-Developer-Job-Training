import { LightningElement, api, track } from 'lwc';

export default class FahrenheitDisplay extends LightningElement {
    @track fahrenheit = '';

    handleChange(event) {
        this.fahrenheit = event.target.value;

        // Dispatch event to parent for bi-directional update
        const fEvent = new CustomEvent('fahrenheitchange', {
            detail: { fahrenheit: this.fahrenheit }
        });
        this.dispatchEvent(fEvent);
    }

    // Public method for parent to set value
    @api
    updateFahrenheit(value) {
        this.fahrenheit = value;
    }
}