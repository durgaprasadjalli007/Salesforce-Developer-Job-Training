public class LeadScoringEngine {

    // Method 1: Calculate Lead Score
    public static Integer calculateLeadScore(Lead leadRec) {
        Integer score = 0;

        // 1. Add 20 points if lead source is Website OR Referral
        String source = leadRec.LeadSource ?? '';
        if (source == 'Website' || source == 'Referral') {
            score += 20;
        }

        // 2. Add 15 points if company size > 100 AND industry = Technology
        Integer empCount = leadRec.NumberOfEmployees ?? 0;
        String industry = leadRec.Industry ?? '';
        if (empCount > 100 && industry == 'Technology') {
            score += 15;
        }

        // 3. Add 10 points if annual revenue > 500000
        Decimal annualRevenue = leadRec.AnnualRevenue ?? 0;
        if (annualRevenue > 500000) {
            score += 10;
        }

        // 4. Add 25 points if lead has both email AND phone
        String email = leadRec.Email ?? '';
        String phone = leadRec.Phone ?? '';
        if (!String.isBlank(email) && !String.isBlank(phone)) {
            score += 25;
        }

        // 5. Subtract 10 points if lead is NOT qualified
        Boolean isQualified = leadRec.IsQualified__c ?? false; // Custom checkbox field
        if (!isQualified) {
            score -= 10;
        }

        // 6. Add 5 points for each completed activity
        // Using Safe Navigation Operator
        Integer completedActivities = [
            SELECT COUNT()
            FROM Task
            WHERE WhoId = :leadRec.Id AND Status = 'Completed'
        ];
        score += (completedActivities ?? 0) * 5;

        // Ensure score doesn't go below 0 or above 100
        if (score < 0) score = 0;
        if (score > 100) score = 100;

        return score;
    }

    // Method 2: Categorize Leads based on score
    public static Map<String, List<Lead>> categorizeLeads(List<Lead> leadList) {
        Map<String, List<Lead>> categorizedMap = new Map<String, List<Lead>>();
        categorizedMap.put('Hot', new List<Lead>());
        categorizedMap.put('Warm', new List<Lead>());
        categorizedMap.put('Cold', new List<Lead>());

        for (Lead l : leadList) {
            Integer score = calculateLeadScore(l);

            if (score >= 70) {
                categorizedMap.get('Hot').add(l);
            } else if (score >= 40 && score < 70) {
                categorizedMap.get('Warm').add(l);
            } else {
                categorizedMap.get('Cold').add(l);
            }
        }
        return categorizedMap;
    }
}