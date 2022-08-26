/**
* @description       : Test class for NC_CloseEventController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_CloseEventControllerTest {
    
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be used in this class
********************************************************
*/
    @TestSetup
    public static void makeData(){
        
        Id nonDHHOutreachRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Non_DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(false, nonDHHOutreachRecordTypeId, System.now(), System.now(), 'title', 'address', null);
        outreach.Submit_for_Approval__c = true;
        outreach.Resolution_Note__c = 'test';
        outreach.Sign_In_Sheets_Uploaded__c = true;
        Insert outreach;
        outreach.Status__c = 'Approved';
        update outreach;
        
        Id eventAttributeRecordTypeId = Schema.SObjectType.Event_Attribute__c.getRecordTypeInfosByDeveloperName().get('Staff_Attending').getRecordTypeId();
        Event_Attribute__c event = new Event_Attribute__c ();
        event.Resolution_Note__c = 'test';
        event.RecordTypeId = eventAttributeRecordTypeId;
        event.Outreach_Request__c = outreach.Id;
        // event.Status__c = 'Created';
        event.Submit_for_Approval__c = true;
        Insert event;
        
        
        event.Status__c ='Approved';
        update event;
        
        Event_Attribute__c event1 = new Event_Attribute__c ();
        event1.Resolution_Note__c = 'test';
        event1.RecordTypeId = eventAttributeRecordTypeId;
        event1.Outreach_Request__c = outreach.Id;
        Insert event1;
        
    }
    
    /*
*********************************************************
@Method Name    : closeEventTest
@description    : Verify event close scenarios
********************************************************
*/
    @isTest
    public static void closeEventTest(){
        Event_Attribute__c event = [SELECT Id,Resolution_Note__c,End_Date_of_Event__c,Outreach_Request__c,RecordTypeId FROM Event_Attribute__c LIMIT 1];
        Test.startTest();
        NC_CloseEventController.closeEvent(event.Id);
        System.assertNotEquals(null, NC_CloseEventController.closeEvent(event.Id));
        Test.stopTest(); 
    }
    /*
*********************************************************
@Method Name    : closeEventTestone
@description    : Verify event close scenarios
********************************************************
*/
    @isTest
    public static void closeEventTestone(){
        Outreach_Request__c outreach=[SELECT Id,End_Date_of_Event__c FROM Outreach_Request__c LIMIT 1];
        outreach.End_Date_of_Event__c=system.today()+10;
        update outreach;
        Event_Attribute__c event = [SELECT Id,Resolution_Note__c,End_Date_of_Event__c,Outreach_Request__c,RecordTypeId FROM Event_Attribute__c LIMIT 1];
        Test.startTest();
        NC_CloseEventController.closeEvent(event.Id);
        System.assertNotEquals(null, NC_CloseEventController.closeEvent(event.Id));
        Test.stopTest(); 
    }
    /*
*********************************************************
@Method Name    : closeEventTesttwo
@description    : Verify event close scenarios
********************************************************
*/
    @isTest
    public static void closeEventTesttwo(){
        Event_Attribute__c event = [SELECT Id,Resolution_Note__c,End_Date_of_Event__c,Outreach_Request__c,RecordTypeId FROM Event_Attribute__c LIMIT 1];
        event.Resolution_Note__c='';
        update event;
        Test.startTest();
        NC_CloseEventController.closeEvent(event.Id);
        System.assertNotEquals(null, NC_CloseEventController.closeEvent(event.Id));
        Test.stopTest(); 
    }
    
    /*
*********************************************************
@Method Name    : closeEventTest1
@description    : Verify event close validation
********************************************************
*/
    @isTest
    public static void closeEventTest1(){
        Outreach_Request__c outReach = [SELECT Id FROM Outreach_Request__c LIMIT 1];
        Test.startTest();
        NC_CloseEventController.closeEvent(outReach.Id);
        System.assertNotEquals(null, NC_CloseEventController.closeEvent(outReach.Id));
        Test.stopTest(); 
    }
}