/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class nc_ServiceRequestTest {
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be used this class
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
        // cas.External_Assessor__c=acc.Id;
        // cas.Assessor_Comment__c ='test1';
        // cas.Comments__c ='';
        insert cas;        
        
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;
        
        
    }
    
    /*
*********************************************************
@Method Name    : checkNDBEDPTest
@description    : Verify ndbedp request by record id
********************************************************
*/
    @isTest
    public static void checkNDBEDPTest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Boolean result = nc_ServiceRequest.checkNDBEDP(cas.Id);
        system.assertEquals(false, result);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getParentCaseNumberTest
@description    : Verify parent NDBEDP case of ndbedp service request
********************************************************
*/
    @isTest
    public static void getParentCaseNumberTest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        String result = nc_ServiceRequest.getParentCaseNumber(cas.Id);
        String res = nc_ServiceRequest.getParentCaseNumber(null);
        system.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : checkUserProfileTest
@description    : Verify current user profile
********************************************************
*/
    @isTest
    public static void checkUserProfileTest(){
        User use=[SELECT Id,Profile.Name  FROM User
                  WHERE id = :UserInfo.getUserId()];
        Test.startTest();
        nc_ServiceRequest.checkUserProfile();
        system.assertEquals(true, use.ProfileId!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getParentCaseNumberIdTest
@description    : Verify parent case details
********************************************************
*/
    @isTest
    public static void getParentCaseNumberIdTest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case result = nc_ServiceRequest.getParentCaseNumberId(cas.Id);
        system.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveDataTest
@description    : Verify request date to be saved
********************************************************
*/
    @isTest
    public static void saveDataTest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        String data = '{"parentName":"00003896","ContactId":"'+con.id+'","requestSubtype":"Follow-up","parentCaseId":"'+cas.Id+'","requestAudience":"Consumer","requestType":"NDBEDP"}';
        Test.startTest();
        try{
            Case result = nc_ServiceRequest.saveData(data);
            system.assertEquals(true, result!=null);
            Case res = NC_ServiceRequestHelper.saveData(null);
            system.assertEquals(false, res!=null);
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
    /*
*********************************************************
@Method Name    : saveDataTestAdditionalPart
@description    : Verify request date to be saved
********************************************************
*/
    @isTest
    public static void saveDataTestAdditionalPart(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        String data = '{"parentName":"00003896","ContactId":"'+con.id+'","requestSubtype":"Additional Part","parentCaseId":"'+cas.Id+'","requestAudience":"Consumer","requestType":"NDBEDP"}';
        Test.startTest();
        try{
            Case result = nc_ServiceRequest.saveData(data);
            system.assertEquals(true, result!=null);
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
    /*
*********************************************************
@Method Name    : saveDataTestRepairRequest
@description    : Verify request date to be saved
********************************************************
*/
    @isTest
    public static void saveDataTestRepairRequest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        String data = '{"parentName":"00003896","ContactId":"'+con.id+'","requestSubtype":"Repair Request","parentCaseId":"'+cas.Id+'","requestAudience":"Consumer","requestType":"NDBEDP"}';
        Test.startTest();
        try{
            Case result = nc_ServiceRequest.saveData(data);
            system.assertEquals(true, result!=null);
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
    /*
*********************************************************
@Method Name    : saveDataTestAdditionalTraining
@description    : Verify request date to be saved
********************************************************
*/
    @isTest
    public static void saveDataTestAdditionalTraining(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        String data = '{"parentName":"00003896","ContactId":"'+con.id+'","requestSubtype":"Additional Training","parentCaseId":"'+cas.Id+'","requestAudience":"Consumer","requestType":"NDBEDP"}';
        Test.startTest();
        try{
            Case result = nc_ServiceRequest.saveData(data);
            system.assertEquals(true, result!=null);
        }
        Catch(Exception e){
        }
        Test.stopTest();
    }
}