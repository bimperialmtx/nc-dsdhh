/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_RefreshLightningPageController {

    /*
    *********************************************************
    @Method Name    : checkPageRefresh
    @description    : Check if page refresh is needed based on Refresh Page field value
    @param          : Id recordId
    @return         : Boolean
    ********************************************************
    */
    @AuraEnabled
    public static Boolean checkPageRefresh(Id recordId) {
        if(recordId != null) {
            List<Case> caseList = [SELECT Refresh_Page__c from Case WHERE id =: recordId WITH SECURITY_ENFORCED];
            if(!caseList.isEmpty() && caseList[0].Refresh_Page__c) {
                Case caseObj = new Case();
                caseObj.id = recordId;
                caseObj.Refresh_Page__c = false;
                //update caseObj;
                SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Case', new List<Case>{caseObj}, 'insert', true,'NC_RefreshLightningPageController','checkPageRefresh');
                update decision.getRecords();
                return true;
            }
        }
        return false;
    }
}