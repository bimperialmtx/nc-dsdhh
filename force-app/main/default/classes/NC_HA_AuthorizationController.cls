/*
*   Class Name: NC_HA_AuthorizationController
*   Description: Wrapper for VF Page NC_HA_Authorization
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_HA_AuthorizationController {
    /* Wrapper Varibale to reflect on Document VF Page*/
    public NC_HA_AuthorizationWrapper authorizationHearingAidObject{get;set;}

    /*
    * Method Name: NC_HA_AuthorizationController
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_HA_AuthorizationController() {
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
        Decimal HearingAidPrice = 0.00;
        List<NC_HA_AuthorizationWrapper.HearingAidSubItem> uperItemList = new List<NC_HA_AuthorizationWrapper.HearingAidSubItem>();
        List<NC_HA_AuthorizationWrapper.HearingAidSubItem> lowerItemList = new List<NC_HA_AuthorizationWrapper.HearingAidSubItem>();
        Authorization__c authorizationRecord = [SELECT Id, Name, Status__c, Vendor__c,Vendor__r.BillingStreet, Vendor__r.BillingState, Vendor__r.BillingPostalCode, Vendor__r.BillingCity, Vendor__r.Name, Consumer__c,Consumer__r.Name,Consumer__r.OtherStreet, Consumer__r.OtherCity, Consumer__r.OtherPostalCode, Consumer__r.OtherState, Request__c, Regional_Center__c, Ship_To__c, Issue_Date__c, Vendor_Email__c, Vendor_Name__c, Contains_Hearing_Aid__c, Preferred_Contact_Method__c, Contact_Info__c FROM Authorization__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        for(Asset__c assetRecord : [SELECT Id, Equipment__r.Equipment_Type__c, Equipment__r.Is_Sub_Equipment__c, Amount_Authorized__c FROM Asset__c WHERE Authorization__c =: recordId AND Equipment__r.Equipment_Type__c =: NC_Constant.EQUIPMENT_TYPE_HEARING_AID AND Equipment__r.Is_Sub_Equipment__c = false WITH SECURITY_ENFORCED]){
            HearingAidPrice = assetRecord.Amount_Authorized__c;
        }
        for(Hearing_Aid_Sub_Item__mdt hearingAidSubItem : [SELECT Id, Amount_Authorized__c, Is_Return_Item__c, Validation_Amount__c, MasterLabel FROM Hearing_Aid_Sub_Item__mdt WHERE Validation_Amount__c = false]){
            if(hearingAidSubItem.MasterLabel == NC_Constant.HEARING_AID_SUB_ITEM_CUSTOM_EAR_MOLD_IMPERSSION || hearingAidSubItem.MasterLabel == NC_Constant.HEARING_AID_SUB_ITEM_CUSTOM_DISPENSING_FEE){
                uperItemList.add(new NC_HA_AuthorizationWrapper.HearingAidSubItem(hearingAidSubItem.MasterLabel, hearingAidSubItem.Amount_Authorized__c));
            }else{
                lowerItemList.add(new NC_HA_AuthorizationWrapper.HearingAidSubItem(hearingAidSubItem.MasterLabel, hearingAidSubItem.Amount_Authorized__c));
            }
        }
        authorizationHearingAidObject = new NC_HA_AuthorizationWrapper(authorizationRecord.Name, authorizationRecord.Consumer__r.Name, authorizationRecord.Consumer__r.OtherStreet, authorizationRecord.Consumer__r.OtherCity, authorizationRecord.Consumer__r.OtherState, authorizationRecord.Consumer__r.OtherPostalCode,authorizationRecord.Vendor__r.Name,authorizationRecord.Vendor__r.BillingStreet, authorizationRecord.Vendor__r.BillingCity, authorizationRecord.Vendor__r.BillingState, authorizationRecord.Vendor__r.BillingPostalCode, System.today(), HearingAidPrice, uperItemList, lowerItemList);
    }
}