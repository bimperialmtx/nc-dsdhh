/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class SurveyResponseTriggerHandler {
    /*
    *********************************************************
    @Method Name    : AfterInsert
    @description    : execute after insert trigger event
    @param          : List<SurveyResponse>newList ,Map<Id,SurveyResponse> oldMap
    @return         : void
    ********************************************************
    */
    public static void AfterInsert (List<SurveyResponse>newList ,Map<Id,SurveyResponse> oldMap ){
        checkConsumer(newList,oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : checkConsumer
    @description    : Create consumer from survey and link it with survey response
    @param          : List<SurveyResponse>newList ,Map<Id,SurveyResponse> oldMap
    @return         : void
    ********************************************************
    */
    public static void checkConsumer(List<SurveyResponse>newList ,Map<Id,SurveyResponse> oldMap){
        Map<String,Id> recordNameToSurvey = new Map<String,Id>();
        Map<String, Survey_Record_Id__mdt > mapEd = Survey_Record_Id__mdt.getAll();
        for(String mapValue : mapEd.keySet()){
            recordNameToSurvey.put(mapEd.get(mapValue).DeveloperName,mapEd.get(mapValue).RecordId__c);
       }
        List<Id> surveyResponseList = new List<Id>();
        List<Id> surveyInvitationList = new List<Id>();
        Map<Id,Id> responseToInitiativeMap = new Map<Id,Id>();
        for(SurveyResponse response :[SELECT Id,SurveyId,InvitationId  FROM SurveyResponse WHERE Id IN:newList]){
            if(response.SurveyId == recordNameToSurvey.get('Customer_Check_Survey')){
                surveyResponseList.add(response.Id);
                surveyInvitationList.add(response.InvitationId);
                responseToInitiativeMap.put(response.Id,response.InvitationId);
            }
        }
        Map<Id,SurveyInvitation> surveyInvitationMap = new Map<Id,SurveyInvitation>();
        for(SurveyInvitation sInitiative:[SELECT Id,Consumer_Id__c  FROM SurveyInvitation WHERE Id IN:surveyInvitationList]){
            surveyInvitationMap.put(sInitiative.Id,sInitiative);
           
        }
        String firstName='';
        String lastName='';
        String emailValue='';
        Date dateOfBirth=null;
        String country = '';
        Set<String> emailSet = new Set<String>();
        Set<Date> dobSet = new Set<Date>();
        Map <Id,List<String>> finalMap= new Map<Id,List<String>>();
        Map <Id,List<String>> searchMap= new Map<Id,List<String>>();
        if(surveyResponseList!=null){
            for(SurveyResponse response: [SELECT Id,SurveyId,(SELECT Id, Question.Name,ResponseShortText FROM SurveyQuestionResponses) FROM SurveyResponse WHERE Id IN:surveyResponseList]){
                for(SurveyQuestionResponse questionResponse:response.SurveyQuestionResponses){
                    List<String> finalSearchList = new List<String>();
                    List<String> searchList = new List<String>();
                    if(questionResponse.Question.Name.contains('First Name')){
                        finalSearchList.add(questionResponse.ResponseShortText);
                    } if(questionResponse.Question.Name.contains('Last Name')){
                        finalSearchList.add(questionResponse.ResponseShortText);
                    } if(questionResponse.Question.Name.contains('Email Address')){
                        finalSearchList.add(questionResponse.ResponseShortText);
                        searchList.add(questionResponse.ResponseShortText);
                        emailSet.add(questionResponse.ResponseShortText);
                    } if(questionResponse.Question.Name.contains('Date of Birth')){
                        finalSearchList.add(questionResponse.ResponseShortText);
                        searchList.add(questionResponse.ResponseShortText);
                        dobSet.add(Date.valueOf(questionResponse.ResponseShortText));
                    } if(questionResponse.Question.Name.contains('County')){
                        finalSearchList.add(questionResponse.ResponseShortText);
                    }
                    finalMap.put(response.Id,finalSearchList); 
                    searchMap.put(response.Id,searchList); 
                    
                }
            }
        }
      
      List<Contact> contactList = new List<Contact>();
        for(Contact con : [SELECT Id FROM Contact WHERE Email IN:emailSet AND Birthdate IN :dobSet]){
            for(Id idValue:searchMap.keySet()){
                if(!(searchMap.get(idValue)[0]==con.Email && searchMap.get(idValue)[1]==String.valueOf(con.Birthdate))){
                    Contact con1 = new Contact();
                    con1.FirstName=finalMap.get(idValue)[0];
                    con1.LastName=finalMap.get(idValue)[1];
                    con1.Email=finalMap.get(idValue)[2];
                    con1.Birthdate=Date.valueOf(finalMap.get(idValue)[3]);
                    con1.County__c  =finalMap.get(idValue)[4];
                   contactList.add(con1);
                }
                
               // SurveyInvitation sinit= surveyInvitationMap.get(responseToInitiativeMap.get(idValue));
               // sinit.Consumer_Id__c=con.Id;
            }
        }
        if(contactList.size()>0){
            insert contactList;
        }
        
              List< SurveyInvitation> surveyInvitList = new List<SurveyInvitation>();
        for(Contact con : [SELECT Id FROM Contact WHERE Email IN:emailSet AND Birthdate IN :dobSet]){
            for(Id idValue:searchMap.keySet()){
                SurveyInvitation sinit= surveyInvitationMap.get(responseToInitiativeMap.get(idValue));
                sinit.Consumer_Id__c=con.Id;
                surveyInvitList.add(sinit);
            }
        
            
        }
        if(surveyInvitList.size()>0){
            update surveyInvitList;
        }
    }
    
}