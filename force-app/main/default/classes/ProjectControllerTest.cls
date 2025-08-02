@isTest
private class ProjectControllerTest {
    @isTest
    static void testSearchFrameworks() {
        String suffix = TestDataFactory.returnUniqueSuffixForExternalId();
        Framework__c fw = new Framework__c(
            Name = 'Searchable Framework ' + suffix,
            External_Id__c = 'FW-SEARCH-' + suffix
        );
        insert fw;

        Test.startTest();
        List<Framework__c> results = ProjectController.searchFrameworks('Searchable');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(fw.Id, results[0].Id);
    }

    @isTest
    static void testCreateProjectWithFramework() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        Test.startTest();
        ProjectController.createProjectWithFramework(
            ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_ISO,     
            ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,  
            ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO,
            'Description A',
            fw.Id
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }
}