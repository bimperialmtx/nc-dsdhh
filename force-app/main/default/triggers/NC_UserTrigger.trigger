/*
*   Class Name: NC_UserTrigger
*   Description: Trigger on User
*
*   Date            New/Modified         User                 Identifier                Description
*   27/04/2020         New         Shubham Dadhich(mtx)
*/

trigger NC_UserTrigger on User (after insert, after update, before insert, before update) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('UserTrigger');
    
    //Trigger on Before Insert 
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(trigger.isInsert && trigger.isBefore){
            NC_UserTriggerHandler.beforeInsert(trigger.new);
        }
    }
    
    //Trigger on Before Update 
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(trigger.isUpdate && trigger.isBefore){
            NC_UserTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        }
    }

    //Trigger on After Insert 
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(trigger.isInsert && trigger.isAfter){
            NC_UserTriggerHandler.afterInsert(trigger.new);
        }
    }
    
    //Trigger on After Update
    if(trigger.isUpdate && trigger.isAfter){
        NC_UserTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
    }

}