public class CaseTriggerHandler {
    public static void updateHighPriorityCaseCounts(
        List<Case> newList,
        List<Case> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> contactIds = new Set<Id>();

        // Collect affected Contact IDs from NEW records
        if (isInsert || isUpdate || isUndelete) {
            for (Case cs : newList) {
                if (cs.ContactId != null) {
                    contactIds.add(cs.ContactId);
                }
            }
        }

        // Collect affected Contact IDs from OLD records (for deletes or contact changes)
        if (isDelete || isUpdate) {
            for (Case cs : oldList) {
                if (cs.ContactId != null) {
                    contactIds.add(cs.ContactId);
                }
            }
        }

        // If no contacts impacted, exit early
        if (contactIds.isEmpty()) {
            return;
        }

        // Query high-priority open cases per contact
        Map<Id, Integer> caseCountMap = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT ContactId, COUNT(Id) cnt
            FROM Case
            WHERE ContactId IN :contactIds
            AND Priority = 'High'
            AND Status != 'Closed'
            GROUP BY ContactId
        ]) {
            caseCountMap.put((Id)ar.get('ContactId'), (Integer)ar.get('cnt'));
        }

        // Prepare list of contacts to update
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Id conId : contactIds) {
            Integer activeCount = caseCountMap.containsKey(conId) ? caseCountMap.get(conId) : 0;
            contactsToUpdate.add(new Contact(
                Id = conId,
                High_Priority_Cases_Count__c = activeCount
            ));
        }

        // Update contacts in bulk
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    }
     public static void updateLatestCaseDate(List<Case> caseList) {
        // Collect all unique Account Ids
        Set<Id> accountIds = new Set<Id>();
        for (Case cs : caseList) {
            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }
        
        if (accountIds.isEmpty()) {
            return;
        }

        // Query latest Case CreatedDate per Account using aggregate function
        Map<Id, Date> accountToLatestCase = new Map<Id, Date>();
        for (AggregateResult ar : [
            SELECT AccountId, MAX(CreatedDate) latestDate
            FROM Case
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountToLatestCase.put((Id) ar.get('AccountId'), ((Datetime) ar.get('latestDate')).date());
        }

        // Prepare Account records for update
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Date latestDate = accountToLatestCase.get(accId);
            accountsToUpdate.add(new Account(
                Id = accId,
                Latest_Case_Date__c = latestDate
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}