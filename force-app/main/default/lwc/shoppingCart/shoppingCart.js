import { LightningElement, track } from 'lwc';

export default class ShoppingCart extends LightningElement {
    // Sample products with actual images
    products = [
        { id: 1, name: 'Laptop', price: 999, image: 'https://i.pinimg.com/736x/6b/de/5a/6bde5a4f33791dd14d2f056c8ab37927.jpg' },
        { id: 2, name: 'Mouse', price: 29, image: 'https://i.pinimg.com/1200x/d0/15/5e/d0155e1ad361723857b4b73a3c8fea64.jpg' },
        { id: 3, name: 'Keyboard', price: 79, image: 'https://i.pinimg.com/736x/0a/4e/41/0a4e415579396ea91fff5730396a257b.jpg' }
    ];

    @track cartItems = [];
    @track showSuccess = false;

    handleAddToCart(event) {
        const newItem = event.detail;
        let found = this.cartItems.find(item => item.productId === newItem.productId);

        if (found) {
            found.quantity += 1;
            found.total = found.price * found.quantity;
        } else {
            newItem.total = newItem.price * newItem.quantity;
            this.cartItems = [...this.cartItems, { ...newItem }];
        }

        this.showSuccess = true;
        setTimeout(() => { this.showSuccess = false; }, 1500);
    }

    handleRemove(event) {
        const idToRemove = parseInt(event.target.dataset.id, 10);
        this.cartItems = this.cartItems.filter(item => item.productId !== idToRemove);
    }

    get totalItems() {
        return this.cartItems.reduce((sum, item) => sum + item.quantity, 0);
    }

    get totalPrice() {
        return this.cartItems.reduce((sum, item) => sum + item.total, 0);
    }
}