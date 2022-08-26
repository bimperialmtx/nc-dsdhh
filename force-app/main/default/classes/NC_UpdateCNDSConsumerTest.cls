/**
* @description       : Test class for NC_UpdateCNDSConsumer
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_UpdateCNDSConsumerTest {
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
        // con.AccountId=acc.Id;
        con.FirstName = 'test';
        con.LastName='Test Con';
        con.Race__c = 'White;Asian';
        con.Birthdate = Date.newInstance(1986, 12, 9);
        con.Cnds_Identifier__c = '956343031K';
        con.MiddleName = 'test';
        con.Suffix = 'Mr';
        con.Gender__c = 'Male';
        con.Ethnicity__c = 'Not Hispanic/Latino';
        con.Hispanic_Ethnicity__c = 'Cuban';
        con.Primary_Language__c = 'Thai';
        con.User_Id__c = u.Id;
        con.Staff_Member_Name__c = u.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        Attendees__c attendess = new Attendees__c();
        // attendess.Trainer_Result__c = acc.Id;
        Insert attendess;
        
        Campaign camp = new Campaign ();
        camp.StartDate = Date.today();
        camp.EndDate = Date.today()+1;
        camp.Name = 'test';
        Insert camp;
    }
    
    /*
    *********************************************************
    @Method Name    : NC_UpdateCNDSConsumerTest
    @description    : Verify CNDS update consumer by mock response
    ********************************************************
    */
    static testmethod  void NC_UpdateCNDSConsumerTest(){
        
        contact con = [select id,name,Race__c,AccountId,Birthdate,Cnds_Identifier__c,LastName,FirstName,MiddleName,Suffix,Gender__c,Hispanic_Ethnicity__c,Primary_Language__c,User_Id__c,Staff_Member_Name__c from contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetCNDSConsumerMock());
        NC_UpdateCNDSConsumer updater = new NC_UpdateCNDSConsumer (contactList);
        System.enqueueJob(updater);
        Contact contact=[SELECT Id,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id= :con.Id];
        System.assertEquals(false, contact.Allow_CNDS_Update_Sync__c);
        Test.stopTest();       
    }
}