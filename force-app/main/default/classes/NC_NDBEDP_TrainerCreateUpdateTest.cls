/**
* @description       : Test class for NC_NDBEDP_TrainerCreateUpdate
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDP_TrainerCreateUpdateTest {
    
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
        
        // con.Patron_ID__c = 'NC-2202015';
        insert con1;
        
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
        acc.County__c = 'Craven';
        acc.Cell_Phone__c = '1234567890';
        acc.Alternative_Phone__c = '1234567890';
        acc.Allow_NDBEDP_Resync__c = true;
        acc.Status_Code__c = 'Active';
        acc.Work_Phone__c = '1234567890';
        acc.Gender__c = 'Male';
        acc.Suffix__c = 'Esq';
        acc.Ethnicity__c = 'Not Hispanic/Latino';
        acc.Primary_Language__c = 'English';
        acc.Video_Phone__c = '1234567890';
        acc.Work_Phone__c = '1234567890';
        acc.Preferred_Method_of_Contact__c = 'Cell Phone';
        acc.Patron_Contact_Obj_MobilePhone__c = '1234567890';
        acc.Patron_Contact_Obj_WorkPhone__c = '1234567890';
        acc.Patron_Contact_Obj_AltPhone__c = '1234567890';
        acc.Patron_Contact_Obj_Video_Phone__c = '1234567890';
        acc.Patron_Contact_Obj_Email__c = 'test@gmail.com';
        acc.Patron_Contact_Obj_Add__c = 'test';
        insert acc;
        
        // Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc1=new Account();
        acc1.RecordTypeId=recordId;
        acc1.Email__c='test1@gmail.com';
        acc1.Name='Test';
        acc1.BillingCity='city';
        acc1.BillingCountry='United States';
        acc1.BillingState='Alabama';
        acc1.BillingPostalCode='12345';
        acc1.BillingStreet='123 Street';
        acc1.Active__c=true;
        acc1.County__c = 'Craven';
        acc1.Cell_Phone__c = '1234567890';
        acc1.Alternative_Phone__c = '1234567890';
        acc1.Allow_NDBEDP_Resync__c = true;
        acc1.Status_Code__c = 'Active';
        acc1.Work_Phone__c = '1234567890';
        acc1.Gender__c = 'Male';
        acc1.Suffix__c = 'Esq';
        acc1.Ethnicity__c = 'Not Hispanic/Latino';
        acc1.Primary_Language__c = 'English';
        acc1.Video_Phone__c = '1234567890';
        acc1.Work_Phone__c = '1234567890';
        acc1.Preferred_Method_of_Contact__c = 'Work Phone';
        acc1.Patron_Contact_Obj_MobilePhone__c = '1234567890';
        acc1.Patron_Contact_Obj_WorkPhone__c = '1234567890';
        acc1.Patron_Contact_Obj_AltPhone__c = '1234567890';
        acc1.Patron_Contact_Obj_Video_Phone__c = '1234567890';
        acc1.Patron_Contact_Obj_Email__c = 'test@gmail.com';
        acc1.Patron_Contact_Obj_Add__c = 'test';
        insert acc1;
        
        // Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc2=new Account();
        acc2.RecordTypeId=recordId;
        acc2.Email__c='test1@gmail.com';
        acc2.Name='Test';
        acc2.BillingCity='city';
        acc2.BillingCountry='United States';
        acc2.BillingState='Alabama';
        acc2.BillingPostalCode='12345';
        acc2.BillingStreet='123 Street';
        acc2.Active__c=true;
        acc2.County__c = 'Craven';
        acc2.Cell_Phone__c = '1234567890';
        acc2.Alternative_Phone__c = '1234567890';
        acc2.Allow_NDBEDP_Resync__c = true;
        acc2.Status_Code__c = 'Active';
        acc2.Work_Phone__c = '1234567890';
        acc2.Gender__c = 'Male';
        acc2.Suffix__c = 'Esq';
        acc2.Ethnicity__c = 'Not Hispanic/Latino';
        acc2.Primary_Language__c = 'English';
        acc2.Video_Phone__c = '1234567890';
        acc2.Work_Phone__c = '1234567890';
        acc2.Preferred_Method_of_Contact__c = 'Alternative Phone';
        acc2.Patron_Contact_Obj_MobilePhone__c = '1234567890';
        acc2.Patron_Contact_Obj_WorkPhone__c = '1234567890';
        acc2.Patron_Contact_Obj_AltPhone__c = '1234567890';
        acc2.Patron_Contact_Obj_Video_Phone__c = '1234567890';
        acc2.Patron_Contact_Obj_Email__c = 'test@gmail.com';
        acc2.Patron_Contact_Obj_Add__c = 'test';
        insert acc2;
        
        
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
        
        // con.Patron_ID__c = 'NC-2202015';
        insert con;
        
        
        
        
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
@description    : Verify NDBEDP Trainer create update using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails(){
        Account acc = [SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Patron_Contact_Obj_MobilePhone__c,Ethnicity__c,Phone,Preferred_Method_of_Contact__c,Primary_Language__c,Cell_Phone__c,Suffix__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,
                       BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,
                       Patron_Contact_Obj_Video_Phone__c,Video_Phone__c, Patron_Contact_Obj_Email__c,Patron_Contact_Obj_Add__c
                       FROM Account LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_TrainerCreateUpdate updater = new NC_NDBEDP_TrainerCreateUpdate (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Primary_Language__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals('English',account.Primary_Language__c);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails1
@description    : Verify NDBEDP Trainer create update validation using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails1(){
        Account acc = [SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Patron_Contact_Obj_MobilePhone__c,Ethnicity__c,Phone,Preferred_Method_of_Contact__c,Primary_Language__c,Cell_Phone__c,Suffix__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,
                       BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,
                       Patron_Contact_Obj_Video_Phone__c,Video_Phone__c, Patron_Contact_Obj_Email__c,Patron_Contact_Obj_Add__c
                       FROM Account WHERE Preferred_Method_of_Contact__c = 'Alternative Phone'  LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_TrainerCreateUpdate updater = new NC_NDBEDP_TrainerCreateUpdate (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Allow_NDBEDP_Resync__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(false,account.Allow_NDBEDP_Resync__c);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails2
@description    : Verify NDBEDP Trainer create update validation using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails2(){
        Account acc = [SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Patron_Contact_Obj_MobilePhone__c,Ethnicity__c,Phone,Preferred_Method_of_Contact__c,Primary_Language__c,Cell_Phone__c,Suffix__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,
                       BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,
                       Patron_Contact_Obj_Video_Phone__c,Video_Phone__c, Patron_Contact_Obj_Email__c,Patron_Contact_Obj_Add__c
                       FROM Account WHERE Preferred_Method_of_Contact__c = 'Work Phone'  LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_TrainerCreateUpdate updater = new NC_NDBEDP_TrainerCreateUpdate (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Library_ID__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals('NC',account.Library_ID__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetails3
    @description    : Verify NDBEDP Trainer create update validation using mock response
    ********************************************************
    */
    @isTest
    public static void testGetEquipmentDetails3(){
        Account acc = [SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Patron_Contact_Obj_MobilePhone__c,Ethnicity__c,Phone,Preferred_Method_of_Contact__c,Primary_Language__c,Cell_Phone__c,Suffix__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,
                       BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,
                       Patron_Contact_Obj_Video_Phone__c,Video_Phone__c, Patron_Contact_Obj_Email__c,Patron_Contact_Obj_Add__c
                       FROM Account WHERE Preferred_Method_of_Contact__c = 'Work Phone'  LIMIT 1];
        acc.Preferred_Method_of_Contact__c = 'Video Phone';
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_TrainerCreateUpdate updater = new NC_NDBEDP_TrainerCreateUpdate (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Library_ID__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals('NC',account.Library_ID__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testTrainerCreateUpdateTest
    @description    : Verify NDBEDP Trainer create update validation using mock response
    ********************************************************
    */
    @isTest
    public static void testTrainerCreateUpdateValidationTest(){
        Account acc = [SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Patron_Contact_Obj_MobilePhone__c,Ethnicity__c,Phone,Preferred_Method_of_Contact__c,Primary_Language__c,Cell_Phone__c,Suffix__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,
                       BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,
                       Patron_Contact_Obj_Video_Phone__c,Video_Phone__c, Patron_Contact_Obj_Email__c,Patron_Contact_Obj_Add__c
                       FROM Account WHERE Preferred_Method_of_Contact__c = 'Work Phone'  LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_TrainerCreateUpdateTest.GetNCNDBEDPResponseInvalidMock());
        NC_NDBEDP_TrainerCreateUpdate updater = new NC_NDBEDP_TrainerCreateUpdate (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Allow_NDBEDP_Resync__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(true,account.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPResponseInvalidMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            NC_NDBEDPResponseWrapper resp = new NC_NDBEDPResponseWrapper();
            resp.STATUS = 200;
            resp.ERROR_DESCRIPTION = '';
            resp.Patron = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(500);
            return response;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : testTrainerCreateUpdateTest2
    @description    : Verify NDBEDP Trainer create update validation using mock response
    ********************************************************
    */
    @isTest
    public static void testTrainerCreateUpdateValidation2Test(){
        Account acc = [SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Patron_Contact_Obj_MobilePhone__c,Ethnicity__c,Phone,Preferred_Method_of_Contact__c,Primary_Language__c,Cell_Phone__c,Suffix__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,
                       BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,
                       Patron_Contact_Obj_Video_Phone__c,Video_Phone__c, Patron_Contact_Obj_Email__c,Patron_Contact_Obj_Add__c
                       FROM Account WHERE Preferred_Method_of_Contact__c = 'Work Phone'  LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_TrainerCreateUpdateTest.GetNCNDBEDPResponseErrorMock());
        NC_NDBEDP_TrainerCreateUpdate updater = new NC_NDBEDP_TrainerCreateUpdate (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Allow_NDBEDP_Resync__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(true,account.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPResponseErrorMock implements HttpCalloutMock{
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