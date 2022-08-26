/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-29-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   07-08-2021   kavya.konagonda@mtxb2b.com   Initial Version
**/
public without sharing class NC_NDBEDPConditionofAcceptanceCtrl {
    public without sharing class RequestDataWrapper{
        //@AuraEnabled public string applicantsName;
        @AuraEnabled public string applicantsSignature;
        @AuraEnabled public string attestationdate;
        @AuraEnabled public string personCompletingInformation;
        @AuraEnabled public string relationship;
        @AuraEnabled public string phoneNumber;
        @AuraEnabled public string alternatecontact;
        @AuraEnabled public string relationshipofalternatecontact;
        @AuraEnabled public string phoneNumberofalternatecontact;
        @AuraEnabled public string requestId;
        @AuraEnabled public string signed;
        @AuraEnabled public Boolean onlineAssessor;
        @AuraEnabled public string frombutton;
        @AuraEnabled public Boolean internalAssessor;

        //@AuraEnabled public string consumername;
    
    public Case requestDataHandler() {
        //Id rtIDNDBEDP = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDBEDP').getRecordTypeId();
        Case cas = new Case();
        //cas.RecordTypeId=rtIDNDBEDP;
        if(requestId!=null){
           cas.Id = requestId;
        
        }
        Case c = [SELECT Id,Contact.Name FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
        cas.Applicants_Name__c = c.Contact.Name;
        cas.Applicants_Signature__c=applicantsSignature;
        if(attestationdate != null){
            cas.Date__c = Date.valueOf(attestationdate);
        }
        cas.Person_completing_Information_if_other__c=personCompletingInformation;
        cas.Relationship__c=relationship;
        cas.Phone_Number__c=phoneNumber;
        cas.Alternate_contact_for_applicant__c=alternatecontact;
        cas.Relationship_of_Alternate_Contact__c=relationshipofalternatecontact;
        cas.Phone_Number_of_Alternate_Contact__c=phoneNumberofalternatecontact;
        return cas;
    }
  }

    /*
    *********************************************************
    @Method Name    : rejectRecords
    @description    : Reject pending approval record in future
    @param          : Set<Id> idSet
    @return         : void
    ********************************************************
    */
  @future
  public static void rejectRecords(Set<Id> idSet){
     
      for(Id idValue:idSet){
          Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
          req.setComments('');
          req.setAction('Reject');        
          Id workItemId = getWorkItemId(idValue); 
          if(workItemId != null){
              req.setWorkitemId(workItemId);
              Approval.ProcessResult result =  Approval.process(req);
          }
      }
          
      
  }

    /*
    *********************************************************
    @Method Name    : saveData
    @description    : save case data
    @param          : String dataObj
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static string saveData(String dataObj){
        string result;
        try {
            RequestDataWrapper requestWrapper = (RequestDataWrapper) JSON.deserialize(dataObj, RequestDataWrapper.class);
            Case cas = requestWrapper.requestDataHandler();
            if(cas.Id!=null){
                //cas.Status='Pending TRP Manager';
                //update cas;
                cas.CheckRejectAssessment__c=true;
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case',new List<Case>{cas}, 'update', true,'NC_NDBEDPConditionofAcceptanceCtrl','saveData');
                update objectDecision.getRecords();
                result='true';
                if(String.isNotBlank(requestWrapper.frombutton) && requestWrapper.frombutton == 'fromaccept'){

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
            
        }
       return result;
    }

    /*
    *********************************************************
    @Method Name    : fetchSignature
    @description    : Retrieve signature id from case record
    @param          : String requestId
    @return         : Id
    ********************************************************
    */
    @AuraEnabled
    public static Id fetchSignature(String requestId){
       Case cas=new Case();
        if(String.isNotBlank(requestId)){
            cas = [SELECT Id,Condition_of_Acceptance_sign_Id__c FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            return cas.Condition_of_Acceptance_sign_Id__c;
           
        }
        return null;
        
    }

    /*
    *********************************************************
    @Method Name    : getEquipmentDetails
    @description    : Get all NDBEDP equipments added to cart
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
    @Method Name    : getConsumerNameFromRequest
    @description    : Get case details
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
            return cas;
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : getAccountFromRequest
    @description    : Get account details from case
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

    /*
    *********************************************************
    @Method Name    : getTodaysDate
    @description    : Get today's date
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
    @Method Name    : getStatus
    @description    : Retrieve case status by id
    @param          : String requestId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static String getStatus(String requestId){
       
        try {
            return [SELECT Id,Status FROM Case WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1].Status;
        }
        catch (Exception e) {
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : getAcceptedValuefromRequest
    @description    : Retrieve case assessment status by id
    @param          : String requestId
    @return         : String
    ********************************************************
    */
    @AuraEnabled
    public static Case getAcceptedValuefromRequest(String requestId){
        Case cas = new Case();
        if(String.isNotBlank(requestId)){
            cas = [SELECT Id,CheckRejectAssessment__c FROM Case 
                          WHERE Id=:requestId WITH SECURITY_ENFORCED LIMIT 1];
            return cas;
        }
        return null;
    }

    /*
    *********************************************************
    @Method Name    : fetchFields
    @description    : Fetch input fields data for condition of acceptance
    @param          : String requestId
    @return         : RequestDataWrapper
    ********************************************************
    */
    @AuraEnabled
    public static RequestDataWrapper fetchFields(string requestId){
        RequestDataWrapper reqDataWrapper = new RequestDataWrapper();

        try{

        if(requestId!=null){
        Case cas=[SELECT Id,Applicants_Name__c,Condition_of_Acceptance_sign_Id__c,Applicants_Signature__c,Date__c,Person_completing_Information_if_other__c,
        Relationship__c,Phone_Number__c,Alternate_contact_for_applicant__c,Relationship_of_Alternate_Contact__c,
        Phone_Number_of_Alternate_Contact__c,External_Assessor__r.Is_Vendor_on_Portal__c,Internal_Assessor__c FROM Case WHERE Id =:requestId WITH SECURITY_ENFORCED];
        //reqDataWrapper.applicantsName = cas.Applicants_Name__c!=null ? cas.Applicants_Name__c :'';
        reqDataWrapper.applicantsSignature = cas.Applicants_Signature__c!=null ? cas.Applicants_Signature__c :'';
        reqDataWrapper.attestationdate = cas.Date__c!=null ? String.valueOf(cas.Date__c) : null;
        reqDataWrapper.personCompletingInformation = cas.Person_completing_Information_if_other__c!=null ? cas.Person_completing_Information_if_other__c :'';
        reqDataWrapper.relationship = cas.Relationship__c!=null ? cas.Relationship__c :'';
        reqDataWrapper.phoneNumber = cas.Phone_Number__c!=null ? cas.Phone_Number__c :null ;
        reqDataWrapper.alternatecontact = cas.Alternate_contact_for_applicant__c!=null ? cas.Alternate_contact_for_applicant__c :'';
        reqDataWrapper.relationshipofalternatecontact = cas.Relationship_of_Alternate_Contact__c!=null ? cas.Relationship_of_Alternate_Contact__c :'';
        reqDataWrapper.phoneNumberofalternatecontact = cas.Phone_Number_of_Alternate_Contact__c!=null ? cas.Phone_Number_of_Alternate_Contact__c :'';
        reqDataWrapper.signed = cas.Condition_of_Acceptance_sign_Id__c!=null ? cas.Condition_of_Acceptance_sign_Id__c :'';
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
    @description    : save comment to case and reject case record
    @param          : String dataObjComment
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void saveCommentData(String dataObjComment){
       
        try {
            RequestCommentDataWrapper wrapper = (RequestCommentDataWrapper) JSON.deserialize(dataObjComment, RequestCommentDataWrapper.class);
           Case cas = wrapper.requestCommentDataHandler();
            if(cas.Id!=null){
               // cas.Status='Pending TRP Manager';
                cas.CheckRejectAssessment__c=true;

                //update cas;
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case',new List<Case>{cas}, 'update', true,'NC_NDBEDPConditionofAcceptanceCtrl','saveCommentData');
                update objectDecision.getRecords();
                //rejectRecords(new Set<Id>{cas.Id});
                //update cas;
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('');
                req.setAction('Reject');        
                Id workItemId = getWorkItemId(cas.Id); 
                if(workItemId != null){
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                }
            }
           
        }
        catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
                }
     
    }

    /*
    *********************************************************
    @Method Name    : getWorkItemId
    @description    : get workitem id from pending approval record
    @param          : Id targetObjectId
    @return         : Id
    ********************************************************
    */
    Public static Id getWorkItemId(Id targetObjectId){
        Id workItemId = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            workItemId  =  workItem.Id;
        }
        return workItemId;
    }

    /*
    *********************************************************
    @Method Name    : requestEquipmentsforRequest
    @description    : get all requested equipments
    @param          : Id requestId
    @return         : List<RequestEquipments>
    ********************************************************
    */
    @AuraEnabled
    public static List<RequestEquipments> requestEquipmentsforRequest(Id requestId){
        List<RequestEquipments> reqEquipList=new List<RequestEquipments>();
        for(Request_Equipment__c reqEquip : [SELECT Id,Equipment_Name__c,Equipment_Amount_Authorized__c,Quantity__c FROM Request_Equipment__c WHERE Request__c=:requestId WITH SECURITY_ENFORCED]){
            RequestEquipments requestEquipmentsWrapper=new RequestEquipments(reqEquip);
            reqEquipList.add(requestEquipmentsWrapper);
        }
        
        return reqEquipList;
    }
    public class RequestEquipments{
        @AuraEnabled public String equipmentName;
        @AuraEnabled public Double equipmentAmountAuthorized;
        @AuraEnabled public String quantity;
        @AuraEnabled public Id id;
      public requestEquipments(Request_Equipment__c reqEquipment){
         this.equipmentName=reqEquipment.Equipment_Name__c;
         this.equipmentAmountAuthorized=reqEquipment.Equipment_Amount_Authorized__c;
         this.quantity=reqEquipment.Quantity__c;
         this.id=reqEquipment.Id;
      }
    
    }
    
}