/*
*   Class Name: NC_AlternateContactTrigger
*   Description: Account Contact Trigger
*
*   Date            New/Modified         User                    Identifier                Description
*   14-07-2020      New                  Hiten Aggarwal(MTX)
*/

trigger NC_AlternateContactTrigger on Alternate_Contact__c (after insert, after update) {
//Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Alternate_Contact__c');
    
    //After Insert
    if(triggerSupport == null || !triggerSupport.After_Insert__c){
        if(Trigger.isInsert && Trigger.isAfter){
             NC_AlternateContactTriggerHandler.afterInsert(Trigger.new);
        }
    }

    //After Update
    if(triggerSupport == null || !triggerSupport.After_Update__c){
        if(Trigger.isUpdate && Trigger.isAfter){
            NC_AlternateContactTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}