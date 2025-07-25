public with sharing class ProjectController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPicklistDependencies() {
        Map<String, Object> result = new Map<String, Object>();
        List<String> bodies = new List<String>();
        Map<String, List<String>> dependencies = new Map<String, List<String>>();

        Schema.DescribeFieldResult bodyField = Project__c.Standards_Alignment_Body__c.getDescribe();
        Schema.DescribeFieldResult frameworkField = Project__c.Standards_Alignment_Framework__c.getDescribe();

        for (Schema.PicklistEntry entry : bodyField.getPicklistValues()) {
            bodies.add(entry.getLabel());
            dependencies.put(entry.getLabel(), new List<String>());
        }
        result.put('bodies', bodies);
        result.put('frameworks', dependencies); 
        return result;
    }

    @AuraEnabled
    public static List<Framework__c> searchFrameworks(String searchKey) {
        return [
            SELECT Id, Name
            FROM Framework__c
            WHERE Name LIKE :('%' + searchKey + '%')
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static void createProjectWithFramework(
        String body,
        String framework,
        String focus,
        String description,
        Id frameworkId
    ) {
        System.enqueueJob(new CreateProjectJob(body, framework, focus, description, frameworkId));
    }
}
