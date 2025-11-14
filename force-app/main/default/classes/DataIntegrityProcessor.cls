public class DataIntegrityProcessor {

    // ================== WRAPPER CLASS ==================
    public class AccountValidationResult {
        public String accountName;
        public String accountNumber;
        public String industry;
        public Decimal revenue;
        public String isActive;           
        public String validationStatus;

        public AccountValidationResult(String accName, String accNum, String ind, Decimal rev, String active, String status) {
            this.accountName = accName;
            this.accountNumber = accNum;
            this.industry = ind;
            this.revenue = rev;
            this.isActive = active;
            this.validationStatus = status;
        }
    }

    // ================== VALIDATION & PROCESSING METHOD ==================
    public static List<AccountValidationResult> validateAndProcessAccounts(List<Account> accList) {
        // Always initialize results list
        List<AccountValidationResult> results = new List<AccountValidationResult>();

        // Variables for summary statistics
        Integer validCount = 0;
        Integer invalidCount = 0;

        if (accList == null || accList.isEmpty()) {
            System.debug('No Accounts found to validate.');
            return results;  // FIX: ensures method always returns something
        }

        for (Account acc : accList) {
            Boolean isValid = true;

            // Rule 1: Account must have Name AND (Phone OR Website)
            if (String.isBlank(acc.Name) || (String.isBlank(acc.Phone) && String.isBlank(acc.Website))) {
                isValid = false;
            }

            // Rule 2: If Annual Revenue exists, it must be > 0
            if (acc.AnnualRevenue != null && acc.AnnualRevenue <= 0) {
                isValid = false;
            }

            // Rule 3: Billing Address required for Enterprise Accounts (Type=Customer AND Employees>500)
            if (acc.Type == 'Customer' && acc.NumberOfEmployees > 500 &&
                (String.isBlank(acc.BillingStreet) && String.isBlank(acc.BillingCity) && String.isBlank(acc.BillingCountry))) {
                isValid = false;
            }

            // Rule 4: Industry must not be null for Technology companies
            if (acc.Type == 'Technology' && acc.Industry == null) {
                isValid = false;
            }

            // Count Valid vs Invalid
            if (isValid) {
                validCount++;
            } else {
                invalidCount++;
            }

            // Convert Active__c safely to String
            String activeStatus = String.valueOf(acc.Active__c);

            // Add result to list
            results.add(
                new AccountValidationResult(
                    acc.Name,
                    acc.AccountNumber,
                    acc.Industry,
                    acc.AnnualRevenue,
                    activeStatus,
                    isValid ? 'Valid' : 'Invalid'
                )
            );
        }

        // Summary Logs
        System.debug('=== Summary Statistics ===');
        System.debug('Total Accounts: ' + accList.size());
        System.debug('Valid Accounts: ' + validCount);
        System.debug('Invalid Accounts: ' + invalidCount);

        // FIX: Ensure return is always present
        return results;
    }

    // ================== PROCESS OPPORTUNITY CHAIN METHOD ==================
    public static void processOpportunityChain(Account acc) {
        if (acc == null) {
            System.debug('Account is null, skipping opportunity processing.');
            return;
        }

        List<Opportunity> oppList = [
            SELECT Id, Name, StageName, Amount
            FROM Opportunity
            WHERE AccountId = :acc.Id
        ];

        Map<String, Decimal> pipelineByStage = new Map<String, Decimal>();

        for (Opportunity opp : oppList) {
            Decimal amt = opp.Amount != null ? opp.Amount : 0;

            if (!pipelineByStage.containsKey(opp.StageName)) {
                pipelineByStage.put(opp.StageName, amt);
            } else {
                pipelineByStage.put(opp.StageName, pipelineByStage.get(opp.StageName) + amt);
            }
        }

        System.debug('=== Pipeline Summary for Account: ' + acc.Name + ' ===');
        for (String stage : pipelineByStage.keySet()) {
            System.debug(stage + ' => ' + pipelineByStage.get(stage));
        }

        Decimal totalPipeline = 0;
        for (Decimal val : pipelineByStage.values()) {
            totalPipeline += val;
        }

        acc.Total_Pipeline_Value__c = totalPipeline;
        update acc;

        System.debug('Updated Account ' + acc.Name + ' with Total Pipeline Value = ' + totalPipeline);
    }
}