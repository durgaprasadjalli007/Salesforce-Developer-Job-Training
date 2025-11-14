public class LibraryBook {
    public String title;
    public String author;
    public String isbn;
    public String checkedOutTo;
    public Date dueDate;

    // Constructor
    public LibraryBook(String title, String author, String isbn) {
        this.title = title;
        this.author = author;
        this.isbn = isbn;
        this.checkedOutTo = null;
        this.dueDate = null;
    }

    // Method: getBookSummary()
    public String getBookSummary() {
        return title + ' by ' + author + ' (ISBN: ' + isbn + ')';
    }

    // Method: getDaysUntilDue()
    public Integer getDaysUntilDue() {
        if (dueDate == null) {
            return null;
        }
        return Date.today().daysBetween(dueDate);
    }

    // Method: getCheckoutInfo()
    public String getCheckoutInfo() {
        if (checkedOutTo == null || dueDate == null) {
            return 'Available for checkout';
        }
        return 'Checked out to ' + checkedOutTo + ', due ' + String.valueOf(dueDate);
    }

    // Optional: checkout book to a user
    public void checkout(String borrower, Date due) {
        this.checkedOutTo = borrower;
        this.dueDate = due;
    }

    // Optional: return book
    public void returnBook() {
        this.checkedOutTo = null;
        this.dueDate = null;
    }
}