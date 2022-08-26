/*
**   Class Name: NC_InformationReferralTrigger
**   Description: Trigger on Information_Referral__c
**
**     Date            New/Modified           User                 Identifier               Description
**   05-08-2020             New          Hiten Aggarwal(mtx)
*/
trigger NC_InformationReferralTrigger on Information_Referral__c (before insert, before update) {

    // Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Information_Referral__c');
    
    // Trigger on Before Update 
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(trigger.isBefore) {
            if( trigger.isUpdate ){
                NC_InformationReferralTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
            }
        }
    }
    
    // Trigger on Before Insert 
    if(triggerSupport == null || !triggerSupport.Before_Insert__c){
        if(trigger.isBefore) {
            if( trigger.isInsert){
                NC_InformationReferralTriggerHandler.beforeInsert(Trigger.new);
            }
        }
    }
    
}