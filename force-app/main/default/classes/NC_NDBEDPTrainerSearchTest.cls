/**
* @description       : Test class for NC_NDBEDPTrainerSearch
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDPTrainerSearchTest {
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
        // acc.Name='Test';
        acc.First_Name__c = 'test';
        acc.Last_Name__c = 'TestCon';
        acc.Name = 'test';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.County__c = 'Craven';
        acc.Cell_Phone__c = '1234567890';
        acc.Allow_NDBEDP_Resync__c = true;
        acc.Status_Code__c = 'Active';
        acc.Work_Phone__c = '1234567890';
        acc.Gender__c = 'Male';
        acc.Patron_ID__c = 'ADVENE01';
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
@Method Name    : testGetEquipmentDetails
@description    : Verify NDBEDP Trainer using mock response
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails(){
        Account acc = [SELECT Id,Patron_ID__c,Patron_Obj__c,Status_Code__c,Library_ID__c,First_Name__c,Last_Name__c
                       FROM Account LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetNCNDBEDPPatronSearch());
        NC_NDBEDPTrainerSearch updater = new NC_NDBEDPTrainerSearch (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Patron_Type__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals('TA', account.Patron_Type__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetailsValidations
    @description    : Verify NDBEDP Trainer validation using mock response
    ********************************************************
    */
    @isTest
    public static void testGetEquipmentDetailsValidations(){
        Account acc = [SELECT Id,Patron_ID__c,Patron_Obj__c,Status_Code__c,Library_ID__c,First_Name__c,Last_Name__c
                       FROM Account LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.ExceptionMock());
        NC_NDBEDPTrainerSearch updater = new NC_NDBEDPTrainerSearch (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Allow_NDBEDP_Resync__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(true, account.Allow_NDBEDP_Resync__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetailsValidations2
    @description    : Verify NDBEDP Trainer validation using mock response
    ********************************************************
    */
    @isTest
    public static void testGetEquipmentDetailsValidations2(){
        Account acc = [SELECT Id,Patron_ID__c,Patron_Obj__c,Status_Code__c,Library_ID__c,First_Name__c,Last_Name__c
                       FROM Account LIMIT 1];
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        Test.setMock(HttpCalloutMock.class, new NC_NDBEDPTrainerSearchTest.GetNCNDBEDPPatronInvalidSearch());
        NC_NDBEDPTrainerSearch updater = new NC_NDBEDPTrainerSearch (accountList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest(); 
        Account account=[SELECT Id,Allow_NDBEDP_Resync__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(true, account.Allow_NDBEDP_Resync__c);
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