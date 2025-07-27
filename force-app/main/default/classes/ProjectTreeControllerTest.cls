@isTest
private class ProjectTreeControllerTest {
    @isTest static void testGetFrameworkTree() {

        String uniqueSuffix = TestDataFactory.returnUniqueSuffixForExternalId();

        Framework__c fw = new Framework__c(
            Name = 'Test Framework ' + uniqueSuffix,
            Description__c = 'Desc',
            URL__c = 'http://example.com',
            Version__c = '1.0',
            External_Id__c = 'FW-' + uniqueSuffix
        );
        insert fw;

        Project__c project = new Project__c(Name='Test Project Record',
                                            Standards_Alignment_Body__c='ISO ',
                                            Standards_Alignment_Framework__c = 'ISO 27001',
                                            Project_Focus__c = 'Compliance',
                                            Description__c = 'Test Project Description',
                                            Framework__c = fw.Id); 
        insert project; 

        Project_Framework__c framework = new Project_Framework__c(Name='Framework A', Project__c = project.Id);
        insert framework;

        Project_Clause_Control_Domain__c domain = new Project_Clause_Control_Domain__c(
            Name='Domain A',
            Project_Framework__c=framework.Id
        );
        insert domain;

        Project_Control__c control = new Project_Control__c(
            Name='Control A',
            Clause_Control_Domain__c=domain.Id
        );
        insert control;

        Project_Control_Requirement__c requirement = new Project_Control_Requirement__c(
            Name='Requirement A',
            Project_Control__c=control.Id
        );
        insert requirement;

        Test.startTest();
        List<TreeNode> tree = ProjectTreeController.getFrameworkTree();
        Test.stopTest();

        System.assertEquals(1, tree.size());
        System.assertEquals('Framework A', tree[0].label);
        System.assertEquals(1, tree[0].children.size());
        System.assertEquals('Domain A', tree[0].children[0].label);
        System.assertEquals(1, tree[0].children[0].children.size());
        System.assertEquals('Control A', tree[0].children[0].children[0].label);
        System.assertEquals(1, tree[0].children[0].children[0].children.size());
        System.assertEquals('Requirement A', tree[0].children[0].children[0].children[0].label);
    }
}
