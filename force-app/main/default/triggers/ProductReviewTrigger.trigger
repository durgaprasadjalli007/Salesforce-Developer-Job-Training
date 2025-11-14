trigger ProductReviewTrigger on Product_Review__c (after insert, after update, after delete, after undelete) {
    ProductReviewTriggerHandler.updateAverageProductRating(
        Trigger.new,
        Trigger.old,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete
    );
}