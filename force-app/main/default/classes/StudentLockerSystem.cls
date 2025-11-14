public class StudentLockerSystem {
    public static void manageLockers() {
        // Step 1: Create the map
        Map<String, String> studentToLocker = new Map<String, String>();

        // Step 2: Assign lockers to students
        studentToLocker.put('Amit', 'L101');
        studentToLocker.put('Bhavya', 'L102');
        studentToLocker.put('Chitra', 'L103');
        System.debug('Initial Assignments: ' + studentToLocker);

        // Step 3: Get locker of a student
        String lockerOfBhavya = studentToLocker.get('Bhavya');
        System.debug('Locker assigned to Bhavya: ' + lockerOfBhavya);

        // Step 4: Update locker assignment - Amit gets a new locker
        studentToLocker.put('Amit', 'L201');
        System.debug('After updating Amit\'s locker: ' + studentToLocker);

        // Step 5: Remove student - Chitra leaves the school
        studentToLocker.remove('Chitra');
        System.debug('After removing Chitra: ' + studentToLocker);

        // Step 6: Print all student-locker assignments
        System.debug('Final Locker Assignments:');
        for (String student : studentToLocker.keySet()) {
            String locker = studentToLocker.get(student);
            System.debug(student + ' -> ' + locker);
        }
    }
}