/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_TaskCreateSchedulableBatchTest {
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Create data to be used in this class
    ********************************************************
    */
    @TestSetup
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.Name='Test';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        insert acc;
        
        
        Contact con=new Contact();   
        con.LastName='Test Con';
        insert con;
        
        
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Assessor_Comment__c ='test';
        cas.Comments__c ='';
        insert cas;
        
        Outreach_Request__c out = new Outreach_Request__c();
        out.Start_Date_of_Event__c = Date.today()+5;
        out.End_Date_of_Event__c = Date.today()+6;
        Insert out;
        
    }
    
    /*
    *********************************************************
    @Method Name    : NC_TaskCreateSchedulableBatchTest
    @description    : Verify task creation batch
    ********************************************************
    */
    static testmethod  void NC_TaskCreateSchedulableBatchTest(){
        
        Outreach_Request__c con = [SELECT Id,Name,Start_Date_of_Event__c,OwnerId FROM Outreach_Request__c LIMIT 1];
        List<Outreach_Request__c> outReachList = new List<Outreach_Request__c>();
        outReachList.add(con);
        try{
        Test.startTest();
        NC_TaskCreateSchedulableBatch obj = new NC_TaskCreateSchedulableBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();   
        Task task =[SELECT Id,Subject,WhatId FROM Task WHERE WhatId=:con.Id];
        System.assertEquals('Sign In Sheet Follow up', task.Subject);
        }
        catch (Exception ex) {
        }
    }
    
}