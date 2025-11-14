public class BirthdayPartySet {
    public static void manageGuestList() {
        // Step 1: Create a Set of guests
        Set<String> guestList = new Set<String>{'Alice', 'Bob', 'Charlie'};
        System.debug('Initial guests: ' + guestList);

        // Step 2: Try adding Alice again
        guestList.add('Alice'); // No effect - Sets reject duplicates
        System.debug('After Alice confirms again: ' + guestList);

        // Step 3: Add more guests
        guestList.add('Diana');
        guestList.add('Emma');
        guestList.add('Frank');
        System.debug('After adding Diana, Emma, Frank: ' + guestList);

        // Step 4: Check if Bob is coming
        System.debug('Is Bob attending? ' + guestList.contains('Bob'));

        // Step 5: Remove Charlie
        guestList.remove('Charlie');
        System.debug('After removing Charlie: ' + guestList);

        // Step 6: Add Alice again
        guestList.add('Alice');
        System.debug('After Alice confirms yet again: ' + guestList);

        // Step 7: Count guests
        System.debug('Final guest count: ' + guestList.size());
    }
}