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
            'ISO',         // Standards_Alignment_Body__c
            'ISO 27001',   // Standards_Alignment_Framework__c ✅ fixed
            'Compliance',
            'Description A',
            fw.Id,
            'Test Name'
        );
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable']);
    }
}
