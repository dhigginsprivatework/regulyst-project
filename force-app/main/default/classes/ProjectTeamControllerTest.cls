@IsTest
private class ProjectTeamControllerTest {

    private class TestSetupResult {
        Framework__c framework;
        Project__c project;
        Id userId;
    }

    private static TestSetupResult setupTestData() {
        TestSetupResult result = new TestSetupResult();
        result.userId = UserInfo.getUserId();
        result.framework = TestDataFactory.createFrameworkWithChildren();
        result.project = TestDataFactory.createTestProjectRecord(result.framework);
        return result;
    }

    @IsTest
    static void testGetTeamMembers() {
        TestSetupResult data = setupTestData();
        Project_Team__c teamMember = new Project_Team__c(
            Project__c = data.project.Id,
            User__c = data.userId,
            Role__c = ProjectConstants.PROJECT_TEAM_TEST_ROLE_VALUE
        );
        insert teamMember;
        Test.startTest();
        List<Project_Team__c> results = ProjectTeamController.getTeamMembers(data.project.Id);
        Test.stopTest();
        System.assertNotEquals(0, results.size(), 'Expected at least one team member');
        System.assertEquals(data.userId, results[0].User__c, 'User ID should match');
    }

    @IsTest
    static void testAddTeamMember() {
        TestSetupResult data = setupTestData();
        Test.startTest();
        Project_Team__c newMember = ProjectTeamController.addTeamMember(
            data.project.Id,
            data.userId,
            ProjectConstants.PROJECT_TEAM_TEST_ROLE_VALUE
        );
        Test.stopTest();
        System.assertNotEquals(null, newMember, 'Returned team member should not be null');
        System.assertEquals(data.project.Id, newMember.Project__c, 'Project ID should match');
        System.assertEquals(data.userId, newMember.User__c, 'User ID should match');
        System.assertEquals(ProjectConstants.PROJECT_TEAM_TEST_ROLE_VALUE, newMember.Role__c, 'Role should match');
    }

    @IsTest
    static void testDeleteTeamMember() {
        TestSetupResult data = setupTestData();
        Project_Team__c teamMember = new Project_Team__c(
            Project__c = data.project.Id,
            User__c = data.userId,
            Role__c = ProjectConstants.PROJECT_TEAM_TEST_ROLE_VALUE
        );
        insert teamMember;
        Test.startTest();
        ProjectTeamController.deleteTeamMember(teamMember.Id);
        Test.stopTest();
        Boolean isDeleted = true;
        try {
            Project_Team__c check = [SELECT Id FROM Project_Team__c WHERE Id = :teamMember.Id];
            isDeleted = false;
        } catch (Exception e) {
            isDeleted = true;
        }
        System.assertEquals(true, isDeleted, 'Team member should be deleted');
    }

    @IsTest
    static void testUpdateTeamMember() {
        TestSetupResult data = setupTestData();
        Project_Team__c teamMember = new Project_Team__c(
            Project__c = data.project.Id,
            User__c = data.userId,
            Role__c = ProjectConstants.PROJECT_TEAM_TEST_ROLE_VALUE
        );
        insert teamMember;
        String newRole = ProjectConstants.PROJECT_TEAM_TEST_ROLE_VALUE_UPDATED;
        Test.startTest();
        ProjectTeamController.updateTeamMember(teamMember.Id, data.userId, newRole);
        Test.stopTest();
        Project_Team__c updated = [SELECT Id, Role__c FROM Project_Team__c WHERE Id = :teamMember.Id];
        System.assertEquals(newRole, updated.Role__c, 'Role should be updated');
    }
}
