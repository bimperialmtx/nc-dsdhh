/**
* @description       : Test class for NCDSH_SignatureController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NCDSH_SignatureControllerTest {

    /*
    *********************************************************
    @Method Name    : saveSignatureTest
    @description    : Verify signature document with data
    ********************************************************
    */
    static testmethod void saveSignatureTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        Id result = NCDSH_SignatureController.saveSignature('test', caseObj.id);
        System.assertNotEquals(null, result);
    }
    
    /*
    *********************************************************
    @Method Name    : saveDocumentWithSignTest
    @description    : Verify signature document and relation with record
    ********************************************************
    */
    static testmethod void saveDocumentWithSignTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        NCDSH_SignatureController.saveDocumentWithSign(caseObj.id);
        
        List<ContentDocumentLink> cdl = [SELECT id FROM ContentDocumentLink WHERE LinkedEntityId =: caseObj.id];
        System.assertNotEquals(0, cdl.size());
    }
    
    /*
    *********************************************************
    @Method Name    : getImageTest
    @description    : Verify images available under parent record
    ********************************************************
    */
    static testmethod void getImageTest() {
        Case caseObj = TestDataUtility.createNDBEDPCase(true);
        TestDataUtility.createAttachment(true, caseObj.id, 'test', 'image/jpeg', 'Consumer Esignature', 'test');
        
        Id result = NCDSH_SignatureController.saveSignature('test', caseObj.id);
        System.assertNotEquals(null, result);
        
        List<Attachment> attList = NCDSH_SignatureController.getImage(caseObj.id);
        System.assertNotEquals(0, attList.size());
    }
}