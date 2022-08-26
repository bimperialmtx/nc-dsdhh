/**
* @description       : Test class for NC_NDBEDP_PatronCreateUpdate
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDP_PatronCreateUpdateTest {
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
        con.Primary_Language__c = 'Thai';
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
        con.Reg_End_Date__c = Date.newInstance(2025, 12, 9);
        con.Preferred_Contact_Method__c = 'Email';
        
        // con.Patron_ID__c = 'NC-2202015';
        insert con;
        
        Contact con1=new Contact();   
        // con.AccountId=acc.Id;
        con1.FirstName = 'testingA';
        // con.MiddleName = '';
        con1.LastName='TestConA';
        con1.Race__c = 'White;Asian';
        con1.Birthdate = Date.newInstance(1986, 12, 9);
        con1.Cnds_Identifier__c = '956343031K';
        con1.MiddleName = 'test';
        con1.Suffix = 'Mr';
        con1.Gender__c = 'Male';
        con1.Ethnicity__c = 'Not Hispanic/Latino';
        con1.Hispanic_Ethnicity__c = 'Cuban';
        con1.Primary_Language__c = '';
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
        con1.Reg_End_Date__c = Date.newInstance(2025, 12, 9);
        con1.Preferred_Contact_Method__c = 'Cell Phone Number';
        insert con1;
        
        Contact con2=new Contact();   
        // con.AccountId=acc.Id;
        con2.FirstName = 'testingB';
        // con.MiddleName = '';
        con2.LastName='TestConB';
        con2.Race__c = 'White;Asian';
        con2.Birthdate = Date.newInstance(1986, 12, 9);
        con2.Cnds_Identifier__c = '956343031K';
        con2.MiddleName = 'test';
        con2.Suffix = 'Mr';
        con2.Gender__c = 'Male';
        con2.Ethnicity__c = 'Not Hispanic/Latino';
        con2.Hispanic_Ethnicity__c = 'Cuban';
        con2.Primary_Language__c = '';
        con2.User_Id__c = u.Id;
        con2.Staff_Member_Name__c = u.Id;
        con2.Status_Code__c = 'T';
        con2.County__c = 'Craven';
        con2.Cell_Phone_Number__c = '1234567890';
        con2.Allow_NDBEDP_Resync__c = true;
        con2.Status_Code__c = 'Active';
        con2.MobilePhone = '1234567890';
        con2.Work_Phone_Number__c = '1234567890';
        con2.Alt_Phone_Number__c = '1234567890';
        con2.Video_Phone_Number__c = '1234567890';
        con2.Email= 'Testing@gmail.com';
        con2.OtherCity = 'test';
        con2.OtherPostalCode = '12345';
        con2.OtherCountryCode = 'US';
        con2.OtherStateCode = 'NC';
        con2.OtherCountry = 'United States';
        con2.OtherStreet = 'North Lakes Drive';
        con2.Reg_End_Date__c = Date.newInstance(2025, 12, 9);
        con2.Preferred_Contact_Method__c = 'Video Phone Number';
        insert con2;
        
        Contact con3=new Contact();   
        // con.AccountId=acc.Id;
        con3.FirstName = 'testingC';
        // con.MiddleName = '';
        con3.LastName='TestConC';
        con3.Race__c = 'White;Asian';
        con3.Birthdate = Date.newInstance(1986, 12, 9);
        con3.Cnds_Identifier__c = '956343031K';
        con3.MiddleName = 'test';
        con3.Suffix = 'Mr';
        con3.Gender__c = 'Male';
        con3.Ethnicity__c = 'Not Hispanic/Latino';
        con3.Hispanic_Ethnicity__c = 'Cuban';
        con3.Primary_Language__c = '';
        con3.User_Id__c = u.Id;
        con3.Staff_Member_Name__c = u.Id;
        con3.Status_Code__c = 'T';
        con3.County__c = 'Craven';
        con3.Cell_Phone_Number__c = '1234567890';
        con3.Allow_NDBEDP_Resync__c = true;
        con3.Status_Code__c = 'Active';
        con3.MobilePhone = '1234567890';
        con3.Work_Phone_Number__c = '1234567890';
        con3.Alt_Phone_Number__c = '1234567890';
        con3.Email= 'Testing@gmail.com';
        con3.OtherCity = 'test';
        con3.OtherPostalCode = '12345';
        con3.OtherCountryCode = 'US';
        con3.OtherStateCode = 'NC';
        con3.OtherCountry = 'United States';
        con3.OtherStreet = 'North Lakes Drive';
        con3.Reg_End_Date__c = Date.newInstance(2025, 12, 9);
        con3.Preferred_Contact_Method__c = 'Work Phone Number';
        insert con3;
        
        
        
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
@description    : Verify NDBEDP Patron create update using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Primary_Language__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals('Thai',contact.Primary_Language__c);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails1
@description    : Verify NDBEDP Patron create update validations using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails1(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact WHERE Preferred_Contact_Method__c = 'Cell Phone Number' LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Contact contact=[SELECT Id,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Allow_CNDS_Update_Sync__c);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails2
@description    : Verify NDBEDP Patron create update validations using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails2(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact WHERE Preferred_Contact_Method__c = 'Work Phone Number' LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Contact contact=[SELECT Id,Reg_End_Date__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(true,contact.Reg_End_Date__c!=null);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails3
@description    : Verify NDBEDP Patron create update validations using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails3(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact WHERE Preferred_Contact_Method__c = 'Video Phone Number' LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Contact contact=[SELECT Id,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Allow_CNDS_Update_Sync__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetails4
    @description    : Verify NDBEDP Patron create update validations using mock response
    ********************************************************
    */
    @isTest
    public static void testGetEquipmentDetails4(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact WHERE Preferred_Contact_Method__c = 'Video Phone Number' LIMIT 1];
        con.Preferred_Contact_Method__c = 'Alt Phone Number';
        update con;
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Contact contact=[SELECT Id,Allow_CNDS_Update_Sync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(false,contact.Allow_CNDS_Update_Sync__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testPatronCreateUpdateValidation
    @description    : Verify NDBEDP Patron create update using mock response
    ********************************************************
    */
    @isTest
    public static void testPatronCreateUpdateValidation(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_PatronCreateUpdateTest.GetNCNDBEDPInvalidResponse());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Allow_NDBEDP_Resync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(true,contact.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPInvalidResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            NC_NDBEDPResponseWrapper resp = new NC_NDBEDPResponseWrapper();
            resp.STATUS = 200;
            resp.ERROR_DESCRIPTION = '';
            resp.Patron = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(400);
            return response;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : testPatronCreateUpdateValidation2
    @description    : Verify NDBEDP Patron create update using mock response
    ********************************************************
    */
    @isTest
    public static void testPatronCreateUpdateValidation2(){
        contact con = [SELECT Id,County__c,Cell_Phone_Number__c,Ethnicity__c,Allow_NDBEDP_Resync__c,Status_Code__c,MobilePhone,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                       OtherCity,OtherPostalCode,OtherCountryCode,OtherStateCode,OtherCountry,OtherStreet,Birthdate,Gender__c,Patron_ID__c,Reg_End_Date__c,Preferred_Contact_Method__c
                       FROM Contact LIMIT 1];
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_PatronCreateUpdateTest.GetNCNDBEDPErrorResponse());
        NC_NDBEDP_PatronCreateUpdate updater = new NC_NDBEDP_PatronCreateUpdate (contactList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Contact contact=[SELECT Id,Allow_NDBEDP_Resync__c FROM Contact WHERE Id=:con.Id];
        System.assertEquals(true,contact.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPErrorResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            NC_NDBEDPResponseWrapper resp = new NC_NDBEDPResponseWrapper();
            resp.STATUS = 500;
            resp.ERROR_DESCRIPTION = '';
            resp.Patron = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
}