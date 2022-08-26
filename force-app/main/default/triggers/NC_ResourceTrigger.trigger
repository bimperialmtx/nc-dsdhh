/*
*   Class Name: NC_ResourceTrigger
*   Description: Resource Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   16/07/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_ResourceTrigger on Resource__c (after update,before Insert,before update) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Resource__c');

    //After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_ResourceTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_ResourceTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    
     //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_ResourceTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}