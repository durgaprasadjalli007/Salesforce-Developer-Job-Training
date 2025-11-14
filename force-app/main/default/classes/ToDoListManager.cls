public class ToDoListManager {
    public static void manageTasks() {
        // Step 1: Create initial list
        List<String> tasks = new List<String>{'Check emails', 'Drink coffee', 'Review calendar'};
        System.debug('Initial Tasks: ' + tasks);

        // Step 2: Add urgent task at beginning
        tasks.add(0, 'URGENT: Call dentist');
        System.debug('After adding urgent task: ' + tasks);

        // Step 3: Insert "Take vitamins" between "Drink coffee" and "Review calendar"
        Integer indexOfReview = tasks.indexOf('Review calendar');
        tasks.add(indexOfReview, 'Take vitamins');
        System.debug('After inserting vitamins task: ' + tasks);

        // Step 4: Check if "Exercise" is in the list
        Boolean hasExercise = tasks.contains('Exercise');
        System.debug('Is "Exercise" in the list? ' + hasExercise);

        // Step 5: Find position of "Drink coffee"
        Integer coffeeIndex = tasks.indexOf('Drink coffee');
        System.debug('"Drink coffee" is at position: ' + coffeeIndex);

        // Step 6: Complete the first task
        String completedTask = tasks.remove(0);
        System.debug('Removed task: ' + completedTask);
        System.debug('After removing first task: ' + tasks);

        // Step 7: Add "Prepare dinner" at end
        tasks.add('Prepare dinner');
        System.debug('After adding dinner task: ' + tasks);

        // Step 8: Show how many tasks left
        System.debug('Remaining tasks count: ' + tasks.size());
    }
}