public class SalesRecordTriggerHandler {

    public static void updateUserTeamTotals(List<Sales_Record__c> salesRecord){
        if(salesRecord.isEmpty()) return;

        // Step 1: Get affected User Ids via Territory Owner
        Set<Id> userIds = new Set<Id>();
		List<Sales_Record__c> salesRecords = [
    SELECT Id,
           Amount__c,
           Contact__c,
           Contact__r.AccountId,
           Contact__r.Account.Territory_Master__c,
           Contact__r.Account.Territory_Master__r.OwnerId
    FROM Sales_Record__c
    WHERE Id IN :trigger.new
];
        for(Sales_Record__c sr : salesRecords){
            system.debug('Contact__c => ' + sr.Contact__c);
system.debug('Contact.Account => ' + ( sr.Contact__r.AccountId));
system.debug('Territory_Master__c => ' + (sr.Contact__r.Account.Territory_Master__c));
            if(sr.Contact__c != null && sr.Contact__r.Account != null && 
               sr.Contact__r.Account.Territory_Master__c != null &&
               sr.Contact__r.Account.Territory_Master__r.OwnerId!= null){
                userIds.add(sr.Contact__r.Account.Territory_Master__r.OwnerId);
                    system.debug('sr.Contact__r.Account.Territory_Master__c' +sr.Contact__r.Account.Territory_Master__c);
            }
        }
       
        system.debug('userIds'+userIds);
        if(userIds.isEmpty()) return;

        // Step 2: Query total sales per User
        Map<Id, Decimal> userSalesTotals = new Map<Id, Decimal>();

        for(AggregateResult ar : [
            SELECT Contact__r.Account.Territory_Master__r.OwnerId userId,
                   SUM(Amount__c) totalSales
            FROM Sales_Record__c
            WHERE Contact__r.Account.Territory_Master__r.OwnerId IN :userIds
            GROUP BY Contact__r.Account.Territory_Master__r.OwnerId
        ]){
            userSalesTotals.put((Id)ar.get('userId'), (Decimal)ar.get('totalSales'));
        }

        // Step 3: Prepare User updates
        List<User> usersToUpdate = new List<User>();

        for(Id userId : userIds){
            Decimal total = userSalesTotals.containsKey(userId) ? userSalesTotals.get(userId) : 0;
            usersToUpdate.add(new User(
                Id = userId,
                Team_Sales_Total__c = total
            ));
            system.debug('usersToUpdate'+usersToUpdate);
        }

        // Step 4: Update Users
        if(!usersToUpdate.isEmpty()){
            update usersToUpdate;
        }
    }
}