public class ContactTriggerHandler {

    // Update Fax field from Phone field on Contact update
    public static void updateFaxFromPhone(List<Contact> contactList) {
        for (Contact con : contactList) {
            // If Phone is available, set Fax = Phone
            if (!String.isBlank(con.Phone)) {
                con.Fax = con.Phone;
            } else {
                // If Phone is blank, clear Fax as well (optional)
                con.Fax = null;
            }
        }
    }
    public static void updateOpportunityWithAccountDetails(List<Contact> contactList) {

        // Collect unique Account Ids from Contacts
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : contactList) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
            }
        }

        // If no contacts have AccountId, exit
        if (accountIds.isEmpty()) {
            return;
        }

        // Fetch Accounts related to the Contacts
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Name, Industry, Phone, Rating
             FROM Account
             WHERE Id IN :accountIds]
        );

        // Fetch Opportunities related to these Accounts
        List<Opportunity> oppList = [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE AccountId IN :accountIds
        ];

        // Update Opportunity fields based on related Account
        for (Opportunity opp : oppList) {
            Account acc = accountMap.get(opp.AccountId);
            if (acc != null) {
                opp.Account_Name__c    = acc.Name;
                opp.Account_Industry__c = acc.Industry;
                opp.Account_Phone__c    = acc.Phone;
                opp.Account_Rating__c   = acc.Rating;
            }
        }

        // Update all Opportunities
        if (!oppList.isEmpty()) {
            update oppList;
        }
    }
    public static void validateAccountActive(List<Contact> contactList) {
        // Collect Account IDs from incoming Contacts
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : contactList) {
            if (con.AccountId != null) {
                accountIds.add(con.AccountId);
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
        for (Contact con : contactList) {
            if (con.AccountId != null && accMap.containsKey(con.AccountId)) {
                Account acc = accMap.get(con.AccountId);
                if (acc.Active__c == 'No') {
                    con.addError('You can not create a Contact under the account that is Not Active.');
                }
            }
        }
    }
}