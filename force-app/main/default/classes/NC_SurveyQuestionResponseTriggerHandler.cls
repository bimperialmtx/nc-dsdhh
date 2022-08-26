/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 06-21-2021
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   06-21-2021   kavya.konagonda@mtxb2b.com   Initial Version
**/
public with sharing class NC_SurveyQuestionResponseTriggerHandler {
    /*
    *********************************************************
    @Method Name    : AfterInsert
    @description    : execute on after insert trigger event
    @param          : List<SurveyQuestionResponse>newList ,Map<Id,SurveyQuestionResponse> oldMap
    @return         : void
    ********************************************************
    */
  public static void AfterInsert (List<SurveyQuestionResponse>newList ,Map<Id,SurveyQuestionResponse> oldMap ){
         checkConsumer(newList,oldMap);
     }
     
    /*
    *********************************************************
    @Method Name    : checkConsumer
    @description    : Create consumer from survey and link it to sureyresponse
    @param          : List<SurveyQuestionResponse>newList ,Map<Id,SurveyQuestionResponse> oldMap
    @return         : void
    ********************************************************
    */
     public static void checkConsumer(List<SurveyQuestionResponse>newList ,Map<Id,SurveyQuestionResponse> oldMap){
       
         Map<String,Id> recordNameToSurvey = new Map<String,Id>();
        /* Map<String, Integer> MyStrings = new Map<String, Integer>{'January' => 1, 'February' => 2,'March' => 3, 'April' => 4,'May' => 5, 'June' => 6,'July' => 7, 'August' => 8,'September' => 9, 'October' => 10,
             'November' => 11, 'December' => 12};*/
         Set<Id> surveyValidSet = new Set<Id>();
         Map<String, Survey_Record_Id__mdt > mapEd = Survey_Record_Id__mdt.getAll();
         for(String mapValue : mapEd.keySet()){
             if(mapEd.get(mapValue).Create_the_new_consumers__c ==true){
                surveyValidSet.add(mapEd.get(mapValue).RecordId__c) ;
             }
            // recordNameToSurvey.put(mapEd.get(mapValue).DeveloperName,mapEd.get(mapValue).RecordId__c);
        }
         List<Id> surveyResponseList = new List<Id>();
         List<Id> surveyInvitationList = new List<Id>();
         Map<Id,Id> responseToInitiativeMap = new Map<Id,Id>();
         Set<Id> surveyResponse= new Set<Id>();
         for(SurveyQuestionResponse response:[SELECT Id,ResponseId FROM SurveyQuestionResponse WHERE Id IN:newList]){
             surveyResponse.add(response.ResponseId);
         }
         
         for(SurveyResponse response :[SELECT Id,SurveyId,InvitationId  FROM SurveyResponse WHERE Id IN:surveyResponse]){
          //   if(surveyValidSet.contains(response.SurveyId)){
           //  if(response.SurveyId == recordNameToSurvey.get('Customer_Check_Survey')){
                 surveyResponseList.add(response.Id);
                 surveyInvitationList.add(response.InvitationId);
                 responseToInitiativeMap.put(response.Id,response.InvitationId);
            // }
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
      // Set<String> dobSet = new Set<String>();
         Map <Id,List<Map<String,String>>> finalMap= new Map<Id,List<Map<String,String>>>();
          Map <Id,List<Map<String,String>>> searchMap= new Map<Id,List<Map<String,String>>>();
       //  Map <Id,List<String>> searchMap= new Map<Id,List<String>>();
         if(surveyResponseList!=null){
             for(SurveyResponse response: [SELECT Id,SurveyId,(SELECT Id, Question.Name,ResponseShortText FROM SurveyQuestionResponses) FROM SurveyResponse WHERE Id IN:surveyResponseList]){
                  List<Map<String,String>> finalSearchList = new List<Map<String,String>>();
                 List<Map<String,String>> searchList = new List<Map<String,String>>();
                 // List<String> searchList = new List<String>();
                 Map<String,String> finalListMap=new Map<String,String>();
                 Map<String,String> searchListMap=new Map<String,String>();
                 for(SurveyQuestionResponse questionResponse:response.SurveyQuestionResponses){
                    
                     if(questionResponse.Question.Name.contains('First Name') && questionResponse.ResponseShortText!=null){
                         finalListMap.put('First Name',questionResponse.ResponseShortText);
                        // finalSearchList.add(questionResponse.ResponseShortText);
                     } 
                     if(questionResponse.Question.Name.contains('Last Name') && questionResponse.ResponseShortText!=null ){
                          finalListMap.put('Last Name',questionResponse.ResponseShortText);
                        // finalSearchList.add(questionResponse.ResponseShortText);
                     } 
                     if(questionResponse.Question.Name.contains('Email Address') && questionResponse.ResponseShortText!=null){
                         finalListMap.put('Email Address',questionResponse.ResponseShortText);
                       //  finalSearchList.add(questionResponse.ResponseShortText);
                        // searchList.add(questionResponse.ResponseShortText);
                         emailSet.add(questionResponse.ResponseShortText);
                         searchListMap.put('Email Address',questionResponse.ResponseShortText);
                     } 
                     if(questionResponse.Question.Name.contains('Date of Birth') && questionResponse.ResponseShortText!=null){
                       //  finalSearchList.add(questionResponse.ResponseShortText);
                         
                         String formattedDate=formatDate(questionResponse.ResponseShortText);
                         finalListMap.put('Date of Birth',formattedDate);
                         searchListMap.put('Date of Birth',formattedDate);
                         // finalSearchList.add(formattedDate);
                        // searchList.add(formattedDate);
                         dobSet.add(Date.parse(formattedDate));
                        // dobSet.add(questionResponse.ResponseShortText);
                     } 
                  if(questionResponse.Question.Name.contains('County') && questionResponse.ResponseShortText!=null){
                         finalListMap.put('County',questionResponse.ResponseShortText);
                         
                       //  finalSearchList.add(questionResponse.ResponseShortText);
                     }
               if(questionResponse.Question.Name.contains('Phone Number') && questionResponse.ResponseShortText!=null){
                         finalListMap.put('Phone Number',questionResponse.ResponseShortText);
                         
                       //  finalSearchList.add(questionResponse.ResponseShortText);
                     }
                     if(finalListMap.size()>0){
                    finalSearchList.add(finalListMap);
                     }
                     if(searchListMap.size()>0){
                    searchList.add(searchListMap);
                     }
                     
                 }
                 if(finalSearchList.size()>0){
                  finalMap.put(response.Id,finalSearchList);
                 }
                 if(searchList.size()>0){
                  searchMap.put(response.Id,searchList); 
                 }
             }
         }
          List<Contact> contactListFinal = new List<Contact>();
         List<Contact> contactList = [SELECT Id,Email,Birthdate FROM Contact WHERE Email IN:emailSet];
             if(contactList.size() == 0){
               for(Id idValue:finalMap.keySet()){
                // if(!(searchMap.get(idValue)[0]==con.Email && searchMap.get(idValue)[1]==String.valueOf(con.Birthdate))){
                   List<Map<String,String>> finalList = new List<Map<String,String>>();
                   
                   finalList=finalMap.get(idValue);
                   Contact con1 = new Contact();
               for(Map<String,String> val:finalMap.get(idValue)){
                   if(val.get('First Name')!=null){
                     con1.FirstName=val.get('First Name');
                   }
                   if(val.get('Last Name')!=null){
                     con1.LastName=val.get('Last Name');
                   }
                   if(val.get('Email Address')!=null){
                     con1.Email=val.get('Email Address');
                   }
                   if(val.get('Date of Birth')!=null){
                     con1.Birthdate=Date.Parse(val.get('Date of Birth'));
                   }
                   if(val.get('County')!=null){
                     con1.County__c  =val.get('County');
                   }
                   if(val.get('Phone Number')!=null){
                     con1.HomePhone  =val.get('Phone Number');
                   }
                    // con1.Relationship_Type__c = 'Friend';
             }
                   contactListFinal.add(con1);
          }
      } 
 
         if(contactListFinal.size()>0){
             insert contactListFinal;
             //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', contactListFinal, 'insert', true,'NC_SurveyQuestionResponseTriggerHandler','checkConsumer');
             //insert decision.getRecords();
         }
         List< SurveyInvitation> surveyInvitList = new List<SurveyInvitation>();
         for(Contact con : [SELECT Id,Email,Birthdate FROM Contact WHERE Email IN:emailSet]){
             for(Id idValue:searchMap.keySet()){
                  List<Map<String,String>> finalList = new List<Map<String,String>>();
                   
                   finalList=searchMap.get(idValue);
                 //  Contact con1 = new Contact();
                 for(Map<String,String> val:searchMap.get(idValue)){
                   //if(val.get('Email Address')==con.Email && Date.parse(val.get('Date of Birth'))==con.Birthdate){ 
                     if(val.get('Email Address')==con.Email){ 
                         
                          SurveyInvitation sinit= surveyInvitationMap.get(responseToInitiativeMap.get(idValue));
                          sinit.Consumer_Id__c=con.Id;
                         if(!surveyInvitList.contains(sinit)){
                          surveyInvitList.add(sinit);
                         }
                 }
               //  if(searchMap.get('Email Address')==con.Email && Date.parse(searchMap.get(idValue)[1])==con.Birthdate){
                /* SurveyInvitation sinit= surveyInvitationMap.get(responseToInitiativeMap.get(idValue));
                 sinit.Consumer_Id__c=con.Id;
                 surveyInvitList.add(sinit);*/
             }
          }
             
         }
         if(surveyInvitList.size()>0){
           update surveyInvitList;
           //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('SurveyInvitation', surveyInvitList, 'update', true,'NC_SurveyQuestionResponseTriggerHandler','checkConsumer');
           //update decision.getRecords();
         }
    
   } 

    /*
    *********************************************************
    @Method Name    : formatDate
    @description    : format date
    @param          : String dateValue
    @return         : String
    ********************************************************
    */
     public Static String formatDate(String dateValue){
         
         Map<String, String> MyStrings = new Map<String, String>{'January' => '1', 'February' => '2','March' => '3', 'April' => '4','May' => '5', 'June' => '6','July' => '7', 'August' => '8','September' => '9', 'October' => '10',
             'November' => '11', 'December' => '12'};
         String correctDate='';
         String[] strSplitDate = dateValue.split(' ');
         correctDate=MyStrings.get(strSplitDate[0]);
         String[] strSplitDateSecond = strSplitDate[1].split(',');
         correctDate=MyStrings.get(strSplitDate[0])+'/'+strSplitDateSecond[0]+'/'+strSplitDate[2];
         
         return correctDate;
     }
 }