/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_NDBEDP_AssessorSearchByIdTest {
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be used in this class
********************************************************
*/  
    @TestSetup
    public static void makeData(){
        
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
            
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
        
        Contact con1=new Contact();   
        con1.FirstName = 'testingA';
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
        con2.FirstName = 'testingB';
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
        con3.FirstName = 'testingC';
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
        cas.Assessor_Comment__c ='test';
        cas.Comments__c ='';
        insert cas;
        
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails2
@description    : Veirfy NDBEDP Assessor search by id using mock response
********************************************************
*/ 
    @isTest
    public static void testGetEquipmentDetails2(){
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '12345';
        userObj.Street = 'test';
        userObj.City = 'Test';
        //userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.StateCode = 'NC';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Email';
        userObj.Gender__c = 'Male';
        insert userObj;
        
        List<User> userList = new List<User>();
        userList.add(userObj);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPPatronSearch());
        NC_NDBEDP_AssessorSearchById updater = new NC_NDBEDP_AssessorSearchById (userList);
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(updater);
            Test.stopTest();
            User use=[SELECT Id,Patron_Type__c FROM User WHERE Id=:userObj.Id];
            System.assertEquals(true,use.Patron_Type__c!=null);
        }
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails3
@description    : Veirfy NDBEDP Assessor search validations by id using mock response
********************************************************
*/ 
    @isTest
    public static void testGetEquipmentDetails3(){
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
        
        List<User> userList = new List<User>();
        userList.add(userObj);
        NC_NDBEDP_AssessorSearchById updater = new NC_NDBEDP_AssessorSearchById (userList);
        System.runAs(userObj){
            try{
                Test.startTest();
                System.enqueueJob(updater);
                Test.stopTest();
                User use=[SELECT Id,Address FROM User WHERE Id=:userObj.Id];
                System.assertEquals(true,use.Address!=null);
            }
            Catch(Exception e){
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : assessorSearchByIdValidationTest
    @description    : Veirfy NDBEDP Assessor search validations by id using mock response
    ********************************************************
    */
    @isTest
    public static void assessorSearchByIdValidationTest(){
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '12345';
        userObj.Street = 'test';
        userObj.City = 'Test';
        //userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.StateCode = 'NC';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Email';
        userObj.Gender__c = 'Male';
        insert userObj;
        
        List<User> userList = new List<User>();
        userList.add(userObj);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_AssessorSearchByIdTest.GetNCNDBEDPPatronErrorSearch());
        NC_NDBEDP_AssessorSearchById updater = new NC_NDBEDP_AssessorSearchById (userList);
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(updater);
            Test.stopTest();
            User use=[SELECT Id,Allow_NDBEDP_Resync__c FROM User WHERE Id=:userObj.Id];
            System.assertEquals(true,use.Allow_NDBEDP_Resync__c);
        }
    }
    
    public class GetNCNDBEDPPatronErrorSearch implements HttpCalloutMock{
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
    @Method Name    : assessorSearchByIdValidation2Test
    @description    : Veirfy NDBEDP Assessor search validations by id using mock response
    ********************************************************
    */
    @isTest
    public static void assessorSearchByIdValidation2Test(){
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Blind_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'test', 'TestCon', 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.Secondary_Regional_Centers__c = 'Charlotte Regional Center';
        userObj.PostalCode = '12345';
        userObj.Street = 'test';
        userObj.City = 'Test';
        //userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.Patron_ID__c = 'Test';
        userObj.MobilePhone = '1234567890';
        userObj.Work_Phone_Number__c = '1234567890';
        userObj.Alt_Phone_Number__c = '1234567890';
        userObj.Video_Phone__c = '1234567890';
        userObj.Street = 'Test';
        userObj.StateCode = 'NC';
        userObj.CountryCode = 'US';
        userObj.Preferred_Contact_Method__c = 'Email';
        userObj.Gender__c = 'Male';
        insert userObj;
        
        List<User> userList = new List<User>();
        userList.add(userObj);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDP_AssessorSearchByIdTest.GetNCNDBEDPPatronInvalidSearch());
        NC_NDBEDP_AssessorSearchById updater = new NC_NDBEDP_AssessorSearchById (userList);
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(updater);
            Test.stopTest();
            User use=[SELECT Id,Allow_NDBEDP_Resync__c FROM User WHERE Id=:userObj.Id];
            System.assertEquals(true,use.Allow_NDBEDP_Resync__c);
        }
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
}