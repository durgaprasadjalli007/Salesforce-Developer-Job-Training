trigger SalesRecordTrigger on Sales_Record__c (
    after insert, after update, after delete, after undelete
) {
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        SalesRecordTriggerHandler.updateUserTeamTotals(Trigger.new);
    }
    if(Trigger.isDelete){
        SalesRecordTriggerHandler.updateUserTeamTotals(Trigger.old);
    }
}