public with sharing class ProjectTreeController {
    @AuraEnabled(cacheable=true)
    public static List<TreeNode> getFrameworkTree() {
        List<Project_Framework__c> frameworks = [
            SELECT Id, Name FROM Project_Framework__c
        ];

        List<Project_Clause_Control_Domain__c> domains = [
            SELECT Id, Name, Project_Framework__c FROM Project_Clause_Control_Domain__c
        ];

        List<Project_Control__c> controls = [
            SELECT Id, Name, Clause_Control_Domain__c FROM Project_Control__c
        ];

        List<Project_Control_Requirement__c> requirements = [
            SELECT Id, Name, Project_Control__c FROM Project_Control_Requirement__c
        ];

        Map<Id, List<Project_Clause_Control_Domain__c>> frameworkToDomains = new Map<Id, List<Project_Clause_Control_Domain__c>>();
        for (Project_Clause_Control_Domain__c domain : domains) {
            if (!frameworkToDomains.containsKey(domain.Project_Framework__c)) {
                frameworkToDomains.put(domain.Project_Framework__c, new List<Project_Clause_Control_Domain__c>());
            }
            frameworkToDomains.get(domain.Project_Framework__c).add(domain);
        }

        Map<Id, List<Project_Control__c>> domainToControls = new Map<Id, List<Project_Control__c>>();
        for (Project_Control__c control : controls) {
            if (!domainToControls.containsKey(control.Clause_Control_Domain__c)) {
                domainToControls.put(control.Clause_Control_Domain__c, new List<Project_Control__c>());
            }
            domainToControls.get(control.Clause_Control_Domain__c).add(control);
        }

        Map<Id, List<Project_Control_Requirement__c>> controlToRequirements = new Map<Id, List<Project_Control_Requirement__c>>();
        for (Project_Control_Requirement__c req : requirements) {
            if (!controlToRequirements.containsKey(req.Project_Control__c)) {
                controlToRequirements.put(req.Project_Control__c, new List<Project_Control_Requirement__c>());
            }
            controlToRequirements.get(req.Project_Control__c).add(req);
        }

        List<TreeNode> tree = new List<TreeNode>();
        for (Project_Framework__c framework : frameworks) {
            TreeNode frameworkNode = new TreeNode(framework.Id, framework.Name, 'Project_Framework__c');

            List<Project_Clause_Control_Domain__c> domainList = frameworkToDomains.containsKey(framework.Id)
                ? frameworkToDomains.get(framework.Id)
                : new List<Project_Clause_Control_Domain__c>();

            for (Project_Clause_Control_Domain__c domain : domainList) {
                TreeNode domainNode = new TreeNode(domain.Id, domain.Name, 'Project_Clause_Control_Domain__c');

                List<Project_Control__c> controlList = domainToControls.containsKey(domain.Id)
                    ? domainToControls.get(domain.Id)
                    : new List<Project_Control__c>();

                for (Project_Control__c control : controlList) {
                    TreeNode controlNode = new TreeNode(control.Id, control.Name, 'Project_Control__c');

                    List<Project_Control_Requirement__c> reqList = controlToRequirements.containsKey(control.Id)
                        ? controlToRequirements.get(control.Id)
                        : new List<Project_Control_Requirement__c>();

                    for (Project_Control_Requirement__c req : reqList) {
                        TreeNode reqNode = new TreeNode(req.Id, req.Name, 'Project_Control_Requirement__c');
                        controlNode.children.add(reqNode);
                    }

                    domainNode.children.add(controlNode);
                }

                frameworkNode.children.add(domainNode);
            }

            tree.add(frameworkNode);
        }

        return tree;
    }
}
