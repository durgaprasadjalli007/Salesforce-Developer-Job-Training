public class LibraryBookLocation {
    public static void manageLibrary() {
        // Step 1: Create the map
        Map<String, String> bookShelfMap = new Map<String, String>();

        // Step 2: Add initial books
        bookShelfMap.put('Moby Dick', 'A-12');
        bookShelfMap.put('1984', 'B-08');
        bookShelfMap.put('Hamlet', 'C-15');

        // Step 3: Update shelf for "1984"
        bookShelfMap.put('1984', 'B-10');

        // Step 4: Add a new book
        bookShelfMap.put('The Catcher in the Rye', 'A-18');

        // Step 5: Find location of "Hamlet"
        String hamletLocation = bookShelfMap.get('Hamlet');
        System.debug('Hamlet is located at: ' + hamletLocation);

        // Step 6: Check if "To Kill a Mockingbird" exists
        Boolean hasMockingbird = bookShelfMap.containsKey('To Kill a Mockingbird');
        System.debug('Is "To Kill a Mockingbird" in the system? ' + hasMockingbird);

        // Step 7: Get list of all book titles
        List<String> allTitles = new List<String>(bookShelfMap.keySet());
        System.debug('All book titles in library: ' + allTitles);

        // Step 8: Add "Pride and Prejudice"
        bookShelfMap.put('Pride and Prejudice', 'C-22');

        // Step 9: Count how many books are tracked
        Integer totalBooks = bookShelfMap.size();
        System.debug('Total books in system: ' + totalBooks);

        // Optional: Final listing
        System.debug('Final book-to-shelf mapping:');
        for (String title : bookShelfMap.keySet()) {
            System.debug(title + ' -> ' + bookShelfMap.get(title));
        }
    }
}