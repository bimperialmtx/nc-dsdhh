/*
*   Class Name: NC_AccountTrigger
*   Description: Account Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   28/04/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_AccountTrigger on Account (before insert, before update, after update) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('AccountTrigger');

    //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_AccountTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    
    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_AccountTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    //After Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_AccountTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
}