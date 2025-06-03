@isTest
public with sharing class TodoTriggerHandlerTest {
    @isTest
    public static void TodoTriggerHandlerTest() {
        Project__c project = DataFactory.createProject();
        insert project;

        Milestone__c milestone = DataFactory.createMilestone('Test', project.Id);
        insert milestone;

        To_do__c todo = DataFactory.createTodo('Test', milestone.Id);
        insert todo;

        todo.Status__c = 'In Progress';
        UPDATE todo;

        Test.startTest();
        Milestone__c milestoneSearched = [SELECT Status__c FROM Milestone__c  WHERE Name = 'Test' LIMIT 1 ];

        System.Assert.areEqual('In Progress', milestoneSearched.Status__c);
        Test.stopTest();
    }

     @isTest
    public static void TodoTriggerHandlerTestDelete() {
        Project__c project = DataFactory.createProject();
        insert project;

        Milestone__c milestone = DataFactory.createMilestone('Test', project.Id);
        insert milestone;

        To_do__c todo = DataFactory.createTodo('Test', milestone.Id);
        insert todo;

        

        Test.startTest();
        todo.Status__c = 'Complete';
        UPDATE todo;

        Milestone__c milestoneSearched = [SELECT Status__c FROM Milestone__c  WHERE Name = 'Test' LIMIT 1 ];
        System.Assert.areEqual('Complete', milestoneSearched.Status__c);

        delete todo;
        milestoneSearched = [SELECT Status__c FROM Milestone__c  WHERE Name = 'Test' LIMIT 1 ];
        System.Assert.areEqual('Not Started', milestoneSearched.Status__c);

        Test.stopTest();
    }
}