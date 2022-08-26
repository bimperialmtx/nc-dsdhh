/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-29-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
* Modifications Log 
* Ver   Date         Author                       Modification
* 1.0   07-13-2021   kavya.konagonda@mtxb2b.com   Initial Version
**/
public without sharing class NC_AssessmentCtrl {
    /*
    *********************************************************
    @Method Name    : fetchPicklist
    @description    : retrieve picklist values by object name and field name
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
    
    /*
    *********************************************************
    @Method Name    : getConsumerNameFromRequest
    @description    : Retrieve case details by record id
    @param          : String requestId
    @return         : Case
    ********************************************************
    */
    @AuraEnabled
    public static Case getConsumerNameFromRequest(String requestId){
        String contactId = '';
        Case cas = new Case();
        if(String.isNotBlank(requestId)){
            cas = [SELECT Id,Contact.Name,ContactId,ContactEmail,Contact.MailingCity,Contact.MailingStreet,Contact.MailingState,Contact.MailingPostalCode,
                   Contact.MailingCountry,Contact.Cell_Phone_Number__c,Contact.HomePhone,Contact.MobilePhone,Contact.Alt_Phone_Number__c,Contact.Video_Phone_Number__c,Contact.Work_Phone_Number__c,Contact.Preferred_Contact_Method__c,Contact.TTY__c,Contact.Captel__c FROM Case 
                   WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            return cas;
        }
        return null;
    }
    
    /*
    *********************************************************
    @Method Name    : getAccountFromRequest
    @description    : Retrieve Assessor details by case record id
    @param          : String requestId
    @return         : Case
    ********************************************************
    */
    @AuraEnabled
    public static Case getAccountFromRequest(String requestId){
        Case cas = new Case();
        cas=[SELECT Id,ContactId,External_Assessor__c,Internal_Assessor__c FROM Case WHERE Id=:requestId WITH SECURITY_ENFORCED];
        if(String.isNotBlank(requestId)){
            
            if(cas.External_Assessor__c!=null){
                cas = [SELECT Id,External_Assessor__c,Internal_Assessor__c,ContactId,Case.External_Assessor__r.Email__c,Case.External_Assessor__r.BillingCity , Case.External_Assessor__r.BillingStreet ,
                       Case.External_Assessor__r.BillingState , Case.External_Assessor__r.BillingPostalCode , Case.External_Assessor__r.BillingCountry, Case.External_Assessor__r.Cell_Phone__c, Case.External_Assessor__r.Is_Vendor_on_Portal__c FROM Case  
                       WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
                return cas;
            }
            else if(cas.Internal_Assessor__c!=null){
                cas = [SELECT Id,ContactId,Internal_Assessor__c,External_Assessor__c,Case.Internal_Assessor__r.Email,Case.Internal_Assessor__r.MobilePhone,Case.Internal_Assessor__r.Phone,Case.Internal_Assessor__r.Work_Phone_Number__c,
                       Case.Internal_Assessor__r.City,Case.Internal_Assessor__r.Street,Case.Internal_Assessor__r.State,Case.Internal_Assessor__r.PostalCode,Case.Internal_Assessor__r.Country 
                       FROM Case WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
                return cas;
            }
        }
        return null;
    }
    
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
        // @AuraEnabled public string other;
        @AuraEnabled public List<string> other;
        //@AuraEnabled public string communicationskills;
        @AuraEnabled public List<string> communicationskills;
        //@AuraEnabled public string connectivity;
        @AuraEnabled public List<string> connectivity;
        //@AuraEnabled public string hearingassessment;
        @AuraEnabled public List<string> hearingassessment;
        //@AuraEnabled public string atUsage;
        @AuraEnabled public List<string> atUsage;
        @AuraEnabled public List<string> computerusageexperience;
        // @AuraEnabled public string visualassessment;
        @AuraEnabled public List<string> visualassessment;
        //@AuraEnabled public string tactileassessment;
        @AuraEnabled public List<string> tactileassessment;
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
        @AuraEnabled public string frombutton;
        @AuraEnabled public string signed;
        @AuraEnabled public Boolean refreshData;
        @AuraEnabled public Boolean onlineAssessor;
        @AuraEnabled public Boolean internalAssessor;
        
        
        public Assessment__c assessmentDataHandler() {
            Assessment__c assessment = new Assessment__c();
            assessment.Hearing_Loss__c = hearing;
            assessment.Narrative__c = narrative;
            assessment.Vision_Loss__c = visionloss;
            //assessment.Other__c = other;
            // assessment.Communication_Skills__c = communicationskills;
            // assessment.Connectivity__c = connectivity;
            // assessment.AT_Usage__c=atUsage;
            //assessment.Hearing_Assessment__c = hearingassessment;
            // assessment.Visual_Assessment__c = visualassessment;
            // assessment.Tactile_Assessment__c = tactileassessment;
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
            else if(levelofcomputerexperience==null){
                assessment.Level_of_Computer_Experience__c=''; 
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
            else if(computerusageexperience==null){
                assessment.Computer_usage_experience__c=''; 
            }
            string otherValue='';
            if(other!=null && other.size()>0){
                for(Integer value=0;value<other.size();value++){
                    if(value==0){
                        otherValue=other[value];
                    }
                    else {
                        otherValue=otherValue+';'+other[value];
                    }
                }
                assessment.Other__c = otherValue;
            }
            else if(other==null){
                assessment.Other__c=''; 
            }
            string computerusageexperienceValue='';
            if(communicationskills!=null && communicationskills.size()>0){
                for(Integer value=0;value<communicationskills.size();value++){
                    if(value==0){
                        computerusageexperienceValue=communicationskills[value];
                    }
                    else {
                        computerusageexperienceValue=computerusageexperienceValue+';'+communicationskills[value];
                    }
                }
                assessment.Communication_Skills__c = computerusageexperienceValue;
            }
            else if(communicationskills==null){
                assessment.Communication_Skills__c=''; 
            }
            
            string connectivityValue='';
            if(connectivity!=null && connectivity.size()>0){
                for(Integer value=0;value<connectivity.size();value++){
                    if(value==0){
                        connectivityValue=connectivity[value];
                    }
                    else {
                        connectivityValue=connectivityValue+';'+connectivity[value];
                    }
                }
                assessment.Connectivity__c = connectivityValue;
            }
            else if(connectivity==null){
                assessment.Connectivity__c=''; 
            }
            string atUsageValue='';
            if(atUsage!=null && atUsage.size()>0){
                for(Integer value=0;value<atUsage.size();value++){
                    if(value==0){
                        atUsageValue=atUsage[value];
                    }
                    else {
                        atUsageValue=atUsageValue+';'+atUsage[value];
                    }
                }
                assessment.AT_Usage__c = atUsageValue;
            }
            else if(atUsage==null){
                assessment.AT_Usage__c=''; 
            }
            
            string hearingassessmentValue='';
            if(hearingassessment!=null && hearingassessment.size()>0){
                for(Integer value=0;value<hearingassessment.size();value++){
                    if(value==0){
                        hearingassessmentValue=hearingassessment[value];
                    }
                    else {
                        hearingassessmentValue=hearingassessmentValue+';'+hearingassessment[value];
                    }
                }
                assessment.Hearing_Assessment__c = hearingassessmentValue;
            }
            else if(hearingassessment==null){
                assessment.Hearing_Assessment__c=''; 
            }
            string visualassessmentValue='';
            if(visualassessment!=null && visualassessment.size()>0){
                for(Integer value=0;value<visualassessment.size();value++){
                    if(value==0){
                        visualassessmentValue=visualassessment[value];
                    }
                    else {
                        visualassessmentValue=visualassessmentValue+';'+visualassessment[value];
                    }
                }
                assessment.Visual_Assessment__c = visualassessmentValue;
            }
            else if(visualassessment==null){
                assessment.Visual_Assessment__c=''; 
            }
            
            string tactileassessmentValue='';
            if(tactileassessment!=null && tactileassessment.size()>0){
                for(Integer value=0;value<tactileassessment.size();value++){
                    if(value==0){
                        tactileassessmentValue=tactileassessment[value];
                    }
                    else {
                        tactileassessmentValue=tactileassessmentValue+';'+tactileassessment[value];
                    }
                }
                assessment.Tactile_Assessment__c = tactileassessmentValue;
            }
            else if(tactileassessment==null){
                assessment.Tactile_Assessment__c=''; 
            }
            
            assessment.Attestation__c = attestation;
            assessment.Attestors_signature__c = attestorsignature;
            if(attestationdate != null){
                assessment.Date__c = Date.valueOf(attestationdate);
            }
            //assessment.Mailing_Address__c = mailingaddress;
            // assessment.Phone_Number__c = phone;
            assessment.License_Certificate_Number_if_applicabl__c = license;
            // assessment.Consumer__c = contactId;
            Case newCase=new Case();
            // newCase = getConsumerNameFromRequest(requestId);
            newCase = getAccountFromRequest(requestId);
            assessment.Consumer__c = newCase.ContactId;
            assessment.Request__c = requestId;
            if(newCase.External_Assessor__c!=null){
                assessment.Email_Address__c = emailaddress!=null ? emailaddress : newCase.External_Assessor__r.Email__c;
                assessment.Phone_Number__c =phone!=null ? phone : newCase.External_Assessor__r.Cell_Phone__c;
                String address= newCase.External_Assessor__r.BillingStreet + '\n' + newCase.External_Assessor__r.BillingCity + '\n' + newCase.External_Assessor__r.BillingState + '\n' + newCase.External_Assessor__r.BillingPostalCode + '\n' + newCase.External_Assessor__r.BillingCountry;
                assessment.Mailing_Address__c = mailingaddress!=null ? mailingaddress : address;
                
            }
            if(newCase.Internal_Assessor__c!=null){
                assessment.Email_Address__c = emailaddress!=null ? emailaddress : newCase.Internal_Assessor__r.Email;
                String address = newCase.Internal_Assessor__r.Street + '\n' + newCase.Internal_Assessor__r.City + '\n' + newCase.Internal_Assessor__r.State + '\n' + newCase.Internal_Assessor__r.PostalCode + '\n' + newCase.Internal_Assessor__r.Country;
                assessment.Mailing_Address__c = mailingaddress!=null ? mailingaddress : address;
                if (newCase.Internal_Assessor__r.MobilePhone !=null) {
                    assessment.Phone_Number__c = phone!=null ? phone : newCase.Internal_Assessor__r.MobilePhone;
                } else if (newCase.Internal_Assessor__r.Phone!=null) {
                    assessment.Phone_Number__c = phone!=null ? phone : newCase.Internal_Assessor__r.Phone;
                } else if (newCase.Internal_Assessor__r.Work_Phone_Number__c !=null) {
                    assessment.Phone_Number__c = phone!=null ? phone : newCase.Internal_Assessor__r.Work_Phone_Number__c;
                }
            }
            // assessment.Email_Address__c = emailaddress!=null ? emailaddress : newCase.ContactEmail;
            //assessment.Phone_Number__c = phone!=null ? phone : newCase.Contact.MobilePhone;
            // String address=newCase.Contact.MailingStreet+'\n'+newCase.Contact.MailingCity+''+newCase.Contact.MailingState+''+newCase.Contact.MailingPostalCode+'\n'+newCase.Contact.MailingCountry;
            // assessment.Mailing_Address__c = mailingaddress!=null ? mailingaddress : address;
            return assessment;
        } 
    }
    
    /*
    *********************************************************
    @Method Name    : getTodaysDate
    @description    : Retrieve todays date
    @param          : 
    @return         : 
    ********************************************************
    */
    @AuraEnabled
    public static Date getTodaysDate(){
        return System.today();
    }
    
    /*
    *********************************************************
    @Method Name    : saveData
    @description    : Save Assessment record details
    @param          : String dataObj
    @return         : Assessment__c
    ********************************************************
    */
    @AuraEnabled
    public static Assessment__c saveData(String dataObj){
        try {
            AssessmentDataWrapper assessmentWrapper = (AssessmentDataWrapper) JSON.deserialize(dataObj, AssessmentDataWrapper.class);
            Assessment__c ass = assessmentWrapper.assessmentDataHandler();
            if(String.isNotBlank(assessmentWrapper.frombutton) && assessmentWrapper.frombutton == 'fromaccept'){
                changeStatus(assessmentWrapper.requestId);
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('');
                req.setAction('Approve');        
                Id workItemId = getWorkItemId(ass.Request__c); 
                if(workItemId != null){
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                }
            }
            
            List<Assessment__c> a= [SELECT Id,Request__c FROM Assessment__c WHERE Request__c =:assessmentWrapper.requestId WITH SECURITY_ENFORCED];
            if(!a.isEmpty()){
                ass.Id=a[0].Id;
                //update ass;
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Assessment__c', new List<Assessment__c>{ass}, 'update', true,'NC_AssessmentCtrl','saveData');
                update decision.getRecords();
                
            }
            else{
                //insert ass;
                SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Assessment__c', new List<Assessment__c>{ass}, 'insert', true,'NC_AssessmentCtrl','saveData');
                insert decision.getRecords();
            }
            
            
            // SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Assessment__c',new List<Assessment__c>{ass}, 'insert', true,'NC_AssessmentCtrl','saveData');
            // insert objectDecision.getRecords();
            return ass;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }        
    }
    
    public without sharing class RequestCommentDataWrapper{
        @AuraEnabled public string requestId;
        @AuraEnabled public string comments;
        
        public Case requestCommentDataHandler() {
            Case cas = new Case();
            if(String.isNotBlank(requestId)){
                cas = [SELECT Id,Comments__c,Assessor_Comment__c FROM Case 
                       WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            }
            //cas.Comments__c=comments;
            //cas.Assessor_Comment__c=comments;
            cas.Comments__c=comments;
            return cas;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : saveCommentData
    @description    : save comment to case record and reject case record
    @param          : String dataObjComment
    @return         : Case
    ********************************************************
    */
    @AuraEnabled
    public static Case saveCommentData(String dataObjComment){
        
        try {
            RequestCommentDataWrapper wrapper = (RequestCommentDataWrapper) JSON.deserialize(dataObjComment, RequestCommentDataWrapper.class);
            Case cas = wrapper.requestCommentDataHandler();
            if(cas.Id!=null){
                //cas.Status='Denied';
                //cas.Status='Assessment Under Review';
                cas.CheckRejectAssessment__c=true;
                //update cas;
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case', new List<Case>{cas}, 'update', true,'NC_AssessmentCtrl','saveCommentData');
                update objectDecision.getRecords();
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('');
                req.setAction('Reject');        
                Id workItemId = getWorkItemId(cas.Id); 
                if(workItemId != null){
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                }
                
                // SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case',new List<Case>{cas}, 'update', true,'NC_AssessmentCtrl','saveCommentData');
                // update objectDecision.getRecords();
            }
            return cas;
        }
        catch (Exception e) {
        }
        return null;
        
    }

    /*
    *********************************************************
    @Method Name    : getWorkItemId
    @description    : Get workitem id of pending approval record
    @param          : Id targetObjectId
    @return         : Id
    ********************************************************
    */
    public static Id getWorkItemId(Id targetObjectId){
        Id workItemId = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            workItemId  =  workItem.Id;
        }
        return workItemId;
    }
    
    
    public class RequestCommentDataWrapperone{
        @AuraEnabled public string requestId;
        
        public Case requestCommentDataHandlerone() {
            Case cas = new Case();
            if(String.isNotBlank(requestId)){
                //     cas = [SELECT Id FROM Case 
                //                   WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
                cas.Id=requestId;
            }
            return cas;
            
        }
    }
    
    /*
    *********************************************************
    @Method Name    : changeStatus
    @description    : Update case record to capture assessment completed
    @param          : String requestId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void changeStatus(String requestId){
        
        try {
            Case c = new Case();
            if(String.isNotBlank(requestId)){
                c=[SELECT Id,Status,AssessmentAccepted__c FROM Case WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
                //c.Status='Pending Condition of Acceptance';
                // c.Status='Assessment Under Review';
                c.AssessmentAccepted__c=true;
                //update c; 
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case', new List<Case>{c}, 'update', true,'NC_AssessmentCtrl','changeStatus');
                update objectDecision.getRecords();
            } 
        }
        catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }
    }

    /*
    *********************************************************
    @Method Name    : fetchSignature
    @description    : Retrieve signature document id from Case record
    @param          : String requestId
    @return         : Id
    ********************************************************
    */
    @AuraEnabled
    public static Id fetchSignature(String requestId){
        Case cas=new Case();
        if(String.isNotBlank(requestId)){
            cas = [SELECT Id,Assessment_Signature_Id_on_Case__c FROM Case 
                   WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            return cas.Assessment_Signature_Id_on_Case__c;
            
        }
        return null;
        
    }
    
    /*
    *********************************************************
    @Method Name    : getStatus
    @description    : Retrieve case and current user details
    @param          : String requestId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> getStatus(String requestId){
        Map<String,Object> result = new Map<String,Object>();
        
        try {
            
            Case cas=new Case();
            User user=[SELECT Id,Profile.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
            if(requestId!=null){
                
                cas= [SELECT Id,Status FROM Case WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            }
            String status=cas.Status;
            String profile=user.Profile.Name;
            result.put('cas',status);
            result.put('user',profile);
            //System.assert(false,'map'+result);
            return result;
        }
        catch (Exception e) {
            throw new AuraHandledException('Error in get status ---> ' + e.getMessage() +e.getLineNumber());
        }
        //return null;
    }
    
    /*
    *********************************************************
    @Method Name    : fetchFields
    @description    : Retrieve Assessment details of related case
    @param          : String requestId
    @return         : AssessmentDataWrapper
    ********************************************************
    */
    @AuraEnabled
    public static AssessmentDataWrapper fetchFields(string requestId){
        AssessmentDataWrapper reqDataWrapper = new AssessmentDataWrapper();
        List<Assessment__c> ass =new  List<Assessment__c>();
        
        try{
            
            if(requestId!=null){
                ass=[SELECT Hearing_Loss__c, Vision_Loss__c,Request__c,Other__c,Assessment_Signature_Id__c,Assessment_Signature_Id_from_Case__c,Request__r.Assessment_Signature_Id_on_Case__c,
                     Communication_Skills__c,Connectivity__c,AT_Usage__c,Computer_usage_experience__c,Hearing_Assessment__c,
                     Visual_Assessment__c,Tactile_Assessment__c,Level_of_Computer_Experience__c,
                     Narrative__c,Consumer_Goals__c,Attestation__c,Attestors_signature__c,Date__c,Mailing_Address__c,Phone_Number__c,License_Certificate_Number_if_applicabl__c  FROM Assessment__c WHERE Request__c =:requestId WITH SECURITY_ENFORCED LiMIT 1];
                Case cas=[SELECT Id,Assessment_Signature_Id_on_Case__c,Internal_Assessor__c,External_Assessor__r.Is_Vendor_on_Portal__c FROM Case WHERE Id =:requestId WITH SECURITY_ENFORCED];
                reqDataWrapper.signed = cas.Assessment_Signature_Id_on_Case__c!=null ? cas.Assessment_Signature_Id_on_Case__c :'';
                if(cas.External_Assessor__c!=null){
                    reqDataWrapper.onlineAssessor=cas.External_Assessor__r.Is_Vendor_on_Portal__c!=null ? cas.External_Assessor__r.Is_Vendor_on_Portal__c : false;
                }
                if(cas.Internal_Assessor__c!=null){
                    reqDataWrapper.internalAssessor=cas.Internal_Assessor__c!=null ? true : false;
                }
                if(ass.size()>0){
                    reqDataWrapper.hearing = ass[0].Hearing_Loss__c!=null ? ass[0].Hearing_Loss__c :'';
                    reqDataWrapper.visionloss = ass[0].Vision_Loss__c!=null ? ass[0].Vision_Loss__c : '';
                    
                    if(ass[0].Other__c!=null){
                        reqDataWrapper.other=ass[0].Other__c.split(';');
                    }
                    else if(ass[0].Other__c==null){
                        reqDataWrapper.other=new List<String>();
                    }
                    
                    if(ass[0].Communication_Skills__c!=null){
                        reqDataWrapper.communicationskills=ass[0].Communication_Skills__c.split(';');
                    }
                    else if(ass[0].Communication_Skills__c==null){
                        reqDataWrapper.communicationskills=new List<String>();
                    }
                    
                    if(ass[0].Connectivity__c!=null){
                        reqDataWrapper.connectivity=ass[0].Connectivity__c.split(';');
                    }
                    else if(ass[0].Connectivity__c==null){
                        reqDataWrapper.connectivity=new List<String>();
                    }
                    
                    if(ass[0].AT_Usage__c!=null){
                        reqDataWrapper.atUsage=ass[0].AT_Usage__c.split(';');
                    }
                    else if(ass[0].AT_Usage__c==null){
                        reqDataWrapper.atUsage=new List<String>();
                    }
                    if(ass[0].Computer_usage_experience__c!=null){
                        reqDataWrapper.computerusageexperience=ass[0].Computer_usage_experience__c.split(';');
                    }
                    else if(ass[0].Computer_usage_experience__c==null){
                        reqDataWrapper.computerusageexperience=new List<String>();
                    }
                    
                    if(ass[0].Hearing_Assessment__c!=null){
                        reqDataWrapper.hearingassessment=ass[0].Hearing_Assessment__c.split(';');
                    }
                    else if(ass[0].Hearing_Assessment__c==null){
                        reqDataWrapper.hearingassessment=new List<String>();
                    }
                    if(ass[0].Visual_Assessment__c!=null){
                        reqDataWrapper.visualassessment=ass[0].Visual_Assessment__c.split(';');
                    }
                    else if(ass[0].Visual_Assessment__c==null){
                        reqDataWrapper.visualassessment=new List<String>();
                    }
                    if(ass[0].Tactile_Assessment__c!=null){
                        reqDataWrapper.tactileassessment=ass[0].Tactile_Assessment__c.split(';');
                    }
                    else if(ass[0].Tactile_Assessment__c==null){
                        reqDataWrapper.tactileassessment=new List<String>();
                    }
                    if(ass[0].Level_of_Computer_Experience__c!=null){
                        reqDataWrapper.levelofcomputerexperience=ass[0].Level_of_Computer_Experience__c.split(';');
                    }
                    else if(ass[0].Level_of_Computer_Experience__c==null){
                        reqDataWrapper.levelofcomputerexperience=new List<String>();
                    }
                    
                    
                    reqDataWrapper.narrative =ass[0].Narrative__c!=null ? ass[0].Narrative__c:'';
                    reqDataWrapper.consumergoals =ass[0].Consumer_Goals__c!=null ? ass[0].Consumer_Goals__c:'';
                    reqDataWrapper.attestation =ass[0].Attestation__c!=null ? ass[0].Attestation__c:'';
                    reqDataWrapper.attestorsignature =ass[0].Attestors_signature__c!=null ? ass[0].Attestors_signature__c:'';
                    reqDataWrapper.attestationdate = ass[0].Date__c!=null ? String.valueOf(ass[0].Date__c) : null;
                    reqDataWrapper.mailingaddress = ass[0].Mailing_Address__c!=null ? ass[0].Mailing_Address__c : null;
                    reqDataWrapper.phone = ass[0].Phone_Number__c!=null ? ass[0].Phone_Number__c : null;
                    reqDataWrapper.license = ass[0].License_Certificate_Number_if_applicabl__c!=null ? ass[0].License_Certificate_Number_if_applicabl__c : null;
                }
            }
            
        }
        catch (Exception e) {
        }
        return reqDataWrapper;
    }
    // @AuraEnabled
    // public static AssessmentDataWrapper fetchFields(string requestId){
    //     AssessmentDataWrapper reqDataWrapper = new AssessmentDataWrapper();
    
    //     try{
    
    //     if(requestId!=null){
    //     Assessment__c ass=[SELECT Hearing_Loss__c, Vision_Loss__c,Request__c,Other__c,
    //     Communication_Skills__c,Connectivity__c,AT_Usage__c,Computer_usage_experience__c,Hearing_Assessment__c,
    //     Visual_Assessment__c,Tactile_Assessment__c,Level_of_Computer_Experience__c,
    //     Narrative__c,Consumer_Goals__c,Attestation__c,Attestors_signature__c,Date__c,Mailing_Address__c,Phone_Number__c,License_Certificate_Number_if_applicabl__c  FROM Assessment__c WHERE Request__c =:requestId LIMIT 1];
    
    //     reqDataWrapper.hearing = ass.Hearing_Loss__c!=null ? ass.Hearing_Loss__c :'';
    //     reqDataWrapper.visionloss = ass.Vision_Loss__c!=null ? ass.Vision_Loss__c : '';
    
    //     if(ass.Other__c!=null){
    //         reqDataWrapper.other=ass.Other__c.split(';');
    //     }
    //     else if(ass.Other__c==null){
    //         reqDataWrapper.other=new List<String>();
    //     }
    
    //     if(ass.Communication_Skills__c!=null){
    //         reqDataWrapper.communicationskills=ass.Communication_Skills__c.split(';');
    //     }
    //     else if(ass.Communication_Skills__c==null){
    //         reqDataWrapper.communicationskills=new List<String>();
    //     }
    
    //     if(ass.Connectivity__c!=null){
    //         reqDataWrapper.connectivity=ass.Connectivity__c.split(';');
    //     }
    //     else if(ass.Connectivity__c==null){
    //         reqDataWrapper.connectivity=new List<String>();
    //     }
    
    //     if(ass.AT_Usage__c!=null){
    //         reqDataWrapper.atUsage=ass.AT_Usage__c.split(';');
    //     }
    //     else if(ass.AT_Usage__c==null){
    //         reqDataWrapper.atUsage=new List<String>();
    //     }
    //     if(ass.Computer_usage_experience__c!=null){
    //         reqDataWrapper.computerusageexperience=ass.Computer_usage_experience__c.split(';');
    //     }
    //     else if(ass.Computer_usage_experience__c==null){
    //         reqDataWrapper.computerusageexperience=new List<String>();
    //     }
    
    //     if(ass.Hearing_Assessment__c!=null){
    //         reqDataWrapper.hearingassessment=ass.Hearing_Assessment__c.split(';');
    //     }
    //     else if(ass.Hearing_Assessment__c==null){
    //         reqDataWrapper.hearingassessment=new List<String>();
    //     }
    //     if(ass.Visual_Assessment__c!=null){
    //         reqDataWrapper.visualassessment=ass.Visual_Assessment__c.split(';');
    //     }
    //     else if(ass.Visual_Assessment__c==null){
    //         reqDataWrapper.visualassessment=new List<String>();
    //     }
    //     if(ass.Tactile_Assessment__c!=null){
    //         reqDataWrapper.tactileassessment=ass.Tactile_Assessment__c.split(';');
    //     }
    //     else if(ass.Tactile_Assessment__c==null){
    //         reqDataWrapper.tactileassessment=new List<String>();
    //     }
    //     if(ass.Level_of_Computer_Experience__c!=null){
    //         reqDataWrapper.levelofcomputerexperience=ass.Level_of_Computer_Experience__c.split(';');
    //     }
    //     else if(ass.Level_of_Computer_Experience__c==null){
    //         reqDataWrapper.levelofcomputerexperience=new List<String>();
    //     }
    
    
    //     reqDataWrapper.narrative =ass.Narrative__c!=null ? ass.Narrative__c:'';
    //     reqDataWrapper.consumergoals =ass.Consumer_Goals__c!=null ? ass.Consumer_Goals__c:'';
    //     reqDataWrapper.attestation =ass.Attestation__c!=null ? ass.Attestation__c:'';
    //     reqDataWrapper.attestorsignature =ass.Attestors_signature__c!=null ? ass.Attestors_signature__c:'';
    //     reqDataWrapper.attestationdate = ass.Date__c!=null ? String.valueOf(ass.Date__c) : null;
    //     reqDataWrapper.mailingaddress = ass.Mailing_Address__c!=null ? ass.Mailing_Address__c : null;
    //     reqDataWrapper.phone = ass.Phone_Number__c!=null ? ass.Phone_Number__c : null;
    //     reqDataWrapper.license = ass.License_Certificate_Number_if_applicabl__c!=null ? ass.License_Certificate_Number_if_applicabl__c : null;
    // }
    
    // }
    //     catch (Exception e) {
    //   }
    //     return reqDataWrapper;
    // }
    
}