public abstract class TriggerHandler {
    public void run() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) beforeInsert((List<SObject>) Trigger.new);
            else if (Trigger.isUpdate) beforeUpdate((List<SObject>) Trigger.new, (Map<Id, SObject>) Trigger.oldMap);
            else if (Trigger.isDelete) beforeDelete((List<SObject>) Trigger.old);
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) afterInsert((List<SObject>) Trigger.new);
            else if (Trigger.isUpdate) afterUpdate((List<SObject>) Trigger.new, (Map<Id, SObject>) Trigger.oldMap);
            else if (Trigger.isDelete) afterDelete((List<SObject>) Trigger.old);
        }
    }

    protected virtual void beforeInsert(List<SObject> newList) {}
    protected virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    protected virtual void beforeDelete(List<SObject> oldList) {}
    protected virtual void afterInsert(List<SObject> newList) {}
    protected virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    protected virtual void afterDelete(List<SObject> oldList) {}
}
