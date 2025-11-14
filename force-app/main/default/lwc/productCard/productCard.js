import { LightningElement, api } from 'lwc';

export default class ProductCard extends LightningElement {
    @api product;

    handleAddToCart() {
        if (!this.product) return;

        const addEvent = new CustomEvent('addtocart', {
            detail: {
                productId: this.product.id,
                productName: this.product.name,
                price: this.product.price,
                quantity: 1
            },
            bubbles: true
        });
        this.dispatchEvent(addEvent);
    }
}