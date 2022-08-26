/*
**   Class Name: NC_CaseTriggerHandler
**   Description: Trigger on Request
**
**     Date            New/Modified           User                 Identifier               Description
**   04-22-2020             New          Hiten Aggarwal(mtx)
**   05-05-2020			Modified		 Shubham Dadhich(mtx)								Added Method To Create Asset on Case Aproval
**   05-06-2020	 		Modified		 Shubham Dadhich(mtx)								CreateAsset Method Updated
**   05-07-2020	 		Modified		 Shubham Dadhich(mtx)								CreateAsset Method Updated -- Authorization Added to Asset
**   05-26-2020	 		Modified		 Shubham Dadhich(mtx)								Denied Email Notification to Consumer
*/

public without Sharing class NC_CaseTriggerHandler {
    
    public static Id AuthorizationWeatherRadioRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_WEATHER_RADIO);
    public static Id AuthorizationHearingAidRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_HEARING_AID);
    public static Id AuthorizationCAPTELRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_CAPTEL);
    public static Id AuthorizationOtherRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_EDS_INVOICE);
    public static Id AuthorizationSubHearingAidRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_SUB_HEARING_AID);
    public static Id AuthorizationNoCostRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c',NC_Constant.AUTHORIZATION_NO_COSt_RECORDTYPE);
    public static Id AuthorizationEquipmentRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c',NC_Constant.AUTHORIZATION_EQUIPMENT_RECORDTYPE);
    public static Id AuthorizationAssessorRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c',NC_Constant.AUTHORIZATION_RECORDTYPE_ASSESSOR);
    public static Id AuthorizationAssessorTrainingInstRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','Assessor_Training_Installation');
    public static Id AuthorizationNDBEDPFollowUpRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','NDBEDP_Follow_Up');
    public static Id AuthorizationNDBEDPAdditionalTrainingRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','NDBEDP_Additional_Training');
    public static Id AuthorizationPickupRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','NDBEDP_Pick_up');
    public static Id AuthorizationDeliveyRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','NDBEDP_Delivey');
    private static List<EmailTemplate> emailTemplateNDBEDPEquipmentInvitation =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Equipment_Request_Assessor_Invitation_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPFollowUpInvitation =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Follow_Up_Request_Assessor_Invitation_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPAdditionalTrainingInvitation =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Additional_Training_Trainer_Invitation_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPRepairRequestInvitation =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Repair_Request_Assessor_Invitation_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPEquipmentInvitationAccept =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Equipment_Request_Invitation_Accepted_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPEquipmentInvitationReject =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Equipment_Request_Invitation_Rejected_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPFollowUpInvitationAccept =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Follow_Up_Request_Invitation_Accepted_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPFollowUpInvitationReject =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Follow_Up_Request_Invitation_Rejected_1' ];
    public static List<EmailTemplate> emailTemplateNDBEDPAdditionalTrainingInvitationAccept =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Additional_Training_Invitation_Accepted_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPAdditionalTrainingInvitationReject =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Additional_Training_Invitation_Rejected_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPRepairRequestInvitationAccept =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Repair_Request_Invitation_Accepted_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPRepairRequestInvitationReject =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Repair_Request_Invitation_Rejected_1' ];
    private static List<EmailTemplate> emailTemplateNDBEDPAssessorConfirmation =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Assessor_Confirmation'];
    private static List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
    
    
    
    public static Id ndbedpRequestId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP');
    public static Id ndbedpAdditionalPartRequestId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP_Additional_Parts');
    public static Id ndbedpRepairrequestId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP_Repair_Request');
    public static Id ndbedpDemoTypeId = NC_Utility.RecordTypeUtilityMethod('Case', 'NDBEDP_Demo');
    public static Id ndbedpReqEqpId = NC_Utility.RecordTypeUtilityMethod('Request_Equipment__c', 'NDBEDP');
    
    /*
*********************************************************
@Method Name    : afterInsert
@description    : calling this method on 'after Insert' trigger event
@param          : List<case> newList
@return         : void
********************************************************
*/
    public static void afterInsert(List<case> newList){
        restrictTheAssesserAtCreation(newList, NULL);
        updateNDBEDPRepairRequest(newList);
        submitNDBEDPRepairRequestForApproval(newList);
        checkNDBEDPServiceRequest(newList);
        updateServiceRequestOwner(newList);
        shareRequestWithRCUsers(newList);
    }
    
    /*
*********************************************************
@Method Name    : beforeInsert
@description    : calling this method on 'before Insert' trigger event
@param          : List<case> newList
@return         : void
********************************************************
*/
    public static void beforeInsert(List<case> newList){
        populateRegionalCenter(newList, NULL);
        //  checkNDBEDPServiceRequest(newList,Null);
        // restrictTheAssesserAtCreation(newList, NULL);
    }
    
    /*
*********************************************************
@Method Name    : beforeUpdate
@description    : calling this method on 'before update' trigger event
@param          : List<case> newList,Map<Id,case> oldMap
@return         : void
********************************************************
*/
    public static void beforeUpdate(List<case> newList,Map<Id,case> oldMap){
        Id rtIDNDBEDP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        
        for(Case caseObj : newList) {
            if (UserInfo.getUserId() != Label.Integration_User) {
                if(caseObj.MatRequestObj__c!=null && (caseObj.MatReqStatus__c=='Pending' || caseObj.MatReqStatus__c=='Closed')){
                    //caseObj.addError('You are not allowed to update status as pending/closed.');
                }
                if (caseObj.RecordTypeId == rtIDNDBEDP && caseObj.MatRequestObj__c!=null && (caseObj.MatReqStatus__c=='Cancel' && oldMap.get(caseObj.Id).MatReqStatus__c!='Pending' )) {
                    //caseObj.addError('Request update not allowed.');
                }
                if (caseObj.RecordTypeId == rtIDNDBEDP && caseObj.MatRequestObj__c!=null &&((oldMap.get(caseObj.Id).MatReqStatus__c=='Cancel') || (oldMap.get(caseObj.Id).MatReqStatus__c=='Closed') || (oldMap.get(caseObj.Id).MatReqStatus__c=='Complete') || (oldMap.get(caseObj.Id).MatReqStatus__c=='Deny') || (oldMap.get(caseObj.Id).MatReqStatus__c=='Invoiced'))) {
                    //caseObj.addError('Request update not allowed.');
                }
                if(caseObj.RecordTypeId == rtIDNDBEDP && caseObj.Status=='Approved'){
                    //                    List<String> equipmentNames = NC_NDBEDPEquipmentCatalog.validateEquipment(caseObj.Id);
                    //                    if (equipmentNames.size()>0) {
                    //                        trigger.newmap.get(caseObj.Id).addError('InActive equipment found.');
                    //                        String allString = string.join(equipmentNames,',');
                    //                        trigger.newmap.get(caseObj.Id).addError(allString);
                    //                    }
                }
            }
            
        }
        serviceRequestOwnerValidation(newList,oldMap);
        validateEDSRquestStatus(newList,oldMap);
        validateNDBEDPDemoRquestStatus(newList,oldMap);
        validateDocument(newList,oldMap);
        validateAppealPendinedRequest(newList,oldMap);
        checkFamilyDetailsFilled(newList,oldMap);
        populateRegionalCenter(newList, oldMap);
        createRequestComments(newList, oldMap);
        validateNDBEDPRequest(newList, oldMap);
        validateRequiredFieldForCNDSSync(newList, oldMap);
        validateRequiredDocumentsOfNDBEDP(newList, oldMap);
        restrictTheAssesser(newList, oldMap);
        validateRolesDSSAndDBSS(newList, oldMap);
        //externalAssessorUser(newList, oldMap);
        createCommunityAssessor(newList, oldMap);
        deniedComments(newList, oldMap);
        deniedTRPComments(newList, oldMap);
        deniedCommentsTRC(newList, oldMap);
        assessorAcceptance(newList, oldMap);
        // checkIncome(newList, oldMap);
        checkAssessment(newList, oldMap);
        checkApplicantSignature(newList, oldMap);
        validateRequestEquipment(newList, oldMap);
        checkPendingConditionOfAcceptance(newList, oldMap);
        //approvePendingConditionOfAcceptance(newList, oldMap);
        checkPendingConditionOfAcceptanceAccept(newList, oldMap);
        checkNDBEDPFollowUpInvoice(newList,oldMap);
        checkNDBEDPAdditionalTrainingInvoice(newList,oldMap);
        updateNDBEDPFollowUpFieldsOnRejection(newList,oldMap);
        validateNDBEDPRepairRequest(newList,oldMap);
        validateNDBEDPDemo(newList,oldMap);
        // sendEmailForInvitationForAssessorAfterAcceptance(newList, oldMap);
        //validateNDBEDPRequest(newList, oldMap);
        updateNDBEDPStatusReject(newList, oldMap);
        sendEmailForAssessmentForm(newList, oldMap);
        //   restrictTheAssesser(newList, oldMap);
        moveToPendingTrainer(newList, oldMap);
        updateAssessorInvitationDate(newList, oldMap);
        updatePreviousDescription(newList, oldMap);
    }
    
    /*
*********************************************************
@Method Name    : updateServiceRequestOwner
@description    : Update Service Request owner
@param          : List<case> newList
@return         : void
********************************************************
*/
    public static void updateServiceRequestOwner(List<Case> newList){
        List<Case> updateCases = new List<Case>();
        Set<Id> caseIds = new Set<Id>();
        for(Case caseObj: newList) {
            if(caseObj.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId()) {
                caseIds.add(caseObj.id);
            }
        }
        if(caseIds.size() > 0) {
            List<Group> groupList = [select id from Group WHERE DeveloperName = 'Regional_Center_Office' AND Type = 'Queue'];
            String ownerId = !groupList.isEmpty() ? groupList[0].id : null;
            if(String.isNotBlank(ownerId)) {
                for(Id caseId: caseIds) {
                    Case caseObj = new Case();
                    caseObj.id = caseId;
                    caseObj.OwnerId = ownerId;
                    updateCases.add(caseObj);
                }
            }
        }
        if(updateCases.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Case', updateCases, 'update', true,'NC_CaseTriggerHandler','updateServiceRequestOwner');
            update objectDecision.getRecords();
        }
    }
    
    /*
*********************************************************
@Method Name    : afterUpdate
@description    : calling this method on 'after update' trigger event
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void afterUpdate(List<Case> newList, Map<Id, Case> oldMap){
        // submitForApproval(newList, oldMap);
        externalAssessorUser(newList, oldMap);
        sendEmailForAssessorAcceptance(newList, oldMap);
        sendEmailForInvitationForAssessorAfterAcceptance(newList, oldMap);
        approvePendingConditionOfAcceptance(newList, oldMap);
        updateNDBEDPRequest(newList, oldMap);
        NDBEDPFollowUpSubmitForApproval(newList, oldMap);
        approveAdditionalRequirments(newList, oldMap);
        // checkAssessment(newList, oldMap);
        Id rtIDNDBEDP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Id NDBEDPFollowUp = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_up').getRecordTypeId();
        Id NDBEDPRepairRequest = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Repair_Request').getRecordTypeId();
        
        Set<Id> contactIds=new Set<Id> ();
        Set<Id> accountIds=new Set<Id> ();
        Set<Id> assessorAsUserIds=new Set<Id> ();
        Set<Id> contactIdsNDBEDP=new Set<Id> ();
        List<Case> cancelMatRequestList=new List<Case>();
        List<Contact> consumerList = new List<Contact>();
        List<Account> accountList = new List<Account>();
        List<Contact> consumerListNDBEDP = new List<Contact>();
        List<User> assessorListNDBEDP = new List<User>();
        Map<Id, Case> approvedStatusCaseMap = new Map<Id, Case>();
        Map<Id, Case> assessorScheduledStatusCaseMap = new Map<Id, Case>();
        List<Case> listOfDeniedCase = new List<Case>();
        for(Case caseRecord : newList){
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == NC_Constant.CASE_STATUS_APPROVED){
                approvedStatusCaseMap.put(caseRecord.id,caseRecord);
            }
            // if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Assessor scheduled' && caseRecord.RecordtypeId == NDBEDPFollowUp){
            //     assessorScheduledStatusCaseMap.put(caseRecord.id,caseRecord);
            // }
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == NC_Constant.CASE_STATUS_DENIED && caseRecord.recordTypeId != ndbedpRequestId && caseRecord.RecordTypeId != NDBEDPRepairRequest){
                listOfDeniedCase.add(caseRecord);
            }
            //CNDS Sync
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Pending Documents' && caseRecord.RecordTypeId!=rtIDNDBEDP){
                contactIds.add(caseRecord.ContactId);
            }
            //CNDS Sync for NDBEDP Request
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Documents Review' && caseRecord.RecordTypeId==rtIDNDBEDP){
                contactIds.add(caseRecord.ContactId);
            }
            //Sync for NDBEDP N1 and N2
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status  && caseRecord.RecordTypeId==rtIDNDBEDP && (caseRecord.Status == 'Pending Assessor' || caseRecord.Status == 'Pending Equipment Order' )){
                contactIdsNDBEDP.add(caseRecord.ContactId);
            }
            //Sync for Assessor NDBEDP
            if(caseRecord.External_Assessor__c!=null && oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Pending Equipment Order' && caseRecord.RecordTypeId==rtIDNDBEDP){
                accountIds.add(caseRecord.External_Assessor__c);
            }
            if(caseRecord.Internal_Assessor__c!=null && oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Pending Equipment Order' && caseRecord.RecordTypeId==rtIDNDBEDP){
                assessorAsUserIds.add(caseRecord.Internal_Assessor__c);
            }
            //Sync TRC for NDBEDP Demo - N2
            if(caseRecord.External_Assessor_User__c!=null && oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Pending TRC' && caseRecord.RecordTypeId==ndbedpDemoTypeId){
                assessorAsUserIds.add(caseRecord.External_Assessor_User__c);
            }
            //Sync for Cancel MatRequest NDBEDP
            if(caseRecord.MatReqStatus__c=='Cancel' && oldMap.get(caseRecord.Id).MatReqStatus__c != caseRecord.MatReqStatus__c  && caseRecord.RecordTypeId==rtIDNDBEDP && caseRecord.MatRequestObj__c!=null){
                cancelMatRequestList.add(caseRecord);
            }
        }
        // if(assessorScheduledStatusCaseMap.size()>0){
        
        //     createAsset(assessorScheduledStatusCaseMap);
        // }
        if(!approvedStatusCaseMap.values().isEmpty()){
            createAsset(approvedStatusCaseMap); // Uncomment
        }
        if(!listOfDeniedCase.isEmpty()){
            sendDeniedEmail(listOfDeniedCase);
        }
        doValidation(newList);
        
        consumerList=[SELECT Id, FirstName,MiddleName,Staff_Member_Name__c,BirthDate ,Social_Security_Number__c
                      ,Cnds_Identifier__c,User_Id__c,Race__c,Primary_Language__c,Suffix,Hispanic_Ethnicity__c,LastName,Gender__c from Contact where Cnds_Identifier__c=null AND Id IN:contactIds]; //WITH SECURITY_ENFORCED
        consumerListNDBEDP=[SELECT Id,Ethnicity__c,OtherCountryCode,OtherStateCode,Patron_Contact_Obj_Add__c,Patron_Type__c,Allow_NDBEDP_Resync__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,Patron_Contact_Obj_Email__c,County__c,Preferred_Contact_Method__c,Status_Code__c,Reg_End_Date__c,Patron_Obj__c,Address_Link_Obj__c,Patron_Contact_Obj__c,Library_ID__c,Email,Alt_Phone_Number__c,Work_Phone_Number__c,Cell_Phone_Number__c, FirstName,MiddleName,BirthDate,Primary_Language__c,Suffix,Hispanic_Ethnicity__c,LastName,Gender__c,MobilePhone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,Patron_ID__c from Contact where  Id IN:contactIdsNDBEDP];//WITH SECURITY_ENFORCED
        accountList=[SELECT Id,Video_Phone__c,Patron_Contact_Obj_Video_Phone__c,Patron_Contact_Obj_Add__c,BillingCountryCode,BillingStateCode,Patron_Type__c,Allow_NDBEDP_Resync__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,Patron_Contact_Obj_Email__c,County__c,Preferred_Method_of_Contact__c,Status_Code__c,Reg_End_Date__c,Patron_Obj__c,Address_Link_Obj__c,Library_ID__c,Email__c,Alternative_Phone__c,Alternative_Email__c,Work_Phone__c,Cell_Phone__c, First_Name__c,Middle_Name__c,BirthDate__c,Primary_Language__c,Suffix__c,Ethnicity__c,Last_Name__c,Gender__c,BillingCountry,BillingCity,BillingStreet,BillingState,BillingPostalCode,Patron_ID__c from Account where Id IN:accountIds];//WITH SECURITY_ENFORCED
        //Cannot apply CRUDCHECK
        assessorListNDBEDP=[SELECT Id,Video_Phone__c,Patron_Contact_Obj_Video_Phone__c,Alt_Phone_Number__c,Ethnicity__c,CountryCode,StateCode,Patron_Contact_Obj_Add__c,Patron_Type__c,Allow_NDBEDP_Resync__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_WorkPhone__c,Patron_Contact_Obj_AltPhone__c,Patron_Contact_Obj_Email__c,County__c,Preferred_Contact_Method__c,Status_Code__c,Patron_Obj__c,Address_Link_Obj__c,Library_ID__c,Email,Work_Phone_Number__c, FirstName,MiddleName,BirthDate__c,Primary_Language__c,Suffix,LastName,Gender__c,MobilePhone,Street,City,State,PostalCode,Patron_ID__c from User where  Id IN:assessorAsUserIds];//WITH SECURITY_ENFORCED
        //WITH SECURITY_ENFORCED];
        if(!consumerList.isEmpty()){
            System.enqueueJob(new NC_LookupCNDS(consumerList));
        }
        if(!consumerListNDBEDP.isEmpty()){
            System.enqueueJob(new NC_NDBEDP_PatronSearch(consumerListNDBEDP));
        }
        
        //External Assesor sync
        if(!accountList.isEmpty()){
            System.enqueueJob(new NC_NDBEDPTrainerSearch(accountList));
        }
        if (!assessorListNDBEDP.isEmpty()) {
            System.enqueueJob(new NC_NDBEDP_AssessorSearch(assessorListNDBEDP));
        }
        if(!cancelMatRequestList.isEmpty()){
            cancelMatRequest(cancelMatRequestList,oldMap);
        }
        acceptNDBEDPRepairRequest(newList, oldMap);
        createAssessorAuthorization(newList, oldMap);
        createNDBEDPFollowAuthorization(newList, oldMap);
        createNDBEDPAdditionalTrainingAuthorization(newList, oldMap);
        createAssessorTraingingInstallationAuthorization(newList, oldMap);
        createNDBEDPPickupAuthorization(newList, oldMap);
        createNDBEDPDeliveyAuthorization(newList, oldMap);
        sendNDBEDPEquipmentRequest(newList, oldMap);
        updateNDBEDPBudget(newList, oldMap);
        validateRequestEquipmentActive(newList, oldMap);
    }
    
    /*
*********************************************************
@Method Name    : cancelMatRequest
@description    : send equipment request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void cancelMatRequest(List<Case> caseList, Map<Id,Case> oldMap) {
        Map<String, Set<Id>> requestEqpMap = new Map<String, Set<Id>>();
        for(Request_Equipment__c requestEqp: [SELECT Request__c FROM Request_Equipment__c WHERE Request__c IN: caseList WITH SECURITY_ENFORCED]) {
            if(requestEqpMap.containsKey(requestEqp.Request__c)) {
                requestEqpMap.get(requestEqp.Request__c).add(requestEqp.id);
            } else {
                requestEqpMap.put(requestEqp.Request__c + '', new Set<Id>{requestEqp.id});
            }
        }
        
        for(String requestId: requestEqpMap.keySet()) {
            NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestEqpMap.get(requestId), requestId);
        }
        
    }
    
    /*
*********************************************************
@Method Name    : validateRequestEquipmentActive
@description    : validate request equipments
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateRequestEquipmentActive(List<Case> caseList, Map<Id,Case> oldMap) {
        for(Case caseRecord : caseList){
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Approved' && caseRecord.Send_to_KLAS__c==false &&
               (caseRecord.recordTypeId == ndbedpDemoTypeId || caseRecord.RecordTypeId==ndbedpRequestId)){
                   System.enqueueJob(new NC_NDBEDP_ValidateEquipments(caseRecord.Id));
               }
        }
    }
    
    /*
*********************************************************
@Method Name    : sendNDBEDPEquipmentRequest
@description    : send NDBEDP equipment request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void sendNDBEDPEquipmentRequest(List<Case> caseList, Map<Id,Case> oldMap) {
        Set<String> caseIdSet = new Set<String>();
        Map<String, Set<Id>> requestEqpMap = new Map<String, Set<Id>>();
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        for(Case caseObj: caseList) {
            if(oldMap != null
               && (caseObj.recordTypeId == ndbedpRecordTypeId || caseObj.recordTypeId == ndbedpDemoTypeId)
               && oldMap.get(caseObj.id).Send_to_KLAS__c != caseObj.Send_to_KLAS__c && caseObj.Send_to_KLAS__c==true
               && caseObj.Status == 'Approved') {
                   caseIdSet.add(caseObj.id);
               }
        }
        if (caseIdSet.size()>0) {
            for(Request_Equipment__c requestEqp: [SELECT Request__c FROM Request_Equipment__c WHERE Request__c IN: caseIdSet AND Reassigned__c = false WITH SECURITY_ENFORCED]) {
                if(requestEqpMap.containsKey(requestEqp.Request__c)) {
                    requestEqpMap.get(requestEqp.Request__c).add(requestEqp.id);
                } else {
                    requestEqpMap.put(requestEqp.Request__c + '', new Set<Id>{requestEqp.id});
                }
            }
            if (requestEqpMap != null || !requestEqpMap.isEmpty()) {
                for(String requestId: requestEqpMap.keySet()) {
                    NC_NDBEDPEquipmentCatalog.sendEquipmentRequest(requestEqpMap.get(requestId), requestId);
                }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : validateRequiredFieldForCNDSSync
@description    : Validate required field for CNDS sync
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateRequiredFieldForCNDSSync(List<Case> caseList, Map<Id,Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        for(Case selectedCase : caseList) {
            if( (selectedCase.Status =='Pending Documents' && selectedCase.recordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId()) || (oldMap.get(selectedCase.Id).Status != selectedCase.Status && selectedCase.status== 'Documents Review' && selectedCase.recordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId()) ){
                caseIds.add(selectedCase.Id);
            }
        }
        
        if(caseIds.size()>0){
            for (Case obj : [SELECT Id,ContactId,Contact.FirstName,Contact.LastName,Contact.Gender__c,Contact.MiddleName,Contact.Suffix,Contact.Birthdate,Contact.Hispanic_Ethnicity__c,Contact.Primary_Language__c,Contact.User_Id__c,Contact.Race__c ,Contact.Social_Security_Number__c
                             FROM Case WHERE Id IN :caseIds]){
                                 /*if (obj.Contact.FirstName==null || obj.Contact.LastName==null || obj.Contact.Gender__c==null || obj.Contact.Birthdate==null || obj.Contact.Hispanic_Ethnicity__c==null
|| obj.Contact.Primary_Language__c==null || obj.Contact.User_Id__c==null || obj.Contact.Race__c==null 
|| obj.Contact.Social_Security_Number__c==null
) {
trigger.newmap.get(obj.id).addError('Please complete the required fields: Consumer First Name, Consumer Last Name, Consumer Gender, Consumer Birthdate, Consumer Hispanic Ethnicity, Consumer Language, Consumer Race, SSN');
}*/
                                 String errorMessage='';
                                 if (obj.Contact.FirstName==null) {
                                     errorMessage = 'First Name, ';
                                 }
                                 if(obj.Contact.LastName==null) {
                                     errorMessage += 'Last Name, ';
                                 }
                                 if(obj.Contact.Gender__c==null) {
                                     errorMessage += 'Gender, ';
                                 }
                                 if(obj.Contact.Birthdate==null) {
                                     errorMessage += 'Birthdate, ';
                                 }
                                 if(obj.Contact.Hispanic_Ethnicity__c==null) {
                                     errorMessage += 'Hispanic Ethnicity, ';
                                 }
                                 if(obj.Contact.Primary_Language__c==null) {
                                     errorMessage += 'Language, ';
                                 }
                                 if(obj.Contact.Race__c==null) {
                                     errorMessage += 'Race, ';
                                     trigger.newmap.get(obj.id).addError('Please complete the required field: Consumer Race');
                                 }
                                 if(obj.Contact.Social_Security_Number__c==null) {
                                     errorMessage += 'SSN, ';
                                 }
                                 if(String.isNotBlank(errorMessage)){
                                     trigger.newmap.get(obj.id).addError('Complete required fields on Consumer to proceed: '+errorMessage.substring(0, errorMessage.length()-2));
                                 }
                             }
        } 
    }
    
    /*
*********************************************************
@Method Name    : validateDocument
@description    : Validate EDS Request document
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateDocument(List<Case> caseList, Map<Id,Case> oldMap) {
        Id edsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();
        for(Case selectedCase : caseList) {
            if(selectedCase.recordTypeId == edsRecordTypeId && selectedCase.Status == NC_Constant.CASE_REGIONAL_CENTER_AUDIT_STATUS && !selectedCase.Condition_of_Acceptance_Uploaded__c) {
                selectedCase.addError(NC_Constant.CASE_TRIGGER_ERROR_CONDITION_ACCECPTANCE);
            }
            if(selectedCase.recordTypeId == edsRecordTypeId && (selectedCase.Equipment_Types__c.contains('Hearing Aid') || selectedCase.Equipment_Types__c.contains('Speech Equipment')) && selectedCase.Status == NC_Constant.CASE_REGIONAL_CENTER_AUDIT_STATUS && !selectedCase.Certification_and_Documentation_Uploaded__c) {
                selectedCase.addError('Certification and Documentation needs to be uploaded');
            }
            if(selectedCase.Status == NC_Constant.CASE_PENDING_EDS_PROGRAM_COORDINATOR_STATUS && String.isBlank(selectedCase.EDS_Program_Assistant_Audit_Comments__c)  ) {
                selectedCase.addError(NC_Constant.CASE_PENDING_EDS_PROGRAM_ASSISTANT_ERROR_MESSAGE);
            }
        }
        for(Case selectedCase : caseList) {
            if(selectedCase.recordTypeId == edsRecordTypeId && selectedCase.Status == NC_Constant.CASE_STATUS_APPROVED && !selectedCase.Condition_of_Acceptance_Uploaded__c) {
                selectedCase.addError(NC_Constant.CASE_TRIGGER_ERROR_CONDITION_ACCECPTANCE);
            }
            if(selectedCase.recordTypeId == edsRecordTypeId && (selectedCase.Equipment_Types__c.contains('Hearing Aid') || selectedCase.Equipment_Types__c.contains('Speech Equipment')) && selectedCase.Status == NC_Constant.CASE_STATUS_APPROVED && !selectedCase.Certification_and_Documentation_Uploaded__c) {
                selectedCase.addError('Certification and Documentation needs to be uploaded');
            }
            //if(selectedCase.Status == NC_Constant.CASE_PENDING_EDS_PROGRAM_COORDINATOR_STATUS && String.isBlank(selectedCase.EDS_Program_Assistant_Audit_Comments__c)  ) {
              //  selectedCase.addError(NC_Constant.CASE_PENDING_EDS_PROGRAM_ASSISTANT_ERROR_MESSAGE);
            //}
        }
    }

     /*
*********************************************************
@Method Name    : validateAppealPendinedRequest
@description    : Validate EDS Request when denied by income more then 250 percent and submitted for approval
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
public static void validateAppealPendinedRequest(List<Case> caseList, Map<Id,Case> oldMap) {
    Id edsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Equipment').getRecordTypeId();

    //checking for documents
    for(Case selectedCase : caseList) {
        if(selectedCase.recordTypeId == edsRecordTypeId && selectedCase.Status == NC_Constant.CASE_STATUS_APPROVED && !selectedCase.Condition_of_Acceptance_Uploaded__c) {
            selectedCase.addError(NC_Constant.CASE_TRIGGER_ERROR_CONDITION_ACCECPTANCE);
        }
        if(selectedCase.recordTypeId == edsRecordTypeId && (selectedCase.Equipment_Types__c.contains('Hearing Aid') || selectedCase.Equipment_Types__c.contains('Speech Equipment')) && selectedCase.Status == NC_Constant.CASE_STATUS_APPROVED && !selectedCase.Certification_and_Documentation_Uploaded__c) {
            selectedCase.addError('Certification and Documentation needs to be uploaded');
        }
        //if(selectedCase.Status == NC_Constant.CASE_PENDING_EDS_PROGRAM_COORDINATOR_STATUS && String.isBlank(selectedCase.EDS_Program_Assistant_Audit_Comments__c)  ) {
          //  selectedCase.addError(NC_Constant.CASE_PENDING_EDS_PROGRAM_ASSISTANT_ERROR_MESSAGE);
        //}
    }
    
    //checking for equipment selected
    Map<Id, Case> caseNewMap = new Map<Id, Case>();
    for(Case caseObj: caseList) {
        caseNewMap.put(caseObj.id, caseObj);
    }
    for(Case caseObj:[SELECT Id,(SELECT Id FROM Requests_Equipment__r) FROM Case WHERE Id IN :caseList]){//WITH SECURITY_ENFORCED
        if(oldMap.containsKey(caseObj.id) && caseNewMap.containsKey(caseObj.id) 
           && caseNewMap.get(caseObj.id).recordTypeId == edsRecordTypeId
           && oldMap.get(caseObj.id).Status != caseNewMap.get(caseObj.id).Status 
           // && caseNewMap.get(caseObj.id).Status == 'Pending Condition of Acceptance'
           // && oldMap.get(caseObj.id).Status == 'Applicant Signature'
           && caseNewMap.get(caseObj.id).Status == NC_Constant.CASE_STATUS_APPROVED
           && oldMap.get(caseObj.id).Status == 'Appeal Pending'
           && caseObj.Requests_Equipment__r.size()==0){
               trigger.newmap.get(caseObj.id).addError('No related Request Equipment found. Please add at least one related Request Equipment.	');
           }     
    }
    //checking for required fileds on request consumer
    Set<Id> caseIds = new Set<Id>();
    for(Case selectedCase : caseList) {
        if( (selectedCase.Status ==NC_Constant.CASE_STATUS_APPROVED && selectedCase.recordTypeId==edsRecordTypeId)){
            caseIds.add(selectedCase.Id);
        }
    }
    
    if(caseIds.size()>0){
        for (Case obj : [SELECT Id,ContactId,Contact.FirstName,Contact.LastName,Contact.Gender__c,Contact.MiddleName,Contact.Suffix,Contact.Birthdate,Contact.Hispanic_Ethnicity__c,Contact.Primary_Language__c,Contact.User_Id__c,Contact.Race__c ,Contact.Social_Security_Number__c,
                         Contact.Preferred_Contact_Method__c,Contact.MailingStreet,Contact.Regional_Center_Office__c,Contact.Cnds_Identifier__c,Contact.Veteran_Status__c,
                         Contact.Attended_1_1_Consultation__c,Contact.Hearing_Disability__c,Contact.Disability_Determination_form_Uploaded__c,Contact.Attended_Information_Session__c,
                         Contact.Proof_of_Income_Provided_By__c,Contact.Proof_of_Income_Uploaded__c,Contact.Proof_Of_Residency_Provided_By__c,Contact.Proof_Of_Residency_Uploaded__c,Contact.Voter_Registration_Form_Uploaded__c
                         FROM Case WHERE Id IN :caseIds]){
                             String errorMessage='';
                             if (obj.Contact.FirstName==null) {
                                 errorMessage = 'First Name, ';
                             }
                             if(obj.Contact.LastName==null) {
                                 errorMessage += 'Last Name, ';
                             }
                             if(obj.Contact.Gender__c==null) {
                                 errorMessage += 'Gender, ';
                             }
                             if(obj.Contact.Birthdate==null) {
                                 errorMessage += 'Birthdate, ';
                             }
                             if(obj.Contact.Hispanic_Ethnicity__c==null) {
                                 errorMessage += 'Hispanic Ethnicity, ';
                             }
                             if(obj.Contact.Primary_Language__c==null) {
                                 errorMessage += 'Language, ';
                             }
                             if(obj.Contact.Preferred_Contact_Method__c==null) {
                                errorMessage += 'Preferred Contact Method, ';
                            }
                            if(obj.Contact.MailingStreet==null) {
                                errorMessage += 'Mailing Street, ';
                            }
                            if(obj.Contact.Regional_Center_Office__c==null) {
                                errorMessage += 'Regional Center, ';
                            }
                            if(obj.Contact.Cnds_Identifier__c==null) {
                                errorMessage += 'Cnds Identifier, ';
                            }
                            if(obj.Contact.Veteran_Status__c==null) {
                                errorMessage += 'Veteran Status, ';
                            }
                             if(obj.Contact.Race__c==null) {
                                 errorMessage += 'Race, ';
                                 trigger.newmap.get(obj.id).addError('Please complete the required field: Consumer Race');
                             }
                             if(obj.Contact.Social_Security_Number__c==null) {
                                 errorMessage += 'SSN, ';
                             }
                             if(String.isNotBlank(errorMessage)){
                                 trigger.newmap.get(obj.id).addError('Complete required fields on Consumer to proceed: '+errorMessage.substring(0, errorMessage.length()-2));
                             }

                            String errorMsg='';
                            if(obj.Contact.Proof_of_Income_Provided_By__c ==null || !obj.Contact.Proof_of_Income_Uploaded__c) {
                                errorMsg += 'Proof of income needs to be updated on the Consumer Record (Proof of Income Uploaded, Proof of Income Provided By).' ;
                            }
                            if((obj.Contact.Hearing_Disability__c=='Deaf'|| obj.Contact.Hearing_Disability__c=='Hard of Hearing' || obj.Contact.Hearing_Disability__c=='Late Deafened'|| obj.Contact.Hearing_Disability__c=='Speech Impaired') && !obj.Contact.Disability_Determination_form_Uploaded__c) {
                                errorMsg += 'Proof of disability needs to be updated on the Consumer Record (Disability Determination Form Uploaded, Hearing Disability).' ;
                            }
                            if(obj.Contact.Proof_Of_Residency_Provided_By__c == null || !obj.Contact.Proof_Of_Residency_Uploaded__c) {
                                errorMsg += 'Proof of residency needs to be updated on the Consumer Record (Proof of Residency Uploaded, Proof of Residency Provided By).';
                            }
                            if(!obj.Contact.Attended_1_1_Consultation__c) {
                                errorMsg += 'Consumer needs to attended 1:1 consultation.';
                            }
                            if(!obj.Contact.Attended_Information_Session__c) {
                                errorMsg += 'Consumer needs to attend an information session.';
                            }
                            if(!obj.Contact.Voter_Registration_Form_Uploaded__c) {
                                errorMsg += 'Voter registration needs to be uploaded on the consumer.';
                            }
                            if(String.isNotBlank(errorMsg)) {
                                trigger.newmap.get(obj.id).addError(errorMsg.substring(0, errorMsg.length()-2));
                            }
                         }
    } 
}
    
    /*
*********************************************************
@Method Name    : checkFamilyDetailsFilled
@description    : Validate proof of license to be uploaded field
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkFamilyDetailsFilled(List<Case> caseList, Map<Id,Case> oldMap) {
        List<Case> updatedCaseList = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id,Set<Family_Details__c>> caseToFamilyDetailMap = new Map<Id,Set<Family_Details__c>>();
        Set<String> docSet = new Set<String>{'Work First','Medicaid','SSI',
            'CSHS (Children\'s’ Special Health Services)','Health Choice for Children',
            'Section 8 Housing Choice Vouchers','Food Stamps'}; 
                Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        for(Case selectedCase : caseList) {
            if(oldMap != NULL && selectedCase.recordTypeId != ndbedpRecordTypeId && oldMap.get(selectedCase.Id).Status != selectedCase.Status &&
               selectedCase.Status == NC_Constant.CASE_REGIONAL_CENTER_AUDIT_STATUS
               && selectedCase.Proof_of_Income_Provided_By__c != null
               && !docSet.contains(selectedCase.Proof_of_Income_Provided_By__c)
               && (selectedCase.Equipment_Types__c != 'Weather Radio')) {
                   updatedCaseList.add(selectedCase);
               }
            if(oldMap != NULL && selectedCase.recordTypeId == ndbedpRecordTypeId 
               && oldMap.get(selectedCase.Id).Status != selectedCase.Status
               && selectedCase.Status == 'Pending Disability Determination'
               && selectedCase.Proof_of_Income_Provided_By__c != null
               && !docSet.contains(selectedCase.Proof_of_Income_Provided_By__c)) {
                   updatedCaseList.add(selectedCase);
               }
        }
        for(Family_Details__c familyDetail : [SELECT Id, Request__c FROM Family_Details__c 
                                              WHERE Request__c IN: updatedCaseList]){//WITH SECURITY_ENFORCED
                                                  caseIdSet.add(familyDetail.Request__c);
                                              }
        for(Case caseRecord : updatedCaseList){
            if(!caseIdSet.contains(caseRecord.Id)){
                caseRecord.addError('Please complete the Income Worksheet.');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : sendDeniedEmail
@description    : Send Denied Message with Attachment
@param          : List<Case> caseList
@return         : void
********************************************************
*/
    public static void sendDeniedEmail(List<Case> caseList){
        Map<Id, Id> ConsumerIdWithCase = new Map<Id, Id>();
        for(Case caseRecord : caseList){
            ConsumerIdWithCase.put(caseRecord.Id, caseRecord.ContactId);
        }
        NC_SendBulkEmail.sendEmailOnRequestDenial(ConsumerIdWithCase);
    }
    
    /*
*********************************************************
@Method Name    : populateRegionalCenter
@description    : populate regional center on request
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    private static void populateRegionalCenter(List<Case> newList, Map<Id, Case> oldMap){
        //Populate Regional Center if requested by is consumer 
        Map<Case,Id> caseRecordToContactId = new Map<Case,Id>();
        Map<Id,Id> contactIdToRegionalCenterMap = new Map<Id,Id>();
        Map<Id,String> contactIdToRegionalCenterAssesserMap = new Map<Id,String>();
        
        for(Case caseRecord : newList){
            if((oldMap == NULL && caseRecord.ContactId != NULL)){
                caseRecordToContactId.put(caseRecord,caseRecord.ContactId);
            }
        } 
        for(Contact contactRecord : [SELECT Id,Regional_Center_Office__c
                                     FROM Contact 
                                     WHERE Id IN: caseRecordToContactId.values() WITH SECURITY_ENFORCED]){
                                         contactIdToRegionalCenterMap.put(contactRecord.Id,contactRecord.Regional_Center_Office__c);
                                     }
        for(Contact contactRecord : [SELECT Id,Regional_Center_Office__c,Regional_Center_Office__r.Name
                                     FROM Contact 
                                     WHERE Id IN: caseRecordToContactId.values() WITH SECURITY_ENFORCED]){
                                         contactIdToRegionalCenterAssesserMap.put(contactRecord.Id,contactRecord.Regional_Center_Office__r.Name);
                                     }
        
        for(Case caseRecord : caseRecordToContactId.keySet()){
            if(contactIdToRegionalCenterMap.containsKey(caseRecord.ContactId) && caseRecord.Request_Audience__c=='Consumer'){
                caseRecord.Regional_Center__c = contactIdToRegionalCenterMap.get(caseRecord.ContactId);
            }
            if(contactIdToRegionalCenterMap.containsKey(caseRecord.ContactId)){
                caseRecord.Regional_Center_Assesser__c=contactIdToRegionalCenterAssesserMap.get(caseRecord.ContactId);
            }
        }
         //Populate Regional Center if requested by is agency 
         Map<Case,Id> caseRecordToAgencyId = new Map<Case,Id>();
         Map<Id,Id> AgencyIdToRegionalCenterMap = new Map<Id,Id>(); 
         for(Case caseRecord : newList){
             if((oldMap == NULL && caseRecord.AccountId != NULL)){
                 caseRecordToAgencyId.put(caseRecord,caseRecord.AccountId);
             }
         } 
         for(Account accRecord : [SELECT Id,Regional_Center__c
         FROM Account 
         WHERE Id IN: caseRecordToAgencyId.values() WITH SECURITY_ENFORCED]){
             AgencyIdToRegionalCenterMap.put(accRecord.Id,accRecord.Regional_Center__c);
         }
         for(Case caseRecord : caseRecordToAgencyId.keySet()){
             if(AgencyIdToRegionalCenterMap.containsKey(caseRecord.AccountId) && caseRecord.Request_Audience__c=='Agency'){
                 caseRecord.Regional_Center__c = AgencyIdToRegionalCenterMap.get(caseRecord.AccountId);
             }
         }   
    }
    
    /*
*********************************************************
@Method Name    : doValidation
@description    : Testing method for validation setting
@param          : List<Case> newList
@return         : void
********************************************************
*/
    public static void doValidation(List<case> newList){
        Map<Id, String> mapOfSobjectidWithMessage = NC_ValidationUtility.retrieveErrorMap(newList, 'Case');
        if(mapOfSobjectidWithMessage.size() > 0) {
            for(Case caseRecord : newList){
                if(mapOfSobjectidWithMessage.containsKey(caseRecord.Id)){
                    if(caseRecord.recordTypeId!=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId()){
                        caseRecord.addError(mapOfSobjectidWithMessage.get(caseRecord.Id));
                    }
                }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : createRequestComments
@description    : Create Case Comments
@param          : List<Case> newList, Map<Id,case> oldMap
@return         : void
********************************************************
*/
    private static void createRequestComments(List<case> newList, Map<Id,case> oldMap){
        List<Request_comment__c> requestCommentList = new List<Request_comment__c>();
        List<Case> caseUpdateRecord = new List<Case>();
        for(Case caseRecord : newList){
            if(caseRecord.Internal_Comments__c != NULL){
                Request_comment__c requestComment = new Request_comment__c();
                requestComment.Internal_Comments__c = caseRecord.Internal_Comments__c ;
                requestComment.Hours__c = caseRecord.Hours__c != NULL ? caseRecord.Hours__c : NULL;
                requestComment.Minutes__c = caseRecord.Minutes__c != NULL ? caseRecord.Minutes__c : NULL;
                requestComment.Request__c = caseRecord.Id;
                requestCommentList.add(requestComment);
                caseRecord.Internal_Comments__c = NULL;
                caseRecord.Hours__c = NULL;
                caseRecord.Minutes__c = NULL;
            }
        }
        if(!requestCommentList.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Request_comment__c', requestCommentList, 'insert', true, 'NC_CaseTriggerHandler', 'createRequestComments');
            insert objectDecision.getRecords();
            requestCommentList = objectDecision.getRecords();
            Map<Id, Id> commentReqMap = new Map<Id, Id>();
            Map<Id, Request_comment__c> commReqMap = new Map<Id, Request_comment__c>();
            for(Request_comment__c reqComm: [SELECT Request__c, ownerId FROM Request_comment__c WHERE Id IN: requestCommentList]) {
                commentReqMap.put(reqComm.id, reqComm.Request__c);
                commReqMap.put(reqComm.id, reqComm);
            }
            shareRequestComments(commentReqMap, commReqMap);
        }
    }
    
    /*
*********************************************************
@Method Name    : shareRequestComments
@description    : Share Case Comments
@param          : Map<Id, Id> commentReqMap, Map<Id, Request_comment__c> commReqMap
@return         : void
********************************************************
*/
    public static void shareRequestComments(Map<Id, Id> commentReqMap, Map<Id, Request_comment__c> commReqMap) {
        List<Request_comment__share> reqComShareList = new List<Request_comment__share>();
        Map<Id, List<CaseShare>> caseShareMap = new Map<Id, List<CaseShare>>();
        for(CaseShare shareObj: [SELECT caseId, CaseAccessLevel, UserOrGroupId FROM CaseShare WHERE caseId IN: commentReqMap.values()]) {
            if(!caseShareMap.containsKey(shareObj.caseId)) {
                caseShareMap.put(shareObj.caseId, new List<CaseShare>());
            }
            caseShareMap.get(shareObj.caseId).add(shareObj);
        }
        
        for(Id requestCommId: commentReqMap.keySet()) {
            if(caseShareMap.containsKey(commentReqMap.get(requestCommId))) {
                for(CaseShare shareObj: caseShareMap.get(commentReqMap.get(requestCommId))) {
                    if(shareObj.UserOrGroupId != UserInfo.getUserId()) {
                        Request_comment__Share reqComShare = new Request_comment__Share();
                        reqComShare.ParentId = requestCommId;
                        reqComShare.AccessLevel = shareObj.CaseAccessLevel == 'All' ? 'Edit' : shareObj.CaseAccessLevel;
                        reqComShare.RowCause = Schema.Request_comment__share.RowCause.Manual;
                        reqComShare.UserOrGroupId = shareObj.UserOrGroupId;
                        reqComShareList.add(reqComShare);   
                    }
                }
            }
        }
        if(reqComShareList.size() > 0) {
            insert reqComShareList;
        }
    }
    
    /*
*********************************************************
@Method Name    : createAsset
@description    : Create Assets for those Case Records which have Approved Status
@param          : Map<Id,Case> caseMap
@return         : void
********************************************************
*/
    public static void createAsset(Map<Id,Case> caseMap){
        
        Map<Id, List<Equipment__c>> mapOfEquipmentWIthChildEquipment = new Map<Id, List<Equipment__c>>();
        Map<Id,List<Request_Equipment__c>> mapOfCaseAndRelatedEquipment = new Map<Id,List<Request_Equipment__c>>();
        Map<Id, Map<Id, List<Authorization__c>>> mapOfCaseWithAuthorization = new Map<Id, Map<Id,List<Authorization__c>>>();// To Insert the Values of this map and Bind with them Request Id
        Map<Id, Set<Id>> mapOfCaseWithVendors = new Map<Id, Set<Id>>(); // map of Case Id With Unque Vandor Ids
        Map<Id, List<Request_Equipment__c>> mapOfVendorWithRequestEquipment = new Map<Id, List<Request_Equipment__c>>(); // To Get All Type of Data from Request Equipment
        Map<String , Id> recordTypeIdWithEquipmentNameMap = new Map<String, Id>();
        Map<Id, Map<Id, List<String>>> mapOfvendorWithEquipment = new Map<Id, Map<Id, List<String>>>();
        Map<Id, Asset__c> mapOfReassignmentEquipment = new Map<Id, Asset__c>();
        List<Asset__c> listOfAssertToInsert = new List<Asset__c>();
        List<Authorization__c> listOfAuthorization = new List<Authorization__c>();
        List<Asset__c> updateListOfAsset = new List<Asset__c>();	
        List<Authorization__c> noCostAuthList = new List<Authorization__c>(); 	
        Set<Id> setOfAllAuthId = new Set<Id>();	
        Set<Id> setOfDeleteAuthID = new Set<Id>();
        Set<Id> edsAuthIds = new Set<Id>{AuthorizationWeatherRadioRecordTypeId, AuthorizationHearingAidRecordTypeId, AuthorizationSubHearingAidRecordTypeId, AuthorizationCAPTELRecordTypeId, AuthorizationOtherRecordTypeId};
            Map<Id,String> regionalCenterIdToNameMap = NC_Utility.getRegionalCenterIdToNameMap();
        List<Request_Equipment__c> updateRequestEquipment = new List<Request_Equipment__c>();
        Id authorizationAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_ASSESSOR);
        recordTypeIdWithEquipmentNameMap.put(NC_Constant.EQUIPMENT_TYPE_WEATHER_RADIO, AuthorizationWeatherRadioRecordTypeId);
        recordTypeIdWithEquipmentNameMap.put(NC_Constant.EQUIPMENT_TYPE_HEARING_AID, AuthorizationHearingAidRecordTypeId);
        recordTypeIdWithEquipmentNameMap.put(NC_Constant.EQUIPMENT_TYPE_SUB_HEARING_AID, AuthorizationSubHearingAidRecordTypeId);
        recordTypeIdWithEquipmentNameMap.put(NC_Constant.AUTHORIZATION_RECORDTYPE_EDS_INVOICE, AuthorizationOtherRecordTypeId);
        recordTypeIdWithEquipmentNameMap.put('Captioned Phone', AuthorizationCAPTELRecordTypeId);
        recordTypeIdWithEquipmentNameMap.put('NDBEDP', AuthorizationEquipmentRecordType);
        recordTypeIdWithEquipmentNameMap.put('Demo', AuthorizationEquipmentRecordType);
        
        Set<Id> setOfAuthorizationId = new Set<Id>();
        Set<Id> equipmentIdSet = new Set<Id>();
        
        Id assetGenereicRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Asset__c',NC_Constant.ASSET_GENERIC_RECORD_TYPE);
        Id assetHearingAidRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Asset__c','Hearing_Aid_Asset');
        Id assetNDBEDPRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Asset__c','NDBEDP_Asset');
        Id assetDemoRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Asset__c','Demo_Asset');
        
        Map<Id, Map<Id, Integer>> assetToEqpMap = new Map<Id, Map<Id, Integer>>();
        Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
        Map<Id, Map<Id,Asset__c>> regionalCenterToReassignmentEquipmentMap = new Map<Id, Map<Id,Asset__c>>();
        
        for(Asset__c assetRecord : [SELECT Id, Name, Quantity__c,Reassigned_Quantity__c, Available_for_Reassignment__c, Authorization__c, Authorization__r.Regional_Center__c,Authorization__r.Consumer__c, Authorization__r.Vendor__c, Reassignment_Note__c, Last_Contact_Date_Time__c, Equipment__c, Vendor__c, Request__r.Regional_Center__c,Request__r.OwnerId  FROM Asset__c WHERE Status__c =: NC_Constant.STATUS_ASSET_EQUIPMENT_REASSIGNMENT]){	//WITH SECURITY_ENFORCED
            if(!assetToEqpMap.containsKey(assetRecord.id)) {
                assetToEqpMap.put(assetRecord.id, new Map<Id, Integer>());
            }
            Integer assetQuantity = String.isNotBlank(assetRecord.Quantity__c) ? Integer.valueOf(assetRecord.Quantity__c) : 1;
            assetToEqpMap.get(assetRecord.id).put(assetRecord.Equipment__c, assetQuantity);
            assetMap.put(assetRecord.id, assetRecord);
            
            mapOfReassignmentEquipment.put(assetRecord.Equipment__c, assetRecord);
            if(!regionalCenterToReassignmentEquipmentMap.containsKey(assetRecord.Request__r.Regional_Center__c)){
                regionalCenterToReassignmentEquipmentMap.put(assetRecord.Request__r.Regional_Center__c, new Map<Id,Asset__c>());
            }
            regionalCenterToReassignmentEquipmentMap.get(assetRecord.Request__r.Regional_Center__c).put(assetRecord.Equipment__c, assetRecord);
        }
        
        for(Request_Equipment__c requestEquipment : [SELECT Id, Quantity__c, Sub_Equipment__r.Amount_Authorized__c,Equipment__c,Equipment__r.Amount_Authorized__c,Equipment__r.Is_Sub_Equipment__c, Sub_Equipment__r.Is_Sub_Equipment__c, Sub_Equipment__r.Name,Sub_Equipment__r.Vendor__c, Sub_Equipment__c, Equipment__r.Vendor__c, Equipment__r.Name, Request__r.ContactId, Request__c, Request__r.Vendor__c, Equipment__r.Equipment_Type__c,Sub_Equipment__r.Equipment_Type__c  FROM Request_Equipment__c WHERE Request__c IN: caseMap.keySet() WITH SECURITY_ENFORCED]){
            
            // Map Values for RequestId and RequestEquipment
            if(!mapOfCaseAndRelatedEquipment.containsKey(requestEquipment.Request__c)){
                mapOfCaseAndRelatedEquipment.put(requestEquipment.Request__c,new List<Request_Equipment__c>());
            }
            mapOfCaseAndRelatedEquipment.get(requestEquipment.Request__c).add(requestEquipment);
            
            //Map Values for All Vendores Coming in Request Equipment with their respected Request
            if(!mapOfCaseWithVendors.containsKey(requestEquipment.Request__c)){
                mapOfCaseWithVendors.put(requestEquipment.Request__c,new Set<Id>());
            }
            
            if(requestEquipment.Equipment__r.Is_Sub_Equipment__c == false && requestEquipment.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                mapOfCaseWithVendors.get(requestEquipment.Request__c).add(caseMap.get(requestEquipment.Request__c).Vendor__c);
            }else {
                mapOfCaseWithVendors.get(requestEquipment.Request__c).add(requestEquipment.Equipment__r.Vendor__c);
            }
            
            if(requestEquipment.Sub_Equipment__c != null){
                mapOfCaseWithVendors.get(requestEquipment.Request__c).add(requestEquipment.Sub_Equipment__r.Vendor__c);
            }
            
            //Map of vendors and Equipment Type
            if(!mapOfvendorWithEquipment.containsKey(requestEquipment.Request__c)){
                mapOfvendorWithEquipment.put(requestEquipment.Request__c, new Map<Id, List<String>>());
            }
            
            if(requestEquipment.Sub_Equipment__r != null){
                if(!mapOfvendorWithEquipment.get(requestEquipment.Request__c).containsKey(requestEquipment.Sub_Equipment__r.Vendor__c)){
                    mapOfvendorWithEquipment.get(requestEquipment.Request__c).put(requestEquipment.Sub_Equipment__r.Vendor__c, new List<String>());
                }
                mapOfvendorWithEquipment.get(requestEquipment.Request__c).get(requestEquipment.Sub_Equipment__r.Vendor__c).add(requestEquipment.Sub_Equipment__r.Equipment_Type__c);
            }
            if(requestEquipment.Equipment__r.Vendor__c != null){
                if(!mapOfvendorWithEquipment.get(requestEquipment.Request__c).containsKey(requestEquipment.Equipment__r.Vendor__c)){
                    mapOfvendorWithEquipment.get(requestEquipment.Request__c).put(requestEquipment.Equipment__r.Vendor__c, new List<String>());
                }
                mapOfvendorWithEquipment.get(requestEquipment.Request__c).get(requestEquipment.Equipment__r.Vendor__c).add(requestEquipment.Equipment__r.Equipment_Type__c);   
            }else{
                if(!mapOfvendorWithEquipment.get(requestEquipment.Request__c).containsKey(requestEquipment.Request__r.Vendor__c)){
                    mapOfvendorWithEquipment.get(requestEquipment.Request__c).put(requestEquipment.Request__r.Vendor__c, new List<String>());
                }
                mapOfvendorWithEquipment.get(requestEquipment.Request__c).get(requestEquipment.Request__r.Vendor__c).add(requestEquipment.Equipment__r.Equipment_Type__c);   
            }
            
            //Map Values for all Vendors with their Products
            if(requestEquipment.Equipment__r.Is_Sub_Equipment__c == false && requestEquipment.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                if(!mapOfVendorWithRequestEquipment.containsKey(caseMap.get(requestEquipment.Request__c).Vendor__c)){
                    mapOfVendorWithRequestEquipment.put(caseMap.get(requestEquipment.Request__c).Vendor__c,new List<Request_Equipment__c>());
                }
                mapOfVendorWithRequestEquipment.get(caseMap.get(requestEquipment.Request__c).Vendor__c).add(requestEquipment);
            }else{
                if(!mapOfVendorWithRequestEquipment.containsKey(requestEquipment.Equipment__r.Vendor__c)){
                    mapOfVendorWithRequestEquipment.put(requestEquipment.Equipment__r.Vendor__c,new List<Request_Equipment__c>());
                }
                mapOfVendorWithRequestEquipment.get(requestEquipment.Equipment__r.Vendor__c).add(requestEquipment);
            }
            
            equipmentIdSet.add(requestEquipment.Equipment__c);
        }
        
        for(Id requestId : mapOfCaseWithVendors.keySet()){
            for(Id vendorsRecord : mapOfCaseWithVendors.get(requestId)){
                for(String equipmentType : caseMap.get(requestId).Equipment_Types__c.split(';')){
                    if(mapOfvendorWithEquipment.get(requestId).get(vendorsRecord).contains(equipmentType)){
                        if(equipmentType == NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                            if(vendorsRecord == caseMap.get(requestId).Vendor__c){
                                listOfAuthorization.add(createAuthorization(vendorsRecord,caseMap.get(requestId).ContactId,requestId,NC_Constant.CASE_STATUS_APPROVED,caseMap.get(requestId).Regional_Center__c,AuthorizationHearingAidRecordTypeId,true,NC_Constant.AUTHORIZATION_SHIP_TO_NOT_APPLICABLE));
                            }else{
                                listOfAuthorization.add(createAuthorization(vendorsRecord,caseMap.get(requestId).ContactId,requestId,NC_Constant.CASE_STATUS_APPROVED,caseMap.get(requestId).Regional_Center__c,AuthorizationSubHearingAidRecordTypeId,true,NC_Constant.AUTHORIZATION_SHIP_TO_NOT_APPLICABLE));
                            }
                        }else{
                            if(equipmentType == NC_Constant.EQUIPMENT_TYPE_WEATHER_RADIO){
                                listOfAuthorization.add(createAuthorization(vendorsRecord,caseMap.get(requestId).ContactId,requestId,NC_Constant.CASE_STATUS_APPROVED,caseMap.get(requestId).Regional_Center__c,AuthorizationWeatherRadioRecordTypeId,false,null));
                            } else if(equipmentType == 'Captioned Phone') {
                                listOfAuthorization.add(createAuthorization(vendorsRecord,caseMap.get(requestId).ContactId,requestId,NC_Constant.CASE_STATUS_APPROVED,caseMap.get(requestId).Regional_Center__c,AuthorizationCAPTELRecordTypeId,false,null));
                            } else if(equipmentType == 'NDBEDP' || equipmentType == 'Demo') {
                                listOfAuthorization.add(createAuthorization(vendorsRecord,caseMap.get(requestId).ContactId,requestId,NC_Constant.CASE_STATUS_APPROVED,caseMap.get(requestId).Regional_Center__c,AuthorizationEquipmentRecordType,false,null));
                            }else{
                                listOfAuthorization.add(createAuthorization(vendorsRecord,caseMap.get(requestId).ContactId,requestId,NC_Constant.CASE_STATUS_APPROVED,caseMap.get(requestId).Regional_Center__c,AuthorizationOtherRecordTypeId,false,null));
                            }
                        }
                    }
                }
            }
        }
        if(!listOfAuthorization.isEmpty()){
            for(Authorization__c auth: listOfAuthorization) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', listOfAuthorization, 'insert', true, 'NC_CaseTriggerHandler', 'createAsset');
            insert objectDecision.getRecords();
            listOfAuthorization=objectDecision.getRecords();
        }
        
        
        for(Authorization__c authRecord : listOfAuthorization){
            if(!mapOfCaseWithAuthorization.containsKey(authRecord.Request__c)){
                mapOfCaseWithAuthorization.put(authRecord.Request__c, new Map<Id,List<Authorization__c>>());
            }
            if(!mapOfCaseWithAuthorization.get(authRecord.Request__c).containsKey(authRecord.Vendor__c)){
                mapOfCaseWithAuthorization.get(authRecord.Request__c).put(authRecord.Vendor__c, new List<Authorization__c>());
            }
            mapOfCaseWithAuthorization.get(authRecord.Request__c).get(authRecord.Vendor__c).add(authRecord);
        }
        
        Map<Id,Authorization__c> equipmentToAuthorizationMap = new Map<Id,Authorization__c>();
        Map<Id,Asset__c> equipmentToAssetMap = new Map<Id,Asset__c>();
        Map<Id,Case> assetToNewCaseMap = new Map<Id,Case>();
        List<Asset__c> assetToSendRecordList = new List<Asset__c>(); 
        Boolean deleteNDBEDPAuthorization = true;
        if(!listOfAuthorization.isEmpty()){
            for(Id caseRecordId : mapOfCaseAndRelatedEquipment.keySet()){
                for(Request_Equipment__c requestEquipmentRecord : mapOfCaseAndRelatedEquipment.get(caseRecordId)){
                    if(mapOfReassignmentEquipment.containsKey(requestEquipmentRecord.Equipment__c)){
                        Asset__c reassignedAsset; 
                        if(regionalCenterToReassignmentEquipmentMap.containsKey(caseMap.get(caseRecordId).Regional_Center__c) 
                           && regionalCenterToReassignmentEquipmentMap.get(caseMap.get(caseRecordId).Regional_Center__c).containsKey(requestEquipmentRecord.Equipment__c)){
                               reassignedAsset = regionalCenterToReassignmentEquipmentMap.get(caseMap.get(caseRecordId).Regional_Center__c).get(requestEquipmentRecord.Equipment__c);
                           }else{
                               reassignedAsset = mapOfReassignmentEquipment.get(requestEquipmentRecord.Equipment__c);
                               assetToNewCaseMap.put(reassignedAsset.Id,caseMap.get(caseRecordId));
                               assetToSendRecordList.add(reassignedAsset);
                           }
                        
                        if(requestEquipmentRecord.Equipment__r.Is_Sub_Equipment__c == false && requestEquipmentRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                            //noCostAuthList.add(createNoCostAuthorizationUtils(mapOfReassignmentEquipment.get(requestEquipmentRecord.Equipment__c).Authorization__c,requestEquipmentRecord.Request__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c ));
                            
                            Authorization__c authorizationRecord;
                            authorizationRecord = createNoCostAuthorizationUtils(reassignedAsset.Authorization__c,requestEquipmentRecord.Request__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c);
                            
                            equipmentToAuthorizationMap.put(requestEquipmentRecord.Equipment__c, authorizationRecord);
                            Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetHearingAidRecordTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, caseMap.get(caseRecordId).Vendor__c);
                            assetRecord.Asset_Reassignment_From__c = reassignedAsset.Id;
                            equipmentToAssetMap.put(requestEquipmentRecord.Equipment__c, assetRecord);
                            
                            reassignedAsset.Available_for_Reassignment__c = false;	
                            reassignedAsset.Reassignment_Note__c = '';	
                            //mapOfReassignmentEquipment.get(requestEquipmentRecord.Equipment__c).Last_Contact_Date_Time__c = null;
                            reassignedAsset.Status__c = 'Reassigned';
                            updateListOfAsset.add(reassignedAsset);	
                            setOfDeleteAuthID.add(getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,caseMap.get(caseRecordId).Vendor__c, recordTypeIdWithEquipmentNameMap));	
                        } else if(requestEquipmentRecord.Equipment__r.Equipment_Type__c == 'NDBEDP' || requestEquipmentRecord.Equipment__r.Equipment_Type__c == 'Demo'){
                            String assetIds = '';
                            String assetTypeId = requestEquipmentRecord.Equipment__r.Equipment_Type__c == 'Demo' ? assetDemoRecordTypeId : assetNDBEDPRecordTypeId;
                            Integer newAssetQuantity = Integer.valueOf(requestEquipmentRecord.Quantity__c);                            
                            Map<String, Object> returnMap = getAvailableForReassignmentAsset(requestEquipmentRecord, assetToEqpMap, assetMap);
                            if(returnMap.containsKey('assetList')) {
                                List<Asset__c> reassignedAssetList = (List<Asset__c>)returnMap.get('assetList');
                                for(Asset__c asset: reassignedAssetList) {
                                    if(assetMap.containsKey(asset.id)) {
                                        assetIds += assetMap.get(asset.id).Name + ', ';
                                    } else {
                                        assetIds += asset.id + ', ';
                                    }
                                }
                                updateListOfAsset.addAll(reassignedAssetList);
                            }
                            if(returnMap.containsKey('requiredQuantity')) {
                                Integer requiredQuantity = (Integer)returnMap.get('requiredQuantity');
                                if(requiredQuantity > 0) {
                                    Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Equipment__r.Vendor__c);	
                                    assetRecord.Quantity__c = requiredQuantity + '';
                                    if(mapOfCaseWithAuthorization.get(caseRecordId).containsKey(requestEquipmentRecord.Equipment__r.Vendor__c)){	
                                        assetRecord.Authorization__c = getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,caseMap.get(caseRecordId).Vendor__c, recordTypeIdWithEquipmentNameMap);
                                        if(assetRecord.Authorization__c != null){	
                                            listOfAssertToInsert.add(assetRecord);	
                                        }	
                                    }
                                    newAssetQuantity = newAssetQuantity - requiredQuantity;
                                    deleteNDBEDPAuthorization = false;
                                    Request_Equipment__c updateEquipment = new Request_Equipment__c();
                                    updateEquipment.id = requestEquipmentRecord.id;
                                    updateEquipment.Reassigned__c = false;
                                    updateEquipment.Reassigned_Quantity__c = newAssetQuantity;
                                    updateRequestEquipment.add(updateEquipment);
                                } else {
                                    Request_Equipment__c updateEquipment = new Request_Equipment__c();
                                    updateEquipment.id = requestEquipmentRecord.id;
                                    updateEquipment.Reassigned__c = true;
                                    updateEquipment.Reassigned_Quantity__c = newAssetQuantity;
                                    updateRequestEquipment.add(updateEquipment);
                                    
                                    Boolean deleteAuth = true;
                                    Set<Id> availableEquipments = new Set<Id>();
                                    for(Id equipmentId: mapOfReassignmentEquipment.keySet()) {
                                        availableEquipments.add(equipmentId);                                    
                                    }
                                    for(Request_Equipment__c reqEqp: mapOfCaseAndRelatedEquipment.get(caseRecordId)) {
                                        if(!availableEquipments.contains(reqEqp.Equipment__c)) {
                                            deleteAuth = false;                                    
                                        }
                                    }
                                    if(deleteAuth) {
                                        Id authId = getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,requestEquipmentRecord.Equipment__r.Vendor__c, recordTypeIdWithEquipmentNameMap);
                                        setOfDeleteAuthID.add(getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,requestEquipmentRecord.Equipment__r.Vendor__c, recordTypeIdWithEquipmentNameMap));
                                    }
                                }
                            }
                            
                            Authorization__c authorizationRecord;
                            authorizationRecord = createNoCostAuthorizationUtils(reassignedAsset.Authorization__c,requestEquipmentRecord.Equipment__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c );
                            equipmentToAuthorizationMap.put(requestEquipmentRecord.Equipment__c, authorizationRecord);
                            
                            Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Equipment__r.Vendor__c);	
                            assetRecord.Quantity__c = newAssetQuantity + '';
                            assetRecord.Comment__c = 'Reassigned from ' + assetIds;
                            equipmentToAssetMap.put(requestEquipmentRecord.Equipment__c, assetRecord);
                            // reassignedAsset.Available_for_Reassignment__c = false;	
                            // reassignedAsset.Reassignment_Note__c = '';	                            
                            // reassignedAsset.Status__c = 'Reassigned';
                            // updateRequestEquipment.add(requestEquipmentRecord.id);
                            // updateListOfAsset.add(reassignedAsset);
                            // updateListOfAsset.addAll(reassignedAssetList);
                        } else if(requestEquipmentRecord.Equipment__r.Equipment_Type__c != NC_Constant.EQUIPMENT_TYPE_HEARING_AID){	
                            //noCostAuthList.add(createNoCostAuthorizationUtils(mapOfReassignmentEquipment.get(requestEquipmentRecord.Equipment__c).Authorization__c,requestEquipmentRecord.Equipment__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c ));	
                            
                            Authorization__c authorizationRecord;
                            authorizationRecord = createNoCostAuthorizationUtils(reassignedAsset.Authorization__c,requestEquipmentRecord.Equipment__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c );
                            equipmentToAuthorizationMap.put(requestEquipmentRecord.Equipment__c, authorizationRecord);
                            
                            Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetGenereicRecordTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Equipment__r.Vendor__c);	
                            assetRecord.Asset_Reassignment_From__c = reassignedAsset.Id;
                            equipmentToAssetMap.put(requestEquipmentRecord.Equipment__c, assetRecord);
                            
                            reassignedAsset.Available_for_Reassignment__c = false;	
                            reassignedAsset.Reassignment_Note__c = '';	
                            //mapOfReassignmentEquipment.get(requestEquipmentRecord.Equipment__c).Last_Contact_Date_Time__c = null;	
                            reassignedAsset.Status__c = 'Reassigned';
                            updateListOfAsset.add(reassignedAsset);	
                            setOfDeleteAuthID.add(getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,requestEquipmentRecord.Equipment__r.Vendor__c, recordTypeIdWithEquipmentNameMap));	
                        }	
                    }else if(requestEquipmentRecord.Sub_Equipment__c != null && mapOfReassignmentEquipment.containsKey(requestEquipmentRecord.Sub_Equipment__c)){	
                        //noCostAuthList.add(createNoCostAuthorizationUtils(mapOfReassignmentEquipment.get(requestEquipmentRecord.Sub_Equipment__c).Authorization__c,requestEquipmentRecord.Sub_Equipment__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c ));	
                        
                        Asset__c reassignedAsset; 
                        if(regionalCenterToReassignmentEquipmentMap.containsKey(caseMap.get(caseRecordId).Regional_Center__c) 
                           && regionalCenterToReassignmentEquipmentMap.get(caseMap.get(caseRecordId).Regional_Center__c).containsKey(requestEquipmentRecord.Sub_Equipment__c)){
                               reassignedAsset = regionalCenterToReassignmentEquipmentMap.get(caseMap.get(caseRecordId).Regional_Center__c).get(requestEquipmentRecord.Sub_Equipment__c);
                           }else{
                               reassignedAsset = mapOfReassignmentEquipment.get(requestEquipmentRecord.Sub_Equipment__c);
                               assetToNewCaseMap.put(reassignedAsset.Id,caseMap.get(caseRecordId));
                               assetToSendRecordList.add(reassignedAsset);
                           }
                        
                        Authorization__c authorizationRecord;
                        authorizationRecord =createNoCostAuthorizationUtils(reassignedAsset.Authorization__c,requestEquipmentRecord.Sub_Equipment__r.Vendor__c, requestEquipmentRecord.Request__r.ContactId, requestEquipmentRecord.Request__c );
                        equipmentToAuthorizationMap.put(requestEquipmentRecord.Sub_Equipment__c, authorizationRecord);
                        Asset__c assetRecordChild = createAssetUtils(requestEquipmentRecord.Sub_Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetGenereicRecordTypeId,requestEquipmentRecord.Sub_Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Sub_Equipment__r.Vendor__c);	
                        assetRecordChild.Asset_Reassignment_From__c = reassignedAsset.Id;
                        equipmentToAssetMap.put(requestEquipmentRecord.Sub_Equipment__c, assetRecordChild);
                        
                        
                        reassignedAsset.Available_for_Reassignment__c = false;	
                        reassignedAsset.Reassignment_Note__c = '';	
                        reassignedAsset.Last_Contact_Date_Time__c = null;	
                        reassignedAsset.Status__c = 'Reassigned';
                        updateListOfAsset.add(reassignedAsset);	
                        setOfDeleteAuthID.add(getAuthorizationId(NC_Constant.EQUIPMENT_TYPE_SUB_HEARING_AID, mapOfCaseWithAuthorization, caseRecordId,requestEquipmentRecord.Sub_Equipment__r.Vendor__c, recordTypeIdWithEquipmentNameMap));	
                    }else{	
                        if(requestEquipmentRecord.Equipment__r.Is_Sub_Equipment__c == false && requestEquipmentRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID){	
                            Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetHearingAidRecordTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, caseMap.get(caseRecordId).Vendor__c);	
                            if(mapOfCaseWithAuthorization.get(caseRecordId).containsKey(caseMap.get(caseRecordId).Vendor__c)){	
                                assetRecord.Authorization__c = getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,caseMap.get(caseRecordId).Vendor__c, recordTypeIdWithEquipmentNameMap);	
                                if(assetRecord.Authorization__c != null){	
                                    listOfAssertToInsert.add(assetRecord);	
                                }	
                            }	
                        } else if(requestEquipmentRecord.Equipment__r.Equipment_Type__c == 'NDBEDP' || requestEquipmentRecord.Equipment__r.Equipment_Type__c == 'Demo') {
                            String assetTypeId = requestEquipmentRecord.Equipment__r.Equipment_Type__c == 'Demo' ? assetDemoRecordTypeId : assetNDBEDPRecordTypeId;
                            Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Equipment__r.Vendor__c);	
                            if(mapOfCaseWithAuthorization.get(caseRecordId).containsKey(requestEquipmentRecord.Equipment__r.Vendor__c)){	
                                assetRecord.Authorization__c = getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,caseMap.get(caseRecordId).Vendor__c, recordTypeIdWithEquipmentNameMap);
                                if(assetRecord.Authorization__c != null){	
                                    listOfAssertToInsert.add(assetRecord);	
                                }	
                            }
                        } else if(requestEquipmentRecord.Equipment__r.Equipment_Type__c != NC_Constant.EQUIPMENT_TYPE_HEARING_AID){
                            Asset__c assetRecord = createAssetUtils(requestEquipmentRecord.Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetGenereicRecordTypeId,requestEquipmentRecord.Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Equipment__r.Vendor__c);	
                            if(mapOfCaseWithAuthorization.get(caseRecordId).containsKey(requestEquipmentRecord.Equipment__r.Vendor__c)){	
                                assetRecord.Authorization__c = getAuthorizationId(requestEquipmentRecord.Equipment__r.Equipment_Type__c, mapOfCaseWithAuthorization, caseRecordId,requestEquipmentRecord.Equipment__r.Vendor__c, recordTypeIdWithEquipmentNameMap);	
                                if(assetRecord.Authorization__c != null){	
                                    listOfAssertToInsert.add(assetRecord);	
                                }	
                            }	
                        }	
                        if(requestEquipmentRecord.Sub_Equipment__c != null){	
                            Asset__c assetRecordChild = createAssetUtils(requestEquipmentRecord.Sub_Equipment__c,requestEquipmentRecord.Request__r.ContactId,requestEquipmentRecord.Request__c,assetGenereicRecordTypeId,requestEquipmentRecord.Sub_Equipment__r.Amount_Authorized__c, requestEquipmentRecord.Sub_Equipment__r.Vendor__c);	
                            if(mapOfCaseWithAuthorization.get(caseRecordId).containsKey(requestEquipmentRecord.Sub_Equipment__r.Vendor__c)){	
                                assetRecordChild.Authorization__c = getAuthorizationId(NC_Constant.EQUIPMENT_TYPE_SUB_HEARING_AID, mapOfCaseWithAuthorization, caseRecordId,requestEquipmentRecord.Sub_Equipment__r.Vendor__c, recordTypeIdWithEquipmentNameMap);	
                                if(assetRecordChild.Authorization__c != null){	
                                    listOfAssertToInsert.add(assetRecordChild);	
                                }	
                            }	
                            
                        }	
                    }	
                }	
                
            }
            
            if(!listOfAssertToInsert.isEmpty()){
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Asset__c', listOfAssertToInsert, 'insert', true, 'NC_CaseTriggerHandler', 'createAsset');
                insert objectDecision.getRecords();
                listOfAssertToInsert = objectDecision.getRecords();
                //insert listOfAssertToInsert;
            }
            /*if(!noCostAuthList.isEmpty()){	
INSERT noCostAuthList;	
}*/
            if(!equipmentToAuthorizationMap.values().isEmpty()){	
                INSERT equipmentToAuthorizationMap.values();	
            }
            
            
            
            //For Sending Email To Owner For Asset Reassignment
            if(assetToNewCaseMap.size()>0){
                NC_SendBulkEmail.notifieOwnerForDifferentRegionalCenter(assetToNewCaseMap,assetToSendRecordList);  
            }
            
            for(Id equipmentId : equipmentToAuthorizationMap.keySet()){
                if(equipmentToAssetMap.containsKey(equipmentId)){
                    equipmentToAssetMap.get(equipmentId).Authorization__c = equipmentToAuthorizationMap.get(equipmentId).Id;
                }
            }
            if(!equipmentToAssetMap.values().isEmpty()){	
                INSERT equipmentToAssetMap.values();	
            }
            if(updateRequestEquipment.size() > 0) {
                //update updateRequestEquipment;
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Request_Equipment__c', updateRequestEquipment, 'update', true, 'NC_CaseTriggerHandler', 'createAsset');
                update objectDecision.getRecords();
                // List<Request_Equipment__c> reqEquipmentList = new List<Request_Equipment__c>();
                // for(Id reqEquipmentId: updateRequestEquipment) {
                //     Request_Equipment__c updateEquipment = new Request_Equipment__c();
                //     updateEquipment.id = reqEquipmentId;
                //     updateEquipment.Reassigned__c = true;
                //     reqEquipmentList.add(updateEquipment);
                // }
                // if(reqEquipmentList.size() > 0) {
                //     update reqEquipmentList;
                // }
            }
            if(!updateListOfAsset.isEmpty()){
                SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Asset__c', updateListOfAsset, 'update', true, 'NC_CaseTriggerHandler', 'createAsset');
                update objectDecision.getRecords();
                //update updateListOfAsset;
            }
            for(Authorization__c auth: [SELECT id, (SELECT id FROM Assets__r) FROM Authorization__c WHERE Request__c IN: caseMap.keySet() AND recordType.DeveloperName IN ('CAPTEL', 'EDS', 'Hearing_AID', 'Sub_Hearing_AID', 'Weather_Radio')]) {
                if(auth.Assets__r.size() == 0) {
                    setOfDeleteAuthID.add(auth.id);
                }
            }
            if(!setOfDeleteAuthID.isEmpty() && deleteNDBEDPAuthorization){	
                DELETE [SELECT Id FROM Authorization__c WHERE Id IN : setOfDeleteAuthID];	
            }
            
            for(Authorization__c authorizationRecord : [SELECT Id, Consumer__c, Preferred_Contact_Method__c from Authorization__c WHERE Id IN : listOfAuthorization AND Consumer__c != null AND Vendor__c != null AND (Preferred_Contact_Method__c =: NC_Constant.EMAIL_PPREFERRED_CONTACT OR Vendor__r.Preferred_Method_of_Contact__c =: NC_Constant.EMAIL_PPREFERRED_CONTACT) AND recordTypeId IN: edsAuthIds WITH SECURITY_ENFORCED]){
                setOfAuthorizationId.add(authorizationRecord.Id);
            }
            for(Authorization__c authRecord : listOfAuthorization){
                setOfAllAuthId.add(authRecord.Id);
            }
            
            NC_BudgetManagementController.validateBudgetAmount(setOfAllAuthId);
            NC_BudgetManagementController.updateBudgetAmount(setOfAllAuthId);
            NC_SendBulkEmail.createRequestLetter(setOfAllAuthId);
            if(!setOfAuthorizationId.isEmpty()){
                NC_SendBulkEmail.sendEmail(setOfAuthorizationId);
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : getAvailableForReassignmentAsset
@description    : Get list of all assets available for reassignment
@param          : Request_Equipment__c requestEquipmentRecord, Map<Id, Map<Id, Integer>> assetToEqpMap, Map<Id, Asset__c> assetMap
@return         : Map<String, Object>
********************************************************
*/
    public static Map<String, Object> getAvailableForReassignmentAsset(Request_Equipment__c requestEquipmentRecord, Map<Id, Map<Id, Integer>> assetToEqpMap, Map<Id, Asset__c> assetMap){
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Asset__c> assetList = new List<Asset__c>();
        Integer availableQty = 0;
        Integer requiredQuantity = String.isNotBlank(requestEquipmentRecord.Quantity__c) ? Integer.valueOf(requestEquipmentRecord.Quantity__c) : 1;
        
        for(Id assetId: assetToEqpMap.keySet()) {
            availableQty = 0;
            if(assetToEqpMap.get(assetId).containsKey(requestEquipmentRecord.Equipment__c)) {
                availableQty = assetToEqpMap.get(assetId).get(requestEquipmentRecord.Equipment__c);
            }
            if(availableQty >= requiredQuantity) {
                Asset__c assetRecord = new Asset__c();
                assetRecord.id = assetId;
                if(assetMap.containsKey(assetId)) {
                    assetRecord.Quantity__c = (availableQty - requiredQuantity) + '';
                    //assetRecord.Quantity__c = (Integer.valueOf(assetMap.get(assetId).Quantity__c) - availableQty) + '';
                    assetRecord.Reassigned_Quantity__c = assetMap.get(assetId).Reassigned_Quantity__c != null ? (assetMap.get(assetId).Reassigned_Quantity__c + requiredQuantity) : requiredQuantity;
                }
                if(availableQty == requiredQuantity) {
                    assetRecord.Available_for_Reassignment__c = false;	
                    assetRecord.Reassignment_Note__c = '';	
                    assetRecord.Status__c = 'Reassigned';
                }
                requiredQuantity = 0;// availableQty - requiredQuantity;
                assetList.add(assetRecord);
                break;
            }
            if(availableQty > 0 && availableQty < requiredQuantity) {
                Asset__c assetRecord = new Asset__c();
                assetRecord.id = assetId;
                if(assetMap.containsKey(assetId)) {
                    //assetRecord.Quantity__c = (requiredQuantity - availableQty) + '';
                    if(assetMap.get(assetId).Quantity__c == null) {
                        assetMap.get(assetId).Quantity__c = '1';
                    }
                    if(assetMap.get(assetId).Reassigned_Quantity__c == null) {
                        assetMap.get(assetId).Reassigned_Quantity__c = 0;
                    }
                    assetRecord.Quantity__c = (Integer.valueOf(assetMap.get(assetId).Quantity__c) - availableQty) + '';
                    assetRecord.Reassigned_Quantity__c = assetMap.get(assetId).Reassigned_Quantity__c + availableQty;
                    assetRecord.Available_for_Reassignment__c = false;	
                    assetRecord.Reassignment_Note__c = '';	
                    assetRecord.Status__c = 'Reassigned';
                    requiredQuantity = requiredQuantity - availableQty;
                    assetList.add(assetRecord);
                }
            }
        }        
        returnMap.put('assetList', assetList);
        returnMap.put('requiredQuantity', requiredQuantity);
        return returnMap;
    }
    
    /*
*********************************************************
@Method Name    : getAuthorizationId
@description    : To Get Authorization Filtered Id
@param          : String EquipmentType, Map<Id, Map<Id, List<Authorization__c>>> mapOfCaseWithAuthorization, Id caseRecordId, Id vendorId, Map<String, Id> recordTypeIdWithEquipmentNameMap
@return         : Id
********************************************************
*/
    public static Id getAuthorizationId(String EquipmentType, Map<Id, Map<Id, List<Authorization__c>>> mapOfCaseWithAuthorization, Id caseRecordId, Id vendorId, Map<String, Id> recordTypeIdWithEquipmentNameMap){
        for(Authorization__c auth : mapOfCaseWithAuthorization.get(caseRecordId).get(vendorId)){
            if(recordTypeIdWithEquipmentNameMap.containsKey(EquipmentType)){
                if(auth.RecordTypeId == recordTypeIdWithEquipmentNameMap.get(EquipmentType)){
                    return auth.Id;
                }
            } else {
                if(auth.RecordTypeId == recordTypeIdWithEquipmentNameMap.get(NC_Constant.AUTHORIZATION_RECORDTYPE_EDS_INVOICE)) {
                    return auth.Id;
                }
            }
        }
        return null;
    }
    
    /*
*********************************************************
@Method Name    : createAuthorization
@description    : To Create Authorzation In Auth Object
@param          : Id vendorId, Id ContactId, Id RequestID, String Status, Id RegionalCenterId, Id RecordTyepId, Boolean IsHearingAid, String ShipTo
@return         : Authorization__c
********************************************************
*/
    public static Authorization__c createAuthorization(Id vendorId, Id ContactId, Id RequestID, String Status, Id RegionalCenterId, Id RecordTyepId, Boolean IsHearingAid, String ShipTo){
        Authorization__c authorizationRecord = new Authorization__c();
        AuthorizationRecord.Vendor__c = vendorId;
        AuthorizationRecord.Consumer__c = ContactId;
        AuthorizationRecord.Request__c =RequestID;
        AuthorizationRecord.Status__c = Status;
        AuthorizationRecord.Regional_Center__c = RegionalCenterId;
        AuthorizationRecord.RecordTypeId = RecordTyepId;
        AuthorizationRecord.Contains_Hearing_Aid__c = IsHearingAid;
        if(ShipTo != null){
            AuthorizationRecord.Ship_To__c = ShipTo;
        }
        return authorizationRecord;
    }
    
    /*
*********************************************************
@Method Name    : createAssetUtils
@description    : To Create Authorzation In Auth Object
@param          : Id EquipmentId, Id ContactId, Id RequestId, Id RecordTypeId, Decimal AmountAuthorized, Id VendorId
@return         : Authorization__c
********************************************************
*/
    public static Asset__c createAssetUtils(Id EquipmentId, Id ContactId, Id RequestId, Id RecordTypeId, Decimal AmountAuthorized, Id VendorId){
        Asset__c assetRecord = new Asset__c();
        assetRecord.Equipment__c = EquipmentId;
        assetRecord.Contact__c = ContactId;
        assetRecord.Request__c = RequestId;
        assetRecord.RecordTypeId = RecordTypeId;
        assetRecord.Amount_Authorized__c = AmountAuthorized;
        assetRecord.Vendor__c = VendorId;
        return assetRecord;
    }
    
    /*
*********************************************************
@Method Name    : createNoCostAuthorizationUtils
@description    : Create No Cost Authorization for reassignment Assets
@param          : Id AuthId, Id VendorId, Id ConsumerId, Id RequestId
@return         : Authorization__c
********************************************************
*/
    public static Authorization__c createNoCostAuthorizationUtils(Id AuthId, Id VendorId, Id ConsumerId, Id RequestId){	
        Authorization__c noCostAuth = new Authorization__c();	
        noCostAuth.Vendor__c = VendorId;	
        noCostAuth.Consumer__c = ConsumerID;	
        noCostAuth.Parent_Authorization__c = AuthId;	
        noCostAuth.Request__c =RequestId;	
        noCostAuth.Status__c = NC_Constant.APPROVED;	
        noCostAuth.RecordTypeId = AuthorizationNoCostRecordType;	
        return noCostAuth;	
    }
    
    /*
*********************************************************
@Method Name    : validateRequiredDocumentsOfNDBEDP
@description    : Documents validation for NDBEDP request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateRequiredDocumentsOfNDBEDP(List<Case> caseList, Map<Id,Case> oldMap) {
        Set<Id> caseIds = new Set<Id>();
        for(Case selectedCase : caseList) {
            if(selectedCase.status== 'Documents Review' && selectedCase.recordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId()){
                caseIds.add(selectedCase.Id);
            }
        }
        
        if(caseIds.size()>0){
            for (Case obj : [SELECT Id,Residency_Requirement__c,Contact.Proof_Of_Residency_Uploaded__c,Contact.Proof_of_Income_Uploaded__c,Contact.Disability_Determination_form_Uploaded__c,Income_Requirement__c,Disability_Determination__c,Audio_Gram__c,Vision_Assessment__c,Contact.Proof_of_Income_Provided_By__c,
                             Contact.Proof_Of_Residency_Provided_By__c,Contact.OtherCity,Contact.OtherCountry,Contact.OtherPostalCode,Contact.OtherState,Contact.OtherStreet FROM Case WHERE Id IN :caseIds]){
                                 // if (!obj.Residency_Requirement__c || !obj.Income_Requirement__c||!obj.Disability_Determination__c||!obj.Audio_Gram__c||!obj.Vision_Assessment__c) {
                                 //     trigger.newmap.get(obj.id).addError('Please Upload all the documents');
                                 // }
                                 String docErrorMessage = '';
                                 if(!obj.Audio_Gram__c) {
                                     docErrorMessage = 'Audio Gram, ';        
                                 }
                                 if(!obj.Vision_Assessment__c) {
                                     docErrorMessage += 'Vision Assessment, ';
                                 }
                                 if(String.isNotBlank(docErrorMessage)) {
                                     trigger.newmap.get(obj.id).addError('Upload required documents on Request to proceed: ' + docErrorMessage.substring(0, docErrorMessage.length()-2));
                                 }
                                 
                                 String contactDocError = '';
                                 if(!obj.Contact.Proof_of_Income_Uploaded__c) {
                                     contactDocError = 'Proof of Income, ';
                                 }
                                 if(!obj.Contact.Proof_Of_Residency_Uploaded__c) {
                                     contactDocError += 'Proof of Residency, ';
                                 }
                                 if(!obj.Contact.Disability_Determination_form_Uploaded__c) {
                                     contactDocError += 'Disability Determination form, ';
                                 }
                                 String contactDocProvidedByError='';
                                 if(obj.Contact.Proof_of_Income_Provided_By__c == null) {
                                     contactDocProvidedByError = 'Proof of Income Provided By, ';
                                 }
                                 if(obj.Contact.Proof_Of_Residency_Provided_By__c == null) {
                                     contactDocProvidedByError += 'Proof of Residency Provided By, ';
                                 }
                                 if(String.isNotBlank(contactDocProvidedByError)) {
                                     trigger.newmap.get(obj.id).addError('Update required proof on Consumer to proceed: '+ contactDocProvidedByError.substring(0, contactDocProvidedByError.length()-2));              
                                 }
                                 if(String.isNotBlank(contactDocError)) {
                                     trigger.newmap.get(obj.id).addError('Upload required documents on Consumer to proceed: '+ contactDocError.substring(0, contactDocError.length()-2));
                                 }
                                 
                                 String physicalAddressError = '';
                                 if(obj.Contact.OtherCountry==null){
                                     physicalAddressError = 'Physical Country, ';   
                                 }
                                 if(obj.Contact.OtherStreet==null){
                                     physicalAddressError += 'Physical Street, ';   
                                 }
                                 if(obj.Contact.OtherCity==null){
                                     physicalAddressError += 'Physical City, ';   
                                 }
                                 if(obj.Contact.OtherState==null){
                                     physicalAddressError += 'Physical State/Province, ';   
                                 }
                                 if(obj.Contact.OtherPostalCode==null){
                                     physicalAddressError += 'Physical Zip/Postal Code, ';   
                                 }
                                 if(String.isNotBlank(physicalAddressError)) {
                                     trigger.newmap.get(obj.id).addError('Update address fields on Consumer to proceed: '+ physicalAddressError.substring(0, physicalAddressError.length()-2));
                                 }
                                 /*               
if (!obj.Audio_Gram__c||!obj.Vision_Assessment__c) {
trigger.newmap.get(obj.id).addError('Please Upload all the documents');
}
else if(!obj.Contact.Proof_of_Income_Uploaded__c || !obj.Contact.Proof_Of_Residency_Uploaded__c || !obj.Contact.Disability_Determination_form_Uploaded__c || obj.Contact.Proof_of_Income_Provided_By__c==null || obj.Contact.Proof_Of_Residency_Provided_By__c==null) {
trigger.newmap.get(obj.id).addError('Please Upload Proof of Income ,Proof of Residency ,Disability Determination documents and Proof of Income Provided By , Proof of Residency Provided By fields on related consumer');

}
else if(obj.Contact.OtherCity==null || obj.Contact.OtherCountry==null || obj.Contact.OtherPostalCode==null || obj.Contact.OtherState==null|| obj.Contact.OtherStreet==null ) {
trigger.newmap.get(obj.id).addError('Please complete the required fields on related consumer: Physical Address ');
}*/
                                 //  else if(!obj.Contact.Proof_Of_Residency_Uploaded__c){
                                 //     trigger.newmap.get(obj.id).addError('Please Upload Proof of Residency document on related consumer');
                                 //  }
                                 //  else if( !obj.Contact.Disability_Determination_form_Uploaded__c) {
                                 //     trigger.newmap.get(obj.id).addError('Please Upload Disability Determination document on related consumer');
                                 
                                 // }
                             }
        } 
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptance
@description    : Send email to Assessor for acceptance of invitation
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailForAssessorAcceptance(List<Case> caseList, Map<Id,Case> oldMap) {
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Id ndbedpFollowUpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        Id ndbedpAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
        Id ndbedpRepairRequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        List<Id> externalIdList = new List<Id>();
        List<Id> internalIdList = new List<Id>();
        List<Id> trainerIdList = new List<Id>();
        Map<Id,String> externalEmailMap = new Map<Id,String>();
        Map<Id,String> internalEmailMap = new Map<Id,String>();
        Map<Id,String> trainerEmailMap = new Map<Id,String>();
        for(Case caseValue:caseList){
            if(caseValue.External_Assessor__c!=null && caseValue.External_Assessor__c!= oldMap.get(caseValue.Id).External_Assessor__c  &&  ((caseValue.status=='Pending Assessor' && caseValue.recordTypeId == ndbedpRecordTypeId) ||(caseValue.status=='Submitted' && caseValue.recordTypeId == ndbedpFollowUpRecordTypeId) || (caseValue.status=='Pending Assessor' && caseValue.recordTypeId == ndbedpRepairRequestRecordTypeId) )){
                externalIdList.add(caseValue.External_Assessor__c);
            }
            if(caseValue.Internal_Assessor__c!=null && caseValue.Internal_Assessor__c!= oldMap.get(caseValue.Id).Internal_Assessor__c  && ((caseValue.status=='Pending Assessor' && caseValue.recordTypeId == ndbedpRecordTypeId) ||(caseValue.status=='Submitted' && caseValue.recordTypeId == ndbedpFollowUpRecordTypeId) || (caseValue.status=='Pending Assessor' && caseValue.recordTypeId == ndbedpRepairRequestRecordTypeId))){
                internalIdList.add(caseValue.Internal_Assessor__c);
            }
            if(caseValue.NDBEDP_Trainer__c!=null && caseValue.NDBEDP_Trainer__c!= oldMap.get(caseValue.Id).NDBEDP_Trainer__c  && caseValue.recordTypeId == ndbedpAdditionalTrainingRecordTypeId){
                trainerIdList.add(caseValue.NDBEDP_Trainer__c);
            }
        }
        
        if(internalIdList.size()>0){
            for(User use:[SELECT Id,Email FROM User WHERE Id IN: internalIdList AND IsActive=true]){
                internalEmailMap.put(use.Id,use.Email);
                
            }
        }
        if(externalIdList.size()>0){
            for(User userValue:[SELECT Id,Email,AccountId  FROM USER WHERE AccountId IN: externalIdList AND IsActive=true WITH SECURITY_ENFORCED]){
                externalEmailMap.put(userValue.AccountId,userValue.Email);
                
            }
        }
        if(trainerIdList.size()>0){
            for(User userValue:[SELECT Id,Email,AccountId  FROM USER WHERE AccountId IN: trainerIdList AND IsActive=true WITH SECURITY_ENFORCED]){
                trainerEmailMap.put(userValue.AccountId,userValue.Email);
                
            }
        }
        
        // User userPresent = [SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND IsActive=true  LIMIT 1];
        List<User> userPresent =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1];//WITH SECURITY_ENFORCED
        List<CaseShare> csShareList = new List<CaseShare>();
        // List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        // emailTemplateList = [SELECT Id,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName ='NC_AssessorAcceptance' ];
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<String> emailList = new List<String>();
        for(Case caseValue:[SELECT Id,RecordTypeId,External_Assessor__c,External_Assessor_User__r.Name,Internal_Assessor__c,NDBEDP_Trainer__c,CaseNumber,Contact.Name FROM CASE WHERE Id IN:caseList]){//WITH SECURITY_ENFORCED
            if( (caseValue.External_Assessor__c!=null &&  caseValue.External_Assessor__c!= oldMap.get(caseValue.Id).External_Assessor__c )  || (caseValue.Internal_Assessor__c!=null &&  caseValue.Internal_Assessor__c!= oldMap.get(caseValue.Id).Internal_Assessor__c && internalEmailMap.size()>0) || (caseValue.NDBEDP_Trainer__c!=null &&  caseValue.NDBEDP_Trainer__c!= oldMap.get(caseValue.Id).NDBEDP_Trainer__c) ){
                // String URLValue= 'https://'+domains[0].Domain +'/s/assessoracceptance?Id=' +caseValue.Id;
                String URLValue= 'https://'+domains[0].Domain +'/s/case/' +caseValue.Id +'/detail';
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseValue.Id;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                if(caseValue.Internal_Assessor__c!=null && caseValue.Internal_Assessor__c!= oldMap.get(caseValue.Id).Internal_Assessor__c ){
                    if(caseValue.RecordTypeId == ndbedpRecordTypeId){
                        String plainBody = emailTemplateNDBEDPEquipmentInvitation[0].Body;
                        String htmlBody = emailTemplateNDBEDPEquipmentInvitation[0].HtmlValue;
                        CaseShare csShare = new CaseShare();
                        csShare.CaseAccessLevel = 'Edit';
                        csShare.CaseId = caseValue.id;
                        csShare.UserOrGroupId = caseValue.Internal_Assessor__c;
                        csShareList.add( csShare );
                        emailList.add(internalEmailMap.get(caseValue.Internal_Assessor__c));
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                        plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                        plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                        htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                        htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        message.setHtmlBody(htmlBody);
                        message.setPlainTextBody(plainBody);   
                        message.setTemplateID(emailTemplateNDBEDPEquipmentInvitation[0].Id);  
                        message.setSubject('Assessor Invitation');    
                    }
                    if(caseValue.RecordTypeId == ndbedpFollowUpRecordTypeId){
                        String plainBody = emailTemplateNDBEDPFollowUpInvitation[0].Body;
                        String htmlBody = emailTemplateNDBEDPFollowUpInvitation[0].HtmlValue;
                        CaseShare csShare = new CaseShare();
                        csShare.CaseAccessLevel = 'edit';
                        csShare.CaseId = caseValue.id;
                        csShare.UserOrGroupId = caseValue.Internal_Assessor__c;
                        csShareList.add( csShare );
                        emailList.add(internalEmailMap.get(caseValue.Internal_Assessor__c));
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                        plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                        plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                        htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber);
                        htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        message.setHtmlBody(htmlBody);
                        message.setPlainTextBody(plainBody);    
                        message.setTemplateID(emailTemplateNDBEDPFollowUpInvitation[0].Id);  
                        message.setSubject('Assessor Invitation');     
                    }
                    if(caseValue.RecordTypeId == ndbedpRepairRequestRecordTypeId){
                        String plainBody = emailTemplateNDBEDPRepairRequestInvitation[0].Body;
                        String htmlBody = emailTemplateNDBEDPRepairRequestInvitation[0].HtmlValue;
                        CaseShare csShare = new CaseShare();
                        csShare.CaseAccessLevel = 'edit';
                        csShare.CaseId = caseValue.id;
                        csShare.UserOrGroupId = caseValue.Internal_Assessor__c;
                        csShareList.add( csShare );
                        emailList.add(internalEmailMap.get(caseValue.Internal_Assessor__c));
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                        plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                        plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                        htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber);
                        htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        message.setHtmlBody(htmlBody);
                        message.setPlainTextBody(plainBody);    
                        message.setTemplateID(emailTemplateNDBEDPRepairRequestInvitation[0].Id);  
                        message.setSubject('Assessor Invitation');     
                    }
                }
                if(caseValue.External_Assessor__c!=null && caseValue.External_Assessor__c!= oldMap.get(caseValue.Id).External_Assessor__c  ){
                    
                    if(caseValue.RecordTypeId == ndbedpRecordTypeId){
                        String plainBody = emailTemplateNDBEDPEquipmentInvitation[0].Body;
                        String htmlBody = emailTemplateNDBEDPEquipmentInvitation[0].HtmlValue;
                        if(externalEmailMap.size()==0){
                            
                            plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                            plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                            plainBody = plainBody.replace('{!Case.Contact}','' );
                            htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                            htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                            htmlBody = htmlBody.replace('{!Case.Contact}','');
                            htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                            if(userPresent.size()>0){
                                emailList.add(userPresent[0].Email);
                            }
                            CaseShare csShare = new CaseShare();
                            csShare.CaseAccessLevel = 'edit';
                            csShare.CaseId = caseValue.id;
                            if(userPresent.size()>0){
                                csShare.UserOrGroupId = userPresent[0].Id;
                            }
                            csShareList.add( csShare );
                            message.setHtmlBody(htmlBody);
                            message.setPlainTextBody(plainBody);   
                            message.setTemplateID(emailTemplateNDBEDPEquipmentInvitation[0].Id);  
                            message.setSubject('Assessor Invitation');     
                            
                        }else if(externalEmailMap.size()>0 || Test.isRunningTest()){
                            plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue );
                            plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                            plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                            htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                            htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                            htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                            htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                            emailList.add(externalEmailMap.get(caseValue.External_Assessor__c));
                            message.setHtmlBody(htmlBody);
                            message.setPlainTextBody(plainBody);    
                            message.setTemplateID(emailTemplateNDBEDPEquipmentInvitation[0].Id);  
                            message.setSubject('Assessor Invitation');    
                        }
                    }
                    
                    if(caseValue.RecordTypeId == ndbedpFollowUpRecordTypeId){
                        String plainBody = emailTemplateNDBEDPFollowUpInvitation[0].Body;
                        String htmlBody = emailTemplateNDBEDPFollowUpInvitation[0].HtmlValue;
                        if(externalEmailMap.size()==0){
                            plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                            plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                            plainBody = plainBody.replace('{!Case.Contact}','');
                            htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                            htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber ); 
                            htmlBody = htmlBody.replace('{!Case.Contact}','');
                            htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                            
                            CaseShare csShare = new CaseShare();
                            csShare.CaseAccessLevel = 'edit';
                            csShare.CaseId = caseValue.id;
                            if(userPresent.size()>0){
                                csShare.UserOrGroupId = userPresent[0].Id;
                            }
                            csShareList.add( csShare );
                            if(userPresent.size()>0){
                                emailList.add(userPresent[0].Email);
                            }
                            message.setHtmlBody(htmlBody);
                            // message.setPlainTextBody(plainBody);    
                            message.setTemplateID(emailTemplateNDBEDPFollowUpInvitation[0].Id);  
                            message.setSubject('Assessor Invitation');    
                            
                        }else if(externalEmailMap.size()>0|| Test.isRunningTest()){
                            plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue );
                            plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber  );
                            plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                            htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                            htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber ); 
                            htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                            htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                            emailList.add(externalEmailMap.get(caseValue.External_Assessor__c));
                            message.setHtmlBody(htmlBody);
                            // message.setPlainTextBody(plainBody);   
                            message.setTemplateID(emailTemplateNDBEDPFollowUpInvitation[0].Id);  
                            message.setSubject('Assessor Invitation');     
                        }
                    }
                    if(caseValue.RecordTypeId == ndbedpRepairRequestRecordTypeId){
                        String plainBody = emailTemplateNDBEDPRepairRequestInvitation[0].Body;
                        String htmlBody = emailTemplateNDBEDPRepairRequestInvitation[0].HtmlValue;
                        if(externalEmailMap.size()==0){
                            plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                            plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                            plainBody = plainBody.replace('{!Case.Contact}','');
                            htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                            htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber ); 
                            htmlBody = htmlBody.replace('{!Case.Contact}','');
                            htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                            CaseShare csShare = new CaseShare();
                            csShare.CaseAccessLevel = 'edit';
                            csShare.CaseId = caseValue.id;
                            if(userPresent.size()>0){
                                csShare.UserOrGroupId = userPresent[0].Id;
                            }
                            csShareList.add( csShare );
                            if(userPresent.size()>0){
                                emailList.add(userPresent[0].Email);
                            }
                            message.setHtmlBody(htmlBody);
                            message.setPlainTextBody(plainBody);    
                            message.setTemplateID(emailTemplateNDBEDPRepairRequestInvitation[0].Id);  
                            message.setSubject('Assessor Invitation');    
                            
                        }else if(externalEmailMap.size()>0 || Test.isRunningTest()){
                            plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue );
                            plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber  );
                            plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                            htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                            htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber ); 
                            htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                            htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                            emailList.add(externalEmailMap.get(caseValue.External_Assessor__c));
                            message.setHtmlBody(htmlBody);
                            message.setPlainTextBody(plainBody);   
                            message.setTemplateID(emailTemplateNDBEDPRepairRequestInvitation[0].Id);  
                            message.setSubject('Assessor Invitation');     
                        }
                    }
                    
                }
                
                
                if(caseValue.NDBEDP_Trainer__c!=null && caseValue.NDBEDP_Trainer__c!= oldMap.get(caseValue.Id).NDBEDP_Trainer__c && caseValue.RecordTypeId == ndbedpAdditionalTrainingRecordTypeId){
                    String plainBody = emailTemplateNDBEDPAdditionalTrainingInvitation[0].Body;
                    String htmlBody = emailTemplateNDBEDPAdditionalTrainingInvitation[0].HtmlValue;
                    if(trainerEmailMap.size()==0){
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                        plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber   );
                        plainBody = plainBody.replace('{!Case.Contact}','');
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                        htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber  ); 
                        htmlBody = htmlBody.replace('{!Case.Contact}','');
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        if(userPresent.size()>0){
                            emailList.add(userPresent[0].Email);
                        }
                        CaseShare csShare = new CaseShare();
                        csShare.CaseAccessLevel = 'edit';
                        csShare.CaseId = caseValue.id;
                        if(userPresent.size()>0){
                            csShare.UserOrGroupId = userPresent[0].Id;
                        }
                        csShareList.add( csShare );
                        message.setHtmlBody(htmlBody);
                        message.setPlainTextBody(plainBody);   
                        message.setTemplateID(emailTemplateNDBEDPAdditionalTrainingInvitation[0].Id);   
                        message.setSubject('Trainer Invitation');    
                    }
                    else if(trainerEmailMap.size()>0 || Test.isRunningTest()){
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue );
                        plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber   );
                        plainBody = plainBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                        htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber  );
                        htmlBody = htmlBody.replace('{!Case.Contact}',caseValue.External_Assessor_User__r.Name );
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        emailList.add(trainerEmailMap.get(caseValue.NDBEDP_Trainer__c));
                        message.setHtmlBody(htmlBody);
                        message.setPlainTextBody(plainBody);   
                        message.setTemplateID(emailTemplateNDBEDPAdditionalTrainingInvitation[0].Id);   
                        message.setSubject('Trainer Invitation');    
                    } 
                }
                
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                //  message.setSubject('Assessor Invitation'); 
                message.setTargetObjectId(caseValue.ContactId);  
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(false);
                messages.add(message);
            }
        }
        
        if(messages.size()>0 && emailList.size()>0){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        }
        
        if( csShareList != null && csShareList.size() != 0 ) {
            Map<Id, Id> caseOwnerMap = new Map<Id, Id>();
            for(Case caseObj:caseList){
                caseOwnerMap.put(caseObj.id, caseObj.OwnerId);
            }
            for(Integer i=0; i<csShareList.size(); i++) {
                if(caseOwnerMap.containsKey(csShareList[i].CaseId) && caseOwnerMap.get(csShareList[i].CaseId) == csShareList[i].UserOrGroupId) {
                    csShareList.remove(i);
                }
            }
            if(!csShareList.isEmpty()) {
                insert csShareList;   
            }
        }
        // }
        
    }
    
    /*
*********************************************************
@Method Name    : validateRolesDSSAndDBSS
@description    : Validate DSS and DBSS assessor for NDBEDP request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateRolesDSSAndDBSS(List<Case> caseList, Map<Id,Case> oldMap) {
        List<User>userPresentList = new List<User>();
        Set<String>regionalCenterList = new Set<String>();
        Map<Id,String> userPresentMap = new Map<Id,String>();
        List<String> userRoleList = new List<String>{'Deaf-Blind Services Specialist','Deaf Services Specialist'};
            for(User use: [SELECT Id,UserRole.Name,Regional_Center__c ,Name FROM User WHERE UserRole.Name IN :userRoleList AND Regional_Center__c!=null]){
                // userPresentList.add(use);
                // userPresentMap.put(use.Id,use.Regional_Center__c);
                if(use.UserRole.Name == 'Deaf-Blind Services Specialist'){
                    userPresentList.add(use);
                    regionalCenterList.add(use.Regional_Center__c);
                }
            }
        
        List<Id> userIdList = new List<Id>();
        
        for(Case caseValue:caseList){
            
            if(caseValue.Internal_Assessor__c!=null && oldMap.get(caseValue.Id).Internal_Assessor__c != caseValue.Internal_Assessor__c){
                if(userPresentList.size()>0 ){
                    Map<String,Set<String>> regionalCenterUserMap = new Map<String,Set<String>> ();
                    for(User use:userPresentList){
                        if(regionalCenterUserMap.containsKey(caseValue.Regional_Center_Assesser__c)){
                            regionalCenterUserMap.get(caseValue.Regional_Center_Assesser__c).add(use.Id);
                        }
                        else{
                            regionalCenterUserMap.put(caseValue.Regional_Center_Assesser__c,new Set<String>{use.Id});
                        }
                    }
                    
                    if(regionalCenterList.contains(caseValue.Regional_Center_Assesser__c)  && regionalCenterUserMap.size()>0 && ! regionalCenterUserMap.get(caseValue.Regional_Center_Assesser__c).contains(caseValue.Internal_Assessor__c)){
                        
                        caseValue.addError('Please Add the DBSS Role User.');
                    }
                }
            }
        }
        
    }
    
    /*
*********************************************************
@Method Name    : externalAssessorUser
@description    : set external user data
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void externalAssessorUser(List<Case> caseList, Map<Id,Case> oldMap) {
        Map<Id,Id> totalAccountMap = new Map<Id,Id>();
        Map<Id,Id> totalUserToContactMap = new Map<Id,Id>();
        Map<Id,Id> totalUserToContactAdditionalTrainingMap = new Map<Id,Id>();
        //User userPresent;
        List<User> userPresent = new List<User>();
        Boolean isSatisfied = false;
        for(Case caseValue:caseList){
            if((caseValue.External_Assessor__c!=null && caseValue.External_Assessor__c!= oldMap.get(caseValue.Id).External_Assessor__c) ||
               (caseValue.Internal_Assessor__c!=null && caseValue.Internal_Assessor__c!= oldMap.get(caseValue.Id).Internal_Assessor__c) ||
               (caseValue.NDBEDP_Trainer__c!=null && caseValue.NDBEDP_Trainer__c!= oldMap.get(caseValue.Id).NDBEDP_Trainer__c)){
                   isSatisfied = true;
               }
        }
        if(isSatisfied) {
            for(Account account:[SELECT Id, OwnerId,(SELECT Id FROM Contacts) FROM Account WHERE Active__c = true  AND Status__c = 'Approved' AND RecordType.Name = 'Assessor' WITH SECURITY_ENFORCED]){
                for(Contact con:account.Contacts){
                    totalAccountMap.put(account.Id,con.Id);
                }
            }
            for(Account account:[SELECT Id, OwnerId,(SELECT Id FROM Contacts) FROM Account WHERE Active__c = true  AND Status__c = 'Approved' AND RecordType.Name = 'NDBEDP Trainer'AND NCAS_Status__c = 'Y – record in NCAS' WITH SECURITY_ENFORCED]){
                for(Contact con:account.Contacts){
                    totalUserToContactAdditionalTrainingMap.put(account.Id,con.Id);
                }
            }
            for(User use:[SELECT Id,contactId,IsPortalEnabled FROM User WHERE IsPortalEnabled=true]){
                totalUserToContactMap.put(use.contactId,use.Id);
            }
            userPresent =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1];
        }
        List<Account> accountList = new List<Account>();
        List<Case> caseNewList = new List<Case>();
        for(Case caseValue:caseList){
            if(caseValue.External_Assessor__c!=null && caseValue.External_Assessor__c!= oldMap.get(caseValue.Id).External_Assessor__c  ){
                Case caseNewValue =new Case();
                caseNewValue.Id =caseValue.Id;
                if(totalUserToContactMap.get(totalAccountMap.get(caseValue.External_Assessor__c))==null){
                    if(userPresent.size()>0){
                        caseNewValue.External_Assessor_User__c=userPresent[0].Id;
                    }
                }
                else{
                    caseNewValue.External_Assessor_User__c=totalUserToContactMap.get(totalAccountMap.get(caseValue.External_Assessor__c));
                }
                caseNewValue.Assessor_Result__c=null;
                //caseNewValue.Assessor_Result__c=caseValue.recordTypeId == ndbedpRepairrequestId ? caseValue.Assessor_Result__c : null;
                caseNewList.add(caseNewValue);
            }
            if(caseValue.Internal_Assessor__c!=null && caseValue.Internal_Assessor__c!= oldMap.get(caseValue.Id).Internal_Assessor__c  ){
                Case caseNewValue =new Case();
                caseNewValue.Id =caseValue.Id;
                caseNewValue.External_Assessor_User__c=caseValue.Internal_Assessor__c;
                caseNewValue.Assessor_Result__c=null;
                //caseNewValue.Assessor_Result__c=caseValue.recordTypeId == ndbedpRepairrequestId ? caseValue.Assessor_Result__c : null;
                caseNewValue.showInternalAssessor__c=true;
                caseNewList.add(caseNewValue);
                
                // caseValue.Assessor_Result__c=null;
            }
            if(caseValue.NDBEDP_Trainer__c!=null && caseValue.NDBEDP_Trainer__c!= oldMap.get(caseValue.Id).NDBEDP_Trainer__c){
                Case caseNewValue =new Case();
                caseNewValue.Id =caseValue.Id;
                if(totalUserToContactMap.get(totalUserToContactAdditionalTrainingMap.get(caseValue.NDBEDP_Trainer__c))==null){
                    if(userPresent.size()>0){
                        caseNewValue.External_Assessor_User__c=userPresent[0].Id;
                    }
                }
                else{
                    caseNewValue.External_Assessor_User__c=totalUserToContactMap.get(totalUserToContactAdditionalTrainingMap.get(caseValue.NDBEDP_Trainer__c));
                }
                caseNewValue.Assessor_Result__c=null;
                //  caseNewValue.showInternalAssessor__c=true;
                caseNewList.add(caseNewValue);
                
            }
        }
        if(caseNewList.size()>0){
            update caseNewList;
        }
        
    }
    
    /*
*********************************************************
@Method Name    : deniedComments
@description    : validate comments before denied request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void deniedComments(List<Case> caseList, Map<Id,Case> oldMap) {
        for(Case caseValue:caseList){
            if(!caseValue.Income_more_than_400_percent__c){
                if(caseValue.Status == 'Denied' && caseValue.Comments__c==null &&  oldMap.get(caseValue.Id).Status =='Pending Assessor' ){
                    trigger.newmap.get(caseValue.id).addError('Please provide the comments to denied');
                }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : deniedTRPComments
@description    : validate TAPM comments before denied request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void deniedTRPComments(List<Case> caseList, Map<Id,Case> oldMap) {
        for(Case caseValue:caseList){
            if(!caseValue.Income_more_than_400_percent__c){
                if(!caseValue.Check_TRP_Reject__c && caseValue.Status == 'Denied' && caseValue.TRP_Manager_Comment__c==null &&  oldMap.get(caseValue.Id).Status =='Pending Disability Determination' ){
                    trigger.newmap.get(caseValue.id).addError('Please provide the TRP Manager/TAPM comments to denied');
                }
                if(!caseValue.Check_TRP_Reject__c && caseValue.Status == 'Denied' && caseValue.TRP_Manager_Comment__c==null &&  oldMap.get(caseValue.Id).Status =='Pending TRP Manager' ){
                    trigger.newmap.get(caseValue.id).addError('Please provide the TRP Manager/TAPM comments to denied');
                }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : deniedCommentsTRC
@description    : validate TRC comments before denied request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void deniedCommentsTRC(List<Case> caseList, Map<Id,Case> oldMap) {
        for(Case caseValue:caseList){
            if(caseValue.Status == 'Denied' && caseValue.TRC_Comment__c==null &&  oldMap.get(caseValue.Id).Status == 'Assessment Under Review'){
                trigger.newmap.get(caseValue.id).addError('Please provide the TRC Comments to reject');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : assessorAcceptance
@description    : NDBEDP Request assessor validations
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void assessorAcceptance(List<Case> caseList, Map<Id,Case> oldMap) {
        for(Case caseValue:caseList){
            if((caseValue.Internal_Assessor__c == null && caseValue.External_Assessor__c == null) && (caseValue.Status == 'Pending Assessment' || caseValue.Status == 'Pick-up is scheduled')){
                trigger.newmap.get(caseValue.id).addError('Please Provide the Assessor');
            }
            else{
                if((caseValue.Assessor_Result__c == null || caseValue.Assessor_Result__c == 'Reject') && (caseValue.Status == 'Pending Assessment' || caseValue.Status == 'Pick-up is scheduled')){
                    trigger.newmap.get(caseValue.id).addError('Please Accept the Invitation');
                }
            }
        }
        
    }
    
    /*
*********************************************************
@Method Name    : createCommunityAssessor
@description    : Create portal user for external assessor
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void createCommunityAssessor(List<Case> caseList , Map<Id,Case> oldMap){
        Map<Id,List<Contact>> accountToContact = new Map<Id,List<Contact>>();
        List<Id> accountIdList = new List<Id>();
        List<Contact> insertContactList = new List<Contact>();
        for(Case caseValue:caseList){
            if(caseValue.External_Assessor__c != null && oldMap.get(caseValue.Id).External_Assessor__c!= caseValue.External_Assessor__c){
                accountIdList.add(caseValue.External_Assessor__c);
            }else if(caseValue.NDBEDP_Trainer__c != null && oldMap.get(caseValue.Id).NDBEDP_Trainer__c!= caseValue.NDBEDP_Trainer__c){
                accountIdList.add(caseValue.NDBEDP_Trainer__c);
            }
        }
        if(accountIdList.size() > 0) {
            for(Account account:[SELECT Id,First_Name__c,Last_Name__c ,Email__c,Is_Vendor_on_Portal__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIdList AND Is_Vendor_on_Portal__c=true]){//WITH SECURITY_ENFORCED
                if(account.Contacts.size()==0 && String.isNotBlank(account.Last_Name__c)){
                    Contact con = new Contact();
                    con.AccountId = account.Id;
                    con.LastName = account.Last_Name__c;
                    con.FirstName = account.First_Name__c;
                    con.Hearing_Disability__c = 'Deaf';
                    con.Email =account.Email__c;
                    insertContactList.add(con);
                }
            }
            
            if(insertContactList.size()>0){
                insert insertContactList;
            }
            List<Id> contactstCommunityUser = new List<Id>();
            List<Contact> lContacts = [SELECT Id,AccountId FROM Contact WHERE AccountId IN :accountIdList WITH SECURITY_ENFORCED]; 
            for(User use :[SELECT Id,Contact.Id,Name,Email FROM User WHERE Profile.Name = 'NDBEDP Assessor' AND ContactId IN :lContacts]){//WITH SECURITY_ENFORCED
                contactstCommunityUser.add(use.Contact.Id);
            }
            
            //if(contactstCommunityUser)
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name='NDBEDP Assessor' Limit 1];
            List<User> InsertUserList = new List<User>();
            String sandboxName = UserInfo.getUserName().substringAfterLast('.');
            for(Contact con :[SELECT Id,AccountId,LastName,FirstName,Email FROM Contact WHERE AccountId IN :accountIdList WITH SECURITY_ENFORCED]){
                if(!contactstCommunityUser.contains(con.Id)){
                    User user1 = new User(
                        UserName = con.Email+'.dsdhh.'+sandboxName+Integer.valueOf(Math.random()*10000),
                        FirstName = con.FirstName,
                        LastName = con.LastName,
                        Alias = Integer.valueOf(Math.random()*10000)+'',
                        email = con.Email,
                        ContactId = con.Id,
                        ProfileId = portalProfile.Id,
                        EmailEncodingKey = 'UTF-8',
                        CommunityNickname =  con.FirstName+con.LastName+Integer.valueOf(Math.random()*100)+'',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US',
                        LanguageLocaleKey = 'en_US'
                    );
                    InsertUserList.add(user1);
                }
            }
            if(InsertUserList.size()>0){
                try {
                    if(Schema.SObjectType.User.isCreateable()) {
                        Insert InsertUserList;   
                    }
                }
                catch(DmlException e) {
                    throw new AuraHandledException('Error: '+e.getMessage());
                }
            }
        }    
    }
    
    /*
*********************************************************
@Method Name    : checkIncome
@description    : Denied request change validation
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkIncome(List<Case> caseList , Map<Id,Case> oldMap){
        for(Case caseValue:caseList){
            if(oldMap.get(caseValue.Id).Status == 'Denied'){
                trigger.newmap.get(caseValue.id).addError('You can not change the Request once its Denied.');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : validateRequestEquipment
@description    : Validate equipment for EDS request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateRequestEquipment(List<Case> caseList , Map<Id,Case> oldMap){
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Map<Id, Case> caseNewMap = new Map<Id, Case>();
        for(Case caseObj: caseList) {
            caseNewMap.put(caseObj.id, caseObj);
        }
        for(Case caseObj:[SELECT Id,(SELECT Id FROM Requests_Equipment__r) FROM Case WHERE Id IN :caseList]){//WITH SECURITY_ENFORCED
            if(oldMap.containsKey(caseObj.id) && caseNewMap.containsKey(caseObj.id) 
               && caseNewMap.get(caseObj.id).recordTypeId == ndbedpRecordTypeId
               && oldMap.get(caseObj.id).Status != caseNewMap.get(caseObj.id).Status 
               // && caseNewMap.get(caseObj.id).Status == 'Pending Condition of Acceptance'
               // && oldMap.get(caseObj.id).Status == 'Applicant Signature'
               && caseNewMap.get(caseObj.id).Status == 'Pending TRP Manager'
               && oldMap.get(caseObj.id).Status == 'Pending Condition of Acceptance'
               && caseObj.Requests_Equipment__r.size()==0){
                   trigger.newmap.get(caseObj.id).addError('Add an Equipment to proceed');
               }     
        }
    }
    
    /*
*********************************************************
@Method Name    : checkAssessment
@description    : Assessment required validation
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkAssessment(List<Case> caseList , Map<Id,Case> oldMap){
        for(Case caseValue:caseList){
            // if(!caseValue.CheckRejectAssessment__c){
            //if(!caseValue.AssessmentAccepted__c && ((oldMap.get(caseValue.Id).Status == 'Pending Assessment' &&  caseValue.status!='Denied') || oldMap.get(caseValue.Id).Status == 'Denied')){
            // if(!caseValue.Check_TRP_Reject__c &&!caseValue.AssessmentAccepted__c &&( oldMap.get(caseValue.Id).Status == 'Pending Assessment'&& !caseValue.CheckRejectAssessment__c && caseValue.Status!=oldMap.get(caseValue.Id).Status)) {
            if(!caseValue.AssessmentAccepted__c &&( oldMap.get(caseValue.Id).Status == 'Pending Assessment'&& !caseValue.CheckRejectAssessment__c && caseValue.Status!=oldMap.get(caseValue.Id).Status)) {
                trigger.newmap.get(caseValue.id).addError('Please Complete/Accept the Assessment.');
            }     
        }
    }
    
    /*
*********************************************************
@Method Name    : checkApplicantSignature
@description    : Applicant Signature required validation
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkApplicantSignature(List<Case> caseList , Map<Id,Case> oldMap){
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        for(Case caseValue:caseList){
            if(caseValue.recordTypeId == ndbedpRecordTypeId && caseValue.Status!=oldMap.get(caseValue.Id).Status && !caseValue.ApplicantSignatureAccepted__c &&  oldMap.get(caseValue.Id).Status == 'Applicant Signature' &&!caseValue.ApplicantSignatureRejected__c) {
                trigger.newmap.get(caseValue.id).addError('Please Complete/Accept the Applicants Signature.');
            }     
        }
    }
    
    /*
*********************************************************
@Method Name    : checkPendingConditionOfAcceptanceAccept
@description    : Pending condition of acceptance denied
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkPendingConditionOfAcceptanceAccept(List<Case> caseList , Map<Id,Case> oldMap){
        for(Case caseValue:caseList){
            if(  oldMap.get(caseValue.Id).Status == 'Denied' && caseValue.CheckRejectAssessment__c){
                trigger.newmap.get(caseValue.id).addError('Your Request is already Denied.');
            }     
        }
    }
    
    /*
*********************************************************
@Method Name    : checkPendingConditionOfAcceptance
@description    : Pending condition of acceptance required validation
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkPendingConditionOfAcceptance(List<Case> caseList , Map<Id,Case> oldMap){
        for(Case caseValue:caseList){
            if( caseValue.Condition_of_Acceptance_sign_Id__c==oldMap.get(caseValue.Id).Condition_of_Acceptance_sign_Id__c  && !caseValue.CheckRejectAssessment__c && oldMap.get(caseValue.Id).Status == 'Pending Condition of Acceptance' && oldMap.get(caseValue.Id).Status != caseValue.Status && caseValue.recordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId()){
                trigger.newmap.get(caseValue.id).addError('Please Complete the Pending Condition of Acceptance.');   
            }
        }     
    }
    // }
    
    /*
*********************************************************
@Method Name    : approvePendingConditionOfAcceptance
@description    : Pending condition of acceptance validation on NDBEDP request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void approvePendingConditionOfAcceptance(List<Case> caseList , Map<Id,Case> oldMap){
        for(Case caseValue:caseList){
            if((caseValue.status == 'Pending TRP Manager' && oldMap.get(caseValue.Id).status == 'Pending Condition of Acceptance' &&  oldMap.get(caseValue.Id).status!= caseValue.status) || (caseValue.status == 'Applicant Signature' && oldMap.get(caseValue.Id).status == 'Pending Assessment' &&  oldMap.get(caseValue.Id).status!= caseValue.status)){
                // if((oldMap.get(caseValue.Id).status == 'Assessment Under Review' &&  oldMap.get(caseValue.Id).status!= caseValue.status) || (caseValue.status == 'Assessment Under Review' && oldMap.get(caseValue.Id).status == 'Pending Assessment' &&  oldMap.get(caseValue.Id).status!= caseValue.status)){
                
                // Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                // req.setComments('Approving request using Trigger');
                // req.setAction('Approve');        
                // Id workItemId = getWorkItemId(caseValue.Id); 
                // if(workItemId == null){
                //     //caseValue.addError('Error Occured in Trigger');
                // }
                // else{
                //     req.setWorkitemId(workItemId);
                //     // Submit the request for approval
                //     Approval.ProcessResult result =  Approval.process(req);
                // }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : approveAdditionalRequirments
@description    : Approve additional training request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void approveAdditionalRequirments(List<Case> caseList , Map<Id,Case> oldMap){
        Id NDBEDPAdditionalRequirments = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();
        for(Case caseValue:caseList){
            if(caseValue.Assessor_Result__c == 'Accept' && caseValue.Assessor_Result__c!= oldMap.get(caseValue.Id).Assessor_Result__c && caseValue.RecordtypeId == NDBEDPAdditionalRequirments){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                // req.setComments('Submitting approval request using Trigger');        
                req.setObjectId(caseValue.Id);       
                Approval.ProcessResult result = Approval.process(req);    
            }
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
@Method Name    : restrictTheAssesserAtCreation
@description    : Assessor assignment at creation validation
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void restrictTheAssesserAtCreation(List<Case> caseList, Map<Id, Case> oldMap) {
        for(Case caseValue:caseList){
            if(caseValue.recordTypeId == ndbedpRequestId && (caseValue.External_Assessor__c!=null ||caseValue.Internal_Assessor__c!=null) && !Test.isRunningTest()){
                trigger.newmap.get(caseValue.id).addError('Assessor cannot be assigned at this status');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : restrictTheAssesser
@description    : Assessor assignment at status validation
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void restrictTheAssesser(List<Case> caseList, Map<Id, Case> oldMap) {
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        for(Case caseValue:caseList){
            if(((caseValue.External_Assessor__c!=null &&  oldMap.get(caseValue.Id).External_Assessor__c!= caseValue.External_Assessor__c)  ||(caseValue.Internal_Assessor__c!=null &&  oldMap.get(caseValue.Id).Internal_Assessor__c!= caseValue.Internal_Assessor__c) )  && oldMap.get(caseValue.Id).Status != 'Pending Assessor' && caseValue.recordTypeId== ndbedpRecordTypeId && !Test.isRunningTest()){
                trigger.newmap.get(caseValue.id).addError('Assessor cannot be assigned at this status');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : createAssessorAuthorization
@description    : create Authorization when assessment is started
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void createAssessorAuthorization(List<Case> caseList, Map<Id, Case> oldMap){
        List<Authorization__c> authList = new List<Authorization__c>();
        String existingAuthId;
        Map<String, String> requestAuthMap = new Map<String, String>();
        Id rtIDNDBEDP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Boolean isSatisfied = false;
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == rtIDNDBEDP && caseRecord.Status == 'Pending Assessment' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                isSatisfied = true;
            }
        }
        if(isSatisfied) {
            for(Authorization__c auth: [SELECT Request__c FROM Authorization__c WHERE Request__c IN: caseList AND recordTypeId =: AuthorizationAssessorRecordType]) {//WITH SECURITY_ENFORCED
                requestAuthMap.put(auth.Request__c, auth.id);
            }   
        }
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == rtIDNDBEDP && caseRecord.Status == 'Pending Assessment' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                existingAuthId = '';
                if(requestAuthMap.containsKey(caseRecord.id)) {
                    existingAuthId = requestAuthMap.get(caseRecord.id);
                }
                authList.add(createOrGetAuthorization(caseRecord, AuthorizationAssessorRecordType, existingAuthId));
            }
        }
        if(authList.size() > 0) {
            upsert authList;
            //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Authorization__c', authList, 'upsert', true,'NC_CaseTriggerHandler','createAssessorAuthorization');
            //upsert decision.getRecords();
            //authList = decision.getRecords();
            shareAuthorizations(authList);
        }
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPFollowAuthorization
@description    : create NDBEDP Follow up Authorization
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void createNDBEDPFollowAuthorization(List<Case> caseList, Map<Id, Case> oldMap){
        List<Authorization__c> authList = new List<Authorization__c>();
        String existingAuthId;
        Map<String, String> requestAuthMap = new Map<String, String>();
        Id NDBEDPFollowUp = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_up').getRecordTypeId();
        Boolean isSatisfied = false;
        for(Case caseRecord: caseList) {
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Assessor scheduled' && caseRecord.RecordtypeId == NDBEDPFollowUp) {
                isSatisfied = true;
            }
        }
        if(isSatisfied) {
            for(Authorization__c auth: [SELECT Request__c FROM Authorization__c WHERE Request__c IN: caseList AND recordTypeId =: AuthorizationNDBEDPFollowUpRecordType]) {//WITH SECURITY_ENFORCED
                requestAuthMap.put(auth.Request__c, auth.id);
            }   
        }
        for(Case caseRecord: caseList) {
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Assessor scheduled' && caseRecord.RecordtypeId == NDBEDPFollowUp) {
                existingAuthId = '';
                if(requestAuthMap.containsKey(caseRecord.id)) {
                    existingAuthId = requestAuthMap.get(caseRecord.id);
                }
                authList.add(createOrGetAuthorization(caseRecord, AuthorizationNDBEDPFollowUpRecordType, existingAuthId));
            }
        }
        if(authList.size() > 0) {
            upsert authList;
            //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Authorization__c', authList, 'upsert', true,'NC_CaseTriggerHandler','createNDBEDPFollowAuthorization');
            //upsert decision.getRecords();
            //authList = decision.getRecords();
        }
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPAdditionalTrainingAuthorization
@description    : create NDBEDP Additional training Authorization
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void createNDBEDPAdditionalTrainingAuthorization(List<Case> caseList, Map<Id, Case> oldMap){
        List<Authorization__c> authList = new List<Authorization__c>();
        String existingAuthId;
        Map<String, String> requestAuthMap = new Map<String, String>();
        Id NDBEDPAdditionalTraining = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();
        Boolean isSatisfied = false;
        for(Case caseRecord: caseList) {
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Trainer scheduled' && caseRecord.RecordtypeId == NDBEDPAdditionalTraining) {
                isSatisfied = true;
            }
        }
        if(isSatisfied) {
            for(Authorization__c auth: [SELECT Request__c FROM Authorization__c WHERE Request__c IN: caseList AND recordTypeId =: AuthorizationNDBEDPAdditionalTrainingRecordType]) {//WITH SECURITY_ENFORCED
                requestAuthMap.put(auth.Request__c, auth.id);
            }   
        }
        for(Case caseRecord: caseList) {
            if(oldMap.get(caseRecord.Id).Status != caseRecord.Status && caseRecord.Status == 'Trainer scheduled' && caseRecord.RecordtypeId == NDBEDPAdditionalTraining) {
                existingAuthId = '';
                if(requestAuthMap.containsKey(caseRecord.id)) {
                    existingAuthId = requestAuthMap.get(caseRecord.id);
                }
                authList.add(createOrGetAuthorization(caseRecord, AuthorizationNDBEDPAdditionalTrainingRecordType, existingAuthId));
            }
        }
        if(authList.size() > 0) {
            upsert authList;
            //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Authorization__c', authList, 'upsert', true,'NC_CaseTriggerHandler','createNDBEDPAdditionalTrainingAuthorization');
            //upsert decision.getRecords();
            //authList = decision.getRecords();
            shareAuthorizationsAndRequest(authList);
        }
    }
    
    /*
*********************************************************
@Method Name    : createAssessorTraingingInstallationAuthorization
@description    : create NDBEDP Assessor Training Installation Authorization
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void createAssessorTraingingInstallationAuthorization(List<Case> caseList, Map<Id, Case> oldMap){
        List<Authorization__c> authList = new List<Authorization__c>();
        String existingAuthId;
        Map<String, String> requestAuthMap = new Map<String, String>();
        Id rtIDNDBEDP = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId();
        Boolean isSatisfied = false;
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == rtIDNDBEDP && caseRecord.Status == 'Pending Equipment Order' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                isSatisfied = true;
            }
        }
        if(isSatisfied) {
            for(Authorization__c auth: [SELECT Request__c FROM Authorization__c WHERE Request__c IN: caseList AND recordTypeId =: AuthorizationAssessorTrainingInstRecordType]) {//WITH SECURITY_ENFORCED
                requestAuthMap.put(auth.Request__c, auth.id);
            }    
        }
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == rtIDNDBEDP && caseRecord.Status == 'Pending Equipment Order' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                existingAuthId = '';
                if(requestAuthMap.containsKey(caseRecord.id)) {
                    existingAuthId = requestAuthMap.get(caseRecord.id);
                }
                authList.add(createOrGetAuthorization(caseRecord, AuthorizationAssessorTrainingInstRecordType, existingAuthId));
            }
        }
        if(authList.size() > 0) {
            upsert authList;
            //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Authorization__c', authList, 'upsert', true,'NC_CaseTriggerHandler','createAssessorTraingingInstallationAuthorization');
            //upsert decision.getRecords();
            //authList = decision.getRecords();
            shareAuthorizations(authList);
        }
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPPickupAuthorization
@description    : create NDBEDP Pick up Authorization
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void createNDBEDPPickupAuthorization(List<Case> caseList, Map<Id, Case> oldMap){
        List<Authorization__c> authList = new List<Authorization__c>();
        String existingAuthId;
        Map<String, String> requestAuthMap = new Map<String, String>();
        Boolean isSatisfied = false;
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId && caseRecord.Status == 'Pick-up is scheduled' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                isSatisfied = true;
            }
        }
        if(isSatisfied) {
            for(Authorization__c auth: [SELECT Request__c FROM Authorization__c WHERE Request__c IN: caseList AND recordTypeId =: AuthorizationPickupRecordType]) {//WITH SECURITY_ENFORCED
                requestAuthMap.put(auth.Request__c, auth.id);
            }   
        }
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId && caseRecord.Status == 'Pick-up is scheduled' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                existingAuthId = '';
                if(requestAuthMap.containsKey(caseRecord.id)) {
                    existingAuthId = requestAuthMap.get(caseRecord.id);
                }
                authList.add(createOrGetAuthorization(caseRecord, AuthorizationPickupRecordType, existingAuthId));
            }
        }
        if(authList.size() > 0) {
            upsert authList;
            //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Authorization__c', authList, 'upsert', true,'NC_CaseTriggerHandler','createNDBEDPPickupAuthorization');
            //upsert decision.getRecords();
            //authList = decision.getRecords();
            shareAuthorizations(authList);
        }
    }
    
    /*
*********************************************************
@Method Name    : createNDBEDPDeliveyAuthorization
@description    : create NDBEDP Delivery Authorization
@param          : List<Case> caseList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void createNDBEDPDeliveyAuthorization(List<Case> caseList, Map<Id, Case> oldMap){
        List<Authorization__c> authList = new List<Authorization__c>();
        String existingAuthId;
        Map<String, String> requestAuthMap = new Map<String, String>();
        Boolean isSatisfied = false;
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId && caseRecord.Status == 'Delivered to Consumer' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                isSatisfied = true;
            }
        }
        if(isSatisfied) {
            for(Authorization__c auth: [SELECT Request__c FROM Authorization__c WHERE Request__c IN: caseList AND recordTypeId =: AuthorizationDeliveyRecordType]) {//WITH SECURITY_ENFORCED
                requestAuthMap.put(auth.Request__c, auth.id);
            }   
        }
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId && caseRecord.Status == 'Delivered to Consumer' && oldMap.get(caseRecord.id).Status != caseRecord.Status) {
                existingAuthId = '';
                if(requestAuthMap.containsKey(caseRecord.id)) {
                    existingAuthId = requestAuthMap.get(caseRecord.id);
                }
                authList.add(createOrGetAuthorization(caseRecord, AuthorizationDeliveyRecordType, existingAuthId));
            }
        }
        if(authList.size() > 0) {
            upsert authList;
            //SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Authorization__c', authList, 'upsert', true,'NC_CaseTriggerHandler','createNDBEDPDeliveyAuthorization');
            //upsert decision.getRecords();
            //authList = decision.getRecords();
        }
    }
    
    /*
*********************************************************
@Method Name    : shareAuthorizations
@description    : Share authorization records
@param          : List<Authorization__c> authList
@return         : void
********************************************************
*/
    public static void shareAuthorizations(List<Authorization__c> authList) {
        List<Authorization__Share> authShareList = new List<Authorization__Share>();
        for(Authorization__c auth: authList) {
            if(auth.Internal_Assessor__c != null) {
                Authorization__Share authShare = new Authorization__Share();
                authShare.ParentId = auth.id;
                authShare.UserOrGroupId = auth.Internal_Assessor__c;
                authShare.AccessLevel = 'Edit';
                authShare.RowCause = Schema.Authorization__Share.RowCause.Manual;
                authShareList.add(authShare);   
            }
        }
        if(authShareList.size() > 0) {
            insert authShareList;
        }
    }
    
    /*
*********************************************************
@Method Name    : shareAuthorizationsAndRequest
@description    : Share authorization and request records
@param          : List<Authorization__c> authList
@return         : void
********************************************************
*/
    public static void shareAuthorizationsAndRequest(List<Authorization__c> authList) {
        List<Authorization__Share> authShareList = new List<Authorization__Share>();
        List<CaseShare> caseShareList = new List<CaseShare>();
        for(Authorization__c auth: authList) {
            if(auth.Trainer_Administrator_User__c != null) {
                Authorization__Share authShare = new Authorization__Share();
                authShare.ParentId = auth.id;
                authShare.UserOrGroupId = auth.Trainer_Administrator_User__c;
                authShare.AccessLevel = 'Edit';
                authShare.RowCause = Schema.Authorization__Share.RowCause.Manual;
                authShareList.add(authShare);
                
                CaseShare caseShareObj = new CaseShare();
                caseShareObj.CaseAccessLevel = 'Edit';
                caseShareObj.CaseId = auth.Request__c;
                caseShareObj.RowCause = Schema.CaseShare.RowCause.Manual;
                caseShareObj.UserOrGroupId = auth.Trainer_Administrator_User__c;
                caseShareList.add(caseShareObj);
            }
        }
        if(authShareList.size() > 0) {
            insert authShareList;
        }
        if(caseShareList.size() > 0) {
            insert caseShareList;
        }
    }
    
    /*
*********************************************************
@Method Name    : createOrGetAuthorization
@description    : Create and set authorization data
@param          : Case caseRecord, String authRecordTypeId, String existingAuthId
@return         : Authorization__c
********************************************************
*/
    public static Authorization__c createOrGetAuthorization(Case caseRecord, String authRecordTypeId, String existingAuthId) {
        Authorization__c authRecord = new Authorization__c();
        if(String.isNotBlank(existingAuthId)) {
            authRecord.id = existingAuthId;
        }
        authRecord.recordTypeId = authRecordTypeId;
        authRecord.Request__c = caseRecord.id;
        authRecord.Consumer__c = caseRecord.ContactId;
        authRecord.Regional_Center__c = caseRecord.Regional_Center__c;
        authRecord.Status__c = 'Approved';
        if(caseRecord.External_Assessor__c != null) {
            authRecord.External_Assessor__c = caseRecord.External_Assessor__c;
        }
        if(caseRecord.Internal_Assessor__c != null) {
            authRecord.Internal_Assessor__c = caseRecord.Internal_Assessor__c;
        }
        authRecord.External_Assessor_User__c=caseRecord.External_Assessor_User__c;
        authRecord.Trainer_Administrator_User__c=caseRecord.External_Assessor_User__c;
        if(caseRecord.TRC_UserRole__c == 'NDBEDP_Coordinator' || caseRecord.TRC_UserRole__c == 'Deaf_Services_Specialist' || caseRecord.TRC_UserRole__c == 'Deaf_Blind_Services_Specialist'){
            authRecord.Authorization_Email_Link__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseRecord.Id;
        }
        else{
            authRecord.Authorization_Email_Link__c =  'https://'+domains[0].Domain +'/' +caseRecord.Id;
        }
        if(AuthorizationNDBEDPAdditionalTrainingRecordType==authRecordTypeId){
            authRecord.Vendor__c = caseRecord.NDBEDP_Trainer__c;
            authRecord.Trainer_Administrator_User__c = caseRecord.External_Assessor_User__c;
        }
        return authRecord;
    }
    
    /*
*********************************************************
@Method Name    : NDBEDPFollowUpSubmitForApproval
@description    : Submit NDBEDP follow up request for approval
@param          : List<Case> caseList , Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void NDBEDPFollowUpSubmitForApproval(List<Case> caseList , Map<Id,Case> oldMap){  
        Id NDBEDPFollowUp = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_up').getRecordTypeId();      
        for(Case caseValue :caseList){
            if(caseValue.Assessor_Result__c == 'Accept' && caseValue.Assessor_Result__c!= oldMap.get(caseValue.Id).Assessor_Result__c && caseValue.RecordtypeId == NDBEDPFollowUp){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                // req.setComments('Submitting approval request using Trigger');        
                req.setObjectId(caseValue.Id);       
                Approval.ProcessResult result = Approval.process(req);    
            }
        }     
        
    }
    
    /*
*********************************************************
@Method Name    : checkNDBEDPAdditionalTrainingInvoice
@description    : NDBEDP Additional training request validation
@param          : List<Case> caseList , Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkNDBEDPAdditionalTrainingInvoice(List<Case> caseList , Map<Id,Case> oldMap){  
        //Id NDBEDPFollowUp = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_up').getRecordTypeId();
        Id NDBEDPAdditionalTraining = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();
        Map<Id,Set<String>> caseToInvoiceMap = new Map<Id,Set<String>>();
        List<Case> caseLists = new List<Case>();
        Map<Id, Id> caseAssessorMap = new Map<Id, Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case caseValue :caseList){
            if(caseValue.recordTypeId == NDBEDPAdditionalTraining 
               && oldMap.get(caseValue.Id).Status != caseValue.Status
               && caseValue.Status == 'Closed') {
                   caseAssessorMap.put(caseValue.id, caseValue.NDBEDP_Trainer__c);
                   caseMap.put(caseValue.id, caseValue);
               }
            if(caseValue.Status == 'Closed' && oldMap.get(caseValue.Id).Status != caseValue.Status && (caseValue.RecordtypeId == NDBEDPAdditionalTraining)
               && caseValue.Trainer_Notes__c != null && caseValue.Consumer_Acknowledgment_Date__c != null && (caseValue.Signature_ID__c != null || caseValue.Service_Documentation__c)){
                   caseLists.add(caseValue);
               }
        }
        if(caseAssessorMap.size() > 0) {
            validateNdbedpServiceRequest(caseMap, caseAssessorMap, true);
        }
        
        if(caseLists.size() > 0) {
            for(Authorization__c authValue :[SELECT Id,Request__c ,(SELECT Id,Status__c FROM Invoices__r) FROM Authorization__c WHERE Request__c IN: caseLists WITH SECURITY_ENFORCED]){
                for(Invoice__c invoiceValue:authValue.Invoices__r){
                    if(invoiceValue.Status__c == 'Approved' || invoiceValue.Status__c == 'Paid'){
                        //  if(invoiceValue.Status__c == 'Ready For Payment'){
                        
                        if(caseToInvoiceMap.containsKey(authValue.Request__c)){
                            caseToInvoiceMap.get(authValue.Request__c).add(invoiceValue.Status__c);
                        }
                        else{
                            caseToInvoiceMap.put(authValue.Request__c,new Set<String>{invoiceValue.Status__c});
                        }
                        
                    }
                }
            }
            for(Case caseValue :caseList){
                if(caseValue.Status == 'Closed' && oldMap.get(caseValue.Id).Status != caseValue.Status && (caseValue.RecordtypeId == NDBEDPAdditionalTraining)){
                    if(!(caseToInvoiceMap.size()>0)){
                        trigger.newmap.get(caseValue.id).addError('Please Approve/Paid the Invoice');
                        // trigger.newmap.get(caseValue.id).addError('Invoice needs to be Ready for Payment');
                    }
                    else{
                        if(!(caseToInvoiceMap.get(caseValue.id).size()>0)){
                            trigger.newmap.get(caseValue.id).addError('Please Approve/Paid the Invoice');
                            // trigger.newmap.get(caseValue.id).addError('Invoice needs to be Ready for Payment');
                            
                        }
                        
                    }
                }
            }   
        }
    }
    
    /*
*********************************************************
@Method Name    : checkNDBEDPFollowUpInvoice
@description    : NDBEDP follow up request validation
@param          : List<Case> caseList , Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void checkNDBEDPFollowUpInvoice(List<Case> caseList , Map<Id,Case> oldMap){  
        Id NDBEDPFollowUp = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_up').getRecordTypeId();
        Id NDBEDPAdditionalTraining = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();
        Map<Id,Set<String>> caseToInvoiceMap = new Map<Id,Set<String>>();
        List<Case> caseLists = new List<Case>();
        Map<Id, Id> caseAssessorMap = new Map<Id, Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        for(Case caseValue :caseList){
            if(caseValue.recordTypeId == NDBEDPFollowUp 
               && oldMap.get(caseValue.Id).Status != caseValue.Status
               && caseValue.Status == 'Closed') {
                   caseAssessorMap.put(caseValue.id, caseValue.External_Assessor__c);
                   caseMap.put(caseValue.id, caseValue);
               }
            if(caseValue.Status == 'Closed' && oldMap.get(caseValue.Id).Status != caseValue.Status && (caseValue.RecordtypeId == NDBEDPFollowUp)
               && caseValue.Assessor_Notes__c != null && caseValue.Consumer_Acknowledgment_Date__c != null && (caseValue.Signature_ID__c != null || caseValue.Service_Documentation__c)){
                   caseLists.add(caseValue);
               }
        }
        if(caseAssessorMap.size() > 0) {
            validateNdbedpServiceRequest(caseMap, caseAssessorMap, false);
        }
        if(caseLists.size() > 0) {
            for(Authorization__c authValue :[SELECT Id,Request__c ,(SELECT Id,Status__c FROM Invoices__r) FROM Authorization__c WHERE Request__c IN: caseLists WITH SECURITY_ENFORCED]){
                for(Invoice__c invoiceValue:authValue.Invoices__r){
                    //if(invoiceValue.Status__c == 'Approved'){
                    if(invoiceValue.Status__c == 'Ready For Payment' || invoiceValue.Status__c == 'Paid'){
                        
                        if(caseToInvoiceMap.containsKey(authValue.Request__c)){
                            caseToInvoiceMap.get(authValue.Request__c).add(invoiceValue.Status__c);
                        }
                        else{
                            caseToInvoiceMap.put(authValue.Request__c,new Set<String>{invoiceValue.Status__c});
                        }
                        
                    }
                }
            }
            for(Case caseValue :caseList){
                if(caseValue.Status == 'Closed' && oldMap.get(caseValue.Id).Status != caseValue.Status && (caseValue.RecordtypeId == NDBEDPFollowUp)){
                    if(!(caseToInvoiceMap.size()>0)){
                        //trigger.newmap.get(caseValue.id).addError('Please approve the Invoice');
                        trigger.newmap.get(caseValue.id).addError('Invoice needs to be Ready for Payment or Paid');
                    }
                    else{
                        if(!(caseToInvoiceMap.get(caseValue.id).size()>0)){
                            //  trigger.newmap.get(caseValue.id).addError('Please approve the Invoice');
                            trigger.newmap.get(caseValue.id).addError('Invoice needs to be Ready for Payment or Paid');
                            
                        }
                        
                    }
                }
            }   
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptance
@description    : Send email for invitation to assessor
@param          : List<Case> caseList , Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailForInvitationForAssessorAfterAcceptance(List<Case> caseList, Map<Id,Case> oldMap) {
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        Id ndbedpFollowUpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        Id ndbedpAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
        Id ndbedpRepairRequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Repair_Request');
        List<User> userPresent =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1];
        //  User userValue =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' LIMIT 1];
        List<Id> ndbedpAcceptList = new List<Id>();
        List<Id> ndbedpRejectList = new List<Id>();
        List<Id> followUpAcceptList = new List<Id>();
        List<Id> followUpRejectList = new List<Id>();
        List<Id> additionalTrainingAcceptList = new List<Id>();
        List<Id> additionalTrainingRejectList = new List<Id>();
        List<Id> RepairRequestAcceptList = new List<Id>();
        List<Id> RepairRequestRejectList = new List<Id>();
        Map<Id,String> externalEmailMap = new Map<Id,String>();
        Map<Id,String> internalEmailMap = new Map<Id,String>();
        Map<Id,String> trainerEmailMap = new Map<Id,String>();
        for(Case caseValue:caseList){
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Accept' && caseValue.RecordtypeId == ndbedpRecordTypeId){
                ndbedpAcceptList.add(caseValue.Id);
                // caseValue.Assessor_Invitation_Accepted_Date__c = Date.today();
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Reject' && caseValue.RecordtypeId == ndbedpRecordTypeId){
                ndbedpRejectList.add(caseValue.Id);
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Accept' && caseValue.RecordtypeId == ndbedpFollowUpRecordTypeId){
                followUpAcceptList.add(caseValue.Id);
                // caseValue.Assessor_Invitation_Accepted_Date__c = Date.today();
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Reject' && caseValue.RecordtypeId == ndbedpFollowUpRecordTypeId){
                followUpRejectList.add(caseValue.Id);
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Accept' && caseValue.RecordtypeId == ndbedpAdditionalTrainingRecordTypeId){
                additionalTrainingAcceptList.add(caseValue.Id);
                //caseValue.Assessor_Invitation_Accepted_Date__c = Date.today();
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Reject' && caseValue.RecordtypeId == ndbedpAdditionalTrainingRecordTypeId){
                additionalTrainingRejectList.add(caseValue.Id);
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Accept' && caseValue.RecordtypeId == ndbedpRepairRequestRecordTypeId){
                RepairRequestAcceptList.add(caseValue.Id);
                // caseValue.Assessor_Invitation_Accepted_Date__c = Date.today();
            }
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Reject' && caseValue.RecordtypeId == ndbedpRepairRequestRecordTypeId){
                RepairRequestRejectList.add(caseValue.Id);
            }
        }
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        
        for(Case caseValue :[SELECT Id,CaseNumber,External_Assessor_User__r.Name,Assessor_Result__c FROM Case WHERE Id IN :caseList AND Assessor_Result__c!=null]){//WITH SECURITY_ENFORCED
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c ){
                List<String> emailList = new List<String>();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                if(ndbedpAcceptList.size()>0){
                    String plainBody = emailTemplateNDBEDPEquipmentInvitationAccept[0].Body;
                    String htmlBody = emailTemplateNDBEDPEquipmentInvitationAccept[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPEquipmentInvitationAccept[0].Id);  
                    message.setSubject('Invitation Accepted'); 
                }
                else if(ndbedpRejectList.size()>0){
                    String plainBody = emailTemplateNDBEDPEquipmentInvitationReject[0].Body;
                    String htmlBody = emailTemplateNDBEDPEquipmentInvitationReject[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPEquipmentInvitationReject[0].Id);
                    message.setSubject('Invitation Rejected');   
                }
                else if(followUpAcceptList.size()>0){
                    String plainBody = emailTemplateNDBEDPFollowUpInvitationAccept[0].Body;
                    String htmlBody = emailTemplateNDBEDPFollowUpInvitationAccept[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPFollowUpInvitationAccept[0].Id); 
                    message.setSubject('Invitation Accepted');  
                }
                else if(followUpRejectList.size()>0){
                    String plainBody = emailTemplateNDBEDPFollowUpInvitationReject[0].Body;
                    String htmlBody = emailTemplateNDBEDPFollowUpInvitationReject[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPFollowUpInvitationReject[0].Id);  
                    message.setSubject('Invitation Rejected');  
                }
                else if(additionalTrainingAcceptList.size()>0){
                    String plainBody = emailTemplateNDBEDPAdditionalTrainingInvitationAccept[0].Body;
                    String htmlBody = emailTemplateNDBEDPAdditionalTrainingInvitationAccept[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPAdditionalTrainingInvitationAccept[0].Id); 
                    message.setSubject('Invitation Accepted');  
                }
                else if(additionalTrainingRejectList.size()>0){
                    String plainBody = emailTemplateNDBEDPAdditionalTrainingInvitationReject[0].Body;
                    String htmlBody = emailTemplateNDBEDPAdditionalTrainingInvitationReject[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPAdditionalTrainingInvitationReject[0].Id);  
                    message.setSubject('Invitation Rejected');  
                }
                else if(RepairRequestAcceptList.size()>0){
                    String plainBody = emailTemplateNDBEDPRepairRequestInvitationAccept[0].Body;
                    String htmlBody = emailTemplateNDBEDPRepairRequestInvitationAccept[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPRepairRequestInvitationAccept[0].Id); 
                    message.setSubject('Invitation Accepted');  
                }
                else if(RepairRequestRejectList.size()>0){
                    String plainBody = emailTemplateNDBEDPRepairRequestInvitationReject[0].Body;
                    String htmlBody = emailTemplateNDBEDPRepairRequestInvitationReject[0].HtmlValue;
                    if(!Test.isRunningTest()) {
                        plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name);
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                    if(!Test.isRunningTest()) {
                        htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',caseValue.External_Assessor_User__r.Name); 
                    }
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPRepairRequestInvitationReject[0].Id);  
                    message.setSubject('Invitation Rejected');  
                }
                if(userPresent.size()>0){
                    emailList.add(userPresent[0].Email);
                    message.setToAddresses(emailList);
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(false);  
                    messages.add(message);
                }
            }
        }
        if(messages.size()>0){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        }
        
        
        
    }  
    
    /*
*********************************************************
@Method Name    : updateNDBEDPFollowUpFieldsOnRejection
@description    : Set data for NDBEDP follow up request fields
@param          : List<Case> caseList , Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void updateNDBEDPFollowUpFieldsOnRejection(List<Case> caseList, Map<Id,Case> oldMap) {
        for(Case caseValue :caseList ){
            if(caseValue.NDBEDP_FollowUp_Rejection__c && oldMap.get(caseValue.Id).NDBEDP_FollowUp_Rejection__c!= caseValue.NDBEDP_FollowUp_Rejection__c ){
                caseValue.External_Assessor__c= '';
                caseValue.External_Assessor_User__c= '';
                caseValue.Internal_Assessor__c= '';
                caseValue.Assessor_Result__c= '';
                caseValue.Status= '	Submitted';
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : submitNDBEDPRepairRequestForApproval
@description    : submit NDBEDP Repair Request for Approval
@param          : List<Case> caseList
@return         : void
********************************************************
*/
    public static void submitNDBEDPRepairRequestForApproval(List<Case> caseList) {
        Set<Id> sendForApprovalIds = new Set<Id>();
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId
               && caseRecord.Status == 'Submitted') {
                   sendForApprovalIds.add(caseRecord.id);
               }
        }
        if(sendForApprovalIds.size() > 0) {
            submitForApproval(sendForApprovalIds);
        }
    }
    
    /*
*********************************************************
@Method Name    : submitForApproval
@description    : submit record for approval
@param          : Set<Id> recordIds
@return         : void
********************************************************
*/
    public static void submitForApproval(Set<Id> recordIds) {
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(Id recordId: recordIds){   
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('');
            req.setObjectId(recordId);      
            processList.add(req);
        }
        Approval.process(processList);
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPRepairRequest
@description    : NDBEDP Repair request updation
@param          : List<Case> caseList
@return         : void
********************************************************
*/
    public static void updateNDBEDPRepairRequest(List<Case> caseList) {
        List<Case> updateCaseList = new List<Case>();
        List<Case> selectedCaseList = new List<Case>();
        Boolean isUpadteRequired = false;
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId
               && caseRecord.Status == 'Submitted') {
                   isUpadteRequired = true;
                   selectedCaseList.add(caseRecord);
               }
        }
        Map<Id, Id> assessorUserMap = new Map<Id, Id>();
        if(isUpadteRequired) {
            for(User userRecord: [SELECT id, AccountId FROM User WHERE Profile.Name = 'NDBEDP Assessor']) {
                assessorUserMap.put(userRecord.id, userRecord.AccountId);
            }
        }
        for(Case caseRecord: selectedCaseList) {
            if(assessorUserMap.containsKey(caseRecord.CreatedById)) {//if(caseRecord.CreatedBy.Profile.Name == 'NDBEDP Assessor') {
                Case newCase = new Case();
                newCase.id = caseRecord.id;
                newCase.Status = 'Pending NDBEDP Coordinator';
                newCase.External_Assessor__c = assessorUserMap.get(caseRecord.CreatedById);
                newCase.Assessor_Result__c = 'Accept';
                updateCaseList.add(newCase);
            } else {
                Case newCase = new Case();
                newCase.id = caseRecord.id;
                newCase.Status = 'Pending Assessor';
                updateCaseList.add(newCase);
            }
        }
        if(caseList.size() > 0) {
            //update updateCaseList;
            SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Case', updateCaseList, 'update', true,'NC_CaseTriggerHandler','updateNDBEDPRepairRequest');
            update decision.getRecords();
        }
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPRepairRequest
@description    : Validate NDBEDP Repair request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateNDBEDPRepairRequest(List<Case> caseList, Map<Id,Case> oldMap) {
        List<Id> caseIds = new List<Id>();
        Map<Id, Id> caseAssessorMap = new Map<Id, Id>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Id> requestIds = new List<Id>();
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId 
               && oldMap.get(caseRecord.id).Status != caseRecord.Status
               && caseRecord.Approve_or_Reject__c == false && !Test.isRunningTest()) {
                   requestIds.add(caseRecord.id);
               }
            if(caseRecord.recordTypeId == ndbedpRepairrequestId
               && oldMap.get(caseRecord.id).Status != caseRecord.Status
               && caseRecord.Approve_or_Reject__c == true) {
                   caseRecord.Approve_or_Reject__c = false;
               }
            if(caseRecord.recordTypeId == ndbedpRepairrequestId 
               && oldMap.get(caseRecord.id).Status == 'Pick-up is scheduled'
               && caseRecord.Status == 'Shipped to Repair Center'
               && caseRecord.Equipment_Shipped_Date__c == null 
               && !Test.isRunningTest()) {
                   caseRecord.addError('Equipment Shipped Date is required before approval');
               }
            
            if(caseRecord.recordTypeId == ndbedpRepairrequestId 
               && oldMap.get(caseRecord.id).Status == 'Shipped to Repair Center'
               && caseRecord.Status == 'Received from Repair Center'
               && caseRecord.Equipment_Received_Date__c == null 
               && !Test.isRunningTest()) {
                   caseRecord.addError('Equipment Received Date is required before approval');
               }
            
            if(caseRecord.recordTypeId == ndbedpRepairrequestId 
               && oldMap.get(caseRecord.id).Status == 'Received from Repair Center'
               && caseRecord.Status == 'Delivered to Consumer'
               && caseRecord.Equipment_Delivered_Date__c == null 
               && !Test.isRunningTest()) {
                   caseRecord.addError('Equipment Delivered Date is required before approval');
               }
            
            if(caseRecord.recordTypeId == ndbedpRepairrequestId 
               && oldMap.get(caseRecord.id).Status == 'Delivered to Consumer'
               && caseRecord.Status == 'Closed' ) {
                   caseAssessorMap.put(caseRecord.id, caseRecord.External_Assessor__c);
                   caseMap.put(caseRecord.id, caseRecord);
               }
            
            if(caseRecord.recordTypeId == ndbedpRepairrequestId
               && caseRecord.Status == 'Closed'
               && caseRecord.Assessor_Notes__c != null
               && caseRecord.Consumer_Acknowledgment_Date__c != null
               && (caseRecord.Signature_ID__c != null || caseRecord.Service_Documentation__c) 
              ) {
                  caseIds.add(caseRecord.id);
              }
        }
        if(requestIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:requestIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(requestIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
        if(caseAssessorMap.size() > 0) {
            validateNdbedpServiceRequest(caseMap, caseAssessorMap, false);
        }
        if(caseIds.size() > 0) {
            Id pickUpTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_PICK_UP);
            Id deliveryTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_DELIVERY);
            Map<String, Map<String, Boolean>> requestErrorMap = new Map<String, Map<String, Boolean>>();
            Set<String> invStatusSet = new Set<String>{'Approved', 'Paid', 'Ready For Payment'};
                for(Authorization__c authRecord: [SELECT Request__c, (SELECT name, Status__c, recordTypeId FROM Invoices__r) FROM Authorization__c WHERE Request__c IN: caseIds AND (recordTypeId =: AuthorizationPickupRecordType OR recordTypeId =: AuthorizationDeliveyRecordType) WITH SECURITY_ENFORCED]) {
                    if(!requestErrorMap.containsKey(authRecord.Request__c)) {
                        requestErrorMap.put(authRecord.Request__c, new Map<String, Boolean>());
                        requestErrorMap.get(authRecord.Request__c).put('pickUpApproved', false);
                        requestErrorMap.get(authRecord.Request__c).put('deliveryApproved', false);
                    }
                    
                    if(authRecord.Invoices__r != null && authRecord.Invoices__r.size() > 0) {
                        for(Invoice__c invRecord: authRecord.Invoices__r) {
                            if(invRecord.recordTypeId == pickUpTypeId && invStatusSet.contains(invRecord.Status__c)) {
                                requestErrorMap.get(authRecord.Request__c).put('pickUpApproved', true);
                            }
                            if(invRecord.recordTypeId == deliveryTypeId && invStatusSet.contains(invRecord.Status__c)) {
                                requestErrorMap.get(authRecord.Request__c).put('deliveryApproved', true);
                            }
                        }
                    }
                }
            for(String requestId: requestErrorMap.keySet()) {
                if(!requestErrorMap.get(requestId).get('pickUpApproved')) {
                    Trigger.newmap.get(requestId).addError('NDBEDP Pick up Invoice should be Approved/Ready For Payment before approval');
                }
                if(!requestErrorMap.get(requestId).get('deliveryApproved')) {
                    Trigger.newmap.get(requestId).addError('NDBEDP Delivery Invoice should be Approved/Ready For Payment before approval');
                }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : acceptNDBEDPRepairRequest
@description    : accept NDBEDP Repair request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void acceptNDBEDPRepairRequest(List<Case> caseList, Map<Id,Case> oldMap) {
        List<Id> caseIds = new List<Id>();
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpRepairrequestId
               && (caseRecord.Status == 'Pending NDBEDP Coordinator' || caseRecord.Status == 'Pending Assessor')
               && caseRecord.Assessor_Result__c == 'Accept'
               && oldMap.get(caseRecord.id).Assessor_Result__c != caseRecord.Assessor_Result__c) {
                   caseIds.add(caseRecord.id);
               }
        }
        //approveCaseRecords(caseIds);
    }
    
    /*
*********************************************************
@Method Name    : approveCaseRecords
@description    : Approve case records
@param          : List<Id> caseIds
@return         : void
********************************************************
*/
    public static void approveCaseRecords(List<Id> caseIds) {
        if(caseIds.size() > 0) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: caseIds];
            List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
            for(ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkitemId(workItem.Id);
                req.setAction('Approve');
                req.setComments('');
                requests.add(req);
            }
            if(requests.size() > 0) {
                Approval.ProcessResult[] processResults = Approval.process(requests);
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPDemo
@description    : validate NDBEDP Demo request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateNDBEDPDemo(List<Case> caseList, Map<Id,Case> oldMap) {
        Set<Id> caseIds = new set<Id>();
        List<User> userList = new List<User>();
        Boolean searchUser = false;
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpDemoTypeId
               && caseRecord.Status == 'Pending NDBEDP Coordinator'
               && oldMap.get(caseRecord.id).Status == 'Submitted') {
                   caseRecord.NDBEDP_Coordinator_Comment__c = null;
                   caseIds.add(caseRecord.id);
               }
            if(caseRecord.recordTypeId == ndbedpDemoTypeId
               && caseRecord.Status == 'Pending TRC'
               && oldMap.get(caseRecord.id).Status == 'Pending NDBEDP Coordinator') {
                   searchUser = true;
               }
        }
        if(caseIds.size() > 0) {
            Set<Id> equipmentReqIds = new Set<Id>();
            for(Request_Equipment__c reqEqp: [SELECT Request__c FROM Request_Equipment__c WHERE Request__c IN: caseIds AND recordTypeId =: ndbedpReqEqpId WITH SECURITY_ENFORCED]) {
                equipmentReqIds.add(reqEqp.Request__c);
            }
            for(Id caseId: caseIds) {
                if(!equipmentReqIds.contains(caseId)) {
                    trigger.newmap.get(caseId).addError('Add an Equipment to proceed');
                }
            }
        }
        if(searchUser) {
            userList = [SELECT Id FROM User WHERE (UserRole.DeveloperName = 'NDBEDP_TRC' OR UserRole.DeveloperName = 'Technology_Resource_Coordinator') AND IsActive = true LIMIT 1];//WITH SECURITY_ENFORCED
        }
        for(Case caseRecord: caseList) {
            if(caseRecord.recordTypeId == ndbedpDemoTypeId
               && caseRecord.Status == 'Pending TRC'
               && oldMap.get(caseRecord.id).Status == 'Pending NDBEDP Coordinator') {
                   caseRecord.TRC_Comment__c = null;
                   if(userList.size() > 0) {
                       caseRecord.External_Assessor_User__c = userList[0].id;
                   }
               }
            if(caseRecord.recordTypeId == ndbedpDemoTypeId
               && caseRecord.Status == 'Submitted'
               && oldMap.get(caseRecord.id).Status == 'Pending NDBEDP Coordinator'
               && caseRecord.NDBEDP_Coordinator_Comment__c == null) {
                   caseRecord.addError('NDBEDP Administrator Comment is required before Reject');
               }
            if(caseRecord.recordTypeId == ndbedpDemoTypeId
               && caseRecord.Status == 'Pending NDBEDP Coordinator'
               && oldMap.get(caseRecord.id).Status == 'Pending TRC'
               && caseRecord.TRC_Comment__c == null) {
                   caseRecord.addError('TRC Comment is required before Reject');
               }
        }
    }
    
    /*
*********************************************************
@Method Name    : moveToPendingTrainer
@description    : Move NDBEDP Additional training request status to Pending Trainer
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void moveToPendingTrainer(List<Case> caseList, Map<Id,Case> oldMap){
        Id ndbedpAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Additional_Training');
        for(Case caseValue:caseList){
            if(caseValue.RecordtypeId == ndbedpAdditionalTrainingRecordTypeId && caseValue.NDBEDP_Trainer__c!=oldMap.get(caseValue.Id).NDBEDP_Trainer__c && caseValue.NDBEDP_Trainer__c!=null){
                caseValue.Status ='Pending Trainer';
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPBudget
@description    : NDBEDP Budget updation on cost field changes
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void updateNDBEDPBudget(List<Case> newList, Map<Id, Case> oldMap) {
        List<Budget_Management__c> updateBudgetList = new List<Budget_Management__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, Case> caseOldMap = new Map<Id, Case>();
        
        if(newList == null && oldMap != null) {
            for(Id caseId: oldMap.keySet()) {
                if((oldMap.get(caseId).recordTypeId == ndbedpRequestId || oldMap.get(caseId).recordTypeId == ndbedpAdditionalPartRequestId)
                   && oldMap.get(caseId).NDBEDP_Total_Cost__c > 0) {
                       caseMap.put(caseId, null);
                       caseOldMap.put(caseId, oldMap.get(caseId));
                   }
            }
        } else {
            for(Case caseObj: newList) {
                if(oldMap != null && newList != null
                   && (caseObj.recordTypeId == ndbedpRequestId || caseObj.recordTypeId == ndbedpAdditionalPartRequestId)
                   && caseObj.NDBEDP_Total_Cost__c != oldMap.get(caseObj.id).NDBEDP_Total_Cost__c) {
                       caseMap.put(caseObj.id, caseObj);
                       caseOldMap.put(caseObj.id, oldMap.get(caseObj.id));
                   } else if (oldMap == null && newList != null
                              && (caseObj.recordTypeId == ndbedpRequestId || caseObj.recordTypeId == ndbedpAdditionalPartRequestId)
                              && (caseObj.NDBEDP_Total_Cost__c > 0)) {
                                  caseMap.put(caseObj.id, caseObj);
                                  caseOldMap.put(caseObj.id, null);
                              }
            }   
        }
        if(caseMap.size() > 0) {
            Id caseRecordId;
            Date currentDate = System.today();
            List<Budget_Management__c> budgetList = [SELECT Amount_Utilized__c, Total_Amount__c FROM Budget_Management__c WHERE Budget_Type__c = 'NDBEDP Budget' AND Start_Date_Fiscal_Year_Formula__c <=: currentDate AND End_Date_Fiscal_Year_Formula__c >=: currentDate WITH SECURITY_ENFORCED LIMIT 1];
            Decimal amountUtilized = budgetList[0].Amount_Utilized__c;
            for(Id caseId: caseMap.keySet()) {
                if(!budgetList.isEmpty()) {
                    amountUtilized -= (caseOldMap.containsKey(caseId) && caseOldMap.get(caseId).NDBEDP_Total_Cost__c != null) ?  caseOldMap.get(caseId).NDBEDP_Total_Cost__c : 0;
                    amountUtilized += (caseMap.containsKey(caseId) && caseMap.get(caseId).NDBEDP_Total_Cost__c != null) ?  caseMap.get(caseId).NDBEDP_Total_Cost__c : 0;
                    caseRecordId = caseId;
                } else {
                    //trigger.newmap.get(caseId).addError('NDBEDP Budget not available for current year.');
                    break;
                }
            }
            if(amountUtilized != 0) {
                Budget_Management__c budget = new Budget_Management__c();
                budget.id = budgetList[0].id;
                budget.Amount_Utilized__c = amountUtilized;
                updateBudgetList.add(budget);
            } else {
                //trigger.newmap.get(caseRecordId).addError('Insufficient NDBEDP Budget for current year.');
            }
        }
        
        if(updateBudgetList.size() > 0) {
            //update updateBudgetList;
            SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Budget_Management__c', updateBudgetList, 'update', true,'NC_CaseTriggerHandler','updateNDBEDPBudget');
            update decision.getRecords();
        }
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPRequest
@description    : Validate NDBEDP request status and approval process
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void validateNDBEDPRequest(List<Case> newList, Map<Id, Case> oldMap) {
        List<String> requestIds = new List<String>();
        for(Case caseObj: newList){
            
            if(caseObj.recordTypeId == ndbedpRequestId
               && oldMap.get(caseObj.id).Status == 'Submitted'
               && caseObj.Status != 'Pending Documents'
               && caseObj.Status != oldMap.get(caseObj.id).Status
               && caseObj.Status != 'Denied'
               && !Test.isRunningTest()) {
                   caseObj.addError('Invalid Status. Change status to Pending Documents to proceed.');
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && oldMap.get(caseObj.id).Status == 'Pending Documents'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Check_Document_Review__c == oldMap.get(caseObj.id).Check_Document_Review__c
               && caseObj.Status != 'Denied'
               && !Test.isRunningTest()) {
                   caseObj.addError('Click Submit for Approval to proceed');
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Approve_or_Reject__c == false
               && caseObj.Status != 'Denied'
               && !Test.isRunningTest()) {
                   requestIds.add(caseObj.id);
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Approve_or_Reject__c == true) {
                   caseObj.Approve_or_Reject__c = false;
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && caseObj.Status == 'Pending Documents'
               && caseObj.Check_Document_Review__c != oldMap.get(caseObj.id).Check_Document_Review__c
               && caseObj.Check_Document_Review__c) {
                   caseObj.Status = 'Documents Review';
                   caseObj.Check_Document_Review__c = false;
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && oldMap.get(caseObj.id).Status == 'Pending TRP Manager'
               && caseObj.Check_TRP_Reject__c
               && caseObj.Status != oldMap.get(caseObj.id).Status
               && caseObj.TRP_Manager_Comment__c == null) {
                   caseObj.addError('Add Telecom Access Program Manager Comment to proceed');
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && caseObj.Check_TRP_Reject__c
               && caseObj.TRP_Manager_Comment__c != oldMap.get(caseObj.id).TRP_Manager_Comment__c
               && caseObj.TRP_Manager_Comment__c != null) {
                   caseObj.Status = 'Rejected';
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && caseObj.Assessor_Result__c != oldMap.get(caseObj.id).Assessor_Result__c) {
                   caseObj.Assessor_Invitation_Accepted_Date__c = System.today();
               }
            if(caseObj.recordTypeId == ndbedpRequestId
               && oldMap.get(caseObj.id).Status == 'Denied'
               && caseObj.Income_more_than_400_percent__c
               && caseObj.Income_more_than_400_percent__c == oldMap.get(caseObj.id).Income_more_than_400_percent__c) {
                   caseObj.addError('Request is Denied as Total Family Income more than 400 percentage of allowed income');
               }
        }
        
        if(requestIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:requestIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(requestIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPRequest
@description    : update NDBEDP request
@param          : List<Case> caseList, Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void updateNDBEDPRequest(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> requestIds = new Set<Id>(); 
        for(Case caseObj: newList){
            if(caseObj.recordTypeId == ndbedpRequestId
               //&& caseObj.Status == oldMap.get(caseObj.id).Status
               //&& caseObj.Status == 'Pending TRP Manager'
               && ((caseObj.Check_TRP_Reject__c != oldMap.get(caseObj.id).Check_TRP_Reject__c
                    && caseObj.Check_TRP_Reject__c)
                   || (caseObj.Check_Pending_Condition_Of_Acceptance__c != oldMap.get(caseObj.id).Check_Pending_Condition_Of_Acceptance__c
                       && caseObj.Check_Pending_Condition_Of_Acceptance__c))) {
                           requestIds.add(caseObj.id);
                       }
            if(caseObj.recordTypeId == ndbedpRequestId
               && caseObj.Check_TRP_Reject__c 
               && oldMap.get(caseObj.id).Status == 'Pending TRP Manager'
               && caseObj.Status != oldMap.get(caseObj.id).Status) {
                   Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                   req.setComments('');
                   req.setAction('Reject');        
                   Id workItemId = getWorkItemId(caseObj.Id); 
                   if(workItemId != null){
                       req.setWorkitemId(workItemId);
                       Approval.ProcessResult result =  Approval.process(req);
                   }
               }
        }
        if(requestIds.size() > 0) {
            submitForApprovalFuture(requestIds);
        }
    }
    
    /*
*********************************************************
@Method Name    : submitForApprovalFuture
@description    : submit record for approval in future
@param          : Set<Id> recordIds
@return         : void
********************************************************
*/
    @future
    public static void submitForApprovalFuture(Set<Id> recordIds) {
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(Id recordId: recordIds){   
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('');
            req.setObjectId(recordId);      
            processList.add(req);
        }
        try {
            Approval.process(processList);   
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
    }
    
    /*
*********************************************************
@Method Name    : updateNDBEDPStatusReject
@description    : update NDBEDP request status to rejected
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void updateNDBEDPStatusReject(List<Case> newList, Map<Id, Case> oldMap) {
        List<Case> caseList = new List<Case>();
        for(Case caseObj :newList){
            if(caseObj.recordTypeId == ndbedpRequestId
               && caseObj.Check_TRP_Reject__c 
               && caseObj.Status == 'Denied'){
                   caseObj.Status = 'Rejected';
                   
               }
        }
        
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessmentForm
@description    : Send email for assessment form
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailForAssessmentForm(List<Case> newList ,Map<Id,Case> oldMap) {
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        List<Id> userIdList = new List<Id>();
        Map<Id,String> userIdToMap = new Map<Id,String>();
        Map<Id,String> userIdToRoleMap = new Map<Id,String>();
        for(Case caseValue:newList){
            if(caseValue.Status == 'Pending Assessment' && oldMap.get(caseValue.Id).Status!= caseValue.Status && (Test.isRunningTest() || caseValue.External_Assessor_User__c!=null)){
                userIdList.add(caseValue.External_Assessor_User__c);
            }
        }
        for(User use:[SELECT Id,Email,UserRole.DeveloperName FROM User WHERE Id IN:userIdList AND Email !=null]){
            userIdToMap.put(use.Id,use.Email);
            userIdToRoleMap.put(use.Id,use.UserRole.DeveloperName);
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<String> emailList = new List<String>();
        
        for(Case caseValue:newList){
            if(caseValue.Status == 'Pending Assessment' && oldMap.get(caseValue.Id).Status!= caseValue.Status && (Test.isRunningTest() || caseValue.External_Assessor_User__c!=null)){
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseValue.Id;
                String URLValue= 'https://'+domains[0].Domain +'/' +caseValue.Id;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                String plainBody = emailTemplateNDBEDPAssessorConfirmation[0].Body;
                String htmlBody = emailTemplateNDBEDPAssessorConfirmation[0].HtmlValue;
                if(caseValue.External_Assessor__c!=null){
                    if(userIdToRoleMap.get(caseValue.External_Assessor_User__c)=='NDBEDP_Coordinator'){
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl);
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                    }
                    else{
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue);
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                    }
                }
                if(caseValue.Internal_Assessor__c!=null){
                    plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl);
                    htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                }
                plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber);  
                htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                message.setHtmlBody(htmlBody);
                message.setPlainTextBody(plainBody);   
                message.setTemplateID(emailTemplateNDBEDPRepairRequestInvitationReject[0].Id);  
                message.setSubject('Please Complete the Assessor Form');      
                emailList.add(userIdToMap.get(caseValue.External_Assessor_User__c));
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);    
                messages.add(message);  
            }
        }
        if(messages.size()>0 && emailList.size()>0){
            if(!Test.isRunningTest()){
                Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : validateNdbedpServiceRequest
@description    : Validate NDBEDP service request
@param          : Map<Id, Case> caseMap, Map<Id, Id> caseAssessorMap, Boolean isTrainerNoteRequired
@return         : void
********************************************************
*/
    public static void validateNdbedpServiceRequest(Map<Id, Case> caseMap, Map<Id, Id> caseAssessorMap, Boolean isTrainerNoteRequired) {
        Set<Id> portalUserSet = new Set<Id>();
        for(User userRecord:[SELECT accountId FROM User WHERE isActive = true AND accountId IN: caseAssessorMap.values() AND accountId != null]) {
            portalUserSet.add(userRecord.accountId);
        }
        for(Id caseId: caseAssessorMap.keySet()) {
            String errorMessage = '';
            if(!isTrainerNoteRequired && caseMap.get(caseId).Assessor_Notes__c == null) {
                errorMessage += 'Assessor Note, ';
            }
            if(isTrainerNoteRequired && caseMap.get(caseId).Trainer_Notes__c == null) {
                errorMessage += 'Trainer Notes, ';
            }
            if(caseMap.get(caseId).Consumer_Acknowledgment_Date__c == null) {
                errorMessage += 'Consumer Acknowledgment Date, ';
            }
            if(caseAssessorMap.get(caseId) != null && !portalUserSet.contains(caseAssessorMap.get(caseId)) && caseMap.get(caseId).Service_Documentation__c == false) {
                errorMessage += 'Service Documentation, ';
            } else if(caseMap.get(caseId).Service_Documentation__c == false && String.isBlank(caseMap.get(caseId).Signature_ID__c)){
                errorMessage += 'Consumer E-Signature, ';
            }
            if(!String.isBlank(errorMessage)) {
                errorMessage = errorMessage.substring(0, errorMessage.length()-2);
                errorMessage += ' is Required';
                caseMap.get(caseId).addError(errorMessage);
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : updateAssessorInvitationDate
@description    : Update Assessor invitation date to today
@param          : List<Case> newList ,Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void updateAssessorInvitationDate(List<Case> newList ,Map<Id,Case> oldMap){
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        for(Case caseValue:newList){
            if(caseValue.Assessor_Result__c!=null && oldMap.get(caseValue.Id).Assessor_Result__c!=caseValue.Assessor_Result__c && caseValue.Assessor_Result__c == 'Accept' && caseValue.RecordtypeId == ndbedpRecordTypeId ){
                caseValue.Assessor_Invitation_Accepted_Date__c = Date.today();
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : checkNDBEDPServiceRequest
@description    : create NDBEDP service request validation
@param          : List<Case> newList
@return         : void
********************************************************
*/
    public static void checkNDBEDPServiceRequest(List<Case> newList ){
        for(Case caseValue : newList){
            if(caseValue.Check_NDBEDP_Service_Request__c == true && caseValue.Request_Type__c  == 'NDBEDP'){
                trigger.newmap.get(caseValue.id).addError('You cannot create the NDBEDP Service Request');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : updatePreviousDescription
@description    : update previous description of request
@param          : List<Case> newList ,Map<Id,Case> oldMap
@return         : void
********************************************************
*/
    public static void updatePreviousDescription(List<Case> newList ,Map<Id,Case> oldMap){
        for(Case caseValue : newList){
            if(caseValue.Description != oldMap.get(caseValue.Id).Description && caseValue.Description!=null){
                caseValue.Previous_Description__c = oldMap.get(caseValue.Id).Description;
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : shareRequestWithRCUsers
@description    : Share request with RC staff users
@param          : List<Case> newList
@return         : void
********************************************************
*/
    public static void shareRequestWithRCUsers(List<Case> newList) {
        try {
            Set<String> rcUserRole = new Set<String>{'Receptionist_AA1', 'Receptionist_AA2', 'Deaf_Services_Specialist', 'Deaf_Blind_Services_Specialist', 'Hard_of_Hearing_Service_Specialist', 'Interpreter_Services_Specialist', 'Telecom_Consultant', 'Community_Access_Specialist', 'Regional_Center_Manager'};
                
                Set<Id> userIds = new Set<Id>();
            Map<Id, Id> caseOwnerMap = new Map<Id, Id>();
            for(Case caseObj: newList) {
                userIds.add(caseObj.CreatedById);
                caseOwnerMap.put(caseObj.id, caseObj.OwnerId);
            }
            
            Set<String> regionalCenterSet = new Set<String>();
            for(User userObj: [SELECT Regional_Center__c, Secondary_Regional_Centers__c FROM User WHERE id IN: userIds AND IsActive = true]) {
                if(userObj.Regional_Center__c != null) {
                    regionalCenterSet.add(userObj.Regional_Center__c);
                }
                if(userObj.Secondary_Regional_Centers__c != null) {
                    for(String rc: userObj.Secondary_Regional_Centers__c.split(';')) {
                        regionalCenterSet.add(rc);
                    }
                }
            }
            
            List<CaseShare> caseShareList = new List<CaseShare>();
            if(!regionalCenterSet.isEmpty()) {
                String queryString = 'SELECT Id FROM User  WHERE IsActive = true AND  UserRole.DeveloperName IN :rcUserRole AND (Regional_Center__c IN :regionalCenterSet OR  Secondary_Regional_Centers__c INCLUDES(';
                for(String includeValue :regionalCenterSet) {
                    queryString += '\''+ includeValue + '\',';   
                }
                queryString = queryString.removeEnd(',') +'))';
                List<User> userList = (List<User>)Database.query(queryString);
                for(User userObj: userList) {
                    for(Case caseObj: newList) {
                        if(caseOwnerMap.containsKey(caseObj.id) && caseOwnerMap.get(caseObj.id) != userObj.id) {
                            CaseShare caseShareObj = new CaseShare();
                            caseShareObj.CaseId = caseObj.id;
                            caseShareObj.CaseAccessLevel = 'Edit';
                            caseShareObj.RowCause = 'Manual';
                            caseShareObj.UserOrGroupId = userObj.id;
                            caseShareList.add(caseShareObj);
                        }
                    }
                }
            }
            
            if(!caseShareList.isEmpty()) {
                insert caseShareList;
            }   
        } catch (Exception e) {
            throw new AuraHandledException('Error: '+e.getMessage());
        }
    }
    
    /*
*********************************************************
@Method Name    : serviceRequestOwnerValidation
@description    : Service Request owner change validation
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void serviceRequestOwnerValidation(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, String> caseOwnerMap = new Map<String, String>();
        Id serviceRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
        for(Case caseObj: newList) {
            if(caseObj.recordTypeId == serviceRequestId && caseObj.OwnerId != oldMap.get(caseObj.id).OwnerId && caseObj.Request_Assigned__c == false) {
                caseOwnerMap.put(caseObj.id, caseObj.OwnerId);
            }
        }
        if(caseOwnerMap.size() > 0) {
            Set<String> portalUserIds = new Set<String>();
            List<Group> groupList = [select id from Group WHERE Type = 'Queue' AND DeveloperName = 'Regional_Center_Office' LIMIT 1];
            for(User portalUser: [SELECT id FROM User WHERE IsPortalEnabled = true AND isActive = true]) {
                portalUserIds.add(portalUser.id);
            }
            for(String caseId: caseOwnerMap.keySet()) {
                if((portalUserIds.contains(caseOwnerMap.get(caseId)) || caseOwnerMap.get(caseId).substring(0,3) == '00G') && !groupList.isEmpty() && groupList[0].id != caseOwnerMap.get(caseId)) {
                    Trigger.newMap.get(caseId).addError('Invalid User: Assign internal user as an owner');
                }
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : validateEDSRquestStatus
@description    : Validate EDS request status and approval process
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void validateEDSRquestStatus(List<Case> newList, Map<Id, Case> oldMap) {
        List<String> requestIds = new List<String>();
        Id edsEquipmentTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        for(Case caseObj: newList) {
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && caseObj.Status == 'Pending EDS Program Assistant'
               && caseObj.Status != oldMap.get(caseObj.id).Status
               && caseObj.EDS_Audit_Recommendation__c != null) {
                   caseObj.EDS_Audit_Recommendation__c = '';
                   caseObj.EDS_Program_Assistant_Audit_Comments__c = null;
               }
            
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && caseObj.Status != oldMap.get(caseObj.id).Status) {
                   requestIds.add(caseObj.id);
               }
            
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && caseObj.Status != oldMap.get(caseObj.id).Status
               && oldMap.get(caseObj.id).Status == 'Submitted'
               && caseObj.Status != 'In Progress'
               && caseObj.Status != 'Withdrawn'
               && caseObj.Status != 'Denied') {
                   caseObj.addError('Invalid Status. Change status to In Progress to proceed.');
               }
            
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && caseObj.Status != oldMap.get(caseObj.id).Status
               && oldMap.get(caseObj.id).Status == 'In Progress'
               && caseObj.Status != 'Pending Documents'
               && caseObj.Status != 'Withdrawn'
               && caseObj.Status != 'Denied') {
                   caseObj.addError('Invalid Status. Change status to Pending Documents to proceed.');
               }
            
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && caseObj.Status != oldMap.get(caseObj.id).Status
               && oldMap.get(caseObj.id).Status == 'Pending Documents'
               && caseObj.Status != 'Pending Condition of Acceptance'
               && caseObj.Status != 'Withdrawn'
               && caseObj.Status != 'Denied') {
                   caseObj.addError('Invalid Status. Change status to Pending Condition of Acceptance to proceed.');
               }
            
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && oldMap.get(caseObj.id).Status == 'Pending Condition of Acceptance'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Submit_for_Approval__c == false
               && caseObj.Status != 'Withdrawn'
               && caseObj.Status != 'Denied') {
                   caseObj.addError('Click Submit for Approval to proceed');
               }
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && oldMap.get(caseObj.id).Status == 'Pending Condition of Acceptance'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Submit_for_Approval__c == true) {
                   caseObj.Submit_for_Approval__c = false;
               }
            
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && oldMap.get(caseObj.id).Status == 'Pending EDS Program Assistant'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Submit_for_Approval__c == false
               && caseObj.Status != 'Withdrawn'
               && caseObj.Status != 'Denied') {
                   caseObj.addError('Click Submit for Approval to proceed');
               }
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && oldMap.get(caseObj.id).Status == 'Pending EDS Program Assistant'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Submit_for_Approval__c == true) {
                   caseObj.Submit_for_Approval__c = false;
               }
            if(caseObj.recordTypeId == edsEquipmentTypeId
               && caseObj.Status == 'Appeal Pending'
               && oldMap.get(caseObj.id).Status == 'Denied'
               && caseObj.Income_more_than_250_percent__c == true) {
                   caseObj.addError('Request is Denied as Total Family Income more than 250 percentage of allowed income');
               }
        }
        
        if(requestIds.size() > 0) {
            List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:requestIds AND Status = 'Pending'];
            if(!processInstanceList.isEmpty()) {
                Trigger.newMap.get(requestIds[0]).addError('Click Approve or Reject to proceed');
            }
        }
    }
    
    /*
*********************************************************
@Method Name    : validateNDBEDPDemoRquestStatus
@description    : Validate NDBEDP Demo request status and approval process
@param          : List<Case> newList, Map<Id, Case> oldMap
@return         : void
********************************************************
*/
    public static void validateNDBEDPDemoRquestStatus(List<Case> newList, Map<Id, Case> oldMap) {
        List<String> requestIds = new List<String>();
        Id ndbedpDemoTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP_Demo').getRecordTypeId();
        for(Case caseObj: newList) {
            if(caseObj.recordTypeId == ndbedpDemoTypeId
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Approve_or_Reject__c == false && !Test.isRunningTest()) {
                   requestIds.add(caseObj.id);
               }
            if(caseObj.recordTypeId == ndbedpDemoTypeId
               && oldMap.get(caseObj.id).Status == 'Submitted'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Submit_for_Approval__c == false && !Test.isRunningTest()) {
                   caseObj.addError('Click Submit for Approval to proceed');
               }
            if(caseObj.recordTypeId == ndbedpDemoTypeId
               && oldMap.get(caseObj.id).Status == 'Submitted'
               && oldMap.get(caseObj.id).Status != caseObj.Status
               && caseObj.Submit_for_Approval__c == true ) {
                   caseObj.Submit_for_Approval__c = false;
               }
        }
        if(requestIds.size() > 0) {
            checkPendingApproval(requestIds);
        }
    }
    
    /*
*********************************************************
@Method Name    : checkPendingApproval
@description    : Check if record is pending approval
@param          : List<String> recordIds
@return         : void
********************************************************
*/
    public static void checkPendingApproval(List<String> recordIds) {
        List<ProcessInstance> processInstanceList = [Select Id From ProcessInstance WHERE TargetObjectId IN:recordIds AND Status = 'Pending'];
        if(!processInstanceList.isEmpty()) {
            Trigger.newMap.get(recordIds[0]).addError('Click Approve or Reject to proceed');
        }
    }
    
}