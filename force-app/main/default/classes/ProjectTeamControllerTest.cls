@isTest
private class ProjectTeamControllerTest {

    private class TestSetupResult {
        Framework__c framework;
        Project__c project;
        Id userId;
    }

    private static TestSetupResult setupTestData() {
        TestSetupResult result = new TestSetupResult();
        result.userId = UserInfo.getUserId();
        String uniqueSuffix = TestDataFactory.returnUniqueSuffixForExternalId();

        result.framework = new Framework__c(
            Name = 'Test Framework ' + uniqueSuffix,
            Description__c = 'Desc',
            URL__c = 'http://example.com',
            Version__c = '1.0',
            External_Id__c = 'FW-' + uniqueSuffix
        );
        insert result.framework;

        result.project = new Project__c(
            Name = 'Test Project Record',
            Standards_Alignment_Body__c = 'ISO ',
            Standards_Alignment_Framework__c = 'ISO 27001',
            Project_Focus__c = 'Compliance',
            Description__c = 'Test Project Description',
            Framework__c = result.framework.Id
        );
        insert result.project;

        return result;
    }

    @isTest
    static void testGetTeamMembers() {
        TestSetupResult data = setupTestData();

        Project_Team__c teamMember = new Project_Team__c(
            Project__c = data.project.Id,
            User__c = data.userId,
            Role__c = 'Compliance Lead'
        );
        insert teamMember;

        Test.startTest();
        List<Project_Team__c> results = ProjectTeamController.getTeamMembers(data.project.Id);
        Test.stopTest();

        System.assertNotEquals(0, results.size(), 'Expected at least one team member');
        System.assertEquals(data.userId, results[0].User__c, 'User ID should match');
    }

    @isTest
    static void testAddTeamMember() {
        TestSetupResult data = setupTestData();

        Test.startTest();
        Project_Team__c newMember = ProjectTeamController.addTeamMember(data.project.Id, data.userId, 'Compliance Lead');
        Test.stopTest();

        System.assertNotEquals(null, newMember, 'Returned team member should not be null');
        System.assertEquals(data.project.Id, newMember.Project__c, 'Project ID should match');
        System.assertEquals(data.userId, newMember.User__c, 'User ID should match');
        System.assertEquals('Compliance Lead', newMember.Role__c, 'Role should match');
    }
}
