/**
* @description       : Test class for NC_NDBEDP_ValidateEquipments
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_NDBEDP_ValidateEquipmentsTest {
    /*
    *********************************************************
    @Method Name    : executeTest
    @description    : Verify NDBEDP request equipments validations
    ********************************************************
    */
    static testmethod void executeTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(false);
        eqp.BibRecObj__c = 'Test1';
        insert eqp;
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        
        Id requestEquipmentTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        TestDataUtility.createRequestEquipment(true, requestEquipmentTypeId, request.id, eqp.id);
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentCatalogMock());
        NC_NDBEDP_ValidateEquipments queueable = new NC_NDBEDP_ValidateEquipments(request.id);
        test.startTest();
        System.enqueueJob(queueable);
        test.stopTest();
        Case req = [SELECT InActive_Equipments__c FROM Case WHERE id =: request.id];
        System.assertEquals(true, req.InActive_Equipments__c);
    }
}