trigger NC_SurveyQuestionResponse on SurveyQuestionResponse (Before insert,After insert,After update,Before update,After delete,Before delete) {
if(trigger.isInsert && trigger.isAfter){
        NC_SurveyQuestionResponseTriggerHandler.AfterInsert(Trigger.new, Trigger.oldMap);
    }
}