@isTest
public with sharing class ProjectMilestoneControllerTest {


@IsTest
    public static void createProjectWithMilestonesAndTasksTest(){
        String json = '{"listMilestones": [{"id": "milestone1", "name": "name1"},'+
        '{"id": "milestone2", "name": "name2"},'+
        '{"id": "milestone3", "name": "name3"}],'+
        '"listToDos": [{"id": "todo1", "name": "todo1", "idMilestone": "milestone1"},'+
        '{"id": "todo2", "name": "todo2", "idMilestone": "milestone2"},'+
        '{"id": "todo3", "name": "todo3", "idMilestone": "milestone3"}]}';

        String projectName = 'Project1';
        String ownerId = UserInfo.getUserId();

        Test.startTest();
        ProjectMilestoneController.createProjectWithMilestonesAndTasks(json, projectName, ownerId);
        Test.stopTest();
        
        List<To_do__c> todos = [SELECT Id, Name, Milestone__c FROM To_do__c];
        List<Milestone__c> milestones = [SELECT Id, Name, Project__c FROM Milestone__c];
        Project__c project = [SELECT Id, Name, OwnerId FROM Project__c];

        System.assertEquals(3, todos.size());
        System.assertEquals(3, milestones.size());
        System.assertEquals(projectName, project.Name);
        System.assertEquals(ownerId, project.OwnerId);
    }
}