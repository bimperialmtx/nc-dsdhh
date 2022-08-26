/**
* @description       : Test class for NC_CreateContactAttemptController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateContactAttemptControllerTest {

    /*
    *********************************************************
    @Method Name    : retrieveDefaultsTest
    @description    : Verify creation of contact attempt based on related request data
    ********************************************************
    */
    static testmethod void retrieveDefaultsTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(true, assetTypeId, auth.Id, eqp.id, request.Id);
        
     	Map<String,Object> resultMap = NC_CreateContactAttemptController.retrieveDefaults(asset.id);
        System.assertEquals(true, resultMap.get('forAsset'));
        
        Map<String,Object> resultMap2 = NC_CreateContactAttemptController.retrieveDefaults(request.id);
        System.assertEquals(false, resultMap2.get('forAsset'));
    }
}