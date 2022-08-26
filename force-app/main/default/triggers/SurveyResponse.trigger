trigger SurveyResponse on SurveyResponse (Before insert,After insert,After update,Before update,After delete,Before delete) {
    if(trigger.isInsert && trigger.isAfter){
       // SurveyResponseTriggerHandler.AfterInsert(Trigger.new, Trigger.oldMap);
        
    }
}