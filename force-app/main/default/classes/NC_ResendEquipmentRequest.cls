/**
 * Created by ashishpandey on 08/09/21.
 */

public with sharing class NC_ResendEquipmentRequest {

    /*
    *********************************************************
    @Method Name    : getStatus
    @description    : Get case details by record id
    @param          : String recordId
    @return         : Case
    ********************************************************
    */
    @AuraEnabled
    public static Case getStatus(String recordId){
        Case caseObj;
        for(Case obj:[SELECT Id,Allow_NDBEDP_Request_resync__c,MatRequestID__c,In_Active_Equipments_Name__c,InActive_Equipments__c,Send_to_KLAS__c from Case WHERE Id=:recordId WITH SECURITY_ENFORCED]){
            caseObj=obj;
        }
        return caseObj;
    }

    /*
    *********************************************************
    @Method Name    : validateEquipment
    @description    : validate inactive equipment and resend to KLAS
    @param          : String requestId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public Static void validateEquipment(String requestId){
        String equipmentNames;
        List<String> inActiveEquipmentNames= new List<String>();
        Boolean inActive=false;
        NC_ConnectEquipmentWrapper.EquipmentResponse response;
        String responseStr = NC_NDBEDPEquipmentCatalog.getEquipmentCatalog();
        response = (NC_ConnectEquipmentWrapper.EquipmentResponse)JSON.deserialize(responseStr, NC_ConnectEquipmentWrapper.EquipmentResponse.class);

        Map<String,Object> catalogEquipmentMap = new Map<String, Object>();
        Map<String,Request_Equipment__c> lineItemMap = new Map<String, Request_Equipment__c>();
        for(Request_Equipment__c item :[SELECT Id,Equipment_Name__c,Request__c,MatRequestLineObj__c,BibRecObj__c,KLASID__c FROM Request_Equipment__c WHERE Request__c =:requestId WITH SECURITY_ENFORCED]){
            lineItemMap.put(item.BibRecObj__c,item);
        }

        for(NC_ConnectEquipmentWrapper.TtEqp equipment: response.eqp.ttEqp) {
            if(String.isNotBlank(equipment.OPACSup) && equipment.OPACSup.toLowerCase() == 'false'){
                catalogEquipmentMap.put(equipment.BibRecObj,equipment);
            }
        }
        for(Request_Equipment__c eqp:lineItemMap.values()){
            if (!catalogEquipmentMap.containsKey(eqp.BibRecObj__c)) {
                inActiveEquipmentNames.add(eqp.Equipment_Name__c);
                inActive=true;
            }
        }
        if(inActiveEquipmentNames.size()>0 && Schema.sObjectType.Case.isUpdateable()){
            equipmentNames = string.join(inActiveEquipmentNames,',');
            update new Case(Id = requestId, In_Active_Equipments_Name__c = equipmentNames,InActive_Equipments__c=inActive,Send_to_KLAS__c=false);
        }else if(Schema.sObjectType.Case.isUpdateable()){
            update new Case(Id = requestId,Send_to_KLAS__c=true,Allow_NDBEDP_Request_resync__c=false,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
        }
    }

}