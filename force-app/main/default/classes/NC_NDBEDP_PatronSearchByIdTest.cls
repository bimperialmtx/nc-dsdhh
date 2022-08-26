/**
* @description       : Test class for NC_NDBEDP_PatronSearchById
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDP_PatronSearchByIdTest {

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
        // con.AccountId=acc.Id;
        con.FirstName = 'test';
       // con.MiddleName = '';
        con.LastName='TestCon';
        con.Race__c = 'White;Asian';
        con.Birthdate = Date.newInstance(1986, 12, 9);
        con.Cnds_Identifier__c = '956343031K';
        con.MiddleName = 'test';
        con.Suffix = 'Mr';
        con.Gender__c = 'Male';
        con.Ethnicity__c = 'Not Hispanic/Latino';
        con.Hispanic_Ethnicity__c = 'Cuban';
        con.Primary_Language__c = 'English';
        con.User_Id__c = u.Id;
        con.Staff_Member_Name__c = u.Id;
        con.Status_Code__c = 'T';
        con.County__c = 'Craven';
        con.Cell_Phone_Number__c = '1234567890';
        con.Allow_NDBEDP_Resync__c = true;
        con.Status_Code__c = 'Active';
        con.MobilePhone = '1234567890';
        con.Work_Phone_Number__c = '1234567890';
        con.Alt_Phone_Number__c = '1234567890';
        con.Email= 'Test@gmail.com';
        con.OtherCity = 'test';
        con.OtherPostalCode = '12345';
        con.OtherCountryCode = 'US';
        con.OtherStateCode = 'NC';
        con.OtherCountry = 'United States';
        con.OtherStreet = 'North Lakes Drive';
        
       // con.Patron_ID__c = 'NC-2202015';
        insert con;
        
        Contact con1=new Contact();   
        // con.AccountId=acc.Id;
        con1.FirstName = 'testing';
       // con.MiddleName = '';
        con1.LastName='TestCon';
        con1.Race__c = 'White;Asian';
        con1.Birthdate = Date.newInstance(1986, 12, 9);
        con1.Cnds_Identifier__c = '956343031K';
        con1.MiddleName = 'test';
        con1.Suffix = 'Mr';
        con1.Gender__c = 'Male';
        con1.Ethnicity__c = 'Not Hispanic/Latino';
        con1.Hispanic_Ethnicity__c = 'Cuban';
        con1.Primary_Language__c = 'English';
        con1.User_Id__c = u.Id;
        con1.Staff_Member_Name__c = u.Id;
        con1.Status_Code__c = 'T';
        con1.County__c = 'Craven';
        con1.Cell_Phone_Number__c = '1234567890';
        con1.Allow_NDBEDP_Resync__c = true;
        con1.Status_Code__c = 'Active';
        con1.MobilePhone = '1234567890';
        con1.Work_Phone_Number__c = '1234567890';
        con1.Alt_Phone_Number__c = '1234567890';
        con1.Email= 'Testing@gmail.com';
        con1.OtherCity = 'test';
        con1.OtherPostalCode = '12345';
        con1.OtherCountryCode = 'US';
        con1.OtherStateCode = 'NC';
        con1.OtherCountry = 'United States';
        con1.OtherStreet = 'North Lakes Drive';
        
       // con.Patron_ID__c = 'NC-2202015';
        insert con1;
        
        
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        // cas.Internal_Assessor__c='';
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
    @description    : Verify NDBEDP Patron search using mock response
    ********************************************************
    */
    @isTest
    public static void testGetEquipmentDetails(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c
        FROM Contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPPatronSearch());
        NC_NDBEDP_PatronSearchById updater = new NC_NDBEDP_PatronSearchById (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Address_Link_Obj__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals('false',contact.Address_Link_Obj__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetails1
    @description    : Verify NDBEDP Patron search validations using mock response
    ********************************************************
    */
        @isTest
    public static void testGetEquipmentDetails1(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c
        FROM Contact WHERE Email = 'Testing@gmail.com'  LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
       // Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPPatronSearch());
        NC_NDBEDP_PatronSearchById updater = new NC_NDBEDP_PatronSearchById (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Patron_Contact_Obj_Add__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Patron_Contact_Obj_Add__c!=null);
    }
    
    /*
    *********************************************************
    @Method Name    : validateNDBEDPPatronSearch
    @description    : Verify NDBEDP Patron search validations using mock response
    ********************************************************
    */
    @isTest
    public static void validateNDBEDPPatronSearch(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c
        FROM Contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_PatronSearchByIdTest.GetNCNDBEDPPatronEmptySearch());
        NC_NDBEDP_PatronSearchById updater = new NC_NDBEDP_PatronSearchById (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Allow_NDBEDP_Resync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(true,contact.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPPatronEmptySearch implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
                
            NC_NDBEDPWrapper resp = new NC_NDBEDPWrapper();
            resp.STATUS = 200;
            resp.ERROR_DESCRIPTION = '';
            resp.count = 1;
            resp.patrons = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateNDBEDPPatronSearch2
    @description    : Verify NDBEDP Patron search validations using mock response
    ********************************************************
    */
    @isTest
    public static void validateNDBEDPPatronSearch2(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c
        FROM Contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_PatronSearchByIdTest.GetNCNDBEDPPatronInvalidSearch());
        NC_NDBEDP_PatronSearchById updater = new NC_NDBEDP_PatronSearchById (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Allow_NDBEDP_Resync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(true,contact.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPPatronInvalidSearch implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
                
            NC_NDBEDPWrapper resp = new NC_NDBEDPWrapper();
            resp.STATUS = 400;
            resp.ERROR_DESCRIPTION = '';
            resp.count = 1;
            resp.patrons = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
           /* @isTest
    public static void testGetEquipmentDetails(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c
        FROM Contact WHERE Email = 'Testing@gmail.com'  LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
       // Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPPatronSearch());
        NC_NDBEDP_PatronSearchById updater = new NC_NDBEDP_PatronSearchById (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
    }*/
    
    
    

}