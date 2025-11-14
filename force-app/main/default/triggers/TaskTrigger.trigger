trigger TaskTrigger on Task (before delete) {
TaskTriggerHandler.restrictTaskDeletion(Trigger.old);
}