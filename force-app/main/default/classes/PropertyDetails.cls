public class PropertyDetails {
    @AuraEnabled(cacheable=true)
    public static List<Property__c> getPropertyWithImages() {
        return [
            SELECT Id, Name, Property_Status__c, Listing_Price__c, Location__c,
            Property_Type__c, Bedrooms__c, Bathrooms__c, Square_Footage__c,
            (SELECT Id, Image_Url__c FROM Property_Images__r)
            FROM Property__c
            // you may add filters, ordering, limits, etc
        ];    }
}