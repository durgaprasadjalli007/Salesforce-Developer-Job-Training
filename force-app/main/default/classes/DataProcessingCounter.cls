public class DataProcessingCounter {
    // === Private Counters ===
    private static Integer totalRecordsProcessed = 0;
    private static Integer successCounter = 0;
    private static Integer errorCounter = 0;

    // === Method: Process Record ===
    public static void processRecord(Decimal amount, Boolean isSuccess) {
        // Increment total records counter
        totalRecordsProcessed++;

        // Update counters based on success or failure
        if (isSuccess) {
            successCounter++;
        } else {
            errorCounter++;
        }
    }

    // === Method: Get Processing Stats ===
    public static String getProcessingStats() {
        return 'Total Records: ' + totalRecordsProcessed +
               ', Successful: ' + successCounter +
               ', Failed: ' + errorCounter;
    }

    // === Method: Reset Counters ===
    public static void resetCounters() {
        totalRecordsProcessed = 0;
        successCounter = 0;
        errorCounter = 0;
    }
}