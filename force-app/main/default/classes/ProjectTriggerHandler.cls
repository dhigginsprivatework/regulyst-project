public class ProjectTriggerHandler extends TriggerHandler {
    override protected void afterInsert(List<SObject> newList) {
        ProjectTriggerService.setProjectname(newList); 
    }
}
