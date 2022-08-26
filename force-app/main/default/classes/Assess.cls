/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   07-02-2021   kavya.konagonda@mtxb2b.com   Initial Version
**/
public with sharing class Assess {
    /*
    *********************************************************
    @Method Name    : fetchPicklist
    @description    : Retrieve picklist values dynamically by providing object name and field name
    @param          : String objectName, String fieldName
    @return         : List<SelectOptionWrapper>
    ********************************************************
    */
    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> opts = new List<SelectOptionWrapper>();

        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            opts.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        
        return opts;
    }
    
    // @AuraEnabled
    // public static String getConsumerName(String contactId){
    //     String parentContactId = '';
    //     if(String.isNotBlank(contactId)){
    //         parentContactId = [SELECT Id, Name FROM Contact WHERE Id=:contactId LIMIT 1].Name;
    //         return parentContactId;
    //     }
    //     return null;
    // }

    /*
    *********************************************************
    @Method Name    : getConsumerNameFromRequest
    @description    : Retrieve Case details by using case record id
    @param          : String requestId
    @return         : Case
    ********************************************************
    */
    @AuraEnabled
    public static Case getConsumerNameFromRequest(String requestId){
        String contactId = '';
        Case cas = new Case();
        if(String.isNotBlank(requestId)){
            // contactId = [SELECT Id,Contact.Name,ContactId FROM Case WHERE Id=:requestId LIMIT 1].Contact.Name;
            cas = [SELECT Id,Contact.Name,ContactId,ContactEmail,Contact.MobilePhone,Contact.MailingCity,Contact.MailingStreet,Contact.MailingState,Contact.MailingPostalCode,Contact.MailingCountry FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            // return contactId;
            return cas;
        }
        return null;
    }

    // @AuraEnabled
    // public static String getConsumerEmailFromRequest(String requestId){
    //     String contactEmail = '';
    //     if(String.isNotBlank(requestId)){
    //         contactEmail = [SELECT Id,ContactEmail FROM Case WHERE Id=:requestId LIMIT 1].contactEmail;
    //         return contactEmail;
    //     }
    //     return null;
    // }

    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }
    
    public class AssessmentDataWrapper{
        @AuraEnabled public string hearing;
        @AuraEnabled public string narrative;
        @AuraEnabled public string visionloss;
        @AuraEnabled public string other;
        @AuraEnabled public string communicationskills;
        @AuraEnabled public string connectivity;
        @AuraEnabled public string hearingassessment;
        @AuraEnabled public string atUsage;
        @AuraEnabled public List<string> computerusageexperience;
        @AuraEnabled public string visualassessment;
        @AuraEnabled public string tactileassessment;
        @AuraEnabled public string consumergoals;
        @AuraEnabled public List<string> levelofcomputerexperience;
        @AuraEnabled public string attestation;
        @AuraEnabled public string attestorsignature;
        @AuraEnabled public string attestationdate;
        @AuraEnabled public string mailingaddress;
        @AuraEnabled public string emailaddress;
        @AuraEnabled public string phone;
        @AuraEnabled public string license;
       // @AuraEnabled public string contactId;
        @AuraEnabled public string requestId;
        
        
         public Assessment__c assessmentDataHandler() {
            Assessment__c assessment = new Assessment__c();
            //  assessment.Hearing_Loss__c = hearing;
             assessment.Narrative__c = narrative;
            //  assessment.Vision_Loss__c = visionloss;
            //  assessment.Other__c = other;
            //  assessment.Communication_Skills__c = communicationskills;
            //  assessment.Connectivity__c = connectivity;
            //  assessment.AT_Usage__c=atUsage;
            //  assessment.Hearing_Assessment__c = hearingassessment;
            //  assessment.Visual_Assessment__c = visualassessment;
            //  assessment.Tactile_Assessment__c = tactileassessment;
             assessment.Consumer_Goals__c = consumergoals;
             String computerValue='';
            if(levelofcomputerexperience!=null && levelofcomputerexperience.size()>0){
             for(Integer value=0;value<levelofcomputerexperience.size();value++){
                 if(value==0){
                    computerValue=levelofcomputerexperience[value];
                 }
                 else {
                    computerValue=computerValue+';'+levelofcomputerexperience[value];
                 }
             }
             assessment.Level_of_Computer_Experience__c = computerValue;
            }
             String pcMacValue='';
            if(computerusageexperience!=null && computerusageexperience.size()>0){
             for(Integer value=0;value<computerusageexperience.size();value++){
                 if(value==0){
                    pcMacValue=computerusageexperience[value];
                 }
                 else {
                    pcMacValue=pcMacValue+';'+computerusageexperience[value];
                 }
             }
             assessment.Computer_usage_experience__c = pcMacValue;
            }
             assessment.Attestation__c = attestation;
             assessment.Attestors_signature__c = attestorsignature;
             if(attestationdate != null){
               assessment.Date__c = Date.valueOf(attestationdate);
             }
            //assessment.Mailing_Address__c = mailingaddress;
            //assessment.Phone_Number__c = phone;
             assessment.License_Certificate_Number_if_applicabl__c = license;
            // assessment.Consumer__c = contactId;
            Case newCase=new Case();
            newCase = getConsumerNameFromRequest(requestId);
            assessment.Consumer__c = newCase.ContactId;
            assessment.Request__c = requestId;
            assessment.Email_Address__c = newCase.ContactEmail;
            assessment.Phone_Number__c=newCase.Contact.MobilePhone;
            String address=newCase.Contact.MailingStreet+''+newCase.Contact.MailingCity+''+newCase.Contact.MailingState+''+newCase.Contact.MailingCountry+''+newCase.Contact.MailingPostalCode;
            assessment.Mailing_Address__c = address;
             return assessment;
        } 
    }

    /*
    *********************************************************
    @Method Name    : saveData
    @description    : Save Assessment object record details
    @param          : String dataObj
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void saveData(String dataObj){
        try {
            AssessmentDataWrapper assessmentWrapper = (AssessmentDataWrapper) JSON.deserialize(dataObj, AssessmentDataWrapper.class);
            Assessment__c ass = assessmentWrapper.assessmentDataHandler();
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Assessment__c', new List<Assessment__c>{ass}, 'insert', true,'Assess','saveData');
            insert decision.getRecords();
            //insert ass;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }

    }
   
 }