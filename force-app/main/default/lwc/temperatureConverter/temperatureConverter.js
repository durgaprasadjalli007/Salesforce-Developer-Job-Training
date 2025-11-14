import { LightningElement } from 'lwc';

export default class TemperatureConverter extends LightningElement {
    handleCelsiusChange(event) {
        const celsius = parseFloat(event.detail.celsius);
        if (isNaN(celsius)) return;

        const fahrenheitValue = (celsius * 9 / 5 + 32).toFixed(2);

        // Update Fahrenheit child
        this.template.querySelector('c-fahrenheit-display')?.updateFahrenheit(fahrenheitValue);
    }

    handleFahrenheitChange(event) {
        const fahrenheit = parseFloat(event.detail.fahrenheit);
        if (isNaN(fahrenheit)) return;

        const celsiusValue = ((fahrenheit - 32) * 5 / 9).toFixed(2);

        // Update Celsius child
        this.template.querySelector('c-celsius-input')?.setCelsius(celsiusValue);
    }
}