/**
* @description       : Test class for NC_GenerateAssessmentEmail
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_GenerateAssessmentEmailTest {
    /*
    *********************************************************
    @Method Name    : batchTest
    @description    : Create data to be used in this class
    ********************************************************
    */
    @TestSetup
    public static void batchTest() {
        
        // Test.startTest(); 
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.First_Name__c='Test';
        acc.Last_Name__c= 'first';
        acc.Name = 'few';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        acc.Is_Vendor_on_Portal__c = true;
        insert acc;
        
        
        Contact con=new Contact();   
        con.LastName='Test Con';
        con.AccountId = acc.Id;
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        cas.Status = 'Pending Assessment';
        cas.Assessor_Result__c = 'Accept';
        cas.Assessor_Invitation_Accepted_Date__c = Date.today()-50;
        cas.External_Assessor__c = acc.Id;
        // cas.e
        insert cas;
       
    }

    /*
    *********************************************************
    @Method Name    : checkBatch
    @description    : Verify generation of assessment emails
    ********************************************************
    */
    @IsTest
    public static void checkBatch(){
        
        Account acc = [SELECT Id,Last_Name__c FROM Account LIMIT 1];
        Contact con = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        Integer randomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        Profile p = [SELECT id FROM Profile WHERE name = 'NDBEDP Assessor'];
        //UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User userObj = TestDataUtility.createUser(false, 'First'+randomId, 'Last'+randomId, 'email'+randomId+'@gmail.com', randomId+'@username.com', randomId+'al', p.id, null);
        userObj.Regional_Center__c = 'Asheville Regional Center';
        userObj.PostalCode = '28370';
        userObj.Street = 'test';
        userObj.City = 'Pinehurst';
        userObj.State = 'Alabama';
        userObj.Country = 'United States';
        userObj.ContactId = con.Id;
        userObj.IsActive = true;
        
        test.startTest();
        insert userObj;
        test.stopTest();
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            
            Case cas = [SELECT Id,CaseNumber,Assessor_Invitation_Accepted_Date__c,Assessor_Result__c,External_Assessor_User__c,External_Assessor_User__r.Email,Status FROM Case LIMIT 1];
            
            cas.External_Assessor_User__c = userObj.Id;
            update cas;
            NC_GenerateAssessmentEmail batch = new NC_GenerateAssessmentEmail();
            Database.executeBatch(batch);
            System.assertNotEquals(null,  Database.executeBatch(batch));
            
        }
    }
    
}