@IsTest
private class ProjectAnalyticsControllerTest {

    @IsTest
    static void testGetAnalytics_ISO27001() {
        // Setup test data using factory and constants
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw);
        Project_Framework__c pf = TestDataFactory.createTestProjectFrameworkRecord(project, fw);
        Project_Clause_Control_Domain__c clause = TestDataFactory.createTestProjectClauseControlDomain(pf);

        Project_Control__c control = new Project_Control__c(
            Name = ProjectConstants.PROJECT_CONTROL_TEST_NAME_ISO,
            Control_Number__c = 'A.5.1',
            Description__c = 'Information security policies',
            Title__c = 'Policy Control',
            Clause_Control_Domain__c = clause.Id,
            Project_Framework__c = pf.Id
        );
        insert control;

        Project_Control_Requirement__c requirement = new Project_Control_Requirement__c(
            Name = ProjectConstants.PROJECT_CONTROL_REQUIREMENT_TEST_NAME_ISO,
            Description__c = 'Define and review policies',
            Source__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
            Framework__c = pf.Id,
            Project_Control__c = control.Id
        );
        insert requirement;

        // Create Evidence records
        Evidence__c ev1 = new Evidence__c(
            Name = 'Evidence 1',
            Project_Control_Requirement__c = requirement.Id,
            Approved__c = true
        );
        Evidence__c ev2 = new Evidence__c(
            Name = 'Evidence 2',
            Project_Control_Requirement__c = requirement.Id,
            Approved__c = false
        );
        insert new List<Evidence__c>{ ev1, ev2 };

        Test.startTest();
        Project_Analytics__c result = ProjectAnalyticsController.getAnalytics(project.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Analytics should be returned');
        System.assertEquals(1, result.Total_Clauses__c);
        System.assertEquals(1, result.Total_Controls__c);
        System.assertEquals(1, result.Total_Control_Requirements__c);
        System.assertEquals(2, result.Control_Requirements_With_Evidence__c);
        System.assertEquals(1, result.Approved_Control_Requirements__c);
    }

    @IsTest
    static void testGetAnalytics_NonISOProject() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = new Project__c(
            Name = 'Non-ISO Project', 
            Standards_Alignment_Body__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_DORA,
            Standards_Alignment_Framework__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_DORA,
            Project_Focus__c = ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO,
            Description__c = 'Non-ISO Project',
            Framework__c = fw.Id
        );
        insert project;

        Test.startTest();
        Project_Analytics__c result = ProjectAnalyticsController.getAnalytics(project.Id);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for non-ISO projects');
    }
}
