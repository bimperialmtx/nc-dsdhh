/**
* @description       : Test class for NC_NDBEDPUpdateLineItems
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDPUpdateLineItemsTest {
    
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
        
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(false);
        eqp.IsActive__c = true;
        eqp.Amount_Authorized__c = 100;
        insert eqp;
        
        Case edsRequest = TestDataUtility.createNDBEDPCase(false, con.id);
        edsRequest.MatRequestObj__c = '54645937.9532';
        insert edsRequest;
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c requestEquipment = TestDataUtility.createRequestEquipment(false, requestEquipmentTypeId, edsRequest.id, eqp.id);
        requestEquipment.MatRequestLineObj__c = '54645944.9532';
        insert requestEquipment;
    }

    /*
    *********************************************************
    @Method Name    : testGetEquipmentDetails
    @description    : Verify NDBEDP update line items using mock response
    ********************************************************
    */
    @IsTest
    public static void testGetEquipmentDetails(){
        Request_Equipment__c requestEquipment = [SELECT Id, equipment__c FROM Request_Equipment__c LIMIT 1];
        Set<Id> requestList = new Set <Id>();
        requestList.add(requestEquipment.Id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentHistoryMock());
        
        NC_NDBEDPUpdateLineItems updater = new NC_NDBEDPUpdateLineItems(requestList);
        
        Test.startTest();
        System.enqueueJob(updater);
        Test.stopTest();
        Request_Equipment__c equip=[SELECT Id,MatRequestObj__c FROM Request_Equipment__c WHERE Id=:requestEquipment.Id];
        System.assertEquals('54645937.9532', equip.MatRequestObj__c);
    }
}