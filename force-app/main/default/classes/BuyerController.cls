public with sharing class BuyerController {

    @AuraEnabled(cacheable=true)
    public static Account getBuyerRecord(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Account Id is required');
        }

        return [
            SELECT Id, Name, Phone, Email__c, Budget_Range__c, Status__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static void updateBuyer(Account updatedBuyer) {
        if (updatedBuyer == null) {
            throw new AuraHandledException('Buyer record cannot be null');
        }

        update updatedBuyer;
    }
    @AuraEnabled(cacheable=true)
public static List<Property_Image__c> getPropertyImages(Id propertyId) {
    if (propertyId == null) return new List<Property_Image__c>();
    return [
        SELECT Id, Name, Image_Url__c
        FROM Property_Image__c
        WHERE Property__c = :propertyId
        LIMIT 10
    ];
}

}