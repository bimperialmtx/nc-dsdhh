/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_NDBEDP_AssessorCreateUpdateTest {
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
        con.FirstName = 'test';
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
        insert con;
        
        
        
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
@Method Name    : emailPreferredMethodTest
@description    : Verify NDBEDP Asessor create or update using mock response
********************************************************
*/
    @isTest
    public static void emailPreferredMethodTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Email';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        User u=[SELECT Id,Patron_Type__c FROM User WHERE Id=:userObj1.Id];
        System.assertEquals('TA',u.Patron_Type__c);
    }
    
    /*
*********************************************************
@Method Name    : mobilePhonePreferredMethodTest
@description    : Verify NDBEDP Asessor create or update validations using mock response
********************************************************
*/
    @isTest
    public static void mobilePhonePreferredMethodTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Mobile Phone';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        User u=[SELECT Id,Patron_Obj__c FROM User WHERE Id=:userObj1.Id];
        System.assertEquals('Test',u.Patron_Obj__c);
    }
    /*you are   @isTest
public static void workPhoneNumberPreferredMethodTest(){
Contact con = [SELECT Id FROM Contact LIMIT 1];
Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
userObj.Regional_Center__c = 'Asheville Regional Center';
userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
userObj.PostalCode = '28370';
userObj.Street = 'test';
userObj.City = 'Pinehurst';
userObj.State = 'Alabama';
userObj.Country = 'United States';
userObj.Patron_ID__c = 'Test';
userObj.MobilePhone = '1234567890';
userObj.Work_Phone_Number__c = '1234567890';
userObj.Alt_Phone_Number__c = '1234567890';
userObj.Video_Phone__c = '1234567890';
userObj.Street = 'Test';
userObj.CountryCode = 'US';
userObj.Preferred_Contact_Method__c = 'Work Phone Number';
insert userObj;

User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
WHERE Id =:userObj.Id LIMIT 1];


List<User> userList = new List<User>();
userList.add(userObj1);
Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);

Test.startTest();
System.enqueueJob(updater);
Test.stopTest(); 
}*/
    
    /*
*********************************************************
@Method Name    : alternativePhonePreferredMethodTest
@description    : Verify NDBEDP Asessor create or update validations using mock response
********************************************************
*/
    @isTest
    public static void alternativePhonePreferredMethodTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Alternative Phone';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        User u=[SELECT Id,Patron_Type__c FROM User WHERE Id=:userObj1.Id];
        System.assertEquals('TA',u.Patron_Type__c);
    }
    
    /*
*********************************************************
@Method Name    : videoPhonePreferredMethodTest
@description    : Verify NDBEDP Asessor create or update validations using mock response
********************************************************
*/
    @isTest
    public static void videoPhonePreferredMethodTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Video Phone';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        User u=[SELECT Id,Address FROM User WHERE Id=:userObj1.Id];
        System.assertEquals(true,u.Address!=null);
    }
    
    /*
    *********************************************************
    @Method Name    : workPhonePreferredMethodTest
    @description    : Verify NDBEDP Asessor create or update validations using mock response
    ********************************************************
    */
    @isTest
    public static void workPhonePreferredMethodTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Work Phone';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPResponseWrapper());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        User u=[SELECT Id,Patron_Type__c FROM User WHERE Id=:userObj1.Id];
        System.assertEquals('TA',u.Patron_Type__c);
    }
    
    /*
    *********************************************************
    @Method Name    : assessorCreateUpdateValidationTest
    @description    : Verify NDBEDP Asessor create or update validations using mock response
    ********************************************************
    */
    @isTest
    public static void assessorCreateUpdateValidationTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Work Phone';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_AssessorCreateUpdateTest.GetNCNDBEDPResponseErrorMock());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        User u=[SELECT Id,Allow_NDBEDP_Resync__c FROM User WHERE Id=:userObj1.Id];
        System.assertEquals(true,u.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPResponseErrorMock implements HttpCalloutMock{
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
    @Method Name    : assessorCreateUpdateValidation2Test
    @description    : Verify NDBEDP Asessor create or update validations using mock response
    ********************************************************
    */
    @isTest
    public static void assessorCreateUpdateValidation2Test(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Work Phone';
        insert userObj;
        
        User userObj1 = [SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                         Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Street,CountryCode,City,PostalCode,StateCode,Preferred_Contact_Method__c,Work_Phone_Number__c,Email,Alt_Phone_Number__c,Video_Phone__c,County__c,Patron_Type__c,MobilePhone,Ethnicity__c,Primary_Language__c,MiddleName,FirstName,LastName,Suffix,BirthDate__c,Gender__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User
                         WHERE Id =:userObj.Id LIMIT 1];
        
        
        List<User> userList = new List<User>();
        userList.add(userObj1);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_AssessorCreateUpdateTest.GetNCNDBEDPResponseInvalidMock());
        NC_NDBEDP_AssessorCreateUpdate updater = new NC_NDBEDP_AssessorCreateUpdate (userList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        User u=[SELECT Id,Allow_NDBEDP_Resync__c FROM User WHERE Id=:userObj1.Id];
        System.assertEquals(true,u.Allow_NDBEDP_Resync__c);
    }
    
    public class GetNCNDBEDPResponseInvalidMock implements HttpCalloutMock{
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