/**
* @description       : Test class for NC_FileUploadController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_FileUploadControllerTest {
    /*
    *********************************************************
    @Method Name    : mapRelatedFieldsTest
    @description    : Verify files available for record
    ********************************************************
    */
    static testmethod void mapRelatedFieldsTest() {
        Contact con = TestDataUtility.createConsumer(true);
        
        Map<String,Object> resultMap = NC_FileUploadController.mapRelatedFields(con.id, '', '');
        System.assertEquals(false, resultMap.get('Disable'));
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveDocumentInfoTest
    @description    : Verify documents from related record
    ********************************************************
    */
    static testmethod void retrieveDocumentInfoTest() {
        Contact con = TestDataUtility.createConsumer(true);
        TestDataUtility.createFile(con.id, 'testing.png', 'Test File', 'body');
        String filter = 'Id = \'' + con.id + '\'';
        
        Map<String,Object> resultMap = NC_FileUploadController.retrieveDocumentInfo('Test File', con.id, filter);
        System.assertNotEquals(null, resultMap.get('contentDocumentId'));
    }
    
    
    /*
    *********************************************************
    @Method Name    : updateDocumentNameTest
    @description    : Verify document name update
    ********************************************************
    */
    static testmethod void updateDocumentNameTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        
        ContentDocumentLink cdl = TestDataUtility.createFile(request.id, 'testing.png', 'Test File', 'body');
        
        Map<String, String> resultMap = NC_FileUploadController.updateDocumentName(cdl.ContentDocumentId, 'Test File', request.id, 'Service_Documentation__c', request.id);
        System.assertEquals('success', resultMap.get('success'));
    }
    
    /*
    *********************************************************
    @Method Name    : updateFileRelatedFieldTest
    @description    : Verify file related data updation
    ********************************************************
    */
    static testmethod void updateFileRelatedFieldTest() {
        
        Contact con = TestDataUtility.createConsumer(true);
        Case request = TestDataUtility.createNDBEDPCase(true, con.id);
        ContentDocumentLink cdl = TestDataUtility.createFile(con.id, 'testing.png', 'Test File', 'body');
        
        NC_FileUploadController.updateFileRelatedField(true, cdl.ContentDocumentId, 'Test File', 'Proof_of_Income_Uploaded__c', con.id);
        Contact contact = [SELECT Proof_of_Income_Uploaded__c FROM Contact WHERE Id =: con.id];
        System.assertEquals(true, contact.Proof_of_Income_Uploaded__c);
    }
    
    /*
    *********************************************************
    @Method Name    : updateContentVersionTest
    @description    : Verify contentversion of file
    ********************************************************
    */
    static testmethod void updateContentVersionTest() {
        Test.startTest();
        Account acc = TestDataUtility.createAssessor(true);
        Contact con = TestDataUtility.createConsumer(true);
        
        ContentDocumentLink cdl = TestDataUtility.createFile(con.id, 'testinging.png', 'Tests File', 'body');
        ContentDocumentLink cd2 = TestDataUtility.createFile(acc.id, 'testinging.png', 'Test File1', 'body');
        
        NC_FileUploadController.updateContentVersion(cd2.ContentDocumentId,  acc.id, 'Tests File', 'Proof_of_Income_Uploaded__c', acc.id);
        Test.stopTest();
        ContentDocument doc=[SELECT Id, Title FROM ContentDocument LIMIT 1];
        System.assertEquals(null, con.Title);
    }
    
    /*
    *********************************************************
    @Method Name    : updateContentVersionTest
    @description    : Verify deletion of document
    ********************************************************
    */
    static testmethod void deleteDocumentNameTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Account acc = TestDataUtility.createAssessor(true);
        ContentDocumentLink cdl = TestDataUtility.createFile(acc.id, 'testing.png', 'Test File', 'body');
        
        String result = NC_FileUploadController.deleteDocumentName(cdl.ContentDocumentId, 'Test File', con.id, 'Proof_of_Income_Uploaded__c',acc.id);
        System.assertNotEquals(null, result);
    }
    
    /*
    *********************************************************
    @Method Name    : updateRelatedRecordsTest
    @description    : Verify parent record updation after file upload
    ********************************************************
    */
    static testmethod void updateRelatedRecordsTest() {
        Account acc = TestDataUtility.createAssessor(false);
        acc.Status__c = 'Approved';
        acc.Document_In_Renewal_Process__c = true;
        insert acc;
        Contact con = TestDataUtility.createConsumer(true);
        ContentDocumentLink cdl = TestDataUtility.createFile(con.id, 'testing.png', 'Test File', 'body');
        NC_FileUploadController.updateRelatedRecords(false, 'Test File', con.id, 'Proof_of_Income_Uploaded__c', con.id);
        Contact contact=[Select Id,Proof_of_Income_Uploaded__c FROM Contact];
        System.assertEquals(false, contact.Proof_of_Income_Uploaded__c);
        NC_FileUploadController.updateRelatedRecordsForRenew(false, 'Test File', 'Acknowledgement_Form__c', acc.id);
        System.assertEquals(false, acc.Acknowledgement_Form__c);
        
    }
}