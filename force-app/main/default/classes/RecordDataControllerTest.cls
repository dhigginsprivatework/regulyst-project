@IsTest
private class RecordDataControllerTest {

    @IsTest
    static void testGetProjectWithFrameworks() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw);
        Project_Framework__c pf = TestDataFactory.createTestProjectFrameworkRecord(project, fw);

        Test.startTest();
        Project__c result = RecordDataController.getProjectWithFrameworks(project.Id);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Project should not be null');
        System.assertEquals(project.Id, result.Id, 'Returned project ID should match');
        System.assertNotEquals(null, result.Project_Frameworks__r, 'Related Project_Frameworks__r should not be null');
        System.assertEquals(1, result.Project_Frameworks__r.size(), 'Should return one related Project_Framework__c');
    }

    @IsTest
    static void testGetProjectFramework() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw);
        Project_Framework__c pf = TestDataFactory.createTestProjectFrameworkRecord(project, fw);

        Test.startTest();
        Project_Framework__c result = RecordDataController.getProjectFramework(pf.Id);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Project_Framework__c should not be null');
        System.assertEquals(pf.Id, result.Id, 'Returned Project_Framework__c ID should match');
        System.assertEquals(pf.Name, result.Name, 'Name should match');
    }
}
