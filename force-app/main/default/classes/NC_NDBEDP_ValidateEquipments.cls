/**
 * Created by ashishpandey on 14/09/21.
 * NDBEDP validate equipments
 */

public class NC_NDBEDP_ValidateEquipments implements Queueable,Database.AllowsCallouts{

    ////Check if added equipment is still active or not in KLAS
    public String requestId;
    public NC_NDBEDP_ValidateEquipments(String reqId){
        requestId = reqId ;

    }
    public void execute(QueueableContext qc){
        String equipmentNames;
        List<String> inActiveEquipmentNames= new List<String>();
        Boolean inActive=false;
        NC_ConnectEquipmentWrapper.EquipmentResponse response;
        String responseStr = NC_NDBEDPEquipmentCatalog.getEquipmentCatalog();
        response = (NC_ConnectEquipmentWrapper.EquipmentResponse)JSON.deserialize(responseStr, NC_ConnectEquipmentWrapper.EquipmentResponse.class);

        Map<String,Object> catalogEquipmentMap = new Map<String, Object>();
        Map<String,Request_Equipment__c> lineItemMap = new Map<String, Request_Equipment__c>();
        for(Request_Equipment__c item :[SELECT Id,Equipment_Name__c,Request__c,MatRequestLineObj__c,BibRecObj__c,KLASID__c FROM Request_Equipment__c WHERE Request__c =:requestId]){
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
        if(inActiveEquipmentNames.size()>0){
            equipmentNames = string.join(inActiveEquipmentNames,',');
            update new Case(Id = requestId, In_Active_Equipments_Name__c = equipmentNames,InActive_Equipments__c=inActive,Send_to_KLAS__c=false);
        }else {
            update new Case(Id = requestId,Send_to_KLAS__c=true,InActive_Equipments__c=false,In_Active_Equipments_Name__c=null);
        }

    }
}