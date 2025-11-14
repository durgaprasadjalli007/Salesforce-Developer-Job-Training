public with sharing class PS_ContactController {

    @AuraEnabled
    public static List<Contact> searchContacts(String searchTerm, String accountId) {
        try {
            if (String.isBlank(searchTerm) && String.isBlank(accountId)) {
                return new List<Contact>();
            }

            String whereClause = '';
            List<String> clauses = new List<String>();

            if (!String.isBlank(searchTerm)) {
                String esc = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                clauses.add('(Name LIKE :esc OR Email LIKE :esc OR Phone LIKE :esc)');
            }

            if (!String.isBlank(accountId)) {
                clauses.add('AccountId = :accountId');
            }

            if (!clauses.isEmpty()) {
                whereClause = ' WHERE ' + String.join(clauses, ' AND ');
            }

            String soql = 'SELECT Id, FirstName, LastName, Email, Phone, AccountId, Account.Name ' +
                          'FROM Contact' + whereClause + ' ORDER BY LastModifiedDate DESC LIMIT 50';

            List<Contact> results = Database.query(soql);
            return results;
        } catch (Exception ex) {
            throw new AuraHandledException('Failed to search contacts: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static Contact getContactById(Id contactId) {
        if (contactId == null) {
            throw new AuraHandledException('Contact Id must be provided.');
        }
        Contact c = [SELECT Id, FirstName, LastName, Email, Phone, AccountId, Account.Name
                     FROM Contact WHERE Id = :contactId LIMIT 1];
        if (c == null || c.Id == null) {
            throw new AuraHandledException('Contact not found with Id: ' + contactId);
        }
        return c;
    }

    @AuraEnabled
    public static Contact createContact(String firstName, String lastName, String email, String phone, Id accountId) {
        if (String.isBlank(lastName)) {
            throw new AuraHandledException('Last Name is required.');
        }

        Contact toInsert = new Contact();
        toInsert.FirstName = firstName;
        toInsert.LastName = lastName;
        toInsert.Email = email;
        toInsert.Phone = phone;
        if (accountId != null) toInsert.AccountId = accountId;

        try {
            insert toInsert;
            return [SELECT Id, FirstName, LastName, Email, Phone, AccountId, Account.Name 
                    FROM Contact WHERE Id = :toInsert.Id LIMIT 1];
        } catch (DmlException dmx) {
            throw new AuraHandledException('Could not create contact: ' + dmx.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Unexpected error creating contact: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static Contact updateContact(Id contactId, String firstName, String lastName, String email, String phone) {
        if (contactId == null) {
            throw new AuraHandledException('Contact Id is required for update.');
        }

        try {
            Contact existing = [SELECT Id, FirstName, LastName, Email, Phone, AccountId FROM Contact WHERE Id = :contactId LIMIT 1];
            if (existing == null || existing.Id == null) {
                throw new AuraHandledException('Contact not found with Id: ' + contactId);
            }

            existing.FirstName = firstName;
            existing.LastName = lastName;
            existing.Email = email;
            existing.Phone = phone;

            update existing;

            return [SELECT Id, FirstName, LastName, Email, Phone, AccountId, Account.Name FROM Contact WHERE Id = :contactId LIMIT 1];

        } catch (DmlException dmx) {
            throw new AuraHandledException('Failed to update contact: ' + dmx.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Error updating contact: ' + ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteContact(Id contactId) {
        if (contactId == null) {
            throw new AuraHandledException('Contact Id is required for deletion.');
        }

        try {
            Contact existing = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
            if (existing == null || existing.Id == null) {
                throw new AuraHandledException('Contact not found with Id: ' + contactId);
            }
            delete existing;
        } catch (DmlException dmx) {
            throw new AuraHandledException('Could not delete contact: ' + dmx.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException('Error deleting contact: ' + ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        return [SELECT Id, Name FROM Account ORDER BY Name LIMIT 100];
    }
}