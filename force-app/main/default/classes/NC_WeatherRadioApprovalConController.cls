/*
*   Class Name: NC_WeatherRadioApprovalConController
*   Description: Weather Radio Document For Authorization
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_WeatherRadioApprovalConController {
    
    /* Wrapper Varibale to reflect on Document VF Page*/
    public NC_WeatherRadioApprovalConsumerWrapper weatherRadioApprovalConsumerObject{get;set;}

    /*
    * Method Name: NC_WeatherRadioApprovalConController
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_WeatherRadioApprovalConController() {
        fetchDocumentData(ApexPages.currentPage().getParameters().get('id').escapeHtml4());
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
        List<NC_WeatherRadioApprovalConsumerWrapper.equipments> listOfEquipment = new List<NC_WeatherRadioApprovalConsumerWrapper.equipments>();
        Authorization__c authorizationRecord = [SELECT Id, Status__c, Vendor__c, Vendor__r.Name, Consumer__c,Consumer__r.Name,Consumer__r.OtherStreet, Consumer__r.OtherCity, Consumer__r.OtherPostalCode, Consumer__r.OtherState, Request__c, Regional_Center__c, Regional_Center__r.Name, Ship_To__c, Issue_Date__c, Vendor_Email__c, Vendor_Name__c, Contains_Hearing_Aid__c, Preferred_Contact_Method__c, Contact_Info__c FROM Authorization__c WHERE Id =: recordId WITH SECURITY_ENFORCED];

        for(Asset__c assetRecord : [SELECT Id, Equipment__c,Equipment__r.Equipment_Type__c,Equipment__r.Is_Sub_Equipment__c, Equipment__r.Equipment_Name__c FROM Asset__c WHERE Authorization__c =: recordId WITH SECURITY_ENFORCED]){
            String daysReturn ='30';
            String daysRecived ='30';
            String daysExchange ='30';
            
            if(assetRecord.Equipment__r.Equipment_Type__c != NC_Constant.EQUIPMENT_TYPE_WEATHER_RADIO){
                daysReturn = '45';
                daysRecived = '45';
                daysExchange = '45';
            }
            if(assetRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID && assetRecord.Equipment__r.Is_Sub_Equipment__c){
                listOfEquipment.add(new NC_WeatherRadioApprovalConsumerWrapper.equipments(assetRecord.Equipment__r.Equipment_Name__c,daysReturn,daysRecived,daysExchange));
            }
            if(assetRecord.Equipment__r.Equipment_Type__c != NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                listOfEquipment.add(new NC_WeatherRadioApprovalConsumerWrapper.equipments(assetRecord.Equipment__r.Equipment_Name__c,daysReturn,daysRecived,daysExchange));
            }
            
            
        }

        weatherRadioApprovalConsumerObject = new NC_WeatherRadioApprovalConsumerWrapper(authorizationRecord.Consumer__r.Name, authorizationRecord.Consumer__r.OtherStreet, authorizationRecord.Consumer__r.OtherCity, authorizationRecord.Consumer__r.OtherState, authorizationRecord.Consumer__r.OtherPostalCode, System.today(), authorizationRecord.Vendor__r.Name, listOfEquipment, authorizationRecord.Regional_Center__r.Name);
    }



}