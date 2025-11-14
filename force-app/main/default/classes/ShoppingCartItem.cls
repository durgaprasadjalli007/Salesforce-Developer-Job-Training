public class ShoppingCartItem {
    public String productCode;
    public String productName;
    public Decimal unitPrice;
    public Integer quantity;
    public Decimal totalPrice;

    // Constructor
    public ShoppingCartItem(String code, String name, Decimal price, Integer qty) {
        if (String.isBlank(code)) {
            throw new IllegalArgumentException('Product code cannot be null or empty');
        }
        if (String.isBlank(name)) {
            throw new IllegalArgumentException('Product name cannot be null or empty');
        }
        if (price == null || price <= 0) {
            throw new IllegalArgumentException('Unit price must be greater than 0');
        }
        if (qty == null || qty <= 0) {
            throw new IllegalArgumentException('Quantity must be greater than 0');
        }

        productCode = code;
        productName = name;
        unitPrice = price;
        quantity = qty;
        totalPrice = unitPrice * quantity;
    }

    // Print details
    public void printDetails() {
        System.debug('*** Shopping Cart Item Details ***');
        System.debug('Product Code: ' + productCode);
        System.debug('Product Name: ' + productName);
        System.debug('Unit Price: ' + unitPrice);
        System.debug('Quantity: ' + quantity);
        System.debug('Total Price: ' + totalPrice);
    }

    // Update quantity method
    public Boolean updateQuantity(Integer newQuantity) {
        if (newQuantity == null || newQuantity <= 0) {
            return false;
        }
        quantity = newQuantity;
        totalPrice = unitPrice * quantity;
        return true;
    }
}