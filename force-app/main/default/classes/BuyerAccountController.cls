public with sharing class BuyerAccountController {
    @AuraEnabled(cacheable=true)
    public static Account getCurrentBuyerAccount() {
        User currentUser = [
            SELECT Id, ContactId, AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        if (currentUser.AccountId == null) {
            throw new AuraHandledException('No Account linked to this Partner User.');
        }
        
        Account acc = [
            SELECT Id, Name, Phone, Budget_Range__c, Status__c
            FROM Account
            WHERE Id = :currentUser.AccountId
            LIMIT 1
        ];
        
        return acc;
    }
    @AuraEnabled(cacheable=false)
    public static void updateBuyerAccount(Account updatedAcc) {
        try {
            // Run in system mode
            Account accToUpdate = [SELECT Id, Name, Phone, Budget_Range__c, Status__c 
                                   FROM Account 
                                   WHERE Id = :updatedAcc.Id 
                                   LIMIT 1];

            accToUpdate.Name = updatedAcc.Name;
            accToUpdate.Phone = updatedAcc.Phone;
            accToUpdate.Budget_Range__c = updatedAcc.Budget_Range__c;
            accToUpdate.Status__c = updatedAcc.Status__c;

            update accToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)			
    public static List<Map<String, String>> getPicklistValues(String objectApiName, String fieldApiName) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        try {
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectApiName);
            if (sobjectType == null) {
                throw new AuraHandledException('Invalid object name: ' + objectApiName);
            }
            
            Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
            if (!fieldMap.containsKey(fieldApiName)) {
                throw new AuraHandledException('Invalid field name: ' + fieldApiName);
            }
            
            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldApiName).getDescribe();
            
            for (Schema.PicklistEntry pe : fieldResult.getPicklistValues()) {
                options.add(new Map<String, String>{
                    'label' => pe.getLabel(),
                        'value' => pe.getValue()
                        });
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving picklist values: ' + e.getMessage());
        }
        return options;
    }
    @AuraEnabled(cacheable=true)
    public static List<Property_Image__c> getPropertyImages(Id propertyId) {
        if (propertyId == null) return new List<Property_Image__c>();
        return [
            SELECT Id, Name, Image_Url__c
            FROM Property_Image__c
            WHERE Property__c = :propertyId
            ORDER BY CreatedDate DESC
            
        ];
    }
}
