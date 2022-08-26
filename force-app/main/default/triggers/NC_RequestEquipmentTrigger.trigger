/*
**   Class Name: NC_RequestEquipmentTrigger
**   Description: Trigger on Request Equipment
**
**     Date            New/Modified           User                 Identifier                Description
**  05-11-2020             New          Shubham Dadhich(mtx)
*/

trigger NC_RequestEquipmentTrigger on Request_Equipment__c (before insert,after insert,after update,before update, after delete) {
    // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('RequestEquipmentTrigger');
    
    // Trigger on Before Insert 
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(trigger.isBefore) {
            if( trigger.isInsert){
                NC_RequestEquipmentTriggerHandler.beforeInsert(Trigger.new);
            }
        }
    }
    if(trigger.isAfter) {
        if( trigger.isUpdate){
            NC_RequestEquipmentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(trigger.isDelete){
            NC_RequestEquipmentTriggerHandler.afterDelete(Trigger.old);
        }
    }
    if(trigger.isAfter) {
        if( trigger.isInsert){
            NC_RequestEquipmentTriggerHandler.afterInsert(Trigger.new);
        }
    }
    if(trigger.isBefore) {
        if( trigger.isUpdate){
            NC_RequestEquipmentTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap); 
        }
    }
}