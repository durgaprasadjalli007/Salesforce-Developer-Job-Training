public class SOQLDemo {
    
    public static void searchAccount(String nameKeyword) {
        List<Account> accounts = [SELECT Id, Name, Phone, Industry 
                                  FROM Account 
                                  WHERE Name LIKE :('%' + nameKeyword + '%')];
        System.debug('Matching Accounts: ' + accounts);
    }
    
        public static void polymorphicQueryDemo() {
        List<Event> eventList = [
            SELECT Id, Subject, WhatId, What.Type
            FROM Event
            WHERE WhatId != null
            AND What.Type IN ('Account', 'Opportunity', 'Case', 'Contact')
            LIMIT 100
        ];

        // Prepare ID sets for each type
        Set<Id> accountIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for (Event evt : eventList) {
            if (evt.What.Type == 'Account') accountIds.add(evt.WhatId);
            else if (evt.What.Type == 'Opportunity') oppIds.add(evt.WhatId);
            else if (evt.What.Type == 'Case') caseIds.add(evt.WhatId);
            else if (evt.What.Type == 'Contact') contactIds.add(evt.WhatId);
        }

        // Query all related records in one go
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Name, Phone, Industry FROM Account WHERE Id IN :accountIds]
        );
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, Name, Amount FROM Opportunity WHERE Id IN :oppIds]
        );
        Map<Id, Case> caseMap = new Map<Id, Case>(
            [SELECT Id, CaseNumber, Subject, Status FROM Case WHERE Id IN :caseIds]
        );
        Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [SELECT Id, Name, Email, Phone FROM Contact WHERE Id IN :contactIds]
        );

        // Loop again and log info
        for (Event evt : eventList) {
            System.debug('----------------------');
            System.debug('Event Subject: ' + evt.Subject);
            System.debug('WhatId Type: ' + evt.What.Type);

            if (evt.What.Type == 'Account' && accountMap.containsKey(evt.WhatId)) {
                Account acc = accountMap.get(evt.WhatId);
                System.debug('Account Name: ' + acc.Name + ', Phone: ' + acc.Phone + ', Industry: ' + acc.Industry);

            } else if (evt.What.Type == 'Opportunity' && oppMap.containsKey(evt.WhatId)) {
                Opportunity opp = oppMap.get(evt.WhatId);
                System.debug('Opportunity Name: ' + opp.Name + ', Amount: ' + opp.Amount);

            } else if (evt.What.Type == 'Case' && caseMap.containsKey(evt.WhatId)) {
                Case cs = caseMap.get(evt.WhatId);
                System.debug('Case Number: ' + cs.CaseNumber + ', Subject: ' + cs.Subject + ', Status: ' + cs.Status);

            } else if (evt.What.Type == 'Contact' && contactMap.containsKey(evt.WhatId)) {
                Contact con = contactMap.get(evt.WhatId);
                System.debug('Contact Name: ' + con.Name + ', Email: ' + con.Email + ', Phone: ' + con.Phone);
            }
        }
    }
    public static void soqlForLoopDemo() {
        // Query on Account using SOQL For Loop
        for (Account acc : [SELECT Id, Name, Industry FROM Account LIMIT 3]) {
            System.debug('Account Name: ' + acc.Name + ', Industry: ' + acc.Industry);
        }

        // Query on Contact using SOQL For Loop
        for (Contact con : [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 3]) {
            System.debug('Contact Name: ' + con.FirstName + ' ' + con.LastName + ', Email: ' + con.Email);
        }

        // Query on Opportunity using SOQL For Loop
        for (Opportunity opp : [SELECT Id, Name, Amount, StageName FROM Opportunity LIMIT 3]) {
            System.debug('Opportunity Name: ' + opp.Name + ', Amount: ' + opp.Amount + ', Stage: ' + opp.StageName);
        }
    }
    public static void runAllQueries() {
        // 1. Contacts without Account
        List<Contact> contactsWithoutAccount = [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId = null];
        System.debug('1. Contacts without Account: ' + contactsWithoutAccount);

        // 2. Contacts with Account
        List<Contact> contactsWithAccount = [SELECT Id, FirstName, LastName, Account.Name FROM Contact WHERE AccountId != null];
        System.debug('2. Contacts with Account: ' + contactsWithAccount);

        // 3. Accounts with no contacts
        List<Account> accountsWithoutContacts = [
            SELECT Id, Name FROM Account
            WHERE Id NOT IN (SELECT AccountId FROM Contact WHERE AccountId != null)
        ];
        System.debug('3. Accounts without Contacts: ' + accountsWithoutContacts);

        // 4. Accounts with at least one contact
        List<Account> accountsWithContacts = [
            SELECT Id, Name, (SELECT Id, LastName FROM Contacts) 
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Contact WHERE AccountId != null)
        ];
        System.debug('4. Accounts with Contacts: ' + accountsWithContacts);

        // 5. Invoice with related Account and Parent Account
        List<Invoice__c> invoices = [
            SELECT Id, Name, Account__r.Name, Account__r.Parent.Name
            FROM Invoice__c
            WHERE Account__c != null
        ];
        System.debug('5. Invoices with related Account and Parent Account: ' + invoices);

        // 6. Invoice Line Items with related Invoice, Account, and Parent Account
        List<Invoice_Line_Item__c> lineItems = [
            SELECT Id, Name,
                Invoice__r.Name,
                Invoice__r.Account__r.Name,
                Invoice__r.Account__r.Parent.Name
            FROM Invoice_Line_Item__c
        ];
        System.debug('6. Invoice Line Items with related Invoice and Account Hierarchy: ' + lineItems);

        // 7. Maximum Opportunity Amount
        AggregateResult maxAmountResult = [SELECT MAX(Amount) maxAmt FROM Opportunity];
        System.debug('7. Max Opportunity Amount: ' + maxAmountResult.get('maxAmt'));

        // 8. Duplicate Contacts by Name & Email
        List<AggregateResult> duplicateContacts = [
            SELECT Name, Email, COUNT(Id) cnt
            FROM Contact
            WHERE Email != null
            GROUP BY Name, Email
            HAVING COUNT(Id) > 1
        ];
        System.debug('8. Duplicate Contacts (Name + Email): ' + duplicateContacts);

        // 9. Count of Accounts per Industry
        List<AggregateResult> industryAccountCount = [
            SELECT Industry, COUNT(Id) total
            FROM Account
            GROUP BY Industry
        ];
        System.debug('9. Account Count by Industry: ' + industryAccountCount);
    }
}