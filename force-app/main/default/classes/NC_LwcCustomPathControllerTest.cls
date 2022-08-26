/**
* @description       : Test class for NC_LwcCustomPathController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_LwcCustomPathControllerTest {

    /*
    *********************************************************
    @Method Name    : getPicklistValuesTest
    @description    : Verify account picklist values and order
    ********************************************************
    */
    static testmethod void getPicklistValuesTest() {
        Account vendor = TestDataUtility.createVendor(true);
        NC_LwcCustomPathController.getPicklistValues('Status__c', vendor.id, 'Vendor');
        System.assertNotEquals(null, NC_LwcCustomPathController.getPicklistValues('Status__c', vendor.id, 'Vendor'));
    }
}