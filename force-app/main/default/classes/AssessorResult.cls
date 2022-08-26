/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class AssessorResult {
    /*
    *********************************************************
    @Method Name    : assessorResult
    @description    : update case or attendees invitation to accept or reject
    @param          : String requestId,String assesserResult
    @return         : Boolean
    ********************************************************
    */
    @AuraEnabled
    public static Boolean assessorResult(String requestId,String assesserResult){
        String sObjName ='';
        if(String.isNotBlank(requestId)){
            sObjName = Id.valueOf(requestId).getSObjectType().getDescribe().getName();
        }
        if(sObjName == 'Case'){
            List<Case> caseFinalList = new List<Case>();
            for(Case caseValue : [SELECT Id,Assessor_Result__c,showInternalAssessor__c,CaseNumber FROM Case WHERE Id = :requestId  LIMIT 1]){
                caseValue.Assessor_Result__c = assesserResult;
                caseValue.showInternalAssessor__c=false;
                caseFinalList.add(caseValue);
            }
            if(caseFinalList.size()>0){
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case', caseFinalList, 'update', true,'AssessorResult','assessorResult');
                update objectDecision.getRecords();
                
                //update caseFinalList;
                return true;
            }
        }
        else{
            List<Attendees__c> AttendeesFinalList = new List<Attendees__c>();
            for(Attendees__c attendeesValue : [SELECT Id,Trainer_Result__c,showInternalAssessor__c,Name FROM Attendees__c WHERE Id = :requestId  LIMIT 1]){
                attendeesValue.Trainer_Result__c = assesserResult;
                attendeesValue.showInternalAssessor__c=false;
                AttendeesFinalList.add(attendeesValue);
            }
            if(AttendeesFinalList.size()>0){
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Attendees__c', AttendeesFinalList, 'update', true,'AssessorResult','assessorResult');
                update objectDecision.getRecords();
                //update AttendeesFinalList;
                return true;
            }
        }
        return false;
        
    }
    
    /*
    *********************************************************
    @Method Name    : getAssessorResult
    @description    : Return current status of Case or Attendees invitation
    @param          : String requestId
    @return         : Boolean
    ********************************************************
    */
    @AuraEnabled
    public static Boolean getAssessorResult(String requestId){
        String sObjName ='';
        if(String.isNotBlank(requestId)){
            sObjName = Id.valueOf(requestId).getSObjectType().getDescribe().getName();
        }
        Boolean assesserResult =false;
        if(sObjName == 'Case'){
            for(Case caseValue : [SELECT Id,Assessor_Result__c,CaseNumber FROM Case WHERE Id = :requestId  LIMIT 1]){
                if(caseValue.Assessor_Result__c==null){
                    assesserResult= false;
                }
                else{
                    assesserResult= true;
                }
            }
        }
        else{
            for(Attendees__c attendeesValue : [SELECT Id,Trainer_Result__c,showInternalAssessor__c,Name FROM Attendees__c WHERE Id = :requestId  LIMIT 1]){
                if(attendeesValue.Trainer_Result__c==null){
                    assesserResult= false;
                }
                else{
                    assesserResult= true;
                }
            }
        }
        return assesserResult;
        
    }
    
    /* @AuraEnabled
public static Boolean checkAssessor(String requestId){
String sObjName ='';
if(String.isNotBlank(requestId)){
sObjName = Id.valueOf(requestId).getSObjectType().getDescribe().getName();
}

User user =[SELECT Id,IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

Case assessorValue=[SELECT Id,External_Assessor__c FROM Case WHERE Id =:requestId];
Case trainerValue=[SELECT Id,NDBEDP_Trainer__c FROM Case WHERE Id =:requestId];

List<Id> userId=new List<Id>();
for(User u : [SELECT Id,contact.AccountId FROM User WHERE contact.AccountId=:assessorValue.External_Assessor__c]){
userId.add(u.Id);
}
for(User u : [SELECT Id,contact.AccountId FROM User WHERE contact.AccountId=:trainerValue.NDBEDP_Trainer__c]){
userId.add(u.Id);
}


Case caseValue = new Case();
Attendees__c attendee = new Attendees__c();
if(sObjName  == 'Case'){
caseValue=[SELECT Id,External_Assessor_User__c FROM Case WHERE Id =:requestId  LIMIT 1];
// if(caseValue.External_Assessor_User__c == user.Id){
//     return true;
// }
if(userId!=NULL && userId.contains(user.Id)){
return true;
}
else{
return false;
}
}
else{
attendee=[SELECT Id,NDBEDP_Trainer_User__c FROM Attendees__c WHERE Id =:requestId LIMIT 1];
if(attendee.NDBEDP_Trainer_User__c == user.Id){
return true;
}
else{
return false;
}
}


// if(caseValue.External_Assessor_User__c == user.Id || attendee.NDBEDP_Trainer_User__c == user.Id){
//     return true;
// }
// else{
//     return false;
// }


}*/

    /*
    *********************************************************
    @Method Name    : checkAssessor
    @description    : Validate if Assessor is authorized to Approve or Reject the invitations
    @param          : String requestId
    @return         : Boolean
    ********************************************************
    */
    @AuraEnabled
    public static Boolean checkAssessor(String requestId){
        String sObjName ='';
        if(String.isNotBlank(requestId)){
            sObjName = Id.valueOf(requestId).getSObjectType().getDescribe().getName();
        }
        
        User user =[SELECT Id,IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Case assessorValue=[SELECT Id,External_Assessor__c FROM Case WHERE Id =:requestId];
        Case trainerValue=[SELECT Id,NDBEDP_Trainer__c FROM Case WHERE Id =:requestId];
        
        List<Id> userId=new List<Id>();
        for(User u : [SELECT Id,contact.AccountId FROM User WHERE contact.AccountId=:assessorValue.External_Assessor__c]){
            userId.add(u.Id);
        }
        
        for(User u : [SELECT Id,contact.AccountId FROM User WHERE contact.AccountId=:trainerValue.NDBEDP_Trainer__c]){
            userId.add(u.Id);
        }
        
        Case caseValue = new Case();
        Attendees__c attendee = new Attendees__c();
        if(sObjName  == 'Case'){
            caseValue=[SELECT Id,External_Assessor_User__c FROM Case WHERE Id =:requestId  LIMIT 1];

            if(userId!=NULL && userId.contains(user.Id)){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            attendee=[SELECT Id,NDBEDP_Trainer_User__c FROM Attendees__c WHERE Id =:requestId LIMIT 1];
            if(attendee.NDBEDP_Trainer_User__c == user.Id){
                return true;
            }
            else{
                return false;
            }
        }
        
    }
    
    /*
    *********************************************************
    @Method Name    : getCaseNumber
    @description    : Get case number or Outreach Request number by input record id
    @param          : String requestId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String getCaseNumber(String requestId){
        String sObjName ='';
        if(String.isNotBlank(requestId)){
            sObjName = Id.valueOf(requestId).getSObjectType().getDescribe().getName();
        }
        Case caseValue = new Case();
        Attendees__c attendee = new Attendees__c();
        if(sObjName  == 'Case'){
            caseValue = [SELECT Id,Assessor_Result__c,CaseNumber FROM Case WHERE Id = :requestId  LIMIT 1];
        }
        else{
            attendee= [SELECT Id, Name, Outreach_Request__r.Name, NDBEDP_Trainer__c, Trainer_Result__c, NDBEDP_Trainer_User__c FROM Attendees__c WHERE Id = :requestId   LIMIT 1];
        }
        if(caseValue.CaseNumber!=null){
            return caseValue.CaseNumber;
        }
        else{
            return attendee.Outreach_Request__r.Name;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getCasesFromAccount
    @description    : Get all cases which required response from current user 
    @param          : 
    @return         : List<Case>
    ********************************************************
    */
    @AuraEnabled
    public static List<Case> getCasesFromAccount(){
        User user =[SELECT Id, AccountId,IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId()  LIMIT 1];
        List<Case> caseList = new List<Case>();
        List<Case> trainerList = new List<Case>();
        if(user.IsPortalEnabled){
            trainerList=[SELECT Id,Assessor_Result__c,AccountId,CaseNumber,NDBEDP_Trainer__c,Status,ContactEmail,Contact.Name FROM Case WHERE NDBEDP_Trainer__c =:user.AccountId AND Assessor_Result__c=null ];
        }
        if(user.IsPortalEnabled){
            caseList =[SELECT Id,Assessor_Result__c,AccountId,CaseNumber,External_Assessor__c,Status,ContactEmail,Contact.Name FROM Case WHERE External_Assessor__c =:user.AccountId AND Assessor_Result__c=null ];
        }
        else{
            caseList=[SELECT Id,Assessor_Result__c,AccountId,CaseNumber,Internal_Assessor__c,Status,Contact.Name,ContactEmail FROM Case WHERE Internal_Assessor__c =:UserInfo.getUserId() AND Assessor_Result__c=null ];
        }
        if(trainerList.size()>0){
            caseList.addAll(trainerList);
        }
        
        return caseList;
    }
    
    /*
    *********************************************************
    @Method Name    : getProfileName
    @description    : Get current user profile name
    @param          : 
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String getProfileName(){
        try {
            User user=[SELECT Id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
            String profileName=user.Profile.Name;
            return profileName;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error in get status ---> ' + e.getMessage() +e.getLineNumber());
        }
    }
}