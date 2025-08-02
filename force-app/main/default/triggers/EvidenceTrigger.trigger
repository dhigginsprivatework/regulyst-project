trigger EvidenceTrigger on Evidence__c (after insert) {
    new EvidenceTriggerHandler().run();
}
