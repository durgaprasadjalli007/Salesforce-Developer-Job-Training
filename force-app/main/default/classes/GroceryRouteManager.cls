public class GroceryRouteManager {
    public static void planRoute() {
        List<String> route = new List<String>{'Produce', 'Dairy', 'Meat', 'Bakery', 'Checkout'};
        System.debug('Initial route: ' + route);

        Integer bakeryIndex = route.indexOf('Bakery');
        route.add(bakeryIndex, 'Frozen Foods');
        System.debug('After inserting Frozen Foods: ' + route);

        route.add(0, 'Customer Service');
        System.debug('After adding Customer Service: ' + route);

        Boolean hasPharmacy = route.contains('Pharmacy');
        System.debug('Is Pharmacy on the list? ' + hasPharmacy);

        String thirdStop = route[2];
        System.debug('3rd stop in the route: ' + thirdStop);

        // ✅ FIXED: remove "Produce" by index
        Integer produceIndex = route.indexOf('Produce');
        if (produceIndex != -1) {
            route.remove(produceIndex);
        }
        System.debug('After removing Produce: ' + route);

        route.add('Self-Checkout');
        System.debug('After adding Self-Checkout: ' + route);

        System.debug('Total sections left to visit: ' + route.size());
    }
}