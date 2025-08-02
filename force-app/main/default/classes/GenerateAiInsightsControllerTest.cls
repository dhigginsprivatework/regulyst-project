@IsTest
private class GenerateAiInsightsControllerTest {

    @IsTest
    static void testGetPromptDetails() {
        // Create Framework
        String uniqueExternalId = TestDataFactory.returnUniqueSuffixForExternalId(); 
        Framework__c framework = new Framework__c(Name = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO, External_Id__c =uniqueExternalId);
        insert framework;

        // Create Project
        Project__c project = new Project__c(Name = 'Test Project', 
                                            Standards_Alignment_Body__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_BODY_TEST_NAME_ISO,
                                           	Standards_Alignment_Framework__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
                                            Framework__c = framework.Id,
                                            Project_Focus__c = ProjectConstants.PROJECT_FOCUS_TEST_VALUE_ISO);
        insert project;

        // Create Project_Framework
        Project_Framework__c projectFramework = new Project_Framework__c(
            Name = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
            Framework__c = framework.Id,
            Project__c = project.Id
        );
        
        insert projectFramework;

        // Create Project_Control
        Project_Control__c control = new Project_Control__c(
            Name = ProjectConstants.PROJECT_CONTROL_TEST_NAME_ISO,
            Project_Framework__c = projectFramework.Id
        );
        insert control;

        // Create Project_Control_Requirement
        Project_Control_Requirement__c requirement = new Project_Control_Requirement__c(
            Name = ProjectConstants.PROJECT_CONTROL_REQUIREMENT_TEST_NAME_ISO,
            Project_Control__c = control.Id,
            Framework__c = projectFramework.Id
        );
        insert requirement;

        // Create Evidence
        Evidence__c evidence = new Evidence__c(
            Project_Control_Requirement__c = requirement.Id
        );
        insert evidence;

        Test.startTest();
        String prompt = GenerateAiInsightsController.getPromptDetails(evidence.Id);
        Test.stopTest();

        System.assertNotEquals(null, prompt);
        System.assert(prompt.contains(ProjectConstants.PROJECT_CONTROL_REQUIREMENT_TEST_NAME_ISO));
        System.assert(prompt.contains(ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO));
    }

    @IsTest
    static void testUpdateAISummary() {
        Evidence__c evidence = new Evidence__c();
        insert evidence;

        String summaryText = ProjectConstants.AI_SUMMARY_TEXT_TEST_VALUE;

        Test.startTest();
        GenerateAiInsightsController.updateAISummary(evidence.Id, summaryText);
        Test.stopTest();

        Evidence__c updatedEvidence = [SELECT AI_Summary__c FROM Evidence__c WHERE Id = :evidence.Id];
        System.assertEquals(summaryText, updatedEvidence.AI_Summary__c);
    }
}
