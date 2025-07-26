@isTest
private class RecordDataControllerTest {

    @isTest
    static void testGetProjectWithFrameworks() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        Project__c project = new Project__c(
            Name = 'Test Project',
            Description__c = 'Test Description',
            Framework__c = fw.Id,
            Project_Focus__c = 'Security',
            Standards_Alignment_Body__c = 'ISO'
        );
        insert project;

        Project_Framework__c pf = new Project_Framework__c(
            Name = 'PF 1',
            Description__c = 'PF Desc',
            URL__c = 'http://pf.com',
            Version__c = '1.0',
            Framework__c = fw.Id,
            Project__c = project.Id
        );
        insert pf;

        Test.startTest();
        Project__c result = RecordDataController.getProjectWithFrameworks(project.Id);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Project should not be null');
        System.assertEquals(project.Id, result.Id, 'Returned project ID should match');
        System.assertNotEquals(null, result.Project_Frameworks__r, 'Related Project_Frameworks__r should not be null');
        System.assertEquals(1, result.Project_Frameworks__r.size(), 'Should return one related Project_Framework__c');
    }

    @isTest
    static void testGetProjectFramework() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        Project__c project = new Project__c(
            Name = 'Test Project',
            Description__c = 'Test Description',
            Framework__c = fw.Id,
            Project_Focus__c = 'Security',
            Standards_Alignment_Body__c = 'ISO'
        );
        insert project;

        Project_Framework__c pf = new Project_Framework__c(
            Name = 'PF 1',
            Description__c = 'PF Desc',
            URL__c = 'http://pf.com',
            Version__c = '1.0',
            Framework__c = fw.Id,
            Project__c = project.Id
        );
        insert pf;

        Test.startTest();
        Project_Framework__c result = RecordDataController.getProjectFramework(pf.Id);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Project_Framework__c should not be null');
        System.assertEquals(pf.Id, result.Id, 'Returned Project_Framework__c ID should match');
        System.assertEquals('PF 1', result.Name, 'Name should match');
    }
}
