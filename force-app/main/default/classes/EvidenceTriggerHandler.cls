public class EvidenceTriggerHandler extends TriggerHandler {
    override protected void afterInsert(List<SObject> newList) {
        if (TriggerRecursion.isFirstRun('EvidenceTrigger')) {
            ProjectInteractionService.logEvidenceContributions((List<Evidence__c>)newList);
        }
    }
}
