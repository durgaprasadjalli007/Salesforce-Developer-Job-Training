public class ApeXTrigger1Handler {
 public static void setDefaultValues(List<Account> accList) {
        for(Account acc : accList) {
            // Set Industry to Education
            acc.Industry = 'Education';

            // If Description is null or blank, set default value
            if(String.isBlank(acc.Description)) {
                acc.Description = 'Account Description is blank';
            }
        }
    }
    public static void setShippingAddress(List<Account> accList) {
        for(Account acc : accList) {
            acc.ShippingStreet = acc.BillingStreet;
            acc.ShippingCity = acc.BillingCity;
            acc.ShippingState = acc.BillingState;
            acc.ShippingPostalCode = acc.BillingPostalCode;
            acc.ShippingStreet = acc.BillingStreet;
            
        }
    }
    public static void setShippingAddressNotNullCheck(List<Account> accList) {
        for(Account acc : accList) {
            if (String.isBlank(acc.ShippingStreet) &&
                String.isBlank(acc.ShippingCity) &&
                String.isBlank(acc.ShippingState) &&
                String.isBlank(acc.ShippingPostalCode) &&
                String.isBlank(acc.ShippingCountry)) {

                acc.ShippingStreet     = acc.BillingStreet;
                acc.ShippingCity       = acc.BillingCity;
                acc.ShippingState      = acc.BillingState;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingCountry    = acc.BillingCountry;
            }
            
        }
    }
    public static void updateActiveOnContactsAndOpps(List<Account> newList, Map<Id, Account> oldMap) {
        // To store Contacts & Opportunities to update
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        // Loop through updated accounts
        for (Account acc : newList) {
            Account oldAcc = oldMap.get(acc.Id);

            // Process only if Active__c changed
            if (acc.Active__c != oldAcc.Active__c) {

                // Fetch related Contacts
                List<Contact> relatedContacts = [
                    SELECT Id, Active__c
                    FROM Contact
                    WHERE AccountId = :acc.Id
                ];

                for (Contact con : relatedContacts) {
                    con.Active__c = acc.Active__c;
                    contactsToUpdate.add(con);
                }

                // Fetch related Opportunities
                List<Opportunity> relatedOpps = [
                    SELECT Id, Active__c
                    FROM Opportunity
                    WHERE AccountId = :acc.Id
                ];

                for (Opportunity opp : relatedOpps) {
                    opp.Active__c = acc.Active__c;
                    oppsToUpdate.add(opp);
                }
            }
        }

        // Perform DML only if there are records to update
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}