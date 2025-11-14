public class RevenueRecordTriggerHandler {
    public static void updateQuarterlyRevenue(List<Revenue_Record__c> newList, Map<Id, Revenue_Record__c> oldMap, Boolean isDelete) {
        Set<Id> accountIds = new Set<Id>();

        // Collect account Ids based on inserted/updated/deleted records
        if (!isDelete) {
            for (Revenue_Record__c rec : newList) {
                if (rec.Account__c != null) {
                    accountIds.add(rec.Account__c);
                }
            }
        }
        if (isDelete && oldMap != null) {
            for (Revenue_Record__c rec : oldMap.values()) {
                if (rec.Account__c != null) {
                    accountIds.add(rec.Account__c);
                }
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Aggregate quarterly revenue by Account
        Map<Id, Map<String, Decimal>> accountQuarterMap = new Map<Id, Map<String, Decimal>>();

        for (AggregateResult ar : [
            SELECT Account__c accId, Quarter__c qtr, SUM(Amount__c) total
            FROM Revenue_Record__c
            WHERE Account__c IN :accountIds
            GROUP BY Account__c, Quarter__c
        ]) {
            Id accId = (Id) ar.get('accId');
            String quarter = (String) ar.get('qtr');
            Decimal total = (Decimal) ar.get('total');

            if (!accountQuarterMap.containsKey(accId)) {
                accountQuarterMap.put(accId, new Map<String, Decimal>());
            }
            accountQuarterMap.get(accId).put(quarter, total);
        }

        // Update Accounts with correct quarterly values
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Account acc = new Account(Id = accId);
            Map<String, Decimal> quarterData = accountQuarterMap.containsKey(accId) ? accountQuarterMap.get(accId) : new Map<String, Decimal>();

            acc.Q1_Revenue__c = quarterData.containsKey('Q1') ? quarterData.get('Q1') : 0;
            acc.Q2_Revenue__c = quarterData.containsKey('Q2') ? quarterData.get('Q2') : 0;
            acc.Q3_Revenue__c = quarterData.containsKey('Q3') ? quarterData.get('Q3') : 0;
            acc.Q4_Revenue__c = quarterData.containsKey('Q4') ? quarterData.get('Q4') : 0;

            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}