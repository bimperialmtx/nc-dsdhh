/*
*   Class Name: NC_AssetTrigger
*   Description: Asset Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/
trigger NC_AssetTrigger on Asset__c (after update, before update, after delete) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Asset__c');

    //Before Insert
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isAfter && Trigger.isUpdate){
            NC_AssetTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }

    //Before Insert
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isBefore && Trigger.isUpdate){
            NC_AssetTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
    
    //After Delete
    if(triggerSupport == null || !triggerSupport.After_Delete__c){
        if(Trigger.isAfter && Trigger.isDelete){
            NC_AssetTriggerHandler.afterDelete(Trigger.old);
        }
    }
}