trigger ProjectTrigger on Project__c (
    before insert, before update, before delete,
    after insert, after update, after delete
) {
    new ProjectTriggerHandler().run();
}
