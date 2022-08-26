/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_ApplicantSignature {
    public without sharing class RequestSignatureDataWrapper{
        @AuraEnabled public string requestId;
        @AuraEnabled public string applicantsSignature;
        @AuraEnabled public string attestationdate;
        @AuraEnabled public string personCompletingInformation;
        @AuraEnabled public string relationship;
        @AuraEnabled public string phoneNumber;
        @AuraEnabled public string alternatecontact;
        @AuraEnabled public string relationshipofalternatecontact;
        @AuraEnabled public string phoneNumberofalternatecontact;
        @AuraEnabled public string emailaddress;
        @AuraEnabled public string signed;
        @AuraEnabled public Boolean onlineAssessor;
        @AuraEnabled public Boolean internalAssessor;
        @AuraEnabled public string frombutton;
    
        public Case requestSignatureDataHandler() {
            Case cas = new Case();
            if(requestId!=null){
               cas.Id = requestId;
            }
        cas.Signature_of_Applicant__c=applicantsSignature;
        Case c = [SELECT Id,Contact.Name FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
        cas.Name_of_Applicant__c = c.Contact.Name;
        if(attestationdate != null){
            cas.Date_on_Applicants_Signature__c = Date.valueOf(attestationdate);
        }
        cas.Person_completing_Information_if_other__c=personCompletingInformation;
        cas.Relationship__c=relationship;
        cas.Phone_Number__c=phoneNumber;
        cas.Alternate_contact_for_applicant__c=alternatecontact;
        cas.Relationship_of_Alternate_Contact__c=relationshipofalternatecontact;
        cas.Phone_Number_of_Alternate_Contact__c=phoneNumberofalternatecontact;
        cas.Email_address__c=emailaddress;
        return cas;
          
    }
}

    /*
    *********************************************************
    @Method Name    : getEquipmentDetails
    @description    : Get all equipments available in case/request
    @param          : Id requestId
    @return         : Boolean
    ********************************************************
    */
@AuraEnabled
public static Boolean getEquipmentDetails(Id requestId){
    Boolean res;
    Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
    for(Case caseObj:[SELECT Id,RecordTypeId,(SELECT Id FROM Requests_Equipment__r) FROM Case WHERE Id=:requestId]){ //WITH SECURITY_ENFORCED
        if(caseObj.RecordTypeId == ndbedpRecordTypeId && caseObj.Requests_Equipment__r.size()==0){
            res=false;
        }
        else if(caseObj.RecordTypeId == ndbedpRecordTypeId && caseObj.Requests_Equipment__r.size()>0){
            res=true;
        }  
    }
    return res;
}

    /*
    *********************************************************
    @Method Name    : saveData
    @description    : Save Case details and submit case record for approval
    @param          : String dataObj
    @return         : String
    ********************************************************
    */
@AuraEnabled
public static string saveData(String dataObj){
    string result;
    try {
        RequestSignatureDataWrapper wrapper = (RequestSignatureDataWrapper) JSON.deserialize(dataObj, RequestSignatureDataWrapper.class);
        Case cas = wrapper.requestSignatureDataHandler();
        //system.assert(false,'case data'+cas);
        if(cas.Id!=null){
            //cas.Status='Pending Condition of Acceptance';
            cas.ApplicantSignatureAccepted__c=true;
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case',new List<Case>{cas}, 'update', true,'NC_ApplicantSignature','saveData');
            update objectDecision.getRecords();
            result='true';
           
            //return result;
            if(String.isNotBlank(wrapper.frombutton) && wrapper.frombutton == 'fromaccept'){

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('');
                req.setAction('Approve');        
                Id workItemId = getWorkItemId(cas.Id); 
                if(workItemId != null){
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result1 =  Approval.process(req);
                }
            }   
       }    
    }
    catch (Exception e) {
       
          throw new AuraHandledException('Error while activate account ---> ' + e.getMessage());
    }
   
    return result;
}

    /*
    *********************************************************
    @Method Name    : getAccountFromRequest
    @description    : Get Internal or External assessor details of case
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
        cas = [SELECT Id,ContactId,External_Assessor__c,Internal_Assessor__c,Case.External_Assessor__r.Email__c,Case.External_Assessor__r.BillingCity , Case.External_Assessor__r.BillingStreet ,
        Case.External_Assessor__r.BillingState , Case.External_Assessor__r.BillingPostalCode , Case.External_Assessor__r.BillingCountry, Case.External_Assessor__r.Cell_Phone__c,Case.External_Assessor__r.Is_Vendor_on_Portal__c FROM Case  
        WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
          return cas;
        }
        else if(cas.Internal_Assessor__c!=null){
            cas = [SELECT Id,External_Assessor__c,Internal_Assessor__c,ContactId,Case.Internal_Assessor__r.Email,Case.Internal_Assessor__r.MobilePhone,Case.Internal_Assessor__r.Phone,Case.Internal_Assessor__r.Work_Phone_Number__c,
            Case.Internal_Assessor__r.City,Case.Internal_Assessor__r.Street,Case.Internal_Assessor__r.State,Case.Internal_Assessor__r.PostalCode,Case.Internal_Assessor__r.Country 
            FROM Case WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            return cas;
        }
    }
    return null;
}
public class RequestCommentDataWrapper{
    @AuraEnabled public string requestId;
    @AuraEnabled public string comments;

    public Case requestCommentDataHandler() {
        Case cas = new Case();
        if(requestId!=null){
           cas.Id = requestId;
        }
        cas.Comments__c=comments;
        return cas;
}
}

    /*
    *********************************************************
    @Method Name    : saveCommentData
    @description    : Save case details and submit case record for approval
    @param          : String dataObjComment
    @return         : void
    ********************************************************
    */
@AuraEnabled
    public static void saveCommentData(String dataObjComment){
       
        try {
            // RequestSignatureDataWrapper wrapper = (RequestSignatureDataWrapper) JSON.deserialize(dataObjComment, RequestSignatureDataWrapper.class);
            RequestCommentDataWrapper wrapper = (RequestCommentDataWrapper) JSON.deserialize(dataObjComment, RequestCommentDataWrapper.class);
            //Case cas = wrapper.requestSignatureDataHandler();
            Case cas = wrapper.requestCommentDataHandler();
            if(cas.Id!=null){
                cas.ApplicantSignatureRejected__c=true;
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case',new List<Case>{cas}, 'update', true,'NC_ApplicantSignature','saveCommentData');
                update objectDecision.getRecords();
                //update cas;
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('');
                req.setAction('Reject');        
                Id workItemId = getWorkItemId(cas.Id); 
                if(workItemId != null){
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                }


                //cas.Status='Denied';
                //cas.CheckRejectAssessment__c=true;
                //update cas;
                // SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case',new List<Case>{cas}, 'update', true,'NC_NDBEDPConditionofAcceptanceCtrl','saveCommentData');
                // update objectDecision.getRecords();
            }
           
        }
        catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }
     
    }

    /*
    *********************************************************
    @Method Name    : getWorkItemId
    @description    : Get workitem id for pending approval record
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

    /*
    *********************************************************
    @Method Name    : getConsumerNameFromRequest
    @description    : Get conumer name from case
    @param          : String requestId
    @return         : Case
    ********************************************************
    */
@AuraEnabled
    public static Case getConsumerNameFromRequest(String requestId){
        String contactId = '';
        Case cas = new Case();
        if(String.isNotBlank(requestId)){
            cas = [SELECT Id,Contact.Name FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
                         // system.assert(false,'contact name'+cas.Contact.Name);
            return cas;
           
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : getTodaysDate
    @description    : Return today's date
    @param          : 
    @return         : Date
    ********************************************************
    */
    @AuraEnabled
    public static Date getTodaysDate(){
            return System.today();
    }

    /*
    *********************************************************
    @Method Name    : fetchSignature
    @description    : Retrieve signature id by providing record id
    @param          : String requestId
    @return         : Id
    ********************************************************
    */
    @AuraEnabled
    public static Id fetchSignature(String requestId){
       Case cas=new Case();
        if(String.isNotBlank(requestId)){
            cas = [SELECT Id,Applicants_Signature_Id__c FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            return cas.Applicants_Signature_Id__c;
           
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
            
         cas= [SELECT Id,Status FROM Case WHERE Id=:requestId LIMIT 1];
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
    @description    : Retrieve signature related details from case
    @param          : String requestId
    @return         : RequestSignatureDataWrapper
    ********************************************************
    */
    @AuraEnabled
    public static RequestSignatureDataWrapper fetchFields(string requestId){
        RequestSignatureDataWrapper reqDataWrapper = new RequestSignatureDataWrapper();

        try{

        if(requestId!=null){
        Case cas=[SELECT Id,Applicants_Signature_Id__c,Signature_of_Applicant__c,Date_on_Applicants_Signature__c,Signature_ID__c,Email_address__c,Person_completing_Information_if_other__c,
        Relationship__c,Phone_Number__c,Alternate_contact_for_applicant__c,Relationship_of_Alternate_Contact__c,Consumer_Signature_Formula__c,
        Phone_Number_of_Alternate_Contact__c,External_Assessor__r.Is_Vendor_on_Portal__c,Internal_Assessor__c FROM Case WHERE Id =:requestId WITH SECURITY_ENFORCED];
        //reqDataWrapper.applicantsName = cas.Applicants_Name__c!=null ? cas.Applicants_Name__c :'';
        reqDataWrapper.applicantsSignature = cas.Signature_of_Applicant__c!=null ? cas.Signature_of_Applicant__c :'';
        reqDataWrapper.attestationdate = cas.Date_on_Applicants_Signature__c!=null ? String.valueOf(cas.Date_on_Applicants_Signature__c) : null;
        reqDataWrapper.personCompletingInformation = cas.Person_completing_Information_if_other__c!=null ? cas.Person_completing_Information_if_other__c :'';
        reqDataWrapper.relationship = cas.Relationship__c!=null ? cas.Relationship__c :'';
        reqDataWrapper.phoneNumber = cas.Phone_Number__c!=null ? cas.Phone_Number__c :null ;
        reqDataWrapper.alternatecontact = cas.Alternate_contact_for_applicant__c!=null ? cas.Alternate_contact_for_applicant__c :'';
        reqDataWrapper.relationshipofalternatecontact = cas.Relationship_of_Alternate_Contact__c!=null ? cas.Relationship_of_Alternate_Contact__c :'';
        reqDataWrapper.phoneNumberofalternatecontact = cas.Phone_Number_of_Alternate_Contact__c!=null ? cas.Phone_Number_of_Alternate_Contact__c :'';
        reqDataWrapper.emailaddress = cas.Email_address__c!=null ? cas.Email_address__c :'';
        reqDataWrapper.signed = cas.Applicants_Signature_Id__c!=null ? cas.Applicants_Signature_Id__c :'';
        if(cas.External_Assessor__c!=null){
            reqDataWrapper.onlineAssessor=cas.External_Assessor__r.Is_Vendor_on_Portal__c!=null ? cas.External_Assessor__r.Is_Vendor_on_Portal__c : false;
        }
        if(cas.Internal_Assessor__c!=null){
            reqDataWrapper.internalAssessor=cas.Internal_Assessor__c!=null ? true : false;
        }

        }
    }
        catch (Exception e) {
      }
        return reqDataWrapper;
    }


}