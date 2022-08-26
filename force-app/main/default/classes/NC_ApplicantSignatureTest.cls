/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@isTest
public class NC_ApplicantSignatureTest {
    
    /*
*********************************************************
@Method Name    : makeData
@description    : Create test data to be used in this class
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
        con.LastName='Test Con';
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
@description    : Verify all equipments available for a request
********************************************************
*/
    @isTest
    public static void testGetEquipmentDetails(){
        
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Boolean result=NC_ApplicantSignature.getEquipmentDetails(cas.Id);
        System.assertEquals(null, result);
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        cas.RecordTypeId=requestTypeId;
        update cas;
        Boolean res=NC_ApplicantSignature.getEquipmentDetails(cas.Id);
        System.assertEquals(false, res);
        
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, cas.id, eqp.id);
        Boolean result1=NC_ApplicantSignature.getEquipmentDetails(cas.Id);
        System.assertEquals(true, result1);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getConsumerNameFromRequestTest
@description    : Verify Consumer name from request
********************************************************
*/
    @isTest
    public static void getConsumerNameFromRequestTest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case res = NC_ApplicantSignature.getConsumerNameFromRequest('');
        System.assertEquals(false, res!=null);
        Case result = NC_ApplicantSignature.getConsumerNameFromRequest(cas.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : testGetTodaysDate
@description    : Verify today's date
********************************************************
*/
    @isTest
    public static void testGetTodaysDate(){
        Test.startTest();
        Date result=NC_ApplicantSignature.getTodaysDate();
        System.assertEquals(true, result!=null);
        //System.assertNotEquals(null, NC_ApplicantSignature.getTodaysDate());
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : fetchSignatureTest
@description    : Verify signature file uploaded
********************************************************
*/
    @isTest
    public static void fetchSignatureTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        try{
            Id res=NC_ApplicantSignature.fetchSignature('');
            System.assertEquals(false, res!=null);
            Id result=NC_ApplicantSignature.fetchSignature(cas.Id);
            System.assertEquals(false, result!=null);
            NC_ApplicantSignature.RequestSignatureDataWrapper result1= NC_ApplicantSignature.fetchFields(cas.Id);
            System.assertEquals(null, result1.attestationdate);
            // System.assertNotEquals(null,NC_ApplicantSignature.fetchFields(cas.Id));
            
        }catch(Exception e){
            throw e;
        }
    }
    
    /*
*********************************************************
@Method Name    : testGetAccountFromRequest
@description    : Verify account details from request
********************************************************
*/
    @isTest
    public static void testGetAccountFromRequest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case result=NC_ApplicantSignature.getAccountFromRequest(cas.Id);
        System.assertEquals(true, result.External_Assessor__c!=null);
        //System.assertNotEquals(null,NC_ApplicantSignature.getAccountFromRequest(cas.Id));
        Test.stopTest();
    }
    /*
*********************************************************
@Method Name    : testGetAccountFromCase
@description    : Verify account details from request
********************************************************
*/    
    @isTest
    public static void testGetAccountFromCase(){
        List<User> user=[SELECT Id,Profile.Name,userrole.DeveloperName FROM User WHERE Profile.Name='Specialist' AND userrole.DeveloperName='Deaf_Services_Specialist' LIMIT 1];
        Contact con1=[SELECT Id FROM Contact LIMIT 1];
        Case cas1= new Case();
        cas1.ContactId=con1.Id;
        if(user.size()>0){
        cas1.Internal_Assessor__c =user[0].Id;
        }
        cas1.Comments__c ='';
        insert cas1;
        
        Test.startTest();
        Case result = NC_ApplicantSignature.getAccountFromRequest(cas1.Id);
        Case res=[SELECT Id,Comments__c FROM Case WHERE ContactId=:con1.Id LIMIT 1];
        System.assertEquals(false, res.Comments__c!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : testGetStatus
@description    : Verify status of request
********************************************************
*/
    @isTest
    public static void testGetStatus(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Map<String,Object> result=NC_ApplicantSignature.getStatus(cas.Id);
        System.assertEquals(true, result.size()>0);
        //System.assertNotEquals(null,NC_ApplicantSignature.getStatus(cas.Id));
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveDataTest
@description    : Verify applicant signature form data
********************************************************
*/
    @isTest
    public static void saveDataTest(){
        Case cas=[SELECT Id,External_Assessor__c FROM Case LIMIT 1];
        Test.startTest();
        try{
            String result=NC_ApplicantSignature.saveData('{"applicantsSignature":"","attestationdate":"2021-11-23","personCompletingInformation":"","relationship":"","phoneNumber":"","alternatecontact":"","relationshipofalternatecontact":"","phoneNumberofalternatecontact":"","emailaddress":"","signed":"","frombutton":"fromaccept","onlineAssessor":false,"internalAssessor":false,"requestId":"'+cas.Id+'\"}');
            system.assertEquals(true, result!=null);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveCommentDataTest
@description    : Verify comment provided while reject
********************************************************
*/
    @isTest
    public static void saveCommentDataTest(){
        Case cas=[SELECT Id,External_Assessor__c FROM Case LIMIT 1];
        Test.startTest();
        try{
            NC_ApplicantSignature.saveCommentData('{"applicantsSignature":"","attestationdate":"2021-11-23","personCompletingInformation":"","relationship":"","phoneNumber":"","alternatecontact":"","relationshipofalternatecontact":"","phoneNumberofalternatecontact":"","emailaddress":"","signed":"","frombutton":"fromaccept","onlineAssessor":false,"internalAssessor":false,"requestId":"'+cas.Id+'\"}');
            Case result =[SELECT Id,Comments__c FROM Case LIMIT 1];
            system.assertEquals(null, result.Comments__c);
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    
}