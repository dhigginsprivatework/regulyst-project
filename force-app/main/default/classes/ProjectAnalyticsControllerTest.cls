@isTest
private class ProjectAnalyticsControllerTest {
    @isTest
    static void testGetAnalytics_ISO27001() {
        // Create Framework and children using your factory
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();

        // Create Project aligned to ISO 27001
        Project__c project = new Project__c(
            Name = 'Test Project Record',
            Standards_Alignment_Body__c = 'ISO',
            Standards_Alignment_Framework__c = 'ISO 27001',
            Project_Focus__c = 'Compliance',
            Description__c = 'Test Project Description',
            Framework__c = fw.Id
        );
        insert project;

        // Create Project_Framework__c
        Project_Framework__c pf = new Project_Framework__c(
            Name = 'Test PF',
            Framework__c = fw.Id,
            Project__c = project.Id
        );
        insert pf;

        // Create Project_Clause_Control_Domain__c
        Project_Clause_Control_Domain__c clause = new Project_Clause_Control_Domain__c(
            Name = 'Clause 1',
            Clause_Number__c = '4.1',
            Description__c = 'Context of the organization',
            Project_Framework__c = pf.Id,
            Sequence__c = 1
        );
        insert clause;

        // Create Project_Control__c
        Project_Control__c control = new Project_Control__c(
            Name = 'Control 1',
            Control_Number__c = 'A.5.1',
            Description__c = 'Information security policies',
            Title__c = 'Policy Control',
            Clause_Control_Domain__c = clause.Id,
            Project_Framework__c = pf.Id
        );
        insert control;

        // Create Project_Control_Requirement__c
        Project_Control_Requirement__c requirement = new Project_Control_Requirement__c(
            Name = 'Requirement 1',
            Description__c = 'Define and review policies',
            Source__c = 'ISO 27001',
            Framework__c = pf.Id,
            Project_Control__c = control.Id
        );
        insert requirement;

        // Create Evidence__c (1 approved, 1 not approved)
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

    @isTest
    static void testGetAnalytics_NonISOProject() {
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = new Project__c(
            Name = 'Non-ISO Project',
            Standards_Alignment_Body__c = 'DORA',
            Standards_Alignment_Framework__c = 'DORA',
            Project_Focus__c = 'Compliance',
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
