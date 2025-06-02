public with sharing class TodoTriggerHandler {
    
    public static void calculatePercentToMilestone(List<To_do__c> listNewTodos, Map<Id,To_do__c> oldMap){
        Set<Id> setIdMilestons = new Set<Id>();
        Set<Id> setIdTodo = new Set<Id>();

        if(Trigger.isDelete){
            for(To_do__c todo : oldMap.values()){
                setIdMilestons.add(todo.Milestone__c);
                setIdTodo.add(todo.id);
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
        

        if(!setIdMilestons.isEmpty()){
            Map<String,Integer> mapMilestonesByStatus = new Map<String,Integer>();
            Map<String,Integer> mapTotalItens = new Map<String,Integer>();   
            Map<String, Milestone__c> mapMilestones = new Map<String, Milestone__c>();         
            String status,idMilestone;
            Integer totalItens = 0, totalComplete = 0,totalInProgress = 0;

            for(AggregateResult agg : [SELECT milestone__c idMilestone, Status__c status,count(id) totalItens FROM To_do__c WHERE milestone__c IN:setIdMilestons AND id not in :setIdTodo GROUP BY milestone__c,Status__c ]){
                status = (String) agg.get('status');
                idMilestone = (String) agg.get('idMilestone');
                totalItens = (Integer) agg.get('totalItens');

                mapMilestonesByStatus.put(idMilestone +'-'+ status , totalItens);
                
                if(mapTotalItens.containsKey(idMilestone)) mapTotalItens.put(idMilestone, totalItens + mapTotalItens.get(idMilestone));
                else mapTotalItens.put(idMilestone,totalItens);
            }

            if(!mapMilestonesByStatus.isEmpty()){
                for(String MilestoneId : setIdMilestons){
                    milestone__c milestone = new milestone__c();
                    milestone.id = MilestoneId;
                    milestone.Complete_Percent__c = 0;
                    milestone.Status__c = 'Not Started';

                    if(mapTotalItens.containsKey(MilestoneId)){
                        totalItens = mapTotalItens.get(MilestoneId);
                        totalInProgress = mapMilestonesByStatus.containsKey(MilestoneId +'-'+ 'In Progress') ? mapMilestonesByStatus.get(MilestoneId +'-'+ 'In Progress') : 0;
                        totalComplete = mapMilestonesByStatus.containsKey(MilestoneId +'-'+ 'Complete') ? mapMilestonesByStatus.get(MilestoneId +'-'+ 'Complete') : 0;
                        milestone.Complete_Percent__c = totalComplete * 100 / totalItens;                        
                    }

                    milestone.Status__c = milestone.Complete_Percent__c == 100 ? 'Complete' : (totalInProgress > 0 || milestone.Complete_Percent__c > 0)  ?  'In Progress' :'Not Started' ;

                    mapMilestones.put(milestone.id, milestone);                    
                }

                UPDATE mapMilestones.values();
            }
        }
    }
}