/*
**   Class Name: NC_EquipmentTriggerHandler
**   Description: Trigger on Equipment
**
**     Date            New/Modified           User                 Identifier                Description
**   12-05-2020             New          Hiten Aggarwal(mtx)
*/

public without sharing class NC_EquipmentTriggerHandler {
    
    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after Insert' trigger event
    @param          : List<Equipment__c> newList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Equipment__c> newList){
        checkOtherEquipment(newList,NULL);
    } 

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after update' trigger event
    @param          : List<Equipment__c> newList, Map<Id, Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Equipment__c> newList, Map<Id, Equipment__c> oldMap){
        checkOtherEquipment(newList,oldMap);
    }

    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Equipment__c> newList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Equipment__c> newList){
       validateDuplicateEquipment(newList,NULL);
    } 
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Equipment__c> newList, Map<Id, Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Equipment__c> newList, Map<Id, Equipment__c> oldMap){
        validateDuplicateEquipment(newList,oldMap);
    } 
    
    /*
    *********************************************************
    @Method Name    : checkOtherEquipment
    @description    : Mark other check box of parent equipment false
    @param          : List<Equipment__c> newList, Map<Id, Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void checkOtherEquipment(List<Equipment__c> newList, Map<Id, Equipment__c> oldMap){
        
        List<Equipment__c> equipmentList = new List<Equipment__c>();
        Map<Id,Equipment__c> parentEquipmentToEquipmentMap = new Map<Id,Equipment__c>();
        
        for(Equipment__c equipmentRecord : newList){
            if(( oldMap == NULL || equipmentRecord.Always_Add_With_Parent__c != oldMap.get(equipmentRecord.Id).Always_Add_With_Parent__c  ) 
               && equipmentRecord.Always_Add_With_Parent__c &&  equipmentRecord.Is_Sub_Equipment__c){
                   parentEquipmentToEquipmentMap.put(equipmentRecord.Parent_Equipment__c,equipmentRecord);
               }
        }
        
        if(parentEquipmentToEquipmentMap.keySet().size()>0){
            for(Equipment__c equipment : [SELECT Id,Is_Sub_Equipment__c,
                                          Always_Add_With_Parent__c,Parent_Equipment__c
                                          FROM Equipment__c
                                          WHERE Parent_Equipment__c IN: parentEquipmentToEquipmentMap.keySet() 
                                          AND Is_Sub_Equipment__c = TRUE 
                                          AND ID NOT IN: parentEquipmentToEquipmentMap.Values() WITH SECURITY_ENFORCED]){
                                              equipment.Always_Add_With_Parent__c = FALSE;         
                                              equipmentList.add(equipment);            
                                              
                                          }
        }
        
        if(equipmentList.size()>0){
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Equipment__c',equipmentList, 'update', true, 'NC_EquipmentTriggerHandler', 'checkOtherEquipment');
                update decision.getRecords();


           // Update equipmentList;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateDuplicateEquipment
    @description    : Validation To Stop Duplicate Records Creation
    @param          : List<Equipment__c> newEquipmentList,  Map<Id, Equipment__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateDuplicateEquipment(List<Equipment__c> newEquipmentList,  Map<Id, Equipment__c> oldMap){
        Map<String,Id> equipmentNameToVendorIdMap = new Map<String,Id>();
        Map<string,Equipment__c> equipmentNameToEquipmentMap = new Map<String,Equipment__c>();    
        for(Equipment__c equipmentRecord : newEquipmentList){
            if((oldMap == NULL  || equipmentRecord.Vendor__c != oldMap.get(equipmentRecord.Id).Vendor__c 
                || equipmentRecord.Equipment_Name__c != oldMap.get(equipmentRecord.Id).Equipment_Name__c)
               && equipmentRecord.Vendor__c != NULL){
                   if(!equipmentNameToVendorIdMap.containsKey(equipmentRecord.Equipment_Name__c)){
                       equipmentNameToVendorIdMap.put(equipmentRecord.Equipment_Name__c,equipmentRecord.Vendor__c);
                   }else if(equipmentNameToVendorIdMap.get(equipmentRecord.Equipment_Name__c) != equipmentRecord.Vendor__c){
                       equipmentNameToVendorIdMap.put(equipmentRecord.Equipment_Name__c,equipmentRecord.Vendor__c);
                   }else{
                       equipmentRecord.addError(NC_Constant.Duplicate_Equipment_Error_Message + ' In List');
                   }
               }
        }
        
        for(Equipment__c equipmentRecord:  [SELECT Id,Equipment_Name__c,Vendor__c
                                            FROM Equipment__c
                                            WHERE Equipment_Name__c IN: equipmentNameToVendorIdMap.keySet()
                                            AND Vendor__c IN: equipmentNameToVendorIdMap.values() WITH SECURITY_ENFORCED]){
                                                equipmentNameToEquipmentMap.put(equipmentRecord.Equipment_Name__c,equipmentRecord);
                                            }
        
        for(Equipment__c equipmentRecord : newEquipmentList){
            
            if(equipmentNameToEquipmentMap.containsKey(equipmentRecord.Equipment_Name__c)){
                equipmentRecord.addError(NC_Constant.Duplicate_Equipment_Error_Message);
            }
        }
    }
}