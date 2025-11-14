public class OrderTriggerHandler {
    public static void updateTotalOrderValue(
        List<Order> newList,
        List<Order> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> accountIds = new Set<Id>();

        // Collect affected Account IDs from NEW records
        if (isInsert || isUpdate || isUndelete) {
            for (Order ord : newList) {
                if (ord.AccountId != null) {
                    accountIds.add(ord.AccountId);
                }
            }
        }

        // Collect affected Account IDs from OLD records (for deletes or account changes)
        if (isDelete || isUpdate) {
            for (Order ord : oldList) {
                if (ord.AccountId != null) {
                    accountIds.add(ord.AccountId);
                }
            }
        }

        // Exit early if no Accounts are impacted
        if (accountIds.isEmpty()) {
            return;
        }

        // Query sum of activated orders for affected accounts
        Map<Id, Decimal> orderSumMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId, SUM(TotalAmount) totalValue
            FROM Order
            WHERE AccountId IN :accountIds
            AND Status = 'Activated'
            GROUP BY AccountId
        ]) {
            orderSumMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalValue'));
        }

        // Prepare list of Accounts to update
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Decimal totalValue = orderSumMap.containsKey(accId) ? orderSumMap.get(accId) : 0;
            accountsToUpdate.add(new Account(
                Id = accId,
                Total_Order_Value__c = totalValue
            ));
        }

        // Bulk update Accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}