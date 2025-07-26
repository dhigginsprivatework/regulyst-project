public class TreeNode {
    @AuraEnabled public Id id;
    @AuraEnabled public String label;
    @AuraEnabled public String sObjectType;
    @AuraEnabled public List<TreeNode> children = new List<TreeNode>();

    public TreeNode(Id id, String label, String sObjectType) {
        this.id = id;
        this.label = label;
        this.sObjectType = sObjectType;
    }
}
