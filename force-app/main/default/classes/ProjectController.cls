public with sharing class ProjectController {
    @AuraEnabled(cacheable=true)
    public static List<Framework__c> searchFrameworks(String searchKey) {
        return [
            SELECT Id, Name, Description__c
            FROM Framework__c
            WHERE Name LIKE :('%' + searchKey + '%')
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static Id createProjectWithFramework(
        String body,
        String framework,
        String focus,
        String description,
        Id frameworkId
    ) {
        Project__c project = new Project__c(
            Standards_Alignment_Body__c = body,
            Standards_Alignment_Framework__c = framework,
            Project_Focus__c = focus,
            Description__c = description,
            Framework__c = frameworkId
        );
        insert project;

        System.enqueueJob(new CreateProjectJob(body, framework, focus, description, frameworkId, project.Id));
        return project.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjectsByFramework(Id frameworkId) {
        return [
            SELECT Id, Name, Description__c
            FROM Project__c
            WHERE Framework__c = :frameworkId
            ORDER BY CreatedDate DESC
        ];
    }
}
