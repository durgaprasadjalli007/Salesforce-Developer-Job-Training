trigger ContactTrigger on Contact (
    before insert, 
    before update, 
    after insert, 
    after update, 
    after delete, 
    after undelete
) {
    // === BEFORE TRIGGERS ===
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ContactTriggerHandler.updateFaxFromPhone(Trigger.new);
        }
        if (Trigger.isInsert) {
            ContactTriggerHandler.validateAccountActive(Trigger.new);
        }
    }

    // === AFTER INSERT / UPDATE ===
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ContactTriggerHandler.updateOpportunityWithAccountDetails(Trigger.new);

        // Collect Contact IDs for Welcome Email
        List<Id> contactIds = new List<Id>();
        for (Contact con : Trigger.new) {
            if (con.Email != null) {
                contactIds.add(con.Id);
            }
        }

        // Send Welcome Email if contacts exist
        if (!contactIds.isEmpty()) {
            System.enqueueJob(new WelcomeEmailQueueable(contactIds));
            WelcomeEmailService.sendWelcomeEmails(contactIds);
        }
    }

    // === AFTER DELETE / UNDELETE ===
    Set<Id> accountIds = new Set<Id>();

    // Collect AccountIds based on trigger context
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Contact con : Trigger.new) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
    } else if (Trigger.isDelete) {
        for (Contact con : Trigger.old) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }
    }

    // Queue job only if accounts exist
    if (!accountIds.isEmpty()) {
        System.enqueueJob(new UpdateAccountContactCountQueueable(accountIds));
    }
}