public class ShoppingCart {
    private Map<String, Integer> items = new Map<String, Integer>(); // ItemName → Quantity
    private Decimal discountPercentage = 0;
    private Decimal taxRate = 0;
    private Map<String, Decimal> priceList = new Map<String, Decimal>();

    public ShoppingCart() {
        // Sample prices
        priceList.put('Widget', 19.99);
        priceList.put('Gadget', 12.50);
        priceList.put('Cable', 4.99);
    }

    public void addItem(String itemName, Integer quantity) {
        if (items.containsKey(itemName)) {
            items.put(itemName, items.get(itemName) + quantity);
        } else {
            items.put(itemName, quantity);
        }
    }

    public void applyDiscount(Decimal discount) {
        discountPercentage = discount;
    }

    public Decimal calculateSubtotal() {
        Decimal subtotal = 0;
        for (String item : items.keySet()) {
            if (priceList.containsKey(item)) {
                subtotal += priceList.get(item) * items.get(item);
            }
        }
        return subtotal.setScale(2);
    }

    public Decimal calculateTax() {
        Decimal subtotal = calculateSubtotal();
        Decimal discountedSubtotal = subtotal * (1 - discountPercentage / 100);
        Decimal tax = discountedSubtotal * (taxRate / 100);
        return tax.setScale(2);
    }

    public Decimal getFinalTotal() {
        Decimal subtotal = calculateSubtotal();
        Decimal discountAmount = subtotal * (discountPercentage / 100);
        Decimal discountedSubtotal = subtotal - discountAmount;
        Decimal tax = discountedSubtotal * (taxRate / 100);
        Decimal finalTotal = discountedSubtotal + tax;
        return finalTotal.setScale(2);
    }

    // ---------------------
    // ✅ Helper Methods
    // ---------------------

    // 1. getItemCount()
    public Integer getItemCount() {
        return items.size();
    }

    // 2. getTotalQuantity()
    public Integer getTotalQuantity() {
        Integer total = 0;
        for (Integer qty : items.values()) {
            total += qty;
        }
        return total;
    }

    // 3. getCartSummary()
    public String getCartSummary() {
        return 'Items: ' + getItemCount() +
               ', Quantity: ' + getTotalQuantity() +
               ', Subtotal: $' + calculateSubtotal() +
               ', Discount: ' + discountPercentage + '%' +
               ', Tax: $' + calculateTax() +
               ', Final Total: $' + getFinalTotal();
    }

    // 4. clearCart()
    public void clearCart() {
        items.clear();
        discountPercentage = 0;
    }

    // 5. setTaxRate()
    public void setTaxRate(Decimal newTaxRate) {
        if (newTaxRate < 0 || newTaxRate > 50) {
            throw new IllegalArgumentException('Tax rate must be between 0 and 50');
        }
        taxRate = newTaxRate;
    }
}