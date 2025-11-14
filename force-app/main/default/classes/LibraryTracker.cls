public class LibraryTracker {
    public static void trackBooks() {
        // Step 1: Create the map
        Map<String, String> bookToUser = new Map<String, String>();

        // Step 2: Add checkouts
        bookToUser.put('1984', 'Alice');
        bookToUser.put('Brave New World', 'Bob');
        bookToUser.put('The Great Gatsby', 'Charlie');
        System.debug('Initial Checkout Map: ' + bookToUser);

        // Step 3: Get who has "1984"
        String user = bookToUser.get('1984');
        System.debug('Who has "1984"? ' + user);

        // Step 4: Update - Bob returns "Brave New World", Dave checks it out
        bookToUser.put('Brave New World', 'Dave');
        System.debug('After Dave checks out "Brave New World": ' + bookToUser);

        // Step 5: Remove "The Great Gatsby" - returned to shelf
        bookToUser.remove('The Great Gatsby');
        System.debug('After removing "The Great Gatsby": ' + bookToUser);

        // Step 6: Final list of checked out books
        System.debug('Final Checkout Status:');
        for (String title : bookToUser.keySet()) {
            System.debug(title + ' -> ' + bookToUser.get(title));
        }
    }
}