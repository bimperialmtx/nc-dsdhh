/*
*   Class Name: NC_MentoringRequestWrapper
*   Description: 
*
*   Date            New/Modified         User                 Identifier                Description
*                      New         Hiten Aggarwal(mtx)
*/
public with sharing class NC_MentoringRequestController {

    /*
    *********************************************************
    @Method Name    : fetchPicklist
    @description    : Get picklist values by object and field name
    @param          : String objectName, String fieldName
    @return         : List<SelectOptionWrapper>
    ********************************************************
    */
    @AuraEnabled
    public static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
        List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            optionList.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
        }    
        return optionList;
    }
    
    /*
    *********************************************************
    @Method Name    : createMentoringRequestRecord
    @description    : Create Mentoring request from input data
    @param          : String wizardData, Id recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> createMentoringRequestRecord(String wizardData, Id recordId){
        Map<String, Object> result = new Map<String, Object>();
        String url = System.URL.getSalesforceBaseUrl().toExternalForm();
        NC_MentoringRequestWrapper mentoringWrapper = (NC_MentoringRequestWrapper) JSON.deserialize(wizardData, NC_MentoringRequestWrapper.class);
        
        Mentoring_Request__c mentoringRequest = new Mentoring_Request__c();
        mentoringRequest.Have_Deaf_Family_Members__c = mentoringWrapper.familyInformation.haveDeafFamilyMembers;
        mentoringRequest.Member_Relationship__c    = mentoringWrapper.familyInformation.memberRelationship;//.replaceAll(',',';');
        mentoringRequest.Relationship_If_Other__c = mentoringWrapper.familyInformation.relationshipIfOther;
        
        
        mentoringRequest.Education_Level__c = mentoringWrapper.educationInformation.educationLevel;
        mentoringRequest.Degree__c = mentoringWrapper.educationInformation.degree;//.replaceAll(',',';');
        mentoringRequest.College__c = mentoringWrapper.educationInformation.college;//.replaceAll(',',';');
        mentoringRequest.Other_Education__c = mentoringWrapper.educationInformation.otherEducation;
        mentoringRequest.Other_Degree__c = mentoringWrapper.educationInformation.otherDegree;
        mentoringRequest.Other_College__c = mentoringWrapper.educationInformation.otherCollege;
        
        
        mentoringRequest.license_Issued_by_the_NCITLB__c = mentoringWrapper.dataNCITL.licenseIssuedbyTheNCITLB;
        mentoringRequest.NCITLB_License_Number__c = mentoringWrapper.dataNCITL.NCITLBLicenseNumber;

        mentoringRequest.Have_interpreter_transliteration_Cert__c = mentoringWrapper.certificateInformation.holdInterpreterCert;
        mentoringRequest.Interpreter_Certifications__c = mentoringWrapper.certificateInformation.certificateValue;
        mentoringRequest.Assessment_Level__c = mentoringWrapper.certificateInformation.assessmentLevel;
        mentoringRequest.RID_Number__c = mentoringWrapper.certificateInformation.RIDNumber;
        
        mentoringRequest.Taken_CASLI_NIC_or_CDI_Knowledge_Exam__c = mentoringWrapper.knowledgeInformation.tkenCASLINICOrCDIKnowledgeExam;
        mentoringRequest.Passed_CASLI_NIC_or_CDI_Knowledge__c = mentoringWrapper.knowledgeInformation.passedCASLINICOrCDIKnowledge;  
        mentoringRequest.Planning_CASLI_NIC_or_CDI_Knowledge__c = mentoringWrapper.knowledgeInformation.planningCASLINICOrCDIKnowledge;
        
        
        mentoringRequest.Taken_CASLI_NIC_or_CDI_Performance_Exam__c = mentoringWrapper.performanceInformation.takenCASLINICOrCDIPerformanceExam;
        mentoringRequest.Passed_CASLI_NIC_or_CDI_Performance_Exam__c = mentoringWrapper.performanceInformation.passedCASLINICOrCDIPerformanceExam;
        mentoringRequest.How_Many_Times_CASLI_NIC_or_CDI_Performa__c = mentoringWrapper.performanceInformation.howManyTimesCASLINICOrCDIPerforma;
        mentoringRequest.Last_CASLI_NIC_or_CDI_Performance_Exam__c = mentoringWrapper.performanceInformation.lastCASLINICOrCDIPerformanceExam;
        mentoringRequest.Planning_CASLI_NIC_or_CDI_Performance__c = mentoringWrapper.performanceInformation.planningCASLINICOrCDIPerformance;
        mentoringRequest.Time_Period_CASLI_NIC_or_CDI_Performance__c = mentoringWrapper.performanceInformation.timePeriodCASLINICOrCDIPerformance;
        
        
        mentoringRequest.Are_you_planning_to_take_the_EIPA__c = mentoringWrapper.eipaInformtion.AreYouPlanningToTakeTheEIPA;
        mentoringRequest.Have_you_taken_the_EIPA__c = mentoringWrapper.eipaInformtion.haveYouTakenTheEIPA;
        mentoringRequest.Last_Take_the_EIPA__c = mentoringWrapper.eipaInformtion.lastTaketheEIPA;
        mentoringRequest.What_is_your_EIPA_score__c = mentoringWrapper.eipaInformtion.whatIsYourEIPAScore;
        mentoringRequest.When_do_you_plan_to_take_the_EIPA__c = mentoringWrapper.eipaInformtion.whenDoYouPlanToTakeTheEIPA;
        
        mentoringRequest.Video_Relay_Interpreting__c = mentoringWrapper.percentageInformation.videoRelayInterpreting;
        mentoringRequest.Video_Remote_Interpreting__c = mentoringWrapper.percentageInformation.videoRemoteInterpreting;
        mentoringRequest.Educational_K_12__c = mentoringWrapper.percentageInformation.eucationalK12;
        mentoringRequest.Educational_Post_Secondary__c = mentoringWrapper.percentageInformation.educationalPostSecondary;
        mentoringRequest.Community_freelance__c = mentoringWrapper.percentageInformation.communityFreelance;
        mentoringRequest.Other__c = mentoringWrapper.percentageInformation.other;
        mentoringRequest.Hours_Worked_in_Medical_Settings__c = mentoringWrapper.percentageInformation.hoursWorkedinMedicalSettings;
        
        mentoringRequest.Information_Assistance__c = mentoringWrapper.skillsInformation.informationAssistance;//.replaceAll(',',';');
        mentoringRequest.Interpreting_skill_development__c = mentoringWrapper.skillsInformation.interpretingSkillDevelopment;//.replaceAll(',',';');
        mentoringRequest.Mentoring_services__c = mentoringWrapper.skillsInformation.mentoringservices;//.replaceAll(',',';');   
        
        mentoringRequest.Are_you_on_DHHS_Interpreter_Vendor_List__c =  mentoringWrapper.otherinformation.areYouOnDHHSInterpreterVendorList;
        mentoringRequest.After_5_Year__c = mentoringWrapper.otherinformation.after5Years;//.replaceAll(',',';') ;
        mentoringRequest.Other_after_5_Year__c = mentoringWrapper.otherinformation.oherAfter5Year;
        mentoringRequest.Workshop_In_North_Carolina__c = mentoringWrapper.otherinformation.workshopInNorthCarolina;
        mentoringRequest.Current_skill_development_goals__c = mentoringWrapper.otherinformation.currentSkillDevelopmentGoals;
       
        
        mentoringRequest.Consumer__c = recordId;
        mentoringRequest.Status__c = 'Created';   
      
       // Insert mentoringRequest;
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Mentoring_Request__c', new List<Mentoring_Request__c>{mentoringRequest}, 'insert', true,'NC_MentoringRequestController','createMentoringRequestRecord');
        Insert decision.getRecords();
        mentoringRequest.Id = decision.getRecords()[0].id;
        url = url+'/lightning/r/Mentoring_Request__c/' + mentoringRequest.Id+'/view';
        result.put('url',url);
        return result;
    }
  
    public class SelectOptionWrapper{
        @AuraEnabled public string value;
        @AuraEnabled public string label;
        public SelectOptionWrapper(string value, string label){
            this.value = value;
            this.label = label;
        }
    }
}