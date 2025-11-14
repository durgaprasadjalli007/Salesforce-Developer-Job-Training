public class InvoiceTriggerHandler {
    public static void updateProjectInvoiceTotals(
        List<Invoice__c> newList,
        List<Invoice__c> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> projectIds = new Set<Id>();

        // Collect affected Project IDs from NEW records
        if (isInsert || isUpdate || isUndelete) {
            for (Invoice__c inv : newList) {
                if (inv.Project__c != null) {
                    projectIds.add(inv.Project__c);
                }
            }
        }

        // Collect affected Project IDs from OLD records (for deletes or project changes)
        if (isDelete || isUpdate) {
            for (Invoice__c inv : oldList) {
                if (inv.Project__c != null) {
                    projectIds.add(inv.Project__c);
                }
            }
        }

        // If no projects are impacted, exit early
        if (projectIds.isEmpty()) {
            return;
        }

        // Query sum of Paid invoices per Project
        Map<Id, Decimal> invoiceSumMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT Project__c, SUM(Amount__c) totalAmount
            FROM Invoice__c
            WHERE Project__c IN :projectIds
            AND Status__c = 'Paid'
            GROUP BY Project__c
        ]) {
            invoiceSumMap.put((Id)ar.get('Project__c'), (Decimal)ar.get('totalAmount'));
        }

        // Prepare list of Projects to update
        List<Project__c> projectsToUpdate = new List<Project__c>();

        for (Id projId : projectIds) {
            Decimal totalAmount = invoiceSumMap.containsKey(projId) ? invoiceSumMap.get(projId) : 0;
            projectsToUpdate.add(new Project__c(
                Id = projId,
                Total_Invoice_Amount__c = totalAmount
            ));
        }

        // Bulk update Projects
        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
        }
    }
}