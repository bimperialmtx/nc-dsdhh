/**
* @description       : Test class for NC_SignatureController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_SignatureControllerTest {
    
    /*
*********************************************************
@Method Name    : saveSignatureTest
@description    : Verify signature document related to parent record
********************************************************
*/
    static testmethod void saveSignatureTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        Id result = NC_SignatureController.saveSignature('test', caseObj.id, 'Applicants_Signature__c');
        System.assertNotEquals(null, result);
    }
    
    /*
*********************************************************
@Method Name    : saveSignatureTest
@description    : Verify images available under parent record
********************************************************
*/
    static testmethod void getImageTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        TestDataUtility.createAttachment(true, caseObj.id, 'test', 'image/jpeg', 'Consumer EsignatureApplicants_Signature__c', 'test');
        
        Id result = NC_SignatureController.saveSignature('test', caseObj.id, 'Applicants_Signature__c');
        System.assertNotEquals(null, result);
        
        List<Attachment> attList = NC_SignatureController.getImage(caseObj.id);
        System.assertNotEquals(0, attList.size());
    }
    
    /*
*********************************************************
@Method Name    : checkFilterTest
@description    : Verify filter of dynamic query
********************************************************
*/
    static testmethod void checkFilterTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        boolean result = NC_SignatureController.checkFilter(caseObj.id, 'Request_Type__c = \'NDBEDP\'');
        System.assertEquals(true, result);
    }
    /*
*********************************************************
@Method Name    : uploadSignTest
@description    : Upload signature 
********************************************************
*/
    static testmethod void uploadSignTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        Id result = NC_SignatureController.uploadSign(null, caseObj.id, 'Applicants_Signature__c');
        System.assertEquals(null, result);
    }
}