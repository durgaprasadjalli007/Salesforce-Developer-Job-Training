trigger CaseTrigger on Case (before insert,before update, after insert, after update, after delete, after undelete) {
    CaseTriggerHandler.updateHighPriorityCaseCounts(
        Trigger.new, 
        Trigger.old, 
        Trigger.isInsert, 
        Trigger.isUpdate, 
        Trigger.isDelete, 
        Trigger.isUndelete
    );
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            CaseTriggerHandler.updateLatestCaseDate(Trigger.new);
        }
        if (Trigger.isDelete) {
            CaseTriggerHandler.updateLatestCaseDate(Trigger.old);
        }
    }
    if (Trigger.isBefore && Trigger.isInsert && Trigger.isUpdate){
        for (Case caserecord : Trigger.NEW){
            if (caserecord.origin == 'Phone'){
                caserecord.Priority = 'High';
            }
            else {
                 Caserecord.Priority = 'Low';
            }
        }
    }
}