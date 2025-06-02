public with sharing class ProjectMilestoneController {
    
    @AuraEnabled
    public static Id createProjectWithMilestonesAndTasks(String valuesJson, string projectName, String ownerId) {        
        Map<String, Object> objMap = new Map<String, Object>(); 
        Map<String, Milestone__c> mapMilestonesById = new Map<String, Milestone__c>(); 
        Map<String, To_do__c> mapTodos = new Map<String, To_do__c>(); 
        
        Wrapper project = (Wrapper) JSON.deserialize(valuesJson, Wrapper.class);
        Project__c newProject = new Project__c(
            Name = projectName,
            OwnerId = ownerId
        );         
        insert newProject;
        
        for(Milestone milestone : project.listMilestones){
            Milestone__c newMilestone = new Milestone__c();
            newMilestone.name = milestone.name;
            newMilestone.Project__c = newProject.Id;
            mapMilestonesById.put( milestone.id, newMilestone);
        }
        
        insert mapMilestonesById.values();
        
        
        for(Todos todo : project.listToDos){
            To_do__c todoObj = new To_do__c();
            todoObj.name = todo.name;
            todoObj.Milestone__c = mapMilestonesById.get(todo.idMilestone).id;
            mapTodos.put(todo.id, todoObj);
        }
        
        insert mapTodos.values();

        return newProject.id;
    }
    
    public class Wrapper{
        @AuraEnabled public List<Milestone> listMilestones;
        @AuraEnabled public List<Todos> listToDos;
    }
    public class Milestone{
        @AuraEnabled public string id;
        @AuraEnabled public string name;        
    }
    public class Todos{
        @AuraEnabled public string id;
        @AuraEnabled public string name; 
        @AuraEnabled public string idMilestone;        
    }
        

}