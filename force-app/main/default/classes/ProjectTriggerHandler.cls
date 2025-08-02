public class ProjectTriggerHandler extends TriggerHandler {
    override protected void afterInsert(List<SObject> newList) {
        if (TriggerRecursion.isFirstRun('ProjectTrigger')) {
             ProjectTriggerService.setProjectname(newList);
        }

        //ProjectTriggerService.setProjectname(newList); 
    }
}
