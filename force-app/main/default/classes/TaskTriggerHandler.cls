public class TaskTriggerHandler {

    public static void restrictTaskDeletion(List<Task> oldTaskList) {
        // Get the current user's profile name
        String currentProfileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;

        // If the current user's profile is NOT System Administrator, restrict deletion
        if (currentProfileName != 'System Administrator') {
            for (Task t : oldTaskList) {
                t.addError('You are not allowed to delete Task records. Only System Administrators can delete tasks.');
            }
        }
    }
}