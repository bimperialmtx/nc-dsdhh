/*
*   Class Name: NC_DenialLetterForEquipmentController
*   Description: Controller for Denial Letter For Equipment
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_DenialLetterForEquipmentController {
    /* Wrapper Varibale to reflect on Document VF Page*/
    public NC_DenialLetterForEquipmentWrapper denialLetterForEquipmentWrapperObject{get;set;}

    /*
    * Method Name: NC_DenialLetterForEquipmentController
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_DenialLetterForEquipmentController() {
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
        Boolean edsRejects=false;
        Case caseRecord = [SELECT Id, Equipment_Types__c, Regional_Center__r.Name, EDS_Program_Assistant_Audit_Comments__c, Regional_Center__r.Phone, Contact.Name, Contact.OtherStreet, Contact.OtherCity, Contact.OtherState, Contact.OtherPostalCode, Vendor__c, Vendor__r.Name,Income_more_than_250_percent__c FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if(caseRecord.EDS_Program_Assistant_Audit_Comments__c!=null){
            edsRejects=true;
        }
        denialLetterForEquipmentWrapperObject = new NC_DenialLetterForEquipmentWrapper(caseRecord.Contact.Name, caseRecord.Contact.OtherStreet, caseRecord.Contact.OtherCity, caseRecord.Contact.OtherState, caseRecord.Contact.OtherPostalCode, System.today(), caseRecord.Vendor__r.Name, caseRecord.Regional_Center__r.Name, caseRecord.Equipment_Types__c, caseRecord.Regional_Center__r.Phone,caseRecord.EDS_Program_Assistant_Audit_Comments__c,caseRecord.Income_more_than_250_percent__c,edsRejects);
    }
}