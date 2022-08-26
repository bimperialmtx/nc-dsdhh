/**
* @description       : Test class for AssessorResult
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @group             : 
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class AssessorResultTest {
    
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Create Assessor & trainer account data, create NDBEDP follow up request data
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
        
        Id recordId1 = NC_Utility.RecordTypeUtilityMethod('Account','NDBEDP_Trainer');
        Account acc1=new Account();
        acc1.RecordTypeId=recordId1;
        acc1.Email__c='testone@gmail.com';
        acc1.Name='Test one';
        acc1.BillingCity='city one';
        acc1.BillingCountry='United States';
        acc1.BillingState='Alabama';
        acc1.BillingPostalCode='12365';
        acc1.BillingStreet='123 Street';
        acc1.Same_As_Physical_Address__c=true;
        acc1.Vendor_Name__c='Test';
        acc1.Tax_Id_Number__c='987654321';
        acc1.X1099_Payee_Name__c='Test';
        acc1.Remit_to_Addr_Ln_1__c='addr';
        acc1.Remit_to_State_Cd__c='NY';
        acc1.Remit_to_Postal_Cd__c='12121';
        acc1.ShippingCity='city';
        acc1.ShippingState='Alabama';
        acc1.ShippingStreet='street';
        acc1.ShippingCountry='United States';
        acc1.ShippingPostalCode='12323';
        acc1.X1099_Code__c='12';
        acc1.Active__c=true;
        insert acc1;
        
        Contact con=new Contact();   
        // con.AccountId=acc.Id;
        con.LastName='Test Con';
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
        
        Case cas1= new Case();
        cas1.ContactId=con.Id;
        cas1.NDBEDP_Trainer__c=acc1.Id;
        cas1.Email_address__c= 'testone@gmail.com';
        cas1.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas1;
        
        Case cas2= new Case();
        cas2.ContactId=con.Id;
        cas2.Email_address__c= 'testtwo@gmail.com';
        cas2.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas2;
        
        Attendees__c attendess = new Attendees__c();
        // attendess.Trainer_Result__c = acc.Id;
        Insert attendess;
       
    }

    /*
    *********************************************************
    @Method Name    : testassessorResults
    @description    : Verify Assessor response Accept for Case/Request
    ********************************************************
    */
    @isTest
    public static void testassessorResults(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        try{
            Test.startTest();
            Boolean result= AssessorResult.assessorResult(cas.Id,'Accept');
            System.assertEquals(true, result);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }

    /*
    *********************************************************
    @Method Name    : testassessorResults1
    @description    : Verify Assessor response Accept for Attendees
    ********************************************************
    */
    @isTest
    public static void testassessorResults1(){
        Attendees__c attendess=[SELECT Id FROM Attendees__c LIMIT 1];
        try{
            Test.startTest();
            Boolean result= AssessorResult.assessorResult(attendess.Id,'Accept');
            System.assertEquals(true, result);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
    *********************************************************
    @Method Name    : testgetAssessorResult
    @description    : Verify captured response of Assessor
    ********************************************************
    */
    @isTest
    public static void testgetAssessorResult(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'Specialist'];
        UserRole role = [SELECT id FROM UserRole WHERE DeveloperName = 'Deaf_Services_Specialist' LIMIT 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, role.id);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.UserRoleId=role.Id;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert userObj;
        }        
        Attendees__c at=[SELECT Id FROM Attendees__c LIMIT 1];
        Test.startTest();
        Boolean result=AssessorResult.getAssessorResult(cas.Id);
        System.assertEquals(false, result);
        Boolean result1=AssessorResult.getAssessorResult(null);
        System.assertEquals(false, result);
        Boolean res=AssessorResult.getAssessorResult(at.Id);
        System.assertEquals(false, result);
        cas.Assessor_Result__c='Accept';
        update cas;
        Boolean result2=AssessorResult.getAssessorResult(cas.Id);
        System.assertEquals(true, result2);
        Test.stopTest();
    }

    /*
    *********************************************************
    @Method Name    : testcheckAssessor
    @description    : Verify request is assigned to valid Assessor
    ********************************************************
    */
    @isTest
    public static void testcheckAssessor(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Boolean result=AssessorResult.checkAssessor(cas.Id);
        System.assertEquals(true, result);
        Test.stopTest();
    }

    /*
    *********************************************************
    @Method Name    : testcheckAssessorone
    @description    : Verify request is assigned to valid Assessor
    ********************************************************
    */
    @isTest
    public static void testcheckAssessorone(){
        Case cas=[SELECT Id,Email_address__c FROM Case WHERE Email_address__c='testone@gmail.com'];
        Test.startTest();
        Boolean result=AssessorResult.checkAssessor(cas.Id);
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : testgetCaseNumber
    @description    : Verify returned case number is valid
    ********************************************************
    */
    @isTest
    public static void testgetCaseNumber(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Attendees__c at=[SELECT Id FROM Attendees__c LIMIT 1];
        Test.startTest();
        String result=AssessorResult.getCaseNumber(cas.Id);
        System.assertEquals(true, result!=null);
        String res=AssessorResult.getCaseNumber(at.Id);
        System.assertEquals(false, res!=null);
        Test.stopTest();
    }

    /*
    *********************************************************
    @Method Name    : testGetCasesFromAccount
    @description    : Verify cases related to account
    ********************************************************
    */
    @isTest
    public static void testGetCasesFromAccount(){
        Test.startTest();
        List<Case> resultList=AssessorResult.getCasesFromAccount();
        System.assertEquals(0, resultList.size());
        Test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : testgetProfileName
    @description    : Verify profile of logged in user
    ********************************************************
    */
    @isTest
    public static void testgetProfileName(){
        Test.startTest();
        String profileName=AssessorResult.getProfileName();
        AssessorResult.getProfileName();
        System.assertEquals(true, profileName!=null);
        Test.stopTest();
    }
    
    
}