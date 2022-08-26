/*
*   Class Name: NC_ContactTrigger
*   Description: Contact Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   28/04/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_ContactTrigger on Contact (before insert, before update, after insert, after update) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('ContactTrigger');

    //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_ContactTriggerHandler.beforeInsert(Trigger.new);
        }
    }
    
    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isInsert && Trigger.isAfter){
            NC_ContactTriggerHandler.afterInsert(Trigger.new);
        }
    }

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_ContactTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
    //After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_ContactTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}