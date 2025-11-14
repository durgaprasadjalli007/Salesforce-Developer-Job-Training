public class AccountDataRollupBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Store summary for email
    private List<String> summaryReport = new List<String>();

    // STEP 1: Query Accounts
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name FROM Account');
    }

    // STEP 2: Process each batch of Accounts
    public void execute(Database.BatchableContext bc, List<Account> accountList) {
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : accountList) {

            // === FETCH OPPORTUNITIES ===
            List<Opportunity> oppList = [
                SELECT Amount, StageName
                FROM Opportunity
                WHERE AccountId = :acc.Id
            ];

            // === FETCH CASES ===
            List<Case> casesUnderAccount = [
                SELECT Status, ClosedDate, CreatedDate, Satisfaction__c
                FROM Case
                WHERE AccountId = :acc.Id
            ];

            // === OPPORTUNITY CALCULATIONS ===
            Decimal totalRevenue = 0;
            Integer closedWonCount = 0;
            Integer totalOpps = oppList.size();

            for (Opportunity opp : oppList) {
                if (opp.StageName == 'Closed Won') {
                    totalRevenue += (opp.Amount != null) ? opp.Amount : 0;
                    closedWonCount++;
                }
            }

            Decimal avgDealSize = (closedWonCount > 0) ? (totalRevenue / closedWonCount) : 0;
            Decimal winRate = (totalOpps > 0) ? ((Decimal) closedWonCount / totalOpps) * 100 : 0;

            // === CASE CALCULATIONS ===
            Decimal totalResolutionTime = 0;
            Integer closedCaseCount = 0;
            Decimal totalSatisfaction = 0;
            Integer satisfactionCount = 0;

            for (Case c : casesUnderAccount) {
                // Calculate resolution time in days
                if (c.Status == 'Closed' && c.ClosedDate != null) {
                    totalResolutionTime += (
                        (c.ClosedDate.getTime() - c.CreatedDate.getTime()) / (1000 * 60 * 60 * 24)
                    );
                    closedCaseCount++;
                }

                // Check Satisfaction__c exists and has value
                if (Schema.SObjectType.Case.fields.getMap().containsKey('Satisfaction__c') && c.Satisfaction__c != null) {
                    totalSatisfaction += c.Satisfaction__c;
                    satisfactionCount++;
                }
            }

            Decimal avgResolution = (closedCaseCount > 0) ? (totalResolutionTime / closedCaseCount) : 0;
            Decimal avgSatisfaction = (satisfactionCount > 0) ? (totalSatisfaction / satisfactionCount) : 0;

            // === UPDATE ACCOUNT FIELDS ===
            acc.Total_Revenue__c         = totalRevenue;
            acc.Average_Deal_Size__c     = avgDealSize;
            acc.Win_Rate__c              = winRate;
            acc.Average_Case_Resolution__c   = avgResolution;
            acc.Customer_Satisfaction__c = avgSatisfaction;

            accountsToUpdate.add(acc);

            // === PREPARE SUMMARY REPORT ===
            summaryReport.add(
                acc.Name +
                ' | Revenue: ' + totalRevenue +
                ' | Avg Deal: ' + avgDealSize +
                ' | Win Rate: ' + winRate + '%' +
                ' | Avg Resolution: ' + avgResolution + ' days' +
                ' | Satisfaction: ' + avgSatisfaction
            );
        }

        // Bulk update Accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    // STEP 3: Send Summary Email to Finance Team
    public void finish(Database.BatchableContext bc) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'finance_team@company.com' });
        email.setSubject('Account Rollup Data Processing Completed');
        email.setPlainTextBody(
            'Hi Finance Team,' + '\n\n' +
            'The account rollup data processing has completed successfully.' + '\n\n' +
            'Summary:\n' + String.join(summaryReport, '\n') +
            '\n\nRegards,\nSalesforce System'
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}