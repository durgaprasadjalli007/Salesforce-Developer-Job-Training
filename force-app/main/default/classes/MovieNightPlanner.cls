public class MovieNightPlanner {
    public static void planMovieNight() {
        // Step 1: Create a list of 5 movies
        List<String> movieList = new List<String>{
            'Inception',
            'The Matrix',
            'Jurassic Park',
            'Titanic',
            'The Dark Knight'
        };

        // Step 2: Add "Intermission Break" after the 2nd movie (index 2)
        movieList.add(2, 'Intermission Break');

        // Step 3: Add "The Avengers" at the very beginning
        movieList.add(0, 'The Avengers');

        // Step 4: Check if "Titanic" is in the list
        Boolean hasTitanic = movieList.contains('Titanic');
        System.debug('Is Titanic in the list? ' + hasTitanic);

        // Step 5: Find the position of "Intermission Break"
        Integer intermissionIndex = movieList.indexOf('Intermission Break');
        System.debug('Intermission Break is at position: ' + intermissionIndex);

        // Step 6: Remove the last movie
        movieList.remove(movieList.size() - 1);

        // Step 7: Print total items in final list
        System.debug('Total movies (including breaks): ' + movieList.size());

        // Print final list
        System.debug('Final Movie List: ' + movieList);
    }
}