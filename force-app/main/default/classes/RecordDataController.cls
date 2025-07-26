public with sharing class RecordDataController {
    @AuraEnabled(cacheable=true)
    public static Project__c getProjectWithFrameworks(Id projectId) {
        return [
            SELECT Id, Name, Description__c, Framework__c, Framework__r.Name, Project_Focus__c, Standards_Alignment_Body__c,Standards_Alignment_Framework__c,
                (SELECT Id, Name, Description__c, URL__c, Version__c FROM Project_Frameworks__r)
            FROM Project__c
            WHERE Id = :projectId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Project_Framework__c getProjectFramework(Id pfId) {
        return [
            SELECT Id, Name, Description__c, URL__c, Version__c, Framework__c, Project__c
            FROM Project_Framework__c
            WHERE Id = :pfId
        ];
    }
}
