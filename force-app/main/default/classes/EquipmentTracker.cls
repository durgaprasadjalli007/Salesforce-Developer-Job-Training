public class EquipmentTracker {
    public static void trackEquipment() {
        // Step 1: Create set with initial equipment
        Set<String> equipment = new Set<String>{'Treadmill', 'Bench Press', 'Rowing Machine'};
        System.debug('Initial Equipment: ' + equipment);

        // Step 2: Add new items
        equipment.add('Yoga Mat');
        equipment.add('Kettlebell');
        System.debug('After adding more: ' + equipment);

        // Step 3: Try adding duplicate
        equipment.add('Treadmill'); // duplicate, won't be added
        System.debug('After trying to add "Treadmill" again: ' + equipment);

        // Step 4: Remove an item
        equipment.remove('Rowing Machine');
        System.debug('After removing "Rowing Machine": ' + equipment);

        // Step 5: Check if "Dumbbells" are available
        Boolean hasDumbbells = equipment.contains('Dumbbells');
        System.debug('Is "Dumbbells" available? ' + hasDumbbells);

        // Step 6: Add "Pull-up Bar"
        equipment.add('Pull-up Bar');
        System.debug('After adding "Pull-up Bar": ' + equipment);

        // Step 7: Total equipment count
        System.debug('Total equipment available: ' + equipment.size());
    }
}