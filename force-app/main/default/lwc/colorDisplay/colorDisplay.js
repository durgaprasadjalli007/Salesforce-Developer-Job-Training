import { LightningElement, track } from 'lwc';

export default class ColorDisplay extends LightningElement {
    @track selectedColor;

    // Update when child sends event
    handleColorSelected(event) {
        this.selectedColor = event.detail;
    }

    // Dynamically set background color
    get containerStyle() {
        return this.selectedColor
            ? `background-color:${this.selectedColor.hexCode}; padding:20px; border-radius:10px;`
            : 'padding:20px; border-radius:10px;';
    }
}