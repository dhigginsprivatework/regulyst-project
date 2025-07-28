@isTest
private class CreateProjectJobTest {
    @isTest
    static void testExecuteCreatesAllRecords() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = new Project__c(
            Name = 'Test Project Record',
            Standards_Alignment_Body__c = 'ISO ',
            Standards_Alignment_Framework__c = 'ISO 27001',
            Project_Focus__c = 'Compliance',
            Description__c = 'Test Project Description',
            Framework__c = fw.Id
        );
        insert project;

        Test.startTest();
        CreateProjectJob job = new CreateProjectJob(
            'ISO', // Valid picklist value
            'ISO 27001',
            'Compliance',
            'Description A',
            fw.Id,
            project.Id
        );
        System.enqueueJob(job);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Project__c]);
        System.assertEquals(1, [SELECT COUNT() FROM Project_Framework__c]);
        System.assertEquals(2, [SELECT COUNT() FROM Project_Clause_Control_Domain__c]);
        System.assertEquals(4, [SELECT COUNT() FROM Project_Control__c]);
        System.assertEquals(4, [SELECT COUNT() FROM Project_Control_Requirement__c]);
        //String body, String framework, String focus, String description, Id frameworkId
    }
}
