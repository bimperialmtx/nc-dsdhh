/*
*   Class Name: NC_EquipmentAuthorizationController
*   Description: Wrapper for VF Page NC_EquipmentAuthorization
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_EquipmentAuthorizationController {
    /* Wrapper Varibale to reflect on Document VF Page*/
    public NC_EquipmentAuthorizationWrapper equipmentAuthorizationObject{get;set;}

    /*
    * Method Name: NC_EquipmentAuthorizationController
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_EquipmentAuthorizationController() {
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
        List<NC_EquipmentAuthorizationWrapper.Equipments> listOfEquipments= new List<NC_EquipmentAuthorizationWrapper.Equipments>();
        NC_EquipmentAuthorizationWrapper.Equipments equipmentsObject;
        Set<String> assetStatusSet = new Set<String>{NC_Constant.ASSET_STATUS_EQUIPMENT_DEFECTIVE, NC_Constant.ASSET_STATUS_EQUIPMENT_UNAVAILABLE};
        Authorization__c authorizationRecord = [SELECT Id,Name, Status__c, Vendor__c,Vendor__r.BillingStreet, Vendor__r.BillingState, Vendor__r.BillingPostalCode, Vendor__r.BillingCity, Vendor__r.Name, Consumer__c,Consumer__r.Name,Consumer__r.OtherStreet, Consumer__r.OtherCity, Consumer__r.OtherPostalCode, Consumer__r.OtherState, Request__c, Regional_Center__c, Ship_To__c, Issue_Date__c, Vendor_Email__c, Vendor_Name__c, Regional_Center__r.Name, Contains_Hearing_Aid__c, Preferred_Contact_Method__c, Contact_Info__c FROM Authorization__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        Set<String> equipmentNameSet = new Set<String>();
        for(Asset__c assetRecord : [SELECT Id, Equipment__r.Equipment_Type__c,Equipment__r.Equipment_Name__c, Equipment__r.Is_Sub_Equipment__c, Amount_Authorized__c, recordType.DeveloperName FROM Asset__c WHERE Authorization__c =: recordId AND Status__c NOT IN: assetStatusSet WITH SECURITY_ENFORCED]){
            if(!(assetRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID && !assetRecord.Equipment__r.Is_Sub_Equipment__c)){
                equipmentsObject = new NC_EquipmentAuthorizationWrapper.Equipments(assetRecord.Equipment__r.Equipment_Name__c,assetRecord.Amount_Authorized__c, assetRecord.recordType.DeveloperName);
                //if(!equipmentNameSet.contains(assetRecord.Equipment__r.Equipment_Type__c)){
                    listOfEquipments.add(equipmentsObject);
                    equipmentNameSet.add(assetRecord.Equipment__r.Equipment_Type__c);
                //} 
            }
        }
        equipmentAuthorizationObject = new NC_EquipmentAuthorizationWrapper(authorizationRecord.Name,authorizationRecord.Consumer__r.Name, authorizationRecord.Consumer__r.OtherStreet, authorizationRecord.Consumer__r.OtherCity, authorizationRecord.Consumer__r.OtherState, authorizationRecord.Consumer__r.OtherPostalCode,authorizationRecord.Vendor__r.Name,authorizationRecord.Vendor__r.BillingStreet, authorizationRecord.Vendor__r.BillingCity, authorizationRecord.Vendor__r.BillingState, authorizationRecord.Vendor__r.BillingPostalCode, System.today(), authorizationRecord.Regional_Center__r.Name,listOfEquipments);
    }
}