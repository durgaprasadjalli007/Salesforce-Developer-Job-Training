public class OpportunityTriggerHandler {

    public static void createTaskForOppWithoutAccount(List<Opportunity> oppList) {
        List<Task> tasksToInsert = new List<Task>();

        for (Opportunity opp : oppList) {
            // Check if Opportunity does NOT have an Account linked
            if (opp.AccountId == null) {
                Task t = new Task();
                t.Subject = 'Opportunity is created without Account';
                t.Description = 'Opportunity is created without Account. Please assign the correct account to this Opportunity.';
                t.ActivityDate = Date.today().addDays(7); // Due date = today + 7 days
                t.Status = 'Not Started';
                t.Priority = 'High';
                t.WhatId = opp.Id;         // Related to Opportunity
                t.OwnerId = opp.OwnerId;   // Assign to Opportunity Owner

                tasksToInsert.add(t);
            }
        }

        // Insert tasks only if we have any
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
    public static void validateAccountActive(List<Opportunity> oppList) {
        // Collect Account IDs from incoming Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : oppList) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        // If there are no Accounts, skip validation
        if (accountIds.isEmpty()) {
            return;
        }

        // Query Account Active field for related Accounts
        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, Active__c FROM Account WHERE Id IN :accountIds]
        );

        // Validate Active field
        for (Opportunity opp : oppList) {
            if (opp.AccountId != null && accMap.containsKey(opp.AccountId)) {
                Account acc = accMap.get(opp.AccountId);
                if (acc.Active__c == 'No') {
                    opp.addError('You can not create an Opportunity under the account that is Not Active.');
                }
            }
        }
    }
     public static void handleAfterInsert(List<Opportunity> newOppList) {
        List<Opportunity> oppToUpdate = new List<Opportunity>();

        // Loop through new Opportunities
        for (Opportunity opp : newOppList) {
            // Check if Amount is null
            if (opp.Amount == null) {
                // Prepare record for update
                Opportunity tempOpp = new Opportunity();
                tempOpp.Id = opp.Id;
                tempOpp.Amount = 1000;
                oppToUpdate.add(tempOpp);
            }
        }

        // Update records if needed
        if(!oppToUpdate.isEmpty()) {
            update oppToUpdate;
        }
    }
    public static void assignTerritory(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        Set<String> regions = new Set<String>();
        Set<String> countries = new Set<String>();

        // STEP 1: Collect all regions & countries from opportunities
        for (Opportunity opp : newOpps) {
            // Process only if it's new OR region/country changed
            if (Trigger.isInsert || isRegionOrCountryChanged(opp, oldMap)) {
                if (!String.isBlank(opp.Customer_Region__c) && !String.isBlank(opp.Customer_Country__c)) {
                    regions.add(opp.Customer_Region__c);
                    countries.add(opp.Customer_Country__c);
                }
            }
        }

        if (regions.isEmpty() || countries.isEmpty()) {
            return; // No matching region/country to process
        }

        // STEP 2: Query all active territories
        List<Territory_Master__c> territories = [
            SELECT Id, Territory_Code__c, Region__c, Country__c, Territory_Manager__c,
                   Commission_Rate__c, Sales_Target__c, Priority_Level__c, Active__c
            FROM Territory_Master__c
            WHERE Region__c IN :regions
            AND Country__c IN :countries
            AND Active__c = TRUE
        ];

        // STEP 3: Group territories by Region + Country and pick highest priority
        Map<String, Territory_Master__c> territoryMap = new Map<String, Territory_Master__c>();

        for (Territory_Master__c terr : territories) {
            String key = terr.Region__c + '-' + terr.Country__c;

            if (!territoryMap.containsKey(key)) {
                territoryMap.put(key, terr);
            } else {
                Territory_Master__c existing = territoryMap.get(key);
                // Replace if current territory has higher priority
                if (getPriorityValue(terr.Priority_Level__c) < getPriorityValue(existing.Priority_Level__c)) {
                    territoryMap.put(key, terr);
                }
            }
        }

        List<Task> tasksToCreate = new List<Task>();

        // STEP 4: Assign territory details OR create a Task if no match
        for (Opportunity opp : newOpps) {
            if (!String.isBlank(opp.Customer_Region__c) && !String.isBlank(opp.Customer_Country__c)) {
                String key = opp.Customer_Region__c + '-' + opp.Customer_Country__c;

                if (territoryMap.containsKey(key)) {
                    Territory_Master__c terr = territoryMap.get(key);
                    opp.Territory_Code__c = terr.Territory_Code__c;
                    opp.Assigned_Territory_Manager__c = terr.Territory_Manager__c;
                    opp.Applicable_Commission_Rate__c = terr.Commission_Rate__c;
                    opp.Territory_Priority__c = terr.Priority_Level__c;
                    opp.Territory_Sales_Target__c = terr.Sales_Target__c;
                } else {
                    // Create a follow-up Task for manual assignment
                    Task t = new Task(
                        WhatId = opp.Id,
                        Subject = 'Manual Territory Assignment Needed',
                        Status = 'Open',
                        Priority = 'High',
                        Description = 'No matching territory found for this opportunity. Please review manually.'
                    );
                    tasksToCreate.add(t);
                }
            }
        }

        // STEP 5: Insert all pending tasks
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }

    // Helper: Convert priority into numeric value for comparison
    private static Integer getPriorityValue(String priority) {
        if (priority == 'High') return 1;
        if (priority == 'Medium') return 2;
        if (priority == 'Low') return 3;
        return 4; // Default if blank or unknown
    }

    // Helper: Check if region/country changed
    private static Boolean isRegionOrCountryChanged(Opportunity opp, Map<Id, Opportunity> oldMap) {
        if (oldMap == null || !oldMap.containsKey(opp.Id)) return true;
        Opportunity oldOpp = oldMap.get(opp.Id);
        return (opp.Customer_Region__c != oldOpp.Customer_Region__c ||
                opp.Customer_Country__c != oldOpp.Customer_Country__c);
    }
    public static void updateActiveOpportunityCounts(
        List<Opportunity> newList,
        List<Opportunity> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> accountIds = new Set<Id>();

        // Collect affected Account Ids from NEW records
        if (isInsert || isUpdate || isUndelete) {
            for (Opportunity opp : newList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        // Collect affected Account Ids from OLD records (for delete or stage changes)
        if (isDelete || isUpdate) {
            for (Opportunity opp : oldList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        // If no accounts are impacted, exit early
        if (accountIds.isEmpty()) {
            return;
        }

        // Query count of active Opportunities for all affected Accounts
        Map<Id, Integer> activeOppCountMap = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) cnt
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND StageName NOT IN ('Closed Won', 'Closed Lost')
            GROUP BY AccountId
        ]) {
            activeOppCountMap.put((Id)ar.get('AccountId'), (Integer)ar.get('cnt'));
        }

        // Prepare list of Accounts to update
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Integer activeCount = activeOppCountMap.containsKey(accId) ? activeOppCountMap.get(accId) : 0;
            accountsToUpdate.add(new Account(
                Id = accId,
                Active_Opportunities_Count__c = activeCount
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    public static void updateAverageDealSize(
        List<Opportunity> newList,
        List<Opportunity> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> accountIds = new Set<Id>();

        // Collect affected Account IDs from NEW records
        if (isInsert || isUpdate || isUndelete) {
            for (Opportunity opp : newList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        // Collect affected Account IDs from OLD records (for deletes or account changes)
        if (isDelete || isUpdate) {
            for (Opportunity opp : oldList) {
                if (opp.AccountId != null) {
                    accountIds.add(opp.AccountId);
                }
            }
        }

        // If no accounts are impacted, exit early
        if (accountIds.isEmpty()) {
            return;
        }

        // Query SUM & COUNT of Closed Won Opportunities per Account
        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();
        Map<Id, Decimal> countMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId, SUM(Amount) totalAmt, COUNT(Id) oppCount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND StageName = 'Closed Won'
            GROUP BY AccountId
        ]) {
            sumMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalAmt'));
            countMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('oppCount'));
        }

        // Prepare list of Accounts to update
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Decimal total = sumMap.containsKey(accId) ? sumMap.get(accId) : 0;
            Decimal cnt = countMap.containsKey(accId) ? countMap.get(accId) : 0;
            Decimal avg = (cnt > 0) ? total / cnt : 0;

            accountsToUpdate.add(new Account(
                Id = accId,
                Average_Deal_Size__c = avg
            ));
        }

        // Bulk update Accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    public static void handleTrigger(
        List<Opportunity> newList,
        List<Opportunity> oldList,
        Map<Id, Opportunity> oldMap,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> accountIds = new Set<Id>();

        // Collect affected Account IDs from new and old records
        if (newList != null) {
            for (Opportunity opp : newList) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        }
        if (oldList != null) {
            for (Opportunity opp : oldList) {
                if (opp.AccountId != null) accountIds.add(opp.AccountId);
            }
        }
        if (accountIds.isEmpty()) return;

        // Route logic based on trigger context
        if (isInsert || isUpdate || isUndelete) {
            updateWeightedPipeline(newList);
        }
        if (isDelete) {
            updateWeightedPipeline(oldList);
        }
    }
     public static void updateWeightedPipeline(List<Opportunity> oppList) {
        Set<Id> accountIds = new Set<Id>();

        // Collect related Account Ids
        for (Opportunity opp : oppList) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        // If no related accounts, exit early
        if (accountIds.isEmpty()) {
            return;
        }

        // Query all Open Opportunities for these Accounts
        List<Opportunity> openOpps = [
            SELECT AccountId, Amount, Probability
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND StageName NOT IN ('Closed Won', 'Closed Lost')
        ];

        // Calculate weighted pipeline = SUM(Amount * Probability/100)
        Map<Id, Decimal> accountToWeighted = new Map<Id, Decimal>();

        for (Opportunity opp : openOpps) {
            Decimal weighted = (opp.Amount != null ? opp.Amount : 0) * (opp.Probability != null ? opp.Probability : 0) / 100;
            accountToWeighted.put(opp.AccountId, accountToWeighted.get(opp.AccountId) == null 
                                  ? weighted 
                                  : accountToWeighted.get(opp.AccountId) + weighted);
        }

        // Fetch all related accounts
        List<Account> accountsToUpdate = [
            SELECT Id, Weighted_Pipeline__c
            FROM Account
            WHERE Id IN :accountIds
        ];

        // Update Weighted_Pipeline__c field on Accounts
        for (Account acc : accountsToUpdate) {
            acc.Weighted_Pipeline__c = accountToWeighted.containsKey(acc.Id) 
                                        ? accountToWeighted.get(acc.Id) 
                                        : 0;
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    // Static variable to prevent recursive trigger calls
    private static Boolean isUpdatingContacts = false;

    public static void updateContactTotalOpportunity(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
        // Prevent recursion
        if (isUpdatingContacts) {
            return;
        }

        // Collect Account Ids from Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : newOpps) {
            // Consider only opportunities linked to an Account
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Fetch all Contacts under these Accounts
        Map<Id, List<Contact>> accountContactsMap = new Map<Id, List<Contact>>();
        for (Contact con : [
            SELECT Id, AccountId, Total_Opportunity_Value__c 
            FROM Contact 
            WHERE AccountId IN :accountIds
        ]) {
            if (!accountContactsMap.containsKey(con.AccountId)) {
                accountContactsMap.put(con.AccountId, new List<Contact>());
            }
            accountContactsMap.get(con.AccountId).add(con);
        }

        // Fetch total "Closed Won" Opportunity Amount per Account
        Map<Id, Decimal> accountOpportunitySum = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT AccountId accId, SUM(Amount) total 
            FROM Opportunity 
            WHERE AccountId IN :accountIds 
            AND StageName = 'Closed Won'
            GROUP BY AccountId
        ]) {
            accountOpportunitySum.put((Id) ar.get('accId'), (Decimal) ar.get('total'));
        }

        List<Contact> contactsToUpdate = new List<Contact>();

        // Assign Opportunity totals to each Contact
        for (Id accId : accountContactsMap.keySet()) {
            Decimal totalAmount = accountOpportunitySum.containsKey(accId) ? accountOpportunitySum.get(accId) : 0;

            for (Contact con : accountContactsMap.get(accId)) {
                if (con.Total_Opportunity_Value__c != totalAmount) {
                    con.Total_Opportunity_Value__c = totalAmount;
                    contactsToUpdate.add(con);
                }
            }
        }

        // Perform Contact Update
        if (!contactsToUpdate.isEmpty()) {
            isUpdatingContacts = true;
            try {
                update contactsToUpdate;
            } catch (DmlException e) {
                System.debug('Failed to update Contacts: ' + e.getMessage());
            } finally {
                isUpdatingContacts = false;
            }
        }
    }
}