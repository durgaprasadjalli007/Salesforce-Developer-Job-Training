trigger OpportunityTrigger on Opportunity (Before insert,before update,after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.createTaskForOppWithoutAccount(Trigger.new);
        OpportunityTriggerHandler.handleAfterInsert(Trigger.new);
    }
     if (Trigger.isBefore && Trigger.isInsert) {
    OpportunityTriggerHandler.validateAccountActive(Trigger.new);
     }
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            OpportunityTriggerHandler.assignTerritory(Trigger.new, Trigger.oldMap);
        }
    }
   
    OpportunityTriggerHandler.updateActiveOpportunityCounts(Trigger.new, Trigger.old, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
    OpportunityTriggerHandler.updateAverageDealSize(
        Trigger.new,
        Trigger.old,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete
    );
    OpportunityTriggerHandler.handleTrigger(
        Trigger.new, Trigger.old,
        Trigger.oldMap,
        Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete
    );
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete || Trigger.isDelete) {
        OpportunityTriggerHandler.updateContactTotalOpportunity(
            Trigger.isDelete ? Trigger.old : Trigger.new,
            Trigger.oldMap
        );
    }
}