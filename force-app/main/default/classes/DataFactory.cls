@isTest
public with sharing class DataFactory {
    

    public static To_do__c createTodo(String name, Id milestoneId) {   
        return new To_do__c(
            Name = name,
            Milestone__c = milestoneId,
            Status__c = 'Not Started'
        );
    }

    public static Milestone__c createMilestone( String name, Id projectId){
        return new Milestone__c(
            Name = name,
            Project__c = projectId
        );
    }

    public static Project__c createProject(){
        return new Project__c(
            Name = 'Test'
        );
    }
}