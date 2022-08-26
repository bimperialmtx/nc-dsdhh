trigger NC_EventAuthorizationTrigger on Event_Authorization__c (before update, after update, after insert, after delete, after undelete) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Event_Authorization__c');

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_EventAuthorizationTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
        }
    }
    
    //afterUpdate
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_EventAuthorizationTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }

    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isAfter && Trigger.isInsert){
            NC_EventAuthorizationTriggerHandler.afterInsert(Trigger.new);
        }
    }

    //After Delete
    if(triggerSupport == null || !triggerSupport.After_Delete__c){
        if(Trigger.isAfter && Trigger.isDelete){
            NC_EventAuthorizationTriggerHandler.afterDelete(Trigger.oldMap);
        }
    }

    //After Un Delete
    if(triggerSupport == null || !triggerSupport.After_UnDelete__c){
        if(Trigger.isAfter && Trigger.isUndelete){
            NC_EventAuthorizationTriggerHandler.afterUndelete(Trigger.new);
        }
    }
}