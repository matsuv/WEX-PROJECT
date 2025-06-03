@isTest
public with sharing class MilestonesTriggerHandlerTest {
    @isTest
    public static void MilestonesTriggerHandlerTest() {
        Project__c project = DataFactory.createProject();
        insert project;

        Milestone__c milestone = DataFactory.createMilestone('Test', project.Id);
        insert milestone;

        To_do__c todo = DataFactory.createTodo('Test', milestone.Id);
        insert todo;

        todo.Status__c = 'In Progress';
        UPDATE todo;

        Test.startTest();
        Project__c projectSearched = [SELECT Status__c FROM Project__c  WHERE Name = 'Test' LIMIT 1 ];

        System.Assert.areEqual('In Progress', projectSearched.Status__c);
        Test.stopTest();
    }

    @isTest
    public static void MilestonesTriggerHandlerTestDelete() {
        Project__c project = DataFactory.createProject();
        insert project;

        Milestone__c milestone = DataFactory.createMilestone('Test', project.Id);
        insert milestone;

        To_do__c todo = DataFactory.createTodo('Test', milestone.Id);
        insert todo;

        todo.Status__c = 'In Progress';
        UPDATE todo;

        Test.startTest();
        
        DELETE milestone;

        Project__c projectSearched = [SELECT Status__c FROM Project__c  WHERE Name = 'Test' LIMIT 1 ];     

        System.Assert.areEqual('Not Started', projectSearched.Status__c);

        Test.stopTest();
    }
}