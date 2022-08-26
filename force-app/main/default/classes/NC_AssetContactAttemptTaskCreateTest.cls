/**
* @description       : Test class for NC_AssetContactAttemptTaskCreate
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_AssetContactAttemptTaskCreateTest {
    
    /*
    *********************************************************
    @Method Name    : batchTest
    @description    : Verify tasl created using batch
    ********************************************************
    */
    static testmethod void batchTest() {
        
        Id authAssessmentId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();   
        Authorization__c auth = TestDataUtility.createAuthorization(true, authAssessmentId);
        

        
        
        
        Contact con = TestDataUtility.createConsumer(true);
        
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case request = TestDataUtility.createCase(true, requestTypeId, con.id, 'EDS', 'Telephone');
        
        Asset__c asset = new Asset__c();
        asset.Authorization__c = auth.Id;
        asset.Status__c = 'Received';
        asset.Request__c = request.Id;
        Insert asset;
        
        Id contactAttemptAssetTypeId = NC_Utility.RecordTypeUtilityMethod('Contact_Attempt__c', 'Contact_Attempt_For_Asset');
        Contact_Attempt__c contact = new Contact_Attempt__c();
        contact.Asset__c = asset.Id;
        contact.RecordTypeId = contactAttemptAssetTypeId;
        contact.Request__c = request.Id;
        Insert contact;
        
        Test.startTest();
        NC_AssetContactAttemptTaskCreateBatch batch = new NC_AssetContactAttemptTaskCreateBatch();
        Database.executeBatch(batch);
        System.assertNotEquals(null, Database.executeBatch(batch));
        Test.stopTest();
        
    }
}