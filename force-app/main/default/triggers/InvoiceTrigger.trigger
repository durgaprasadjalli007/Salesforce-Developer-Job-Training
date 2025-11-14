trigger InvoiceTrigger on Invoice__c (after insert, after update, after delete, after undelete) {
    InvoiceTriggerHandler.updateProjectInvoiceTotals(
        Trigger.new,
        Trigger.old,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete
    );
}