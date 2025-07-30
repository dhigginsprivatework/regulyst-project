public with sharing class ProjectAnalyticsController {
    @AuraEnabled(cacheable=true)
    public static Project_Analytics__c getAnalytics(Id projectId) {
        Project__c project = [
            SELECT Id, Standards_Alignment_Body__c, Standards_Alignment_Framework__c 
            FROM Project__c 
            WHERE Id = :projectId 
            LIMIT 1
        ];

        if (project.Standards_Alignment_Body__c != 'ISO' || 
            project.Standards_Alignment_Framework__c != 'ISO 27001') {
            return null;
        }

        Id projectFrameworkId = [
            SELECT Id 
            FROM Project_Framework__c 
            WHERE Project__c = :projectId 
            LIMIT 1
        ].Id;

        Integer totalClauses = [
            SELECT COUNT() 
            FROM Project_Clause_Control_Domain__c 
            WHERE Project_Framework__c = :projectFrameworkId
        ];

        Integer totalControls = [
            SELECT COUNT() 
            FROM Project_Control__c 
            WHERE Project_Framework__c = :projectFrameworkId
        ];

        Integer totalRequirements = [
            SELECT COUNT() 
            FROM Project_Control_Requirement__c 
            WHERE Framework__c = :projectFrameworkId
        ];

        Integer withEvidence = [
            SELECT COUNT() 
            FROM Evidence__c 
            WHERE Project_Control_Requirement__c != null
        ];

        Integer approved = [
            SELECT COUNT() 
            FROM Evidence__c 
            WHERE Project_Control_Requirement__c != null AND Approved__c = TRUE
        ];

        Project_Analytics__c analytics = new Project_Analytics__c(
            Total_Clauses__c = totalClauses,
            Total_Controls__c = totalControls,
            Total_Control_Requirements__c = totalRequirements,
            Control_Requirements_With_Evidence__c = withEvidence,
            Approved_Control_Requirements__c = approved,
            Project__c = projectId,
            Last_Updated__c = System.now(),
            Total_Evidence_Collected__c = withEvidence/totalRequirements
        );

        return analytics;
    }
}
