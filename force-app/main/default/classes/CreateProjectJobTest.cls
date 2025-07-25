@isTest
private class CreateProjectJobTest {
    @isTest
    static void testExecuteCreatesAllRecords() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        Test.startTest();
        CreateProjectJob job = new CreateProjectJob('Body A', 'Framework A', 'Focus A', 'Description A', fw.Id);
        System.enqueueJob(job);
        Test.stopTest();

        // Validate Project__c
        List<Project__c> projects = [SELECT Id FROM Project__c];
        System.assertEquals(1, projects.size());

        // Validate Project_Framework__c
        List<Project_Framework__c> pfs = [SELECT Id FROM Project_Framework__c];
        System.assertEquals(1, pfs.size());

        // Validate Project_Clause_Control_Domain__c
        List<Project_Clause_Control_Domain__c> clauses = [SELECT Id FROM Project_Clause_Control_Domain__c];
        System.assertEquals(2, clauses.size());

        // Validate Project_Control__c
        List<Project_Control__c> controls = [SELECT Id FROM Project_Control__c];
        System.assertEquals(4, controls.size());

        // Validate Project_Control_Requirement__c
        List<Project_Control_Requirement__c> reqs = [SELECT Id FROM Project_Control_Requirement__c];
        System.assertEquals(4, reqs.size());
    }
}
