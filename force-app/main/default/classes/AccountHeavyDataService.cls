public class AccountHeavyDataService {

    @future(callout=true)
    public static void processAccounts(List<Id> accountIds) {
        List<Account> accountsToUpdate = new List<Account>();

        for(Account acc : [SELECT Id, Name,
                                  (SELECT Amount, StageName FROM Opportunities),
                                  (SELECT Status, ClosedDate, CreatedDate, Satisfaction__c FROM Cases)
                           FROM Account
                           WHERE Id IN :accountIds]) {

            Decimal totalRevenue = 0;
            Decimal averageDealSize = 0;
            Decimal winRate = 0;
            Decimal closedWonCount = 0;
            Decimal totalOppCount = 0;
            Decimal avgCaseResolution = 0;
            Decimal custSatisfaction = 0;
            Decimal closedCaseCount = 0;

            // Opportunities Calculations
            for(Opportunity opp : acc.Opportunities){
                totalOppCount += 1;
                if(opp.StageName == 'Closed Won'){
                    totalRevenue += (opp.Amount != null ? opp.Amount : 0);
                    closedWonCount += 1;
                }
            }
            if(closedWonCount > 0){
                averageDealSize = totalRevenue / closedWonCount;
            }
            if(totalOppCount > 0){
                winRate = (closedWonCount / totalOppCount) * 100;
            }

            // Cases Calculations
            for(Case c : acc.Cases){
                if(c.Status == 'Closed' && c.ClosedDate != null && c.CreatedDate != null){
                    Decimal daysToResolve = c.ClosedDate.getTime() - c.CreatedDate.getTime();
                    // Convert milliseconds to days
                    avgCaseResolution += daysToResolve / (1000*60*60*24);
                    closedCaseCount += 1;

                    if(c.Satisfaction__c != null){
                        custSatisfaction += c.Satisfaction__c;
                    }
                }
            }

            if(closedCaseCount > 0){
                avgCaseResolution = avgCaseResolution / closedCaseCount;
                custSatisfaction = custSatisfaction / closedCaseCount;
            }

            // Set calculated values to Account
            acc.Total_Revenue__c = totalRevenue;
            acc.Average_Deal_Size__c = averageDealSize;
            acc.Win_Rate__c = winRate;
            acc.Average_Case_Resolution__c = avgCaseResolution;
            acc.Customer_Satisfaction__c = custSatisfaction;

            accountsToUpdate.add(acc);
        }

        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }

        // Send summary email to finance team
        sendSummaryEmail(accountsToUpdate);
    }

    private static void sendSummaryEmail(List<Account> accounts){
        String subject = 'Account Heavy Data Processing Completed';
        String body = 'The heavy calculations for the following accounts have been completed:\n\n';
        for(Account a : accounts){
            body += 'Account: ' + a.Name + ', Total Revenue: ' + a.Total_Revenue__c + '\n';
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'finance@example.com'}); // replace with actual email
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}