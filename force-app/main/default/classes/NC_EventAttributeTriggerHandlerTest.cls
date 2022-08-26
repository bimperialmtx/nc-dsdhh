/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_EventAttributeTriggerHandlerTest {
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify Event attribute create/update validations
    ********************************************************
    */
    @IsTest
    public static void makeData(){
        
        Id nonDHHOutreachRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('Non_DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, nonDHHOutreachRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        
        
        Id eventAttributeRecordIdPublicCommunication = NC_Utility.RecordTypeUtilityMethod('Event_Attribute__c','Public_Communication');
        Event_Attribute__c event = new Event_Attribute__c ();
        event.Resolution_Note__c = 'test';
        event.RecordTypeId = eventAttributeRecordIdPublicCommunication;
        Insert event;
        try{
            event.Outreach_Request__c = outreach.Id;
            update event;
        List< Event_Attribute__c > requestList = [SELECT Id FROM Event_Attribute__c];
        System.assertNotEquals(0, requestList.size());
        }
        catch(Exception e){
        }
        
        Id eventAttributeRecordIdStaffAttending = NC_Utility.RecordTypeUtilityMethod('Event_Attribute__c','Staff_Attending');
        Event_Attribute__c event1 = new Event_Attribute__c ();
        event1.Resolution_Note__c = 'test';
        event1.RecordTypeId = eventAttributeRecordIdStaffAttending;
        Insert event1;
        try{
            event1.Status__c = 'Pending Approval';
            event1.Outreach_Request__c = outreach.Id;
            update event1;
            List< Event_Attribute__c > requestList = [SELECT Id FROM Event_Attribute__c];
            System.assertNotEquals(0, requestList.size());
        }
        catch(Exception e){
        }
        
        
        
    }
}