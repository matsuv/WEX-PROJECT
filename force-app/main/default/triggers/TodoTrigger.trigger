trigger TodoTrigger on To_do__c (after insert, after update, before delete, after undelete) {
    Boolean afterInser = Trigger.isAfter && Trigger.isInsert;
    Boolean afterUpdate = Trigger.isAfter && Trigger.isUpdate;
    Boolean beforeDelete = Trigger.isBefore && Trigger.isDelete;
    Boolean afterUndelete = Trigger.isAfter && Trigger.isUndelete;

    if(afterInser){
        TodoTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
    if(afterUpdate){
        TodoTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
    if(beforeDelete){
        TodoTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
    if(afterUndelete){
        TodoTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
}