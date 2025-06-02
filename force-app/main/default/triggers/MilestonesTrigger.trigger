trigger MilestonesTrigger on Milestone__c (after insert, after update, before delete, after undelete) {
    Boolean afterInser = Trigger.isAfter && Trigger.isInsert;
    Boolean afterUpdate = Trigger.isAfter && Trigger.isUpdate;
    Boolean beforeDelete = Trigger.isBefore && Trigger.isDelete;
    Boolean afterUndelete = Trigger.isAfter && Trigger.isUndelete;

    if(afterInser){
        MilestonesTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
    if(afterUpdate){
        MilestonesTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
    if(beforeDelete){
        MilestonesTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
    if(afterUndelete){
        MilestonesTriggerHandler.calculatePercentToMilestone(Trigger.new, Trigger.oldMap);
    }
}