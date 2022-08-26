/**
* @description       : Test class for NC_DocumentViewerController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_DocumentViewerControllerTest {

    /*
    *********************************************************
    @Method Name    : saveSignatureTest
    @description    : Verify document generation using vf page
    ********************************************************
    */
    static testmethod void saveSignatureTest() {
     
        Contact con = TestDataUtility.createConsumer(true);
        TestDataUtility.createAttachment(true, con.id, 'test', 'image/jpeg', 'test', 'Sign');
        
        Test.startTest();
        PageReference pageRef = Page.NC_DocumentViewer;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(con.id));
        NC_DocumentViewerController controller=new NC_DocumentViewerController();
        Test.stopTest();
        System.assertNotEquals(null, controller.url);
    }
}