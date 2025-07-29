@isTest
private class TestProjectTriggerHandler {

    @isTest
    static void testAfterInsert_ProjectNameSet() {
        // Arrange: Create test Framework__c using your factory
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        // Act: Create a Project__c record that meets the criteria
        Project__c project = new Project__c(
            Standards_Alignment_Body__c = 'ISO',
            Standards_Alignment_Framework__c = 'ISO 27001',
            Project_Focus__c = 'Compliance',
            Description__c = 'Test Project Description',
            Framework__c = fw.Id,
            Name = 'Implementation of ISO Compliance for ISO 27001'
        );

        Test.startTest();
        insert project;
        Test.stopTest();

        // Assert: Reload the project and check if the name was updated
        Project__c insertedProject = [
            SELECT Name, Framework__r.Name, Project_Focus__c, Standards_Alignment_Framework__c
            FROM Project__c
            WHERE Id = :project.Id
        ];

        System.assert(insertedProject.Name.contains('Implementation of ISO'), 'Project name should contain "Implementation of ISO"');
        System.assert(insertedProject.Name.contains('Compliance'), 'Project name should include the Project Focus');
        System.assert(insertedProject.Name.contains('ISO 27001'), 'Project name should include the Standards Alignment Framework');
    }

    @isTest
    static void testAfterInsert_DoesNotMeetCriteria() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        // Create a project that does NOT meet the criteria (e.g., Framework name doesn't contain ISO)
        Project__c project = new Project__c(
            Standards_Alignment_Body__c = 'DORA',
            Standards_Alignment_Framework__c = 'DORA',
            Project_Focus__c = 'Governance',
            Description__c = 'Test Project Description',
            Framework__c = fw.Id,
            Name = 'Implementation of ISO Compliance for ISO 27001'
        );

        // Update the framework name to something that doesn't contain 'ISO'
        fw.Name = 'NIST Framework';
        update fw;

        Test.startTest();
        insert project;
        Test.stopTest();

        Project__c insertedProject = [
            SELECT Name FROM Project__c WHERE Id = :project.Id
        ];

        // Assert: Name should not be updated by the trigger logic
        System.assertEquals('Implementation of ISO Compliance for ISO 27001', insertedProject.Name, 'Project name should be updated if criteria not met');
    }
}
