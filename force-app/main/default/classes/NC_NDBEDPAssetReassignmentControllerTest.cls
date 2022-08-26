/**
* @description       : Test class for NC_NDBEDPAssetReassignmentController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_NDBEDPAssetReassignmentControllerTest {

    /*
    *********************************************************
    @Method Name    : getAssetReassignmentInfoTest
    @description    : Verify NDBEDP Assets available for reassignment 
    ********************************************************
    */
    static testmethod void getAssetReassignmentInfoTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(false);
        caseObj.Status = 'Pending Equipment Order';
        insert caseObj;
        
        //Id authEqpId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        //Authorization__c authObj = TestDataUtility.createAuthorization(true, authEqpId, caseObj.id, null, null);
        
        Id AuthorizationTrainingVendorIncoiveId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
        Authorization__c auth3 = TestDataUtility.createAuthorization(true, AuthorizationTrainingVendorIncoiveId);
        
        Equipment__c equipment = TestDataUtility.createNDBEDPEquipment(true);
        
        Id assetEqpId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(false, assetEqpId, auth3.id, equipment.id, caseObj.id);
        asset.Status__c = 'Available For Reassignment';
        insert asset;
        
        Id reqEqpTypeId = Schema.SObjectType.Request_Equipment__c.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Request_Equipment__c reqEqp = TestDataUtility.createRequestEquipment(true, reqEqpTypeId, caseObj.id, equipment.id);
        
        Map<String, Object> resultMap = NC_NDBEDPAssetReassignmentInfoController.getAssetReassignmentInfo(caseObj.id);
        System.assertEquals(false, resultMap.get('isError'));
        System.assertNotEquals(null, resultMap.get('data'));
    }
}