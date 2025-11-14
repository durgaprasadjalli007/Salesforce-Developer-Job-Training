public class AccountCleanupService {
    @future
    public static void cleanupAccountData(List<Id> accountIds) {
        List<Account> accList = [SELECT Id, Name, Phone, BillingStreet, BillingState, BillingCountry, Last_Cleaned__c 
                                 FROM Account 
                                 WHERE Id IN :accountIds];

        for (Account acc : accList) {
            // Format Account Name
            if (acc.Name != null)
                acc.Name = formatAccountName(acc.Name);

            // Format Phone Number
            if (acc.Phone != null)
                acc.Phone = formatPhoneNumber(acc.Phone);

            // Clean up billing address
            if (acc.BillingStreet != null)
                acc.BillingStreet = acc.BillingStreet.trim().replaceAll('\\s+', ' ');

            // Set last cleaned timestamp
            acc.Last_Cleaned__c = System.now();
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }

    private static String formatPhoneNumber(String phone) {
        String digits = phone.replaceAll('\\D', '');
        if (digits.length() == 10) {
            return '(' + digits.substring(0, 3) + ') ' + digits.substring(3, 6) + '-' + digits.substring(6);
        }
        return phone;
    }

    private static String formatAccountName(String name) {
        List<String> words = name.toLowerCase().split(' ');
        String formatted = '';
        for (String word : words) {
            if (!String.isBlank(word)) {
                formatted += word.substring(0, 1).toUpperCase() + word.substring(1) + ' ';
            }
        }
        return formatted.trim();
    }
}