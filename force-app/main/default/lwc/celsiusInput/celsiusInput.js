import { LightningElement, api, track } from 'lwc';

export default class CelsiusInput extends LightningElement {
    @track celsius = '';

    handleChange(event) {
        this.celsius = event.target.value;

        // Dispatch event to parent with Celsius value
        const cEvent = new CustomEvent('celsiuschange', {
            detail: { celsius: this.celsius }
        });
        this.dispatchEvent(cEvent);
    }

    // Public method for parent to set value
    @api
    setCelsius(value) {
        this.celsius = value;
    }
}