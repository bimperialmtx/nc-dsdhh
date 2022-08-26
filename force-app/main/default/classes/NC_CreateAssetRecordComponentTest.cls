/**
* @description       : Test class for NC_CreateAssetRecordComponent
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_CreateAssetRecordComponentTest {

    /*
    *********************************************************
    @Method Name    : cloneAssetRecordTest
    @description    : Verify cloning of asset record and validations
    ********************************************************
    */
    static testmethod void cloneAssetRecordTest() {
        
        Contact con = TestDataUtility.createConsumer(true);
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId);
        
        Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Asset').getRecordTypeId();
        Asset__c asset = TestDataUtility.createAsset(false, assetTypeId, auth.Id, eqp.id, request.Id);
        asset.Status__c = 'Equipment Defective';
        insert asset;
        
        String response = NC_CreateAssetRecordComponentHandler.cloneAssetRecord(asset.id);
        System.assertNotEquals(null, response);
    }
}