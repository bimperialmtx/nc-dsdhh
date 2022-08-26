/*
*   Class Name: NC_HA_ConApprovalController
*   Description: VF page Controller for NC_HA_ConsumerController
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_HA_ConApprovalController {
    
    /* Wrapper Varibale to reflect on Document VF Page*/
    public NC_HA_ConApprovalWrapper consumerApprovalHearingAidObject{get;set;}

    /*
    * Method Name: NC_HA_ConApprovalController
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_HA_ConApprovalController() {
        fetchDocumentData(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id').escapeHtml4()));
    }
    
    /*
    *********************************************************
    @Method Name    : fetchDocumentData
    @description    : Fetch Details from the Authorization Record and Added them to wrapper
    @param          : String recordId
    @return         : void
    ********************************************************
    */
    public void fetchDocumentData(String recordId){
        Authorization__c authorizationRecord = [SELECT Id, Status__c, Vendor__c, Vendor__r.Name, Consumer__c,Consumer__r.Name,Consumer__r.OtherStreet, Consumer__r.OtherCity, Consumer__r.OtherPostalCode, Consumer__r.OtherState, Request__c, Regional_Center__c, Ship_To__c, Issue_Date__c, Vendor_Email__c, Vendor_Name__c, Contains_Hearing_Aid__c, Preferred_Contact_Method__c, Contact_Info__c FROM Authorization__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        consumerApprovalHearingAidObject = new NC_HA_ConApprovalWrapper(authorizationRecord.Consumer__r.Name, authorizationRecord.Consumer__r.OtherStreet, authorizationRecord.Consumer__r.OtherCity, authorizationRecord.Consumer__r.OtherState, authorizationRecord.Consumer__r.OtherPostalCode, System.today(), authorizationRecord.Vendor__r.Name);
    }
}