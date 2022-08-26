/**
* @description       : Test class for NC_LookupCNDS
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_LookupCNDSTest {
    
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be used in this class
********************************************************
*/
    @TestSetup
    public static void makeData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
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
        con.FirstName = 'TEST';
        con.LastName='TESTCON';
        con.Race__c = 'White;Asian;Black or African American;Native Hawaiian or other Pacific Islander;American Indian or Alaska Native';
        con.Birthdate = Date.newInstance(1986, 12, 9);
        con.MiddleName = 'TEST';
        con.Suffix = 'Mr';
        con.Gender__c = 'Male';
        con.Ethnicity__c = 'Not Hispanic/Latino';
        con.Hispanic_Ethnicity__c = 'Cuban';
        con.Primary_Language__c = 'Thai';
        con.User_Id__c = u.Id;
        con.Staff_Member_Name__c = u.Id;
        con.Status_Code__c = 'T';
        con.Social_Security_Number__c ='1234';
        // con.Cnds_Identifier__c = '956343029S';
        insert con;
        
        Contact con1=new Contact();   
        con1.FirstName = 'TEST';
        con1.LastName='Testing';
        con1.Race__c = 'White;Asian;Black or African American;Native Hawaiian or other Pacific Islander;American Indian or Alaska Native';
        con1.Birthdate = Date.newInstance(1986, 12, 9);
        con1.MiddleName = 'TEST';
        con1.Suffix = 'Mr';
        con1.Gender__c = 'Male';
        con1.Ethnicity__c = 'Not Hispanic/Latino';
        con1.Hispanic_Ethnicity__c = 'Cuban';
        con1.Primary_Language__c = 'Thai';
        con1.User_Id__c = u.Id;
        con1.Staff_Member_Name__c = u.Id;
        con1.Status_Code__c = 'T';
        con1.Social_Security_Number__c ='1234';
        // con.Cnds_Identifier__c = '956343029S';
        insert con1;
        
        Contact con2=new Contact();   
        con2.FirstName = 'test';
        con2.LastName='TestCon';
        con2.Race__c = 'White;Asian';
        con2.Birthdate = Date.newInstance(1986, 12, 9);
        con2.Cnds_Identifier__c = '956343031K';
        con2.Suffix = 'Mr';
        con2.Gender__c = 'FeMale';
        con2.Ethnicity__c = 'Not Hispanic/Latino';
        con2.Hispanic_Ethnicity__c = 'Cuban';
        con2.Primary_Language__c = 'Thai';
        con2.User_Id__c = u.Id;
        con2.Staff_Member_Name__c = u.Id;
        con2.Status_Code__c = 'T';
        con.Patron_ID__c = 'NC-2202015';
        insert con2;
        
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Assessor_Comment__c ='test';
        cas.Comments__c ='';
        insert cas;
        
        
        
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;
        
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails
@description    : Verify lookup to consumer in mock CNDS
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails(){
        contact con = [select id,name,Race__c,AccountId,Birthdate,Cnds_Identifier__c,Social_Security_Number__c,LastName,FirstName,MiddleName,Suffix,Gender__c,Status_Code__c,Hispanic_Ethnicity__c,Primary_Language__c,User_Id__c,Staff_Member_Name__c,Patron_ID__c from contact
                       LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetCNDSPersonSearchMock());
        NC_LookupCNDS updater = new NC_LookupCNDS (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Contact contact=[SELECT Id,Duplicate_CNDS__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Duplicate_CNDS__c);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails1
@description    : Verify lookup to consumer in mock CNDS and validations
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails1(){
        contact con = [select id,name,Race__c,AccountId,Birthdate,Cnds_Identifier__c,Social_Security_Number__c,LastName,FirstName,MiddleName,Suffix,Gender__c,Status_Code__c,Hispanic_Ethnicity__c,Primary_Language__c,User_Id__c,Staff_Member_Name__c,Patron_ID__c from contact
                       WHERE LastName='Testing' LIMIT  1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetCNDSPersonSearchMock());
        NC_LookupCNDS updater = new NC_LookupCNDS (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Cnds_Identifier__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Cnds_Identifier__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails2
@description    : Verify lookup to consumer in mock CNDS and validations
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails2(){
        contact con = [select id,name,Race__c,AccountId,Birthdate,Cnds_Identifier__c,Social_Security_Number__c,LastName,FirstName,MiddleName,Suffix,Gender__c,Status_Code__c,Hispanic_Ethnicity__c,Primary_Language__c,User_Id__c,Staff_Member_Name__c,Patron_ID__c from contact
                       WHERE LastName='Testing' LIMIT  1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        // Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetCNDSPersonSearchMock());
        NC_LookupCNDS updater = new NC_LookupCNDS (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Duplicate_CNDS__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Duplicate_CNDS__c);
    }
}