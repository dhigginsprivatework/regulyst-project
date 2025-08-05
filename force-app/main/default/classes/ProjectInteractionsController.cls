public with sharing class ProjectInteractionsController {
    @AuraEnabled(cacheable=true)
    public static List<Project_Interaction__c> getInteractions(Id projectId) {
        return [
            SELECT Id, Contributor__c, Contributor__r.Name, Item_Interacted_With__c, Item_Interacted_With_Name__c, Type__c, CreatedDate, Item_Interacted_With_API_Name__c, Item_Interacted_With_Record_Id__c
            FROM Project_Interaction__c
            WHERE Project__c = :projectId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [
            SELECT Id, Name FROM User WHERE IsActive = TRUE ORDER BY Name
        ];
    }
}