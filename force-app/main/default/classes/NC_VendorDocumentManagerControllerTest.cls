/**
* @description       : Test class for NC_VendorDocumentManagerController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_VendorDocumentManagerControllerTest {
    
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
        acc.Name='TestA';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        acc.Hearing_Aid_Provider__c = true;
        acc.Document_In_Renewal_Process__c = true;
        insert acc;
        
        // Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc1=new Account();
        acc1.RecordTypeId=recordId;
        acc1.Email__c='test@gmail.com';
        acc1.Name='TestB';
        acc1.BillingCity='city';
        acc1.BillingCountry='United States';
        acc1.BillingState='Alabama';
        acc1.BillingPostalCode='12345';
        acc1.BillingStreet='123 Street';
        acc1.Active__c=true;
        acc1.Hearing_Aid_Provider__c = true;
        acc1.Electronic__c = true;
        acc1.Document_In_Renewal_Process__c = true;
        insert acc1;
        
        Account acc2=new Account();
        acc2.RecordTypeId=recordId;
        acc2.Email__c='test@gmail.com';
        acc2.Name='TestC';
        acc2.BillingCity='city';
        acc2.BillingCountry='United States';
        acc2.BillingState='Alabama';
        acc2.BillingPostalCode='12345';
        acc2.BillingStreet='123 Street';
        acc2.Active__c=true;
        acc2.CART__c = true;
        acc2.Document_In_Renewal_Process__c = true;
        insert acc2;
        
        
        Account acc3=new Account();
        acc3.RecordTypeId=recordId;
        acc3.Email__c='test@gmail.com';
        acc3.Name='TestD';
        acc3.BillingCity='city';
        acc3.BillingCountry='United States';
        acc3.BillingState='Alabama';
        acc3.BillingPostalCode='12345';
        acc3.BillingStreet='123 Street';
        acc3.Active__c=true;
        acc3.SSP__c = true;
        acc3.Document_In_Renewal_Process__c = true;
        insert acc3;
        
        Account acc4=new Account();
        acc4.RecordTypeId=recordId;
        acc4.Email__c='test@gmail.com';
        acc4.Name='TestE';
        acc4.BillingCity='city';
        acc4.BillingCountry='United States';
        acc4.BillingState='Alabama';
        acc4.BillingPostalCode='12345';
        acc4.BillingStreet='123 Street';
        acc4.Active__c=true;
        acc4.Training_Vendor__c = true;
        acc4.Document_In_Renewal_Process__c = true;
        insert acc4;
        
        Account acc5=new Account();
        acc5.RecordTypeId=recordId;
        acc5.Email__c='test@gmail.com';
        acc5.Name='TestF';
        acc5.BillingCity='city';
        acc5.BillingCountry='United States';
        acc5.BillingState='Alabama';
        acc5.BillingPostalCode='12345';
        acc5.BillingStreet='123 Street';
        acc5.Active__c=true;
        acc5.Interpreter__c = true;
        acc5.Individual__c = true;
        acc5.License_Type__c = 'Full License';
        acc5.Document_In_Renewal_Process__c = true;
        insert acc5;
        
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
        
        Attendees__c attendess = new Attendees__c();
        // attendess.Trainer_Result__c = acc.Id;
        Insert attendess;
    }
    
    /*
    *********************************************************
    @Method Name    : testassessorResults1
    @description    : Verify documents for Vendor
    ********************************************************
    */
    @isTest
    public static void testassessorResults1(){
        Account acc=[SELECT Id FROM Account   WHERE Name = 'TestA'];
        try{
            Test.startTest();
            Map<String,Object> result = NC_VendorDocumentManagerController.retrieveVendorFilesList(acc.Id);
            System.assertEquals(true, result.size()>0);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }

    /*
    *********************************************************
    @Method Name    : testassessorResults2
    @description    : Verify documents for Vendor and validations
    ********************************************************
    */
    @isTest
    public static void testassessorResults2(){
        Account acc=[SELECT Id FROM Account  WHERE Name = 'TestB'];
        try{
            Test.startTest();
            Map<String,Object> result = NC_VendorDocumentManagerController.retrieveVendorFilesList(acc.Id);
            System.assertEquals(true, result.size()>0);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }

    /*
    *********************************************************
    @Method Name    : testassessorResults3
    @description    : Verify documents for Vendor and validations
    ********************************************************
    */
    @isTest
    public static void testassessorResults3(){
        Account acc=[SELECT Id FROM Account  WHERE Name = 'TestC'];
        try{
            Test.startTest();
            Map<String,Object> result = NC_VendorDocumentManagerController.retrieveVendorFilesList(acc.Id);
            System.assertEquals(true, result.size()>0);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }

    /*
    *********************************************************
    @Method Name    : testassessorResults4
    @description    : Verify documents for Vendor and validations
    ********************************************************
    */
    @isTest
    public static void testassessorResults4(){
        Account acc=[SELECT Id FROM Account  WHERE Name = 'TestD'];
        try{
            Test.startTest();
            Map<String,Object> result = NC_VendorDocumentManagerController.retrieveVendorFilesList(acc.Id);
            System.assertEquals(true, result.size()>0);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
    *********************************************************
    @Method Name    : testassessorResults5
    @description    : Verify documents for Vendor and validations
    ********************************************************
    */
    @isTest
    public static void testassessorResults5(){
        Account acc=[SELECT Id FROM Account  WHERE Name = 'TestE'];
        try{
            Test.startTest();
            Map<String,Object> result = NC_VendorDocumentManagerController.retrieveVendorFilesList(acc.Id);
            System.assertEquals(true, result.size()>0);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
    
    /*
    *********************************************************
    @Method Name    : testassessorResults6
    @description    : Verify documents for Vendor and validations
    ********************************************************
    */
    @isTest
    public static void testassessorResults6(){
        Account acc=[SELECT Id FROM Account  WHERE Name = 'TestF'];
        try{
            Test.startTest();
            Map<String,Object> result = NC_VendorDocumentManagerController.retrieveVendorFilesList(acc.Id);
            System.assertEquals(true, result.size()>0);
            Test.stopTest();
        }
        catch (Exception e) {
        }
    }
}