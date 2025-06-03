public with sharing class MilestonesTriggerHandler {
    public static void calculatePercentToMilestone(List<Milestone__c> listNewmilestones, Map<Id,Milestone__c> oldMap){
        Set<Id> setIdProjects = new Set<Id>();
        Set<Id> setIdsDisconsider = new Set<Id>();

        if(Trigger.isDelete){
            for(Milestone__c milestone : oldMap.values()){                
                setIdProjects.add(milestone.Project__c);
                setIdsDisconsider.add(milestone.id);
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

        if(setIdProjects.size() > 0){
            Map<Id,Project__c> mapProjectsUpp = new Map<Id,Project__c>();
            Project__c projectInstance;
            Boolean hasAnyCompleteItem,anyoneStarted,notInitiated;

            for(Project__c project : [SELECT Id, Status__c, (SELECT Id, Status__c FROM Milestones__r WHERE Id NOT IN :setIdsDisconsider) FROM Project__c WHERE Id IN :setIdProjects]){
                hasAnyCompleteItem = false;
                anyoneStarted = false;
                notInitiated = false;
                
                projectInstance = new Project__c();
                projectInstance.id = project.id;

                for(Milestone__c milestone : project.Milestones__r){
                    if(milestone.Status__c == 'Complete') hasAnyCompleteItem = true;
                    else if(milestone.Status__c == 'In Progress') anyoneStarted = true;
                    else notInitiated = true;
                }

                projectInstance.Status__c = hasAnyCompleteItem && !anyoneStarted && !notInitiated ? 'Complete' : (anyoneStarted || hasAnyCompleteItem) ? 'In Progress' : 'Not Started';
                
                if(project.Status__c != projectInstance.Status__c) mapProjectsUpp.put(projectInstance.id, projectInstance);
            }
            
            UPDATE  mapProjectsUpp.values();
        }
    }
}