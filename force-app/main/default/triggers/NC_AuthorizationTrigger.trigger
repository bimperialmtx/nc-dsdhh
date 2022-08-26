/*
*   Class Name: NC_AuthorizationTrigger
*   Description: Authorization Trigger
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/

trigger NC_AuthorizationTrigger on Authorization__c (after update, after insert, after delete, after undelete,before update) {
    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Authorization__c');
    
    //before Update
    if(triggerSupport == null || !triggerSupport.Before_update__c){
        if(Trigger.isBefore && Trigger.isUpdate){
            NC_AuthorizationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    

    //After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isAfter && Trigger.isUpdate){
            NC_AuthorizationTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,Trigger.oldMap);
            NC_AuthorizationTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }

    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isAfter && Trigger.isInsert){
            NC_AuthorizationTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
        }
    }


    //After Delete
    if(triggerSupport == null || !triggerSupport.After_Delete__c){
        if(Trigger.isAfter && Trigger.isDelete){
            NC_AuthorizationTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.old, null);
        }
    }

    //After Un Delete
    if(triggerSupport == null || !triggerSupport.After_UnDelete__c){
        if(Trigger.isAfter && Trigger.isUndelete){
            NC_AuthorizationTriggerHandler.rollUpOnDelete(Trigger.new);
        }
    }


}