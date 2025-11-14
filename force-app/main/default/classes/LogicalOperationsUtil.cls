public class LogicalOperationsUtil {

    // === Method 1: Evaluate Account Status ===
    public static String evaluateAccountStatus(Account acc) {
        // Null check to avoid NullPointerException
        if (acc == null) {
            return 'Unknown';
        }

        // Assuming Active__c is a Picklist/Text field with values: 'Active', 'Inactive'
        String accountStatus = acc.Active__c;

        // === Condition 1: Premium Account ===
        if (accountStatus == 'Active' && acc.AnnualRevenue > 1000000) {
            return 'Premium';
        }
        // === Condition 2: Standard Account ===
        else if (accountStatus == 'Active' || acc.NumberOfEmployees > 100) {
            return 'Standard';
        }
        // === Condition 3: Inactive Account ===
        else if (accountStatus == 'Inactive') {
            return 'Inactive';
        }
        // === Default: Unknown ===
        return 'Unknown';
    }

    // === Method 2: Validate Contact Information ===
    public static Boolean validateContactInformation(Contact con) {
        // Null check for contact record
        if (con == null) {
            return false;
        }

        // Check if email or phone is present
        Boolean hasContactInfo = (String.isNotBlank(con.Email) || String.isNotBlank(con.Phone));

        // Check if the contact has a linked account and if the account is active
        Boolean hasValidAccount = (con.AccountId != null && con.Account.Active__c == 'Active');

        // Check if the contact has a valid name
        Boolean hasValidName = String.isNotBlank(con.LastName);

        // Final validation
        return (hasContactInfo && hasValidAccount && hasValidName);
    }
}