public with sharing class ProjectTriggerService {
    public static void setProjectname(List<SObject> newList){
        List<Id> projectIds = new List<Id>();
        for (SObject s : newList) {
            projectIds.add(s.Id);
        }
        List<Project__c> projects = [
            SELECT Id, Framework__r.Name, Project_Focus__c, Standards_Alignment_Framework__c
            FROM Project__c
            WHERE Id IN :projectIds
        ];
        List<Project__c> updateList = new List<Project__c>();
        for (Project__c proj : projects) {
            if (!String.isBlank(proj.Framework__r.Name) && !String.isBlank(proj.Project_Focus__c) && !String.isBlank(proj.Standards_Alignment_Framework__c) &&
                proj.Framework__r.Name.contains('ISO')) {
                proj.Name = 'Implementation of ISO for ' + proj.Project_Focus__c + ' under the ' +proj.Standards_Alignment_Framework__c + ' framework';
                updateList.add(proj);
            }
        }
        if (!updateList.isEmpty()) {
            update updateList;
        }
    }
}
