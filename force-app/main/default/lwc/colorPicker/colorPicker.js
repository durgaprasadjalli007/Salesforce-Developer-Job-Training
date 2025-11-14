import { LightningElement } from 'lwc';

export default class ColorPicker extends LightningElement {
    // List of colors
    colors = [
        { name: 'Red', hex: '#FF0000', style: 'background:#FF0000' },
        { name: 'Blue', hex: '#0000FF', style: 'background:#0000FF' },
        { name: 'Green', hex: '#008000', style: 'background:#008000' },
        { name: 'Yellow', hex: '#FFFF00', style: 'background:#FFFF00' },
        { name: 'Purple', hex: '#800080', style: 'background:#800080' },
        { name: 'Orange', hex: '#FFA500', style: 'background:#FFA500' },
    ];

    handleColorClick(event) {
        const colorName = event.currentTarget.dataset.name;
        const hexCode = event.currentTarget.dataset.hex;

        // Dispatch custom event to parent
        const colorEvent = new CustomEvent('colorselected', {
            detail: { colorName, hexCode }
        });
        this.dispatchEvent(colorEvent);
    }
}