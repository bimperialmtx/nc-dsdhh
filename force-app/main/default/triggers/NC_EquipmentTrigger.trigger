/*
**   Class Name: NC_EquipmentTrigger
**   Description: Trigger on Equipment
**
**     Date            New/Modified           User                 Identifier                Description
**  12-05-2020             New          Hiten Aggarwal(mtx)
**  15-05-2020            modified      Hiten Aggarwal(mtx)
*/

trigger NC_EquipmentTrigger on Equipment__c (before insert,before Update,After Insert, After Update) {
    
    
     // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('EquipmentTrigger');

    // Trigger on Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(trigger.isBefore) {
            if( trigger.isInsert){
                NC_EquipmentTriggerHandler.beforeInsert(Trigger.new);
            }
        }
    }
    
    // Trigger on Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(trigger.isBefore) {
            if( trigger.isUpdate){
                NC_EquipmentTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
            }
        }
    }
    
     
    //Trigger on After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(trigger.isAfter) {
            if( trigger.isInsert){
                NC_EquipmentTriggerHandler.afterInsert(Trigger.new);
            }
        }
    }

    //Trigger on After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(trigger.isAfter) {
            if( trigger.isUpdate){
               NC_EquipmentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }


}