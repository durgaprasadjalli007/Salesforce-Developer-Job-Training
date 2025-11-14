public class ProjectTriggerHandler {
    public static void updateEarliestProjectStart(Set<Id> clientIds) {
        // Map to store clientId -> earliest date
        Map<Id, Date> clientToEarliestDate = new Map<Id, Date>();

        // Query projects for these clients, excluding Cancelled
        List<Project__c> activeProjects = [
            SELECT Id, Client__c, Start_Date__c
            FROM Project__c
            WHERE Client__c IN :clientIds
            AND Status__c != 'Cancelled'
            AND Start_Date__c != NULL
            ORDER BY Start_Date__c ASC
        ];

        // Find earliest start date per client
        for (Project__c proj : activeProjects) {
            if (!clientToEarliestDate.containsKey(proj.Client__c)) {
                clientToEarliestDate.put(proj.Client__c, proj.Start_Date__c);
            }
        }

        // Prepare list of clients to update
        List<Client__c> clientsToUpdate = new List<Client__c>();
        for (Id clientId : clientIds) {
            Client__c client = new Client__c(Id = clientId);
            client.Earliest_Project_Start__c = clientToEarliestDate.containsKey(clientId)
                                              ? clientToEarliestDate.get(clientId)
                                              : null; // Clear if no active projects
            clientsToUpdate.add(client);
        }

        if (!clientsToUpdate.isEmpty()) {
            update clientsToUpdate;
        }
    }
}