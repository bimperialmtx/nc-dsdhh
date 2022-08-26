/**
* @description       : Test class for NC_ResendEquipmentRequest
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_ResendEquipmentRequestTest {
    
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be tested in this class
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
        // con.AccountId=acc.Id;
        con.LastName='Test Con';
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
@Method Name    : getStatusTest
@description    : Verify request status by id
********************************************************
*/
    @isTest
    public static void getStatusTest(){
        Case cas = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case result = NC_ResendEquipmentRequest.getStatus(cas.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest(); 
    }
    
    /*
*********************************************************
@Method Name    : validateEquipmentTest
@description    : Verify ndbedp request selected equipments status
********************************************************
*/
    @isTest
    public static void validateEquipmentTest(){
        Case cas = [SELECT Id,InActive_Equipments__c FROM Case LIMIT 1];
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, null, 'Test', 'Hearing Aid', 100);
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, cas.id, eqp.id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentCatalogMock());
        //  NC_NDBEDPEquipmentCatalog updater = new NC_NDBEDPEquipmentCatalog (userList);
        Test.startTest();
        NC_ResendEquipmentRequest.validateEquipment(cas.Id);
        System.assertEquals(false, cas.InActive_Equipments__c);
        Test.stopTest(); 
    }
    
}