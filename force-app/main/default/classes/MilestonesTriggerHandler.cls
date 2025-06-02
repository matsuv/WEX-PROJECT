public with sharing class MilestonesTriggerHandler {
    public static void calculatePercentToMilestone(List<Milestone__c> listNewmilestones, Map<Id,Milestone__c> oldMap){
        Set<Id> setIdProjects = new Set<Id>();
        Set<Id> setIdMilestone = new Set<Id>();

        if(Trigger.isDelete){
            for(Milestone__c milestone : oldMap.values()){                
                setIdProjects.add(milestone.Project__c);
                setIdMilestone.add(milestone.id);
            }
        }else{
            for(Milestone__c milestone : listNewmilestones){
                if(Trigger.isUpdate){
                    if(milestone.status__c != oldMap.get(milestone.Id).status__c){ 
                        setIdProjects.add(milestone.Project__c);
                    }
                }
                else{
                    setIdProjects.add(milestone.Project__c);
                }
            }
        }
        
        if(!setIdProjects.isEmpty()){
            Map<String,Integer> mapProjectByStatus = new Map<String,Integer>();
            Map<String,Integer> mapTotalItens = new Map<String,Integer>();   
            Map<String, Project__c> mapProjects = new Map<String, Project__c>();         
            String status,idProject;
            Integer totalItens = 0, totalComplete = 0, totalInProgress = 0;

            for(AggregateResult agg : [SELECT Project__c idProject, Status__c status,count(id) totalItens FROM Milestone__c WHERE Project__c IN:setIdProjects AND ID NOT IN: setIdMilestone GROUP BY Project__c,Status__c ]){
                status = (String) agg.get('status');
                idProject = (String) agg.get('idProject');
                totalItens = (Integer) agg.get('totalItens');

                mapProjectByStatus.put(idProject +'-'+ status, totalItens);

                if(mapTotalItens.containsKey(idProject)) mapTotalItens.put(idProject, totalItens + mapTotalItens.get(idProject));
                else mapTotalItens.put(idProject, totalItens);
            }

            if(!mapProjectByStatus.isEmpty()){
                for(String projectId : setIdProjects){
                    Project__c project = new Project__c();
                    project.id = projectId;
                    project.Complete_Percent__c = 0;
                    project.Status__c = 'Not Started';

                    if(mapTotalItens.containsKey(projectId)){
                        totalItens = mapTotalItens.get(projectId);
                        totalInProgress = mapProjectByStatus.containsKey(projectId +'-'+ 'In Progress') ? mapProjectByStatus.get(projectId +'-'+ 'In Progress') : 0;
                        totalComplete = mapProjectByStatus.containsKey(projectId +'-'+ 'Complete') ? mapProjectByStatus.get(projectId +'-'+ 'Complete') : 0;
                        project.Complete_Percent__c = totalComplete * 100 / totalItens;                        
                    }

                    system.debug('proejto' + project.Complete_Percent__c);
                    system.debug('mapProjectByStatus' + mapProjectByStatus);
                    system.debug('totalInProgress' + totalInProgress);

                    project.Status__c = project.Complete_Percent__c == 100 ? 'Complete' : (totalInProgress > 0 || project.Complete_Percent__c > 0)   ?  'In Progress' :'Not Started' ;

                    mapProjects.put(project.id, project);                    
                }

                UPDATE mapProjects.values();
            }
        }
    }
}