public class WelcomeEmailQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> contactIds;

    public WelcomeEmailQueueable(List<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public void execute(QueueableContext context) {
        List<Contact> contacts = [
            SELECT Id, FirstName, Email, Account.Name
            FROM Contact
            WHERE Id IN :contactIds
            AND Email != null
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Email_Log__c> failedLogs = new List<Email_Log__c>();

        for (Contact con : contacts) {
            try {
                // Create email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{con.Email});
                email.setSubject('Welcome to Our Company!');
                email.setPlainTextBody('Hi ' + con.FirstName + ',\n\n' +
                    'Welcome to ' + (con.Account != null ? con.Account.Name : 'our platform') + '! ' +
                    'We are excited to have you onboard.\n\nRegards,\nCustomer Success Team');

                emails.add(email);
            } catch (Exception e) {
                // Log failed email attempts
                failedLogs.add(new Email_Log__c(
                    Contact__c = con.Id,
                    Email__c = con.Email,
                    Status__c = 'Failed',
                    Error_Message__c = e.getMessage()
                ));
            }
        }

        // Send emails in bulk
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails, false);
            } catch (Exception ex) {
                // If bulk email fails, log for all
                for (Contact con : contacts) {
                    failedLogs.add(new Email_Log__c(
                        Contact__c = con.Id,
                        Email__c = con.Email,
                        Status__c = 'Failed',
                        Error_Message__c = ex.getMessage()
                    ));
                }
            }
        }

        // Insert failed email logs
        if (!failedLogs.isEmpty()) {
            insert failedLogs;
        }
    }
}