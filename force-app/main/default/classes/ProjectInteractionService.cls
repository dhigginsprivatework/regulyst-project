public class ProjectInteractionService {
    public static void logEvidenceContributions(List<Evidence__c> evidenceList) {
        Set<Id> clauseDomainIds = new Set<Id>();
        Set<Id> controlIds = new Set<Id>();
        Set<Id> requirementIds = new Set<Id>();

        for (Evidence__c ev : evidenceList) {
            if (ev.Clause_Control_Domain_project__c != null) clauseDomainIds.add(ev.Clause_Control_Domain_project__c);
            if (ev.Project_Control__c != null) controlIds.add(ev.Project_Control__c);
            if (ev.Project_Control_Requirement__c != null) requirementIds.add(ev.Project_Control_Requirement__c);
        }

        Map<Id, Project_Clause_Control_Domain__c> clauseDomainMap = new Map<Id, Project_Clause_Control_Domain__c>();
        Map<Id, Project_Control__c> controlMap = new Map<Id, Project_Control__c>();
        Map<Id, Project_Control_Requirement__c> requirementMap = new Map<Id, Project_Control_Requirement__c>();

        if (!clauseDomainIds.isEmpty()) {
            clauseDomainMap = new Map<Id, Project_Clause_Control_Domain__c>(
                [SELECT Id, Name, Project_Framework__r.Project__c FROM Project_Clause_Control_Domain__c WHERE Id IN :clauseDomainIds]
            );
        }

        if (!controlIds.isEmpty()) {
            controlMap = new Map<Id, Project_Control__c>(
                [SELECT Id, Name, Project_Framework__r.Project__c FROM Project_Control__c WHERE Id IN :controlIds]
            );
        }

        if (!requirementIds.isEmpty()) {
            requirementMap = new Map<Id, Project_Control_Requirement__c>(
                [SELECT Id, Name, Project_Control__r.Project_Framework__r.Project__c FROM Project_Control_Requirement__c WHERE Id IN :requirementIds]
            );
        }

        List<Project_Interaction__c> interactions = new List<Project_Interaction__c>();

        for (Evidence__c ev : evidenceList) {
            Id projectId;
            String itemType;
            String itemName;
            String itemRelatedObjectApiName; 

            if (ev.Project_Control_Requirement__c != null && requirementMap.containsKey(ev.Project_Control_Requirement__c)) {
                Project_Control_Requirement__c req = requirementMap.get(ev.Project_Control_Requirement__c);
                projectId = req.Project_Control__r.Project_Framework__r.Project__c;
                itemType = 'Control Requirement';
                itemName = req.Name;
                itemRelatedObjectApiName = 'Project_Control_Requirement__c'; 
            } else if (ev.Project_Control__c != null && controlMap.containsKey(ev.Project_Control__c)) {
                Project_Control__c ctrl = controlMap.get(ev.Project_Control__c);
                projectId = ctrl.Project_Framework__r.Project__c;
                itemType = 'Control';
                itemName = ctrl.Name;
                itemRelatedObjectApiName = 'Project_Control__c';
            } else if (ev.Clause_Control_Domain_project__c != null && clauseDomainMap.containsKey(ev.Clause_Control_Domain_project__c)) {
                Project_Clause_Control_Domain__c domain = clauseDomainMap.get(ev.Clause_Control_Domain_project__c);
                projectId = domain.Project_Framework__r.Project__c;
                itemType = 'Clause/Control Domain';
                itemName = domain.Name;
                itemRelatedObjectApiName = 'Project_Clause_Control_Domain__c';
            }

            if (projectId != null) {
                interactions.add(new Project_Interaction__c(
                    Type__c = ProjectInteractionTypes.EVIDENCE_CONTRIBUTION,
                    Contributor__c = ev.CreatedById,
                    Project__c = projectId,
                    Item_Interacted_With__c = itemType,
                    Item_Interacted_With_Name__c = itemName,
                    Item_Interacted_With_API_Name__c = itemRelatedObjectApiName
                ));
            }
        }

        if (!interactions.isEmpty()) {
            insert interactions;
        }
    }
}
