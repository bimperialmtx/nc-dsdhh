/**
* @description       : Test class for NC_HA_ConApprovalController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_HA_ConApprovalControllerTest {

    /*
    *********************************************************
    @Method Name    : fetchDocumentDataTest
    @description    : Verify generation of hearing aid contact letter
    ********************************************************
    */
    static testmethod void fetchDocumentDataTest() {
        
        Account vendor = TestDataUtility.createVendor(false);
        vendor.Status__c = 'Approved';
        vendor.Active__c = true;
        insert vendor;
        
        Id equipmentTypeId = Schema.SObjectType.Equipment__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Equipment__c eqp = TestDataUtility.createEquipment(true, equipmentTypeId, vendor.id, 'Test', 'Weather Radio', 100);
        Equipment__c eqp2 = TestDataUtility.createEquipment(true, equipmentTypeId, vendor.id, 'Test2', 'Telephone', 100);
        
        Id authWRId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Weather_Radio').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authWRId);
        
        Id caseEquipmentTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Contact con = TestDataUtility.createConsumer(true);
        Case request = TestDataUtility.createCase(true, caseEquipmentTypeId, con.id, 'EDS', 'Weather Radio;Telephone');
        
        Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Generic_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(true, assetTypeId, auth.Id, eqp.id, request.Id);
        Asset__c asset2 = TestDataUtility.createAsset(true, assetTypeId, auth.Id, eqp2.id, request.Id);
        
        Test.startTest();
        PageReference pageRef = Page.NC_WeatherRadioApprovalConsumer;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(auth.id));
        NC_HA_ConApprovalController controller = new NC_HA_ConApprovalController();
        controller.fetchDocumentData(auth.Id);
        Test.stopTest();
        System.assertNotEquals(null, controller.consumerApprovalHearingAidObject);
    }
}