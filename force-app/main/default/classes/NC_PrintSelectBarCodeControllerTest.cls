/**
* @description       : Test class for NC_PrintSelectBarCodeController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_PrintSelectBarCodeControllerTest {

    /*
    *********************************************************
    @Method Name    : getBarcodeFromResourcesTest
    @description    : Verify generation of barcode to be printed 
    ********************************************************
    */
    static testmethod void getBarcodeFromResourcesTest() {
        Account rc = TestDataUtility.createRegionalCenter(true);
        Resource__c resource = TestDataUtility.createResource(true, 'Test', 'Equipment', rc.id);
        
        Test.startTest();
        Test.setCurrentPage(Page.NC_PrintSelectedBarCode);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Resource__c>{resource});
        stdSetController.setSelected(new List<Resource__c>{resource});
        
        NC_PrintSelectBarCodeController ctrl = new NC_PrintSelectBarCodeController(stdSetController);
        System.assertNotEquals(0, ctrl.resourceList.size());
        Test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : getBarcodeFromResourcesErrorTest
    @description    : Verify error in generation of barcode to be printed 
    ********************************************************
    */
    static testmethod void getBarcodeFromResourcesErrorTest() {
        Test.startTest();
        Test.setCurrentPage(Page.NC_PrintSelectedBarCode);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Resource__c>{});
        stdSetController.setSelected(new List<Resource__c>{});
        
        NC_PrintSelectBarCodeController ctrl = new NC_PrintSelectBarCodeController(stdSetController);
        System.assertNotEquals(null, ctrl.errorMessage);
        Test.stopTest();
    }
}