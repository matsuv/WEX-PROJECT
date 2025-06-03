public with sharing class TodoTriggerHandler {
    
    public static void calculatePercentToMilestone(List<To_do__c> listNewTodos, Map<Id,To_do__c> oldMap){
        Set<Id> setIdMilestons = new Set<Id>();
        Set<Id> setIdDisconsider = new Set<Id>();

        if(Trigger.isDelete){
            for(To_do__c todo : oldMap.values()){
                setIdMilestons.add(todo.Milestone__c);
                setIdDisconsider.add(todo.id);
            }
        }
        else{
            for(To_do__c todo : listNewTodos){
                if(Trigger.isUpdate){
                    if(todo.status__c != oldMap.get(todo.Id).status__c){
                        setIdMilestons.add(todo.Milestone__c);
                    }
                }
                else{
                    setIdMilestons.add(todo.Milestone__c);
                }
            }
        }

        if(setIdMilestons.size() > 0){
            Map<Id,Milestone__c> mapMilestonesUpp = new Map<Id,Milestone__c>();
            Milestone__c milestoneInstance;
            Boolean hasAnyCompleteItem,anyoneStarted,notInitiated;

            for(Milestone__c milestone : [SELECT Id, Status__c, (SELECT Id, Status__c FROM To_do__r WHERE Id NOT IN :setIdDisconsider) FROM Milestone__c WHERE Id IN :setIdMilestons WITH SECURITY_ENFORCED]){
                hasAnyCompleteItem = false;
                anyoneStarted = false;
                notInitiated = false;
                
                milestoneInstance = new Milestone__c();
                milestoneInstance.id = milestone.id;

                for(To_do__c item : milestone.To_do__r){
                    if(item.Status__c == 'Complete') hasAnyCompleteItem = true;
                    else if(item.Status__c == 'In Progress') anyoneStarted = true;
                    else notInitiated = true;
                }

                milestoneInstance.Status__c = hasAnyCompleteItem && !anyoneStarted && !notInitiated ? 'Complete' : (anyoneStarted || hasAnyCompleteItem) ? 'In Progress' : 'Not Started';
                
                if(milestone.Status__c != milestoneInstance.Status__c) mapMilestonesUpp.put(milestoneInstance.id, milestoneInstance);
            }
            
            UPDATE  mapMilestonesUpp.values();
        }
    }
}