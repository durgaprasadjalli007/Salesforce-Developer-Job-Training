public class ProductReviewTriggerHandler {
    public static void updateAverageProductRating(
        List<Product_Review__c> newList,
        List<Product_Review__c> oldList,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete,
        Boolean isUndelete
    ) {
        Set<Id> productIds = new Set<Id>();

        // Collect affected Product IDs from NEW records
        if (isInsert || isUpdate || isUndelete) {
            for (Product_Review__c review : newList) {
                if (review.Product__c != null) {
                    productIds.add(review.Product__c);
                }
            }
        }

        // Collect affected Product IDs from OLD records (for deletes or product changes)
        if (isDelete || isUpdate) {
            for (Product_Review__c review : oldList) {
                if (review.Product__c != null) {
                    productIds.add(review.Product__c);
                }
            }
        }

        // Exit early if no products impacted
        if (productIds.isEmpty()) {
            return;
        }

        // Query SUM & COUNT of Approved Reviews per Product
        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();
        Map<Id, Decimal> countMap = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT Product__c, SUM(Rating__c) totalRating, COUNT(Id) ratingCount
            FROM Product_Review__c
            WHERE Product__c IN :productIds
            AND Status__c = 'Approved'
            GROUP BY Product__c
        ]) {
            sumMap.put((Id)ar.get('Product__c'), (Decimal)ar.get('totalRating'));
            countMap.put((Id)ar.get('Product__c'), (Decimal)ar.get('ratingCount'));
        }

        // Prepare list of Products to update
        List<Product__c> productsToUpdate = new List<Product__c>();

        for (Id prodId : productIds) {
            Decimal total = sumMap.containsKey(prodId) ? sumMap.get(prodId) : 0;
            Decimal cnt = countMap.containsKey(prodId) ? countMap.get(prodId) : 0;
            Decimal avg = (cnt > 0) ? total / cnt : 0;

            productsToUpdate.add(new Product__c(
                Id = prodId,
                Average_Rating__c = avg
            ));
        }

        // Bulk update Products
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
}