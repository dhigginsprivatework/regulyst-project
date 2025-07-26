@isTest
private class ProjectTreeControllerTest {
    @isTest static void testGetFrameworkTree() {
        Project_Framework__c framework = new Project_Framework__c(Name='Framework A');
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
