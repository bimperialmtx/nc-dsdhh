/**
 * Created by ashishpandey on 11/05/21.
 */

@RestResource(urlMapping='/ConsumerMerge/*')
global with sharing class NC_ConsumerMergeService {

    /**API URL: https://ncdsdhh--qa.my.salesforce.com/services/apexrest/ConsumerMerge*****
     * archive Source ID record with the Target ID
     * IF 'Target ID' does not exist in SMS and Source 'ID' exist
    Ability to replace 'Source ID' with Target ID in SMS
    Logic: I-69857*/

    /*Request
        {
            "TARGET_PERSON_ID": "123456789",
            "TARGET_CD": "1",
            "SOURCE_PERSON_ID": "987654321",
            "SOURCE_CD": "2",
            "TARGET_SSN": "*********",
            "TARGET_DOB": "12122001"
        }
    */

    /*
    *********************************************************
    @Method Name    : doPost
    @description    : Merge two contacts from CNDS
    @param          : 
    @return         : void
    ********************************************************
    */
    @HttpPost
    global static void doPost() {

        String smsTargetDOB;
        String smsSourceDOB;
        String dayString;
        String monthString;
        Integer day;

        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        Contact sourceContact;
        Contact targetContact;

        try {
            CNDSResponseWrapper responseWrapper = new CNDSResponseWrapper();
            CNDSRequestWrapper wrapperObject = (CNDSRequestWrapper)JSON.deserialize(request.requestbody.toString(), CNDSRequestWrapper.class);
            String targetCNDSId = wrapperObject.TARGET_PERSON_ID+wrapperObject.TARGET_CD;
            String sourceCNDSId = wrapperObject.SOURCE_PERSON_ID+wrapperObject.SOURCE_CD;
            String targetSSN = wrapperObject.TARGET_SSN.right(4);
            String targetDOB = wrapperObject.TARGET_DOB;
            String sourceSSN;
            String smsTargetSSN;

            for(Contact con:[SELECT Id,FirstName,User_Id__c,Race__c,BirthDate,Gender__c,Hispanic_Ethnicity__c,Suffix,Primary_Language__c,MiddleName,Social_Security_Number__c,LastName,Staff_Member_Name__c, Cnds_Identifier__c, Disability_Determination_form_Uploaded__c,Proof_of_Income_Uploaded__c,
                    Proof_Of_Residency_Uploaded__c, Voter_Registration_Form_Uploaded__c FROM Contact WHERE Cnds_Identifier__c=:targetCNDSId WITH SECURITY_ENFORCED]){
                targetContact=con;
            }

            for(Contact con:[SELECT Id,FirstName,User_Id__c,Race__c,BirthDate,Gender__c,Hispanic_Ethnicity__c,Suffix,Primary_Language__c,MiddleName,Social_Security_Number__c,LastName,Staff_Member_Name__c, Cnds_Identifier__c, Disability_Determination_form_Uploaded__c,Proof_of_Income_Uploaded__c,
                    Proof_Of_Residency_Uploaded__c, Voter_Registration_Form_Uploaded__c FROM Contact WHERE Cnds_Identifier__c=:sourceCNDSId WITH SECURITY_ENFORCED]){
                sourceContact = con;
            }
            if (sourceContact!=null) {
                sourceSSN=sourceContact.Social_Security_Number__c!=null?sourceContact.Social_Security_Number__c.right(4):'';
            }
            if (targetContact!=null) {
                smsTargetSSN=targetContact.Social_Security_Number__c!=null?targetContact.Social_Security_Number__c.right(4):'';
            }
            //Transforming SMS DOB to required for matching
            if(targetContact!=null && targetContact.BirthDate!=null){
                day = targetContact.BirthDate.Day(); //get day
                if(String.valueOf(day).length()==1){
                    dayString= String.valueOf(day).leftPad(2, '0');
                }else {
                    dayString=String.valueof(day);
                }
                Integer month = targetContact.BirthDate.Month(); //get month
                if(String.valueOf(month).length()==1){
                    monthString= String.valueOf(month).leftPad(2, '0');
                }else {
                    monthString=String.valueof(month);
                }
                Integer year = targetContact.BirthDate.Year(); //get year
                smsTargetDOB = String.valueof(year)+ monthString + dayString;
            }
            //Transforming SMS DOB to required for matching
            if(sourceContact!=null && sourceContact.BirthDate!=null){
                day = sourceContact.BirthDate.Day(); //get day
                if(String.valueOf(day).length()==1){
                    dayString= String.valueOf(day).leftPad(2, '0');
                }else {
                    dayString=String.valueof(day);
                }
                Integer month = sourceContact.BirthDate.Month(); //get month
                if(String.valueOf(month).length()==1){
                    monthString= String.valueOf(month).leftPad(2, '0');
                }else {
                    monthString=String.valueof(month);
                }
                Integer year = sourceContact.BirthDate.Year(); //get year
                smsSourceDOB = String.valueof(year)+ monthString + dayString;
            }
            //If Both Contact found in SMS
            if(targetContact!=null && sourceContact!=null){
                //Check If Target and Source SSN and DOB Matching
                if (((targetSSN==sourceSSN && targetSSN==smsTargetSSN) || (targetSSN=='0000')) && (targetDOB==smsTargetDOB && targetDOB==smsSourceDOB)) {
                    Boolean isDocumentPresent = false;
                    if(sourceContact.Disability_Determination_form_Uploaded__c) {
                        targetContact.Disability_Determination_form_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(sourceContact.Proof_of_Income_Uploaded__c) {
                        targetContact.Proof_of_Income_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(sourceContact.Proof_Of_Residency_Uploaded__c) {
                        targetContact.Proof_Of_Residency_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(sourceContact.Voter_Registration_Form_Uploaded__c) {
                        targetContact.Voter_Registration_Form_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(isDocumentPresent) {
                        //update targetContact;
                        SObjectAccessDecision decision = SecurityLibrary.getAccessibleData('Contact', new List<Contact>{targetContact}, 'update', true,'NC_ConsumerMergeService','doPost');
                        update decision.getRecords();
                    }

                    List<Client_Archive__c> clientArchiveList = new List<Client_Archive__c>();
                    Client_Archive__c archive = new Client_Archive__c();
                    archive.Consumer__c = targetContact.Id;
                    archive.First_Name__c = sourceContact.FirstName;
                    archive.Last_Name__c = sourceContact.LastName;
                    clientArchiveList.add(archive);
                    for(Client_Archive__c obj:[SELECT Id,Consumer__c FROM Client_Archive__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c = targetContact.Id;
                        clientArchiveList.add(obj);
                    }
                    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Client_Archive__c', clientArchiveList, 'upsert', true, 'NC_ConsumerMergeService', 'doPost');
                    upsert decision.getRecords();

                    //Re-Parenting Source Request record to target
                    List<Case> caseList = new List<Case>();
                    for(Case obj:[SELECT Id,ContactId FROM Case WHERE ContactId=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.ContactId=targetContact.Id;
                        caseList.add(obj);
                    }
                    SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Case', caseList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision1.getRecords();
                    //  update caseList;

                    //Re-Parenting Asset__c record to target
                    List<Asset__c> assetList = new List<Asset__c>();
                    for(Asset__c obj:[SELECT Id,Contact__c FROM Asset__c WHERE Contact__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Contact__c=targetContact.Id;
                        assetList.add(obj);
                    }
                    SObjectAccessDecision decision2 =  SecurityLibrary.getAccessibleData('Asset__c', assetList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision2.getRecords();
                    //update assetList;

                    //Re-Parenting Authorization__c record to target
                    List<Authorization__c> authList = new List<Authorization__c>();
                    for(Authorization__c obj:[SELECT Id,Consumer__c FROM Authorization__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        authList.add(obj);
                    }
                    for(Authorization__c auth: authList) {
                        auth.Update_If_Vendor_Inactive__c = true;
                    }
                    SObjectAccessDecision decision3 =  SecurityLibrary.getAccessibleData('Authorization__c', authList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision3.getRecords();
                    // update authList;

                    //Re-Parenting Information_Referral__c  record to target
                    List<Information_Referral__c> infoList = new List<Information_Referral__c>();
                    for(Information_Referral__c obj:[SELECT Id,Consumer__c FROM Information_Referral__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        infoList.add(obj);
                    }
                    SObjectAccessDecision decision4 =  SecurityLibrary.getAccessibleData('Information_Referral__c', infoList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision4.getRecords();
                    // update infoList;

                    //Re-Parenting Resource_Loan__c record to target
                    List<Resource_Loan__c> resourceLoans = new List<Resource_Loan__c>();
                    for(Resource_Loan__c obj:[SELECT Id,Consumer__c FROM Resource_Loan__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        resourceLoans.add(obj);
                    }
                    SObjectAccessDecision decision5 =  SecurityLibrary.getAccessibleData('Resource_Loan__c', resourceLoans, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision5.getRecords();
                    // update resourceLoans;

                    //Re-Parenting Mentoring_Request__c record to target
                    List<Mentoring_Request__c> mentoringRequests = new List<Mentoring_Request__c>();
                    for(Mentoring_Request__c obj:[SELECT Id,Consumer__c FROM Mentoring_Request__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        mentoringRequests.add(obj);
                    }
                    SObjectAccessDecision decision6 =  SecurityLibrary.getAccessibleData('Mentoring_Request__c', mentoringRequests, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision6.getRecords();
                    // update mentoringRequests;

                    //Re-Parenting Alternate_Contact__c record to target
                    List<Alternate_Contact__c> alternateContacts = new List<Alternate_Contact__c>();
                    for(Alternate_Contact__c obj:[SELECT Id,Consumer__c FROM Alternate_Contact__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        alternateContacts.add(obj);
                    }
                    SObjectAccessDecision decision7 =  SecurityLibrary.getAccessibleData('Alternate_Contact__c', alternateContacts, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision7.getRecords();
                    // update alternateContacts;

                    //Re-Parenting Attachment record to target
                    List<Attachment> attachments = new List<Attachment>();
                    for(Attachment obj:[SELECT Id,ParentId FROM Attachment WHERE ParentId=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.ParentId=targetContact.Id;
                        attachments.add(obj);
                    }
                    SObjectAccessDecision decision8 =  SecurityLibrary.getAccessibleData('Attachment', attachments, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision8.getRecords();

                    List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
                    List<ContentDocumentLink> deleteContentDocumentLinks = new List<ContentDocumentLink>();
                    for(ContentDocumentLink obj:[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:sourceContact.Id WITH SECURITY_ENFORCED]){
                        ContentDocumentLink newCdl = obj.clone();
                        newCdl.LinkedEntityId=targetContact.Id;
                        newContentDocumentLinks.add(newCdl);
                        deleteContentDocumentLinks.add(obj);
                    }
                    SObjectAccessDecision decision9 =  SecurityLibrary.getAccessibleData('ContentDocumentLink', newContentDocumentLinks, 'insert', true, 'NC_ConsumerMergeService', 'doPost');
                    insert decision9.getRecords();

                    if(Schema.SObjectType.ContentDocumentLink.isDeletable()) {
                        delete deleteContentDocumentLinks;
                    }

                    //Re-Parenting Outreach Request record to target
                    List<Outreach_Request__c> outReachRequests = new List<Outreach_Request__c>();
                    for(Outreach_Request__c obj:[SELECT Id,Consumer__c FROM Outreach_Request__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        outReachRequests.add(obj);
                    }
                    SObjectAccessDecision decision10 =  SecurityLibrary.getAccessibleData('Outreach_Request__c', outReachRequests, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision10.getRecords();

                    //Re-Parenting Error record to target
                    List<Error__c> errors = new List<Error__c>();
                    for(Error__c obj:[SELECT Id,Consumer__c FROM Error__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        errors.add(obj);
                    }
                    SObjectAccessDecision decision11 =  SecurityLibrary.getAccessibleData('Error__c', errors, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision11.getRecords();

                    //Re-Parenting Survey Invitation record to target
                    List<SurveyInvitation> surveyInvitations = new List<SurveyInvitation>();
                    for(SurveyInvitation obj:[SELECT Id,Consumer_Id__c FROM SurveyInvitation WHERE Consumer_Id__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer_Id__c=targetContact.Id;
                        surveyInvitations.add(obj);
                    }
                    SObjectAccessDecision decision12 =  SecurityLibrary.getAccessibleData('SurveyInvitation', surveyInvitations, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision12.getRecords();

                    //finally Delete the Source Contact/Consumer record If Merged
                    if(Contact.sObjectType.getDescribe().isDeletable()){
                        delete sourceContact;
                    }
                    else {
                        throw new NC_Custom_Exception('You don\'t have access to delete');
                    }

                    responseWrapper.recordId = sourceContact.Id;
                    responseWrapper.errorMsg=null;
                    responseWrapper.success=true;
                    res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper)); 
                }else {
                    //Create new record in CNDS
                    List<Contact> contacts = new List<Contact>{targetContact};
                    System.enqueueJob(new NC_CreateCNDSConsumer(contacts));

                    //finally Delete the Source Contact/Consumer record If Merged
                    Boolean isDocumentPresent = false;
                    if(sourceContact.Disability_Determination_form_Uploaded__c) {
                        targetContact.Disability_Determination_form_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(sourceContact.Proof_of_Income_Uploaded__c) {
                        targetContact.Proof_of_Income_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(sourceContact.Proof_Of_Residency_Uploaded__c) {
                        targetContact.Proof_Of_Residency_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(sourceContact.Voter_Registration_Form_Uploaded__c) {
                        targetContact.Voter_Registration_Form_Uploaded__c = true;
                        isDocumentPresent = true;
                    }
                    if(isDocumentPresent) {
                        //update targetContact;
                        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', new List<Contact>{targetContact}, 'update', true,'NC_ConsumerMergeService','doPost');
                        update decision.getRecords();
                    }

                    List<Client_Archive__c> clientArchiveList = new List<Client_Archive__c>();
                    Client_Archive__c archive = new Client_Archive__c();
                    archive.Consumer__c = targetContact.Id;
                    archive.First_Name__c = sourceContact.FirstName;
                    archive.Last_Name__c = sourceContact.LastName;
                    clientArchiveList.add(archive);
                    for(Client_Archive__c obj:[SELECT Id,Consumer__c FROM Client_Archive__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c = targetContact.Id;
                        clientArchiveList.add(obj);
                    }
                    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Client_Archive__c', clientArchiveList, 'upsert', true, 'NC_ConsumerMergeService', 'doPost');
                    upsert decision.getRecords();

                    //Re-Parenting Source Request record to target
                    List<Case> caseList = new List<Case>();
                    for(Case obj:[SELECT Id,ContactId FROM Case WHERE ContactId=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.ContactId=targetContact.Id;
                        caseList.add(obj);
                    }
                    SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Case', caseList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision1.getRecords();
                    //  update caseList;

                    //Re-Parenting Asset__c record to target
                    List<Asset__c> assetList = new List<Asset__c>();
                    for(Asset__c obj:[SELECT Id,Contact__c FROM Asset__c WHERE Contact__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Contact__c=targetContact.Id;
                        assetList.add(obj);
                    }
                    SObjectAccessDecision decision2 =  SecurityLibrary.getAccessibleData('Asset__c', assetList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision2.getRecords();
                    //update assetList;

                    //Re-Parenting Authorization__c record to target
                    List<Authorization__c> authList = new List<Authorization__c>();
                    for(Authorization__c obj:[SELECT Id,Consumer__c FROM Authorization__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        authList.add(obj);
                    }
                    for(Authorization__c auth: authList) {
                        auth.Update_If_Vendor_Inactive__c = true;
                    }
                    SObjectAccessDecision decision3 =  SecurityLibrary.getAccessibleData('Authorization__c', authList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision3.getRecords();
                    // update authList;

                    //Re-Parenting Information_Referral__c  record to target
                    List<Information_Referral__c> infoList = new List<Information_Referral__c>();
                    for(Information_Referral__c obj:[SELECT Id,Consumer__c FROM Information_Referral__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        infoList.add(obj);
                    }
                    SObjectAccessDecision decision4 =  SecurityLibrary.getAccessibleData('Information_Referral__c', infoList, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision4.getRecords();
                    // update infoList;

                    //Re-Parenting Resource_Loan__c record to target
                    List<Resource_Loan__c> resourceLoans = new List<Resource_Loan__c>();
                    for(Resource_Loan__c obj:[SELECT Id,Consumer__c FROM Resource_Loan__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        resourceLoans.add(obj);
                    }
                    SObjectAccessDecision decision5 =  SecurityLibrary.getAccessibleData('Resource_Loan__c', resourceLoans, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision5.getRecords();
                    // update resourceLoans;

                    //Re-Parenting Mentoring_Request__c record to target
                    List<Mentoring_Request__c> mentoringRequests = new List<Mentoring_Request__c>();
                    for(Mentoring_Request__c obj:[SELECT Id,Consumer__c FROM Mentoring_Request__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        mentoringRequests.add(obj);
                    }
                    SObjectAccessDecision decision6 =  SecurityLibrary.getAccessibleData('Mentoring_Request__c', mentoringRequests, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision6.getRecords();
                    // update mentoringRequests;

                    //Re-Parenting Alternate_Contact__c record to target
                    List<Alternate_Contact__c> alternateContacts = new List<Alternate_Contact__c>();
                    for(Alternate_Contact__c obj:[SELECT Id,Consumer__c FROM Alternate_Contact__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        alternateContacts.add(obj);
                    }
                    SObjectAccessDecision decision7 =  SecurityLibrary.getAccessibleData('Alternate_Contact__c', alternateContacts, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision7.getRecords();
                    // update alternateContacts;

                    //Re-Parenting Attachment record to target
                    List<Attachment> attachments = new List<Attachment>();
                    for(Attachment obj:[SELECT Id,ParentId FROM Attachment WHERE ParentId=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.ParentId=targetContact.Id;
                        attachments.add(obj);
                    }
                    SObjectAccessDecision decision8 =  SecurityLibrary.getAccessibleData('Attachment', attachments, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision8.getRecords();

                    List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
                    List<ContentDocumentLink> deleteContentDocumentLinks = new List<ContentDocumentLink>();
                    for(ContentDocumentLink obj:[SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:sourceContact.Id WITH SECURITY_ENFORCED]){
                        ContentDocumentLink newCdl = obj.clone();
                        newCdl.LinkedEntityId=targetContact.Id;
                        newContentDocumentLinks.add(newCdl);
                        deleteContentDocumentLinks.add(obj);
                    }
                    SObjectAccessDecision decision9 =  SecurityLibrary.getAccessibleData('ContentDocumentLink', newContentDocumentLinks, 'insert', true, 'NC_ConsumerMergeService', 'doPost');
                    insert decision9.getRecords();

                    if(Schema.SObjectType.ContentDocumentLink.isDeletable()) {
                        delete deleteContentDocumentLinks;
                    }

                    //Re-Parenting Outreach Request record to target
                    List<Outreach_Request__c> outReachRequests = new List<Outreach_Request__c>();
                    for(Outreach_Request__c obj:[SELECT Id,Consumer__c FROM Outreach_Request__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        outReachRequests.add(obj);
                    }
                    SObjectAccessDecision decision10 =  SecurityLibrary.getAccessibleData('Outreach_Request__c', outReachRequests, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision10.getRecords();

                    //Re-Parenting Error record to target
                    List<Error__c> errors = new List<Error__c>();
                    for(Error__c obj:[SELECT Id,Consumer__c FROM Error__c WHERE Consumer__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer__c=targetContact.Id;
                        errors.add(obj);
                    }
                    SObjectAccessDecision decision11 =  SecurityLibrary.getAccessibleData('Error__c', errors, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision11.getRecords();

                    //Re-Parenting Survey Invitation record to target
                    List<SurveyInvitation> surveyInvitations = new List<SurveyInvitation>();
                    for(SurveyInvitation obj:[SELECT Id,Consumer_Id__c FROM SurveyInvitation WHERE Consumer_Id__c=:sourceContact.Id WITH SECURITY_ENFORCED]){
                        obj.Consumer_Id__c=targetContact.Id;
                        surveyInvitations.add(obj);
                    }
                    SObjectAccessDecision decision12 =  SecurityLibrary.getAccessibleData('SurveyInvitation', surveyInvitations, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision12.getRecords();

                    //finally Delete the Source Contact/Consumer record If Merged
                    if(Contact.sObjectType.getDescribe().isDeletable()){
                        delete sourceContact;
                    }
                    else {
                        throw new NC_Custom_Exception('You don\'t have access to delete');
                    }

                    responseWrapper.recordId = targetContact.Id;
                    responseWrapper.errorMsg=null;
                    responseWrapper.success=true;
                    res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper));
                }
            }
            //Target Id  exist and Source Id does not exist
            if(targetContact!=null && sourceContact==null){
                //Do Nothing
                responseWrapper.recordId='Source Id not available in SMS';
                responseWrapper.errorMsg='';
                responseWrapper.success=true;
                res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper));
            }
            //Target Id does not exist and Source Id Exist
            if(targetContact==null && sourceContact!=null){
        
                if (((targetSSN==sourceSSN) || (targetSSN=='0000')) && (targetDOB==smsSourceDOB)) {
                    sourceContact.Cnds_Identifier__c=targetCNDSId;//Replace CNDS_Id
                    SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Contact', new List<Contact>{sourceContact}, 'update', true, 'NC_ConsumerMergeService', 'doPost');
                    update decision.getRecords();
                }else {
                    List<Contact> contacts = new List<Contact>{sourceContact};
                    System.enqueueJob(new NC_CreateCNDSConsumer(contacts));
                }
                responseWrapper.recordId=sourceContact.Id;
                responseWrapper.errorMsg='';
                responseWrapper.success=true;
                res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper));
            }
            if (targetContact==null && sourceContact==null) {
                responseWrapper.recordId='';
                responseWrapper.errorMsg='Source and Target not found.';
                responseWrapper.success=true;
                res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper));

            }
           
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 200;
        } catch (Exception e) {
            excepMessage(res,e);
            if(sourceContact != null) {
                createError(sourceContact.id,e.getMessage());
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : excepMessage
    @description    : Create exception message
    @param          : RestResponse res , Exception e
    @return         : void
    ********************************************************
    */
    private static void excepMessage(RestResponse res , Exception e){
        if(res!=null){
            CNDSResponseWrapper responseWrapper = new CNDSResponseWrapper();
            res.addHeader('Content-Type', 'application/json');
            responseWrapper.recordId=null;
            responseWrapper.success=false;
            responseWrapper.errorMsg=e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper));
            res.statusCode = 400;
        }
    }

    /*
    *********************************************************
    @Method Name    : createError
    @description    : Create Error record
    @param          : Id contactId, String errorMessage
    @return         : void
    ********************************************************
    */
    private static void createError(Id contactId, String errorMessage){
        Id cndsTypeId = NC_Utility.RecordTypeUtilityMethod('Error__c', 'CNDS_Error');

        Error__c error = new Error__c();
        error.RecordTypeId = cndsTypeId;
        error.Type__c = 'API Exception';
        error.Consumer__c = contactId;
        error.Error_Description__c = errorMessage;

        SObjectAccessDecision sobjdecision =  SecurityLibrary.getAccessibleData('Error__c', new List<Error__c>{error}, 'insert', true, 'NC_ConsumerMergeService','createError');
        insert sobjdecision.getRecords();
    }
    public class CNDSRequestWrapper{
        public String TARGET_PERSON_ID;
        public String TARGET_CD;
        public String SOURCE_PERSON_ID;
        public String SOURCE_CD;
        public String TARGET_SSN;
        public String TARGET_DOB;
    }
    public class CNDSResponseWrapper{
        public String recordId;
        public String errorMsg;
        public Boolean success;
    }

}