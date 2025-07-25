@isTest
private class ProjectControllerTest {
    @isTest
    static void testGetPicklistDependencies() {
        Test.startTest();
        Map<String, Object> result = ProjectController.getPicklistDependencies();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey('bodies'));
        System.assert(result.containsKey('frameworks'));
    }

    @isTest
    static void testSearchFrameworks() {
        Framework__c fw = new Framework__c(Name = 'Searchable Framework');
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
        ProjectController.createProjectWithFramework('Body A', 'Framework A', 'Focus A', 'Description A', fw.Id);
        Test.stopTest();

        // Assert job was enqueued (indirectly)
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }
}
