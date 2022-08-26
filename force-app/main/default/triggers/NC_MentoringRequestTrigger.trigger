trigger NC_MentoringRequestTrigger on Mentoring_Request__c (before update) {

    //Trigger Support To Lock Unlock Trigger
    TriggerSupport__mdt triggerSupport = NC_BaseController.getTriggerSupport('Mentoring_Request__c');

    //Before Update
    if(triggerSupport == null || !triggerSupport.Before_Update__c){
        if(Trigger.isUpdate && Trigger.isBefore){
            NC_MentoringRequestTriggerHandler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
    }
}