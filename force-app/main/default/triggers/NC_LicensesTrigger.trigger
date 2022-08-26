/*
**   Class Name: NC_LicensesTrigger
**   Description: Trigger on License
**
**     Date            New/Modified           User                 Identifier                Description
**   05-15-2020             New          Shubham Dadhich
*/

trigger NC_LicensesTrigger on License__c (before update, before Insert) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('LicenseTrigger');

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_LicensesTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    
    //Before Insert 
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(Trigger.isInsert && Trigger.isBefore){
            NC_LicensesTriggerHandler.beforeInsert(Trigger.new);
        }
    }

}