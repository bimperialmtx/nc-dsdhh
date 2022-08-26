/**
* @description       : Test class for NC_NDBEDPEquipmentCatalog
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDPEquipmentCatalogTest {
    
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be used in this class
********************************************************
*/
    @TestSetup
    public static void makeData(){
        
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        Contact con = TestDataUtility.createConsumer(true);
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(false, equipmentTypeId, null, 'test', 'Hearing Aid', 100);
        eqp.IsActive__c = true;
        eqp.BibRecObj__c = '575390.9532';
        insert eqp;
        
        Id equipmentRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case edsRequest = TestDataUtility.createCase(false, equipmentRequestId, con.id, 'EDS', 'Hearing Aid');
        edsRequest.MatRequestID__c = '1223';
        Insert edsRequest;
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, edsRequest.id, eqp.id);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails
@description    : Verify NDBEDP equipments using mock response
********************************************************
*/
    @IsTest
    public static void testGetEquipmentDetails(){
        Request_Equipment__c requestEquipment = [SELECT Id FROM Request_Equipment__c LIMIT 1];
        Case cas = [SELECT Id,MatRequestID__c FROM case LIMIT 1];
        
        Set<Id> requestList = new Set <Id>();
        requestList.add(requestEquipment.Id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentCatalogMock());
        
        /*  NC_NDBEDPUpdateLineItems updater = new NC_NDBEDPUpdateLineItems(requestList);*/
        
        Test.startTest();
        // NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestList,cas.Id);
        NC_NDBEDPEquipmentCatalog.validateEquipment(cas.Id);
        Request_Equipment__c equip=[SELECT Id,BibRecObj__c FROM Request_Equipment__c WHERE Id=:requestEquipment.Id];
        System.assertEquals(true, equip.BibRecObj__c!=null);
        String result = NC_NDBEDPEquipmentCatalog.getEquipmentRequestStatus(cas.Id);
        system.assertEquals(true,result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails1
@description    : Verify NDBEDP equipments validations using mock response
********************************************************
*/
    @IsTest
    public static void testGetEquipmentDetails1(){
        Request_Equipment__c requestEquipment = [SELECT Id,MatRequestLineObj__c,LastActionCode__c FROM Request_Equipment__c LIMIT 1];
        Case cas = [SELECT Id,MatRequestID__c FROM case LIMIT 1];
        
        Set<Id> requestList = new Set <Id>();
        requestList.add(requestEquipment.Id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentHistoryMock());
        
        Test.startTest();
        NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestList,cas.Id);
        Test.stopTest();
        Request_Equipment__c equip=[SELECT Id,MatRequestID__c FROM Request_Equipment__c WHERE Id=:requestEquipment.Id];
        System.assertEquals('1223', equip.MatRequestID__c);
    }
    
    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetails2
    @description    : Verify NDBEDP equipments validations using mock response
    ********************************************************
    */
    @IsTest
    public static void testGetEquipmentDetails2(){
        Request_Equipment__c requestEquipment = [SELECT Id,MatRequestLineObj__c,LastActionCode__c FROM Request_Equipment__c LIMIT 1];
        Case cas = [SELECT Id,MatRequestID__c FROM case LIMIT 1];
        cas.MatReqType__c = 'Demo';
        update cas;
        
        Set<Id> requestList = new Set <Id>();
        requestList.add(requestEquipment.Id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentDemoHistoryMock());
        
        Test.startTest();
        NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestList,cas.Id);
        Test.stopTest();
        Request_Equipment__c equip=[SELECT Id,MatRequestID__c FROM Request_Equipment__c WHERE Id=:requestEquipment.Id];
        System.assertEquals('1223', equip.MatRequestID__c);
    }
    
    /*
*********************************************************
@Method Name    : testGetEquipmentDetails3
@description    : Verify NDBEDP equipments validations using mock response
********************************************************
*/
    @IsTest
    public static void testGetEquipmentDetails3(){
        Request_Equipment__c requestEquipment = [SELECT Id,MatRequestLineObj__c,LastActionCode__c FROM Request_Equipment__c LIMIT 1];
        Account assessor = TestDataUtility.createAssessor(false);
        assessor.BillingStreet = 'test';
        assessor.Status__c = 'Approved';
        assessor.Active__c = true;
        insert assessor;
        Case cas = [SELECT Id,MatRequestID__c FROM case LIMIT 1];
        
        Set<Id> requestList = new Set <Id>();
        requestList.add(requestEquipment.Id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentHistoryMock());
        
        Test.startTest();
        cas.External_Assessor__c = assessor.id;
        update cas;
        NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestList,cas.Id);
        Test.stopTest();
        Request_Equipment__c equip=[SELECT Id,MatRequestID__c FROM Request_Equipment__c WHERE Id=:requestEquipment.Id];
        System.assertEquals('1223', equip.MatRequestID__c);
    }
}