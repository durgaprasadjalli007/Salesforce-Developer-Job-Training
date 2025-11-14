public class UpdateAccountContactCountQueueable implements Queueable {

    private Set<Id> accountIds;

    public UpdateAccountContactCountQueueable(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }

    public void execute(QueueableContext context) {

        // Aggregate contacts count for affected accounts
        Map<Id, Integer> accountToContactCount = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) cnt
            FROM Contact
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountToContactCount.put((Id) ar.get('accId'), (Integer) ar.get('cnt'));
        }

        // Prepare Account updates
        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIds) {
            Integer contactCount = accountToContactCount.containsKey(accId) 
                ? accountToContactCount.get(accId) 
                : 0;

            accountsToUpdate.add(new Account(
                Id = accId,
                NumberOfEmployees = contactCount
            ));
        }

        // Update Accounts in bulk
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}