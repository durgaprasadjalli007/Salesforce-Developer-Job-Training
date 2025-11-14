trigger RevenueRecordTrigger on Revenue_Record__c (
    after insert, after update, after delete, after undelete
) {
    if (Trigger.isInsert) {
        RevenueRecordTriggerHandler.updateQuarterlyRevenue(Trigger.new, null, false);
    }
    if (Trigger.isUpdate) {
        RevenueRecordTriggerHandler.updateQuarterlyRevenue(Trigger.new, Trigger.oldMap, false);
    }
    if (Trigger.isDelete) {
        RevenueRecordTriggerHandler.updateQuarterlyRevenue(null, Trigger.oldMap, true);
    }
    if (Trigger.isUndelete) {
        RevenueRecordTriggerHandler.updateQuarterlyRevenue(Trigger.new, null, false);
    }
}