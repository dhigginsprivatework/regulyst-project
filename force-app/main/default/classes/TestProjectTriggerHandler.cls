@IsTest
private class TestProjectTriggerHandler {

    @IsTest
    static void testAfterInsert_ProjectNameSet() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        Project__c project = new Project__c(
            Standards_Alignment_Body__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_ISO,
            Standards_Alignment_Framework__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
            Project_Focus__c = ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO,
            Description__c = 'Test Project Description',
            Framework__c = fw.Id,
            Name = 'Implementation of ISO Compliance for ISO 27001'
        );

        // Act
        Test.startTest();
        insert project;
        Test.stopTest();

        // Assert
        Project__c insertedProject = [
            SELECT Name, Framework__r.Name, Project_Focus__c, Standards_Alignment_Framework__c
            FROM Project__c
            WHERE Id = :project.Id
        ];

        System.assert(insertedProject.Name.contains('Implementation of ISO'), 'Project name should contain "Implementation of ISO"');
        System.assert(insertedProject.Name.contains(ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO), 'Project name should include the Project Focus');
        System.assert(insertedProject.Name.contains(ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO), 'Project name should include the Standards Alignment Framework');
    }

    @IsTest
    static void testAfterInsert_DoesNotMeetCriteria() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        // Update the framework name to something that doesn't contain 'ISO'
        fw.Name = 'NIST Framework';
        update fw;

        Project__c project = new Project__c(
            Standards_Alignment_Body__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_DORA,
            Standards_Alignment_Framework__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_DORA,
            Project_Focus__c = ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO,
            Description__c = 'Test Project Description',
            Framework__c = fw.Id,
            Name = 'Implementation of ISO Compliance for ISO 27001'
        );

        // Act
        Test.startTest();
        insert project;
        Test.stopTest();

        // Assert
        Project__c insertedProject = [
            SELECT Name FROM Project__c WHERE Id = :project.Id
        ];

        System.assertEquals('Implementation of ISO Compliance for ISO 27001', insertedProject.Name, 'Project name should remain unchanged if criteria not met');
    }
}
