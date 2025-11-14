public class WelcomeEmailService {

    // Future method to send emails asynchronously
    @future
    public static void sendWelcomeEmails(List<Id> contactIds) {
        try {
            // Step 1: Fetch contacts and their accounts
            List<Contact> contacts = [
                SELECT Id, FirstName, Email, Account.Name
                FROM Contact
                WHERE Id IN :contactIds
            ];

            // Step 2: Prepare a list to hold email messages
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            // Step 3: Loop through contacts and prepare emails
            for (Contact con : contacts) {
                if (con.Email != null && con.Email.contains('@')) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                    // Set recipient
                    email.setToAddresses(new List<String>{con.Email});

                    // Set subject
                    email.setSubject('Welcome to ' + (con.Account != null ? con.Account.Name : 'Our Company'));

                    // Set email body
                    String body = 'Hi ' + con.FirstName + ',\n\n'
                                + 'Welcome to ' + (con.Account != null ? con.Account.Name : 'our company') + '! '
                                + 'We are excited to have you with us.\n\n'
                                + 'Regards,\n'
                                + 'Team Support';

                    email.setPlainTextBody(body);

                    // Add to email list
                    emails.add(email);
                } else {
                    System.debug('Skipping contact ' + con.Id + ' due to invalid or missing email.');
                }
            }

            // Step 4: Send all emails at once
            if (!emails.isEmpty()) {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(emails, false);

                // Step 5: Log any failures
                for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        System.debug('Failed to send email to: ' + emails[i].getToAddresses() 
                            + '. Error: ' + results[i].getErrors()[0].getMessage());
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error in sendWelcomeEmails: ' + e.getMessage());
        }
    }
}