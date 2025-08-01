public with sharing class GenerateAiInsightsController {
    @AuraEnabled(cacheable=true)
    public static String getPromptDetails(Id evidenceId) {
        Evidence__c evidence = [
            SELECT Id, Project_Control_Requirement__r.Name, Project_Control_Requirement__r.Framework__r.Name
            FROM Evidence__c
            WHERE Id = :evidenceId
            LIMIT 1
        ];

        String requirement = evidence.Project_Control_Requirement__r.Name;
        String framework = evidence.Project_Control_Requirement__r.Framework__r.Name;

        return 'Based on the attached document, does it provide sufficient evidence to fulfill the control requirement "' +
               requirement + '" under the "' + framework + '" framework? Please summarize your reasoning.';
    }

    @AuraEnabled
    public static void updateAISummary(Id evidenceId, String summaryText) {
        Evidence__c evidence = new Evidence__c(Id = evidenceId, AI_Summary__c = summaryText);
        update evidence;
    }
}