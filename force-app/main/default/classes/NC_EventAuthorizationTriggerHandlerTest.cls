/**
* @description       : Test class for NC_EventAuthorizationTriggerHandler
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_EventAuthorizationTriggerHandlerTest {
    
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify Event Authorization create/update validations
    ********************************************************
    */
    @IsTest
    public static void makeData(){
        Budget_Management__c budget = new Budget_Management__c();
        budget.Budget_Year__c = '1990';
        budget.Budget_Type__c = 'NDBEDP Budget';
        budget.Amount_Utilized__c  =100;
        budget.Start_Date_Fiscal_Year__c = Date.today();
        budget.End_Date_Fiscal_Year__c = Date.today()+2;
        Insert budget;
        budget.End_Date_Fiscal_Year__c = Date.today()+2;
        update budget;
        
        Id nonDHHOutreachRecordTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, nonDHHOutreachRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        
        
        Id ndbedpOutreachCost = NC_Utility.RecordTypeUtilityMethod('Event_Authorization__c', 'NDBEDP_Outreach_Attendee_Cost');
        Event_Authorization__c auth = new Event_Authorization__c();
        auth.DHH_Sponsor_Event__c = outreach.Id;
        auth.RecordTypeId = ndbedpOutreachCost;
        Insert auth;
        
        auth.Service_Time__c = 20;
        update auth;
        Event_Authorization__c evt=[SELECT Id,NDBEDP_Total_Cost_Rollup__c,NDBEDP_Total_Cost__c FROM Event_Authorization__c LIMIT 1]; 
        System.assertEquals(500.00, evt.NDBEDP_Total_Cost_Rollup__c);
    }
}