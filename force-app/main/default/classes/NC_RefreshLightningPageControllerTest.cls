/**
* @description       : Test class for NC_RefreshLightningPageController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public with sharing class NC_RefreshLightningPageControllerTest {
    
    /*
    *********************************************************
    @Method Name    : checkPageRefreshTest
    @description    : Verify NDBEDP request page needs to be refreshed
    ********************************************************
    */
    static testmethod void checkPageRefreshTest() {

        Case caseObj = new Case();
        caseObj.Refresh_Page__c = true;
        insert caseObj;
        Boolean res = NC_RefreshLightningPageController.checkPageRefresh(null);
        System.assertEquals(false, res);
        Boolean result = NC_RefreshLightningPageController.checkPageRefresh(caseObj.id);
        System.assertEquals(true, result);
    }
}