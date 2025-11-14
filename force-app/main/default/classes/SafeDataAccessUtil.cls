public class SafeDataAccessUtil {

    // Method to safely extract details from an Opportunity
    public static Map<String, Object> extractOpportunityDetails(Opportunity opp) {
        Map<String, Object> details = new Map<String, Object>();

        // Account Name
        details.put('AccountName', opp.Account?.Name ?? 'No Account');

        // Primary Contact Email via OpportunityContactRole (pick first contact if exists)
        String contactEmail = 'No Email';
        List<OpportunityContactRole> ocrList = [
            SELECT Contact.Email 
            FROM OpportunityContactRole 
            WHERE OpportunityId = :opp.Id 
            LIMIT 1
        ];
        if (!ocrList.isEmpty()) {
            contactEmail = ocrList[0].Contact?.Email ?? 'No Email';
        }
        details.put('PrimaryContactEmail', contactEmail);

        // Opportunity Owner's Manager Name
        String managerName = opp.Owner?.Manager?.Name ?? opp.Owner?.Name ?? 'No Manager';
        details.put('OwnerManagerName', managerName);

        // Close Date as String
        details.put('CloseDate', opp.CloseDate?.format() ?? 'No Date');

        return details;
    }

    // Method to calculate account metrics
    public static Map<String, Object> calculateAccountMetrics(List<Account> accounts) {
        Map<String, Object> metrics = new Map<String, Object>();

        Decimal totalRevenue = 0;
        Integer revenueCount = 0;
        Integer billingCount = 0;
        Map<String, Integer> industryCountMap = new Map<String, Integer>();

        for (Account acc : accounts) {
            // Average Annual Revenue (excluding null)
            totalRevenue += acc.AnnualRevenue ?? 0;
            revenueCount += acc.AnnualRevenue != null ? 1 : 0;

            // Count accounts with billing address (any field filled)
            billingCount += (acc.BillingStreet != null || acc.BillingCity != null || acc.BillingState != null) ? 1 : 0;

            // Count industries
            String industry = acc.Industry ?? 'Unknown';
            industryCountMap.put(industry, (industryCountMap.get(industry) ?? 0) + 1);
        }

        // Average Revenue
        Decimal avgRevenue = revenueCount > 0 ? totalRevenue / revenueCount : 0;

        // Most common industry
        String mostCommonIndustry = null;
        Integer maxCount = 0;
        for (String key : industryCountMap.keySet()) {
            if (industryCountMap.get(key) > maxCount) {
                maxCount = industryCountMap.get(key);
                mostCommonIndustry = key;
            }
        }

        metrics.put('AverageRevenue', avgRevenue);
        metrics.put('AccountsWithBillingAddress', billingCount);
        metrics.put('MostCommonIndustry', mostCommonIndustry ?? 'No Industry');

        return metrics;
    }
}