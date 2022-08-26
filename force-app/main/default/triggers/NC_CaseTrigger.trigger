/*
**   Class Name: NC_CaseTrigger
**   Description: Trigger on User
**
**     Date            New/Modified           User                 Identifier                Description
**  22-04-2020             New          Hiten Aggarwal(mtx)
*/

trigger NC_CaseTrigger on Case (after insert, before update, after update, before insert) {
    
    // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('CaseTrigger');
    
    // Trigger on Before Update 
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(trigger.isBefore) {
            if( trigger.isUpdate){
                NC_CaseTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
            }
        }
    }
    
    // Trigger on Before Insert 
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(trigger.isBefore) {
            if( trigger.isInsert){
                NC_CaseTriggerHandler.beforeInsert(Trigger.new);
            }
        }
    }
    
    //Trigger on After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(trigger.isAfter) {
            if( trigger.isInsert){
                NC_CaseTriggerHandler.afterInsert(Trigger.new);
            }
        }
    }

    //Trigger on After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(trigger.isAfter) {
            if( trigger.isUpdate){
                NC_CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }

}