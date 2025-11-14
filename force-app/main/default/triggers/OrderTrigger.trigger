trigger OrderTrigger on Order (after insert, after update, after delete, after undelete) {
    OrderTriggerHandler.updateTotalOrderValue(
        Trigger.new,
        Trigger.old,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete
    );
}