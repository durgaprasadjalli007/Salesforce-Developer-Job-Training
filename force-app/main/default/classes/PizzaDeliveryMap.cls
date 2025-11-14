public class PizzaDeliveryMap {
    public static void managePizzaOrders() {
        // Step 1: Create the map
        Map<String, String> pizzaOrders = new Map<String, String>();

        // Step 2: Add orders
        pizzaOrders.put('John', 'Pepperoni');
        pizzaOrders.put('Sarah', 'Margherita');
        pizzaOrders.put('Mike', 'Supreme');
        System.debug('Initial Orders: ' + pizzaOrders);

        // Step 3: John changes order to Hawaiian
        pizzaOrders.put('John', 'Hawaiian');
        System.debug('After John changes order: ' + pizzaOrders);

        // Step 4: Add Lisa's order
        pizzaOrders.put('Lisa', 'Veggie Deluxe');
        System.debug('After adding Lisa: ' + pizzaOrders);

        // Step 5: Check Sarah's order
        String sarahOrder = pizzaOrders.get('Sarah');
        System.debug('Sarah ordered: ' + sarahOrder);

        // Step 6: Check if David has an order
        Boolean hasDavid = pizzaOrders.containsKey('David');
        System.debug('Is there an order for David? ' + hasDavid);

        // Step 7: Get all customer names
        Set<String> customerNames = pizzaOrders.keySet();
        System.debug('All customers: ' + customerNames);

        // Step 8: Count total orders
        Integer totalOrders = pizzaOrders.size();
        System.debug('Total orders: ' + totalOrders);
    }
}