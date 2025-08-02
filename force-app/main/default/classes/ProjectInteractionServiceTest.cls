@IsTest
private class ProjectInteractionServiceTest {
    @IsTest
    static void testEvidenceInteraction_AllPaths() {
        // Arrange
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw);
        Project_Framework__c pf = TestDataFactory.createTestProjectFrameworkRecord(project, fw);

        // Clause/Control Domain Path
        Project_Clause_Control_Domain__c clause = TestDataFactory.createTestProjectClauseControlDomain(pf);
        Evidence__c clauseEvidence = new Evidence__c(
            Clause_Control_Domain_project__c = clause.Id,
            Description__c = TestDataFactory.TEST_EVIDENCE_DESCRIPTION
        );

        // Control Path
        Project_Control__c control = new Project_Control__c(
            Name = ProjectConstants.PROJECT_CONTROL_TEST_NAME_ISO,
            Clause_Control_Domain__c = clause.Id,
            Project_Framework__c = pf.Id,
            Control_Number__c = 'CTRL-001',
            Description__c = 'Control Desc'
        );
        insert control;

        Evidence__c controlEvidence = new Evidence__c(
            Project_Control__c = control.Id,
            Description__c = TestDataFactory.TEST_EVIDENCE_DESCRIPTION
        );

        // Control Requirement Path
        Project_Control_Requirement__c requirement = new Project_Control_Requirement__c(
            Name = ProjectConstants.PROJECT_CONTROL_REQUIREMENT_TEST_NAME_ISO,
            Project_Control__c = control.Id,
            Description__c = 'Requirement Desc',
            Framework__c = pf.Id,
            Source__c = 'ISO 27001'
        );
        insert requirement;

        Evidence__c requirementEvidence = new Evidence__c(
            Project_Control_Requirement__c = requirement.Id,
            Description__c = TestDataFactory.TEST_EVIDENCE_DESCRIPTION
        );

        // Act
        Test.startTest();
        insert new List<Evidence__c>{ clauseEvidence, controlEvidence, requirementEvidence };
        Test.stopTest();

        // Assert
        List<Project_Interaction__c> interactions = [
            SELECT Type__c, Contributor__c, Project__c, Item_Interacted_With__c, Item_Interacted_With_Name__c
            FROM Project_Interaction__c
            WHERE Project__c = :project.Id
        ];

        System.assertEquals(3, interactions.size(), 'Should have 3 interaction records');

        Set<String> expectedTypes = new Set<String>{'Clause/Control Domain', 'Control', 'Control Requirement'};
        Set<String> actualTypes = new Set<String>();
        Set<String> actualNames = new Set<String>();

        for (Project_Interaction__c pi : interactions) {
            actualTypes.add(pi.Item_Interacted_With__c);
            actualNames.add(pi.Item_Interacted_With_Name__c);
            System.assertEquals(ProjectInteractionTypes.EVIDENCE_CONTRIBUTION, pi.Type__c, 'Type should be Evidence Contribution');
            System.assertEquals(UserInfo.getUserId(), pi.Contributor__c, 'Contributor should be current user');
        }

        System.assertEquals(expectedTypes, actualTypes, 'All interaction types should be captured');
        System.assert(actualNames.contains(clause.Name), 'Clause name should be captured');
        System.assert(actualNames.contains(control.Name), 'Control name should be captured');
        System.assert(actualNames.contains(requirement.Name), 'Requirement name should be captured');
    }
}
