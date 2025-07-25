@isTest
private class CreateProjectJobTest {
    @isTest
    static void testExecuteCreatesAllRecords() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        Test.startTest();
        CreateProjectJob job = new CreateProjectJob(
            'ISO', // Valid picklist value
            'ISO 27001:2022 Controls Mapping to Information Security Control Domains',
            'Compliance',
            'Description A',
            fw.Id
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
