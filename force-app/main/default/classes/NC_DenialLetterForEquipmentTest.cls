/**
* @description       : Test class for NC_DenialLetterForEquipment
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_DenialLetterForEquipmentTest {

    /*
    *********************************************************
    @Method Name    : fetchDocumentDataTest
    @description    : Verify EDS request denial letter generation
    ********************************************************
    */
    static testmethod void fetchDocumentDataTest(){
        
        Contact con = TestDataUtility.createConsumer(true);
        
        Id requestTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case request = TestDataUtility.createCase(true, requestTypeId, con.id, 'EDS', 'Telephone');
        
        PageReference pageRef = Page.NC_DenialLetterForEquipment;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(request.id));
        NC_DenialLetterForEquipmentController ctrl = new NC_DenialLetterForEquipmentController();
       	System.assertNotEquals(null, ctrl.denialLetterForEquipmentWrapperObject);
    }
}