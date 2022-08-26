/*
**   Class Name: NC_StaffingRequestTrigger
**   Description: Trigger on Staffing_Request__c
**
**     Date            New/Modified           User                 Identifier                Description
**  06-14-2020             New          Shubham Dadhich
*/
trigger NC_CommunicationAccessRequestTrigger on Communication_Access_Request__c (before update, after update, after insert, after delete, after undelete) {

    // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Communication_Access_Request__c');
    
    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_ComRequestAccessTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
        }
    }
    
    // Trigger on After Update 
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(trigger.isAfter) {
            if( trigger.isUpdate){
                NC_ComRequestAccessTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
            }
        }
    }

    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isAfter && Trigger.isInsert){
            NC_ComRequestAccessTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.new,null);
        }
    }

    //After Delete
    if(triggerSupport == null || !triggerSupport.After_Delete__c){
        if(Trigger.isAfter && Trigger.isDelete){
            NC_ComRequestAccessTriggerHandler.rollUpOnInsertUpdateUnDelete(Trigger.old, null);
        }
    }

    //After Un Delete
    if(triggerSupport == null || !triggerSupport.After_UnDelete__c){
        if(Trigger.isAfter && Trigger.isUpdate){
            NC_ComRequestAccessTriggerHandler.rollUpOnDelete(Trigger.new);
        }
    }

}