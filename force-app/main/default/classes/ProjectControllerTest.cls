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
        String unique = String.valueOf(Crypto.getRandomLong());
        Framework__c fw = new Framework__c(
            Name = 'Searchable Framework ' + unique,
            External_Id__c = 'FW-SEARCH-' + unique
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
        ProjectController.createProjectWithFramework('Body A', 'Framework A', 'Focus A', 'Description A', fw.Id);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }
}
