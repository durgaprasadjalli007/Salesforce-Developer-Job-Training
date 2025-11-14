public class BookClubSet {
    public static void manageBookList() {
        // Step 1: Create initial book set
        Set<String> books = new Set<String>{'1984', 'Pride and Prejudice', 'The Hobbit'};
        System.debug('Initial books: ' + books);

        // Step 2: Try to add '1984' again
        books.add('1984'); // no effect
        System.debug('After duplicate "1984": ' + books);

        // Step 3: Add new books
        books.add('Dune');
        books.add('Jane Eyre');
        books.add('To Kill a Mockingbird');
        System.debug('After adding more books: ' + books);

        // Step 4: Check if 'Harry Potter' is in the list
        Boolean hasHP = books.contains('Harry Potter');
        System.debug('Is "Harry Potter" suggested? ' + hasHP);

        // Step 5: Remove 'The Hobbit'
        books.remove('The Hobbit');
        System.debug('After removing "The Hobbit": ' + books);

        // Step 6: Try adding 'Pride and Prejudice' again
        books.add('Pride and Prejudice'); // no effect
        System.debug('After duplicate "Pride and Prejudice": ' + books);

        // Step 7: Add 'The Great Gatsby'
        books.add('The Great Gatsby');
        System.debug('After adding "The Great Gatsby": ' + books);

        // Step 8: Final count
        System.debug('Total unique books: ' + books.size());
    }
}