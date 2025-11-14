trigger ProjectTrigger on Project__c (after insert, after update, after delete, after undelete) {
    Set<Id> clientIds = new Set<Id>();

    // Collect Client Ids for inserted or updated records
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Project__c proj : Trigger.new) {
            if (proj.Client__c != null) {
                clientIds.add(proj.Client__c);
            }
        }
    }

    // Collect Client Ids for deleted records
    if (Trigger.isDelete) {
        for (Project__c proj : Trigger.old) {
            if (proj.Client__c != null) {
                clientIds.add(proj.Client__c);
            }
        }
    }

    if (!clientIds.isEmpty()) {
        ProjectTriggerHandler.updateEarliestProjectStart(clientIds);
    }
}