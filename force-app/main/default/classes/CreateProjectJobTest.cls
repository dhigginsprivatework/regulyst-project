@isTest
private class CreateProjectJobTest {
    @isTest
    static void testExecuteCreatesAllRecords() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw); 

        Test.startTest();
        CreateProjectJob job = new CreateProjectJob(
            ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_ISO, 
            ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
            ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO,
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
    }
}
