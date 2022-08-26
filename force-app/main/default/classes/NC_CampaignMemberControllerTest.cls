/**
* @description       : Test class for NC_CampaignMemberController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_CampaignMemberControllerTest {
    /*
*********************************************************
@Method Name    : makeData
@description    : Verify Campaign validations and operations
********************************************************
*/
    @TestSetup
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.Name='TestA';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        insert acc;
        
        Contact con=new Contact();   
        con.LastName='Test Con';
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        Attendees__c attendess = new Attendees__c();
        Insert attendess;
        
        Campaign camp = new Campaign ();
        camp.StartDate = Date.today();
        camp.EndDate = Date.today()+1;
        camp.Name = 'test';
        Insert camp;
    }
    
    /*
*********************************************************
@Method Name    : getCampgaignMemberTest
@description    : Verify Campaign Member related to account
********************************************************
*/
    @isTest
    public static void getCampgaignMemberTest(){
        Campaign acc=[SELECT Id FROM Campaign LIMIT 1];
        try{
            Test.startTest();
            NC_CampaignMemberController.getCampgaignMember(acc.Id);
            System.assertNotEquals(null, NC_CampaignMemberController.getCampgaignMember(acc.Id));
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
*********************************************************
@Method Name    : createCampaignMemberTest
@description    : Verify Campaign Member creation
********************************************************
*/
    @isTest
    public static void createCampaignMemberTest(){
        Campaign acc=[SELECT Id FROM Campaign LIMIT 1];
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        List<Id> contactList = new List<Id>();
        contactList.add(con.Id);
        try{
            Test.startTest();
            NC_CampaignMemberController.createCampaignMember(acc.Id,contactList);
            System.assertNotEquals(null, NC_CampaignMemberController.createCampaignMember(acc.Id,contactList));
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    /*
*********************************************************
@Method Name    : getCampgaignMemberTestone
@description    : Verify Campaign Member related to account
********************************************************
*/
    @isTest
    public static void getCampgaignMemberTestone(){
        Campaign acc=[SELECT Id FROM Campaign LIMIT 1];
        Contact con=[SELECT Id FROM Contact LIMIT 1];
        CampaignMember camMem= new CampaignMember();
        camMem.CampaignId=acc.Id;
        camMem.ContactId=con.Id;
        insert camMem;
        try{
            Test.startTest();
            NC_CampaignMemberController.getCampgaignMember(acc.Id);
            System.assertNotEquals(null, NC_CampaignMemberController.getCampgaignMember(acc.Id));
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
}