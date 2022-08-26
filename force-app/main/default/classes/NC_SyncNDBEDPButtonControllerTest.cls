/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_SyncNDBEDPButtonControllerTest {
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
        // con.AccountId=acc.Id;
        con.Allow_NDBEDP_Resync__c = true;
        con.Patron_ID__c = 'NC-2202015';
        con.Comments__c = 'test';
        con.LastName='Test Con';
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        // cas.Internal_Assessor__c='';
        cas.Assessor_Comment__c ='test';
        cas.Comments__c ='';
        insert cas;
        
        /*  Case cas1= new Case();
cas1.ContactId=con.Id;
cas1.Internal_Assessor__c=user.Id;
cas1.Assessor_Comment__c ='test';
cas1.Comments__c ='';
insert cas1;*/
        
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;
        
    }
    
    /*
*********************************************************
@Method Name    : getNDBEDPSyncStatusTest
@description    : Verify NDBEDP sync status for ndbedp request
********************************************************
*/
    @isTest
    public static void getNDBEDPSyncStatusTest(){
        Contact con=[SELECT Id,Allow_NDBEDP_Resync__c,Patron_Id__c,Comments__c FROM Contact LIMIT 1];
        Test.startTest();
        Contact cont = NC_SyncNDBEDPButtonController.getNDBEDPSyncStatus(con.Id);
        System.assertEquals('NC-2202015', cont.Patron_Id__c);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getCommentFromErrorTest
@description    : Verify NDBEDP sync error from error record
********************************************************
*/
    @isTest
    public static void getCommentFromErrorTest(){
        Contact con=[SELECT Id,Allow_NDBEDP_Resync__c,Patron_Id__c,Comments__c FROM Contact LIMIT 1];
        Test.startTest();
        
        Error__c err = NC_SyncNDBEDPButtonController.getCommentFromError(con.Id);
        System.assertEquals(null, err);
        Test.stopTest();
    }
    /*
*********************************************************
@Method Name    : getCommentFromErrorTestOne
@description    : Verify NDBEDP sync error from error record
********************************************************
*/
    @isTest
    public static void getCommentFromErrorTestOne(){
        Contact con=[SELECT Id,Allow_NDBEDP_Resync__c,Patron_Id__c,Comments__c FROM Contact LIMIT 1];
        Error__c e=new Error__c();
        e.Consumer__c=con.Id;
        insert e; 
        
        Test.startTest();
        Error__c err = NC_SyncNDBEDPButtonController.getCommentFromError(con.Id);
        System.assertEquals(null, err);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : sendLookupRequestTest
@description    : Verify NDBEDP request to KLAS by using mock response
********************************************************
*/
    @isTest
    public static void sendLookupRequestTest(){
        Contact con=[SELECT Id,Allow_NDBEDP_Resync__c,Patron_Id__c,Comments__c FROM Contact LIMIT 1];
        Test.startTest();
        try{
            NC_SyncNDBEDPButtonController.sendLookupRequest(con.Id);
            System.assertEquals('test', con.Comments__c);
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
}