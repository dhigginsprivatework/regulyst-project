@IsTest
private class ProjectTreeControllerTest {

    @IsTest
    static void testGetFrameworkTree() {
        // Setup test data using factory and constants
        Framework__c fw = TestDataFactory.createFrameworkWithChildren();
        Project__c project = TestDataFactory.createTestProjectRecord(fw);
        Project_Framework__c pf = TestDataFactory.createTestProjectFrameworkRecord(project, fw);

        Project_Clause_Control_Domain__c domain = new Project_Clause_Control_Domain__c(
            Name = 'Domain A',
            Clause_Number__c = '4.1',
            Description__c = 'Context of the organization',
            Project_Framework__c = pf.Id,
            Sequence__c = 1
        );
        insert domain;

        Project_Control__c control = new Project_Control__c(
            Name = 'Control A',
            Control_Number__c = 'A.5.1',
            Description__c = 'Information security policies',
            Title__c = 'Policy Control',
            Clause_Control_Domain__c = domain.Id,
            Project_Framework__c = pf.Id
        );
        insert control;

        Project_Control_Requirement__c requirement = new Project_Control_Requirement__c(
            Name = 'Requirement A',
            Description__c = 'Define and review policies',
            Source__c = ProjectConstants.PROJECT_STANDARDS_ALIGNMENT_FRAMEWORK_TEST_NAME_ISO,
            Framework__c = pf.Id,
            Project_Control__c = control.Id
        );
        insert requirement;

        Test.startTest();
        List<TreeNode> tree = ProjectTreeController.getFrameworkTree(project.Id);
        Test.stopTest();

        System.assertEquals(1, tree.size(), 'Should have one framework node');
        System.assertEquals(pf.Name, tree[0].label, 'Framework label should match');
        System.assertEquals(1, tree[0].children.size(), 'Should have one domain child');
        System.assertEquals(domain.Name, tree[0].children[0].label, 'Domain label should match');
        System.assertEquals(1, tree[0].children[0].children.size(), 'Should have one control child');
        System.assertEquals(control.Name, tree[0].children[0].children[0].label, 'Control label should match');
        System.assertEquals(1, tree[0].children[0].children[0].children.size(), 'Should have one requirement child');
        System.assertEquals(requirement.Name, tree[0].children[0].children[0].children[0].label, 'Requirement label should match');
    }
}
