/*
*   Class Name: NC_SendBulkEmail
*   Description: Bul Email Handler
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_SendBulkEmail {

    /*
    *********************************************************
    @Method Name    : sendEmail
    @description    : send Email Method to send Bulk Emails to related Consumers in future Callout
    @param          : Set<Id> setOfAuthorizationId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void sendEmail(Set<Id> setOfAuthorizationId) {
        Set<Id> setOfAuthorizationNonHearingAid = new Set<Id>();
        Set<Id> setOfAuthorizationHearingAid = new Set<Id>();
        Map<Id, Id> mapOfContactIdWithAuth = new Map<Id, Id>();
        Map<Id, String> mapOfAuthWithEmail = new Map<Id, String>();
        Map<Id, String> mapofAssetWithConsumer = new Map<Id, String>();
        Map<Id, String> mapofAssetWithRegionalCenter = new Map<Id, String>();
        Map<Id, String> mapofAssetWithVendor = new Map<Id, String>();
        Map<Id, String> mapOfAuthIdWithRecordtypeName = new Map<Id, String>();
        Map<Id, String> mapOfAuthIdWithRequestRecordtypeName = new Map<Id, String>();
        Map<Id, Case> mapOfAuthIdWithRequest = new Map<Id, Case>();
        Map<Id, Contact> mapOfAuthIdWithContact = new Map<Id, Contact>();
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<Request_Letter__c> requestLetterList = new List<Request_Letter__c>();
        Id requestRecordId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP');
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();

        for(Asset__c assetRecord : [SELECT Id,Authorization__r.Recordtype.DeveloperName,Authorization__r.Request__r.RecordtypeId,Authorization__r.Request__r.ContactId,Authorization__r.Request__r.CaseNumber, Authorization__r.Vendor__r.Email__c,Authorization__c, Authorization__r.Consumer__c,Authorization__r.Consumer__r.Name, Authorization__r.Consumer__r.Preferred_Contact_Method__c, Authorization__r.Consumer__r.Email, Authorization__r.Vendor__r.Name,Authorization__r.Regional_Center__r.Name, Equipment__c, Equipment__r.Equipment_Type__c, Equipment__r.Is_Sub_Equipment__c FROM Asset__c WHERE Authorization__c IN : setOfAuthorizationId WITH SECURITY_ENFORCED]){
            if(assetRecord.Equipment__r.Equipment_Type__c == NC_Constant.EQUIPMENT_TYPE_HEARING_AID && !assetRecord.Equipment__r.Is_Sub_Equipment__c){
                setOfAuthorizationHearingAid.add(assetRecord.Authorization__c);
                mapOfContactIdWithAuth.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Consumer__c);
                mapOfAuthWithEmail.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Vendor__r.Email__c);
            }else{
                setOfAuthorizationNonHearingAid.add(assetRecord.Authorization__c);
                mapOfContactIdWithAuth.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Consumer__c);
                mapOfAuthWithEmail.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Vendor__r.Email__c);
            }
            mapofAssetWithConsumer.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Consumer__r.Name);
            mapofAssetWithRegionalCenter.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Regional_Center__r.Name);
            mapofAssetWithVendor.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Vendor__r.Name);
            mapOfAuthIdWithRequest.put(assetRecord.Authorization__c,assetRecord.Authorization__r.Request__r);
            mapOfAuthIdWithContact.put(assetRecord.Authorization__c, assetRecord.Authorization__r.Consumer__r);
        }

        for(Id recordId : setOfAuthorizationId){

            //Consumer Email Send
            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> listofEmailAttachments = new List<Messaging.EmailFileAttachment>();
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = mapOfAuthIdWithRequest.get(recordId).id + '.pdf';
            conVer.Title = mapOfAuthIdWithRequest.get(recordId).caseNumber + ' - Consumer Approval Letter';
            
            Request_Letter__c requestLetter = new Request_Letter__c();
            requestLetter.name = mapOfAuthIdWithRequest.get(recordId).caseNumber + ' - Consumer Approval Letter';
            requestLetter.Request__c = mapOfAuthIdWithRequest.get(recordId).id;
            requestLetter.Consumer__c = mapOfAuthIdWithRequest.get(recordId).ContactId;
            requestLetter.Mailed__c = mapOfAuthIdWithContact.get(recordId).Preferred_Contact_Method__c == NC_Constant.EMAIL_PPREFERRED_CONTACT ? true : false;
            requestLetterList.add(requestLetter);
            
            if(setOfAuthorizationNonHearingAid.contains(recordId)){
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment(); 
                PageReference ref= Page.NC_WeatherRadioApprovalConsumer;
                ref.getParameters().put('id',recordId);
                try{
                    Blob blobValue = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                    emailAttachment.setFileName('Equipment_Authorization.pdf');
                    emailAttachment.setBody(blobValue);
                    conVer.VersionData = blobValue;
                    listofEmailAttachments.add(emailAttachment);
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());
                }
                
            }
            if(setOfAuthorizationHearingAid.contains(recordId)){
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment(); 
                PageReference ref= Page.NC_HA_ConsumerApproval;
                ref.getParameters().put('id',recordId);
                try{
                    Blob blobValue = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                    emailAttachment.setFileName('Hearing_Aid_Authorization.pdf');
                    emailAttachment.setBody(blobValue);
                    conVer.VersionData = blobValue;
                    listofEmailAttachments.add(emailAttachment);
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());
                                }
                
            }
            
            singleEmailMessage.setSubject( NC_Constant.CONSUMER_SUBJECT_AUTHORIZATION +String.valueOf(DateTime.now()));
            singleEmailMessage.setTargetObjectId(mapOfContactIdWithAuth.get(recordId));
            singleEmailMessage.setPlainTextBody('Your application for (equipment(s)) have been approved.  Your approval letter is attached.  Please keep it for your files.  Please contact your '+ mapofAssetWithRegionalCenter.get(recordId)+' if you have any questions or concerns and use this letter as reference.');
            singleEmailMessage.setFileAttachments(listofEmailAttachments);
            if(mapOfAuthIdWithContact.get(recordId).Email != null) {
                singleEmailMessageList.add(singleEmailMessage);
            }
            contentVersionList.add(conVer);

            //vendor Email Send
            Messaging.SingleEmailMessage singleEmailMessageVendor = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> listofEmailAttachmentsVendor = new List<Messaging.EmailFileAttachment>();
            if(setOfAuthorizationNonHearingAid.contains(recordId)){
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment(); 
                PageReference ref= Page.NC_EquipmentAuthorization;
                ref.getParameters().put('id',recordId);
                try{
                    Blob blobValue = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                    emailAttachment.setFileName('Equipment_Authorization.pdf');
                    emailAttachment.setBody(blobValue);
                    listofEmailAttachmentsVendor.add(emailAttachment);
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());
                                }
                
            }
            if(setOfAuthorizationHearingAid.contains(recordId)){
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment(); 
                PageReference ref= Page.NC_HA_Authorization;
                ref.getParameters().put('id',recordId);
                try{
                    Blob blobValue = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                    emailAttachment.setFileName('Hearing_Aid_Authorization.pdf');
                    emailAttachment.setBody(blobValue);
                    listofEmailAttachmentsVendor.add(emailAttachment);
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());
                }
                
            }
            
            singleEmailMessageVendor.setSubject( NC_Constant.VENDOR_SUBJECT_AUTHORIZATION +String.valueOf(DateTime.now()));
            singleEmailMessageVendor.setToAddresses(new List<String>{mapOfAuthWithEmail.get(recordId)});
            singleEmailMessageVendor.setPlainTextBody('Dear '+mapofAssetWithVendor.get(recordId)+', Attached is the official authorization for equipments for '+mapofAssetWithConsumer.get(recordId)+'.  Please contact your '+mapofAssetWithRegionalCenter.get(recordId)+' for any questions about this authorization.');
            singleEmailMessageVendor.setFileAttachments(listofEmailAttachmentsVendor);
            if(mapOfAuthWithEmail.get(recordId) != null) {
                singleEmailMessageList.add(singleEmailMessageVendor);
            }
        }

        // Send Email
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);
		createRequestLetters(contentVersionList, requestLetterList);
    }

    /*
    *********************************************************
    @Method Name    : createRequestLetter
    @description    : Create Request Letters for EDS Request
    @param          : Set<Id> setOfAuthorizationId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void createRequestLetter(Set<Id> setOfAuthorizationId) {
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<Request_Letter__c> requestLetterList = new List<Request_Letter__c>();
        Id AuthorizationWeatherRadioRecordTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get(NC_Constant.AUTHORIZATION_RECORDTYPE_WEATHER_RADIO).getRecordTypeId();
        Id AuthorizationHearingAidRecordTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get(NC_Constant.AUTHORIZATION_RECORDTYPE_HEARING_AID).getRecordTypeId();
        Id AuthorizationCAPTELRecordTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get(NC_Constant.AUTHORIZATION_RECORDTYPE_CAPTEL).getRecordTypeId();
        Id AuthorizationOtherRecordTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get(NC_Constant.AUTHORIZATION_RECORDTYPE_EDS_INVOICE).getRecordTypeId();
        Id AuthorizationSubHearingAidRecordTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get(NC_Constant.AUTHORIZATION_RECORDTYPE_SUB_HEARING_AID).getRecordTypeId();
        Set<Id> setOfAuthorizationNonHearingAid = new Set<Id>{AuthorizationWeatherRadioRecordTypeId, AuthorizationCAPTELRecordTypeId, AuthorizationOtherRecordTypeId};
        Set<Id> setOfAuthorizationHearingAid = new Set<Id>{AuthorizationHearingAidRecordTypeId, AuthorizationSubHearingAidRecordTypeId};
        Set<Id> edsAuthIds = new Set<Id>{AuthorizationWeatherRadioRecordTypeId, AuthorizationHearingAidRecordTypeId, AuthorizationSubHearingAidRecordTypeId, AuthorizationCAPTELRecordTypeId, AuthorizationOtherRecordTypeId};
        
        for(Authorization__c auth: [SELECT recordTypeId, Request__r.CaseNumber, Consumer__r.Preferred_Contact_Method__c FROM Authorization__c WHERE id IN: setOfAuthorizationId AND recordTypeId IN: edsAuthIds AND Consumer__r.Preferred_Contact_Method__c != null AND Consumer__r.Preferred_Contact_Method__c !=: NC_Constant.EMAIL_PPREFERRED_CONTACT]) {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = auth.Request__r.CaseNumber + '.pdf';
            conVer.Title = auth.Request__r.CaseNumber + ' - Consumer Approval Letter';
            
            Request_Letter__c requestLetter = new Request_Letter__c();
            requestLetter.name = auth.Request__r.CaseNumber + ' - Consumer Approval Letter';
            requestLetter.Request__c = auth.Request__c;
            requestLetter.Consumer__c = auth.Consumer__c;
            requestLetter.Mailed__c = auth.Consumer__r.Preferred_Contact_Method__c == NC_Constant.EMAIL_PPREFERRED_CONTACT ? true : false;
            requestLetterList.add(requestLetter);

            if(setOfAuthorizationNonHearingAid.contains(auth.recordTypeId)){
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment(); 
                PageReference ref= Page.NC_WeatherRadioApprovalConsumer;
                ref.getParameters().put('id',auth.id);
                try{
                    conVer.VersionData = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());
                }
            }
            if(setOfAuthorizationHearingAid.contains(auth.recordTypeId)){
                PageReference ref= Page.NC_HA_ConsumerApproval;
                ref.getParameters().put('id',auth.id);
                try{
                    conVer.VersionData = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());
                }
            }
            contentVersionList.add(conVer);
            createRequestLetters(contentVersionList, requestLetterList);
        }
    }

    /*
    *********************************************************
    @Method Name    : sendEmailForExternalAuthorization
    @description    : send Email Method to send Bulk Emails to related Vendor in future Callout
    @param          : Set<Id> setOfAuthorizationId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void sendEmailForExternalAuthorization(Set<Id> setOfAuthorizationId) {
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id, String> mapOfAuthWithEmail = new Map<Id, String>();

        for(Authorization__c auth : [SELECT Vendor__c, vendor__r.Email__c, Vendor__r.Preferred_Method_of_Contact__c FROM Authorization__c WHERE Id IN: setOfAuthorizationId]){
            if(auth.Vendor__r.Preferred_Method_of_Contact__c == NC_Constant.EMAIL_PPREFERRED_CONTACT){
                mapOfAuthWithEmail.put(auth.Id, auth.vendor__r.Email__c);
            }
        }
        
        for(Id recordId : setOfAuthorizationId){
            if(mapOfAuthWithEmail.containsKey(recordId)){
                //Consumer Email Send
                Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
                List<Messaging.EmailFileAttachment> listofEmailAttachments = new List<Messaging.EmailFileAttachment>();
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment(); 
                PageReference ref= Page.NC_InterpreterAuthorizationDocument;
                try{
                    Blob blobValue = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                    emailAttachment.setFileName('Authorization.pdf');
                    emailAttachment.setBody(blobValue);
                    listofEmailAttachments.add(emailAttachment);
                }catch(Exception e){
                    throw new AuraHandledException('Error: '+e.getMessage());              
                }
                singleEmailMessage.setSubject(NC_Constant.EXTERNAL_AUTHORIZATION_SUBJECT +String.valueOf(DateTime.now()));
                singleEmailMessage.setToAddresses(new List<String>{mapOfAuthWithEmail.get(recordId)});
                singleEmailMessage.setPlainTextBody(NC_Constant.EXTERNAL_AUTHORIZATION_BODY);
                singleEmailMessage.setFileAttachments(listofEmailAttachments);
                singleEmailMessageList.add(singleEmailMessage);
            }
        }

        if(!singleEmailMessageList.isEmpty()){
            Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);
        }

    }

    /*
    *********************************************************
    @Method Name    : sendEmailOnRequestDenial
    @description    : send Email on request denial
    @param          : Map<Id,Id> mapOfConsumerWithCase
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void sendEmailOnRequestDenial(Map<Id,Id> mapOfConsumerWithCase) {
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
		List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<Request_Letter__c> requestLetterList = new List<Request_Letter__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT caseNumber, Contact.Preferred_Contact_Method__c, Contact.Email FROM Case WHERE Id IN: mapOfConsumerWithCase.keySet()]);
        
        for(Id recordId : mapOfConsumerWithCase.keySet()){
            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment EmailAttachments = new Messaging.EmailFileAttachment();
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = recordId + '.pdf';
            conVer.Title = caseMap.get(recordId).CaseNumber + ' - Consumer Denial Letter';

            Request_Letter__c requestLetter = new Request_Letter__c();
            requestLetter.name = caseMap.get(recordId).CaseNumber + ' - Consumer Denial Letter';
            requestLetter.Request__c = recordId;
            requestLetter.Consumer__c = mapOfConsumerWithCase.get(recordId);
            requestLetter.Mailed__c = caseMap.get(recordId).Contact.Preferred_Contact_Method__c == NC_Constant.EMAIL_PPREFERRED_CONTACT ? true : false;
            requestLetterList.add(requestLetter);
            
            PageReference ref= Page.NC_DenialLetterForEquipment;
            ref.getParameters().put('id',recordId);
            try{
                Blob blobValue = !Test.isRunningTest() ? ref.getContentAsPDF() : Blob.valueOf('Test Doc');
                EmailAttachments.setFileName('Denial_Letter_Equipment.pdf');
                EmailAttachments.setBody(blobValue);
                conVer.VersionData = blobValue;
            }catch(Exception e){
                EmailAttachments.setBody(Blob.valueOf('test'));
            }
            singleEmailMessage.setSubject( NC_Constant.REQUEST_DENIED_EMAIL_SUBJECT + String.valueOf(DateTime.now()));
            singleEmailMessage.setTargetObjectId(mapOfConsumerWithCase.get(recordId));
            singleEmailMessage.setPlainTextBody(NC_Constant.REQUEST_DENIED_EMAIL_BODY);
            singleEmailMessage.setFileAttachments(new List<Messaging.EmailFileAttachment>{EmailAttachments});
            if(caseMap.get(recordId).Contact.Email != null) {
                singleEmailMessageList.add(singleEmailMessage);
            }
            contentVersionList.add(conVer);
        }
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);
		createRequestLetters(contentVersionList, requestLetterList);
    }
    
    public static void createRequestLetters(List<ContentVersion> contentVersionList, List<Request_Letter__c> requestLetterList) {
        System.debug('contentVersionList-->'+contentVersionList);
        System.debug('requestLetterList-->'+requestLetterList);
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        List<Request_Letter__c> updateRequestLetters = new List<Request_Letter__c>();
        Map<String, String> requestLetterDocMap = new Map<String, String>();
        if(contentVersionList.size() > 0) {
            insert contentVersionList;
        }
        if(requestLetterList.size() > 0) {
            insert requestLetterList;
            for(Request_Letter__c requestLetter: requestLetterList) {
                requestLetterDocMap.put(requestLetter.Request__c+'.pdf', requestLetter.id);
            }
        }
        if(contentVersionList.size() > 0 && requestLetterDocMap.size() > 0) {
            for (ContentVersion cv: [SELECT contentDocumentId, PathOnClient FROM ContentVersion WHERE Id in :contentVersionList]) {
                System.debug('cv.PathOnClient-->'+cv.PathOnClient);
                if(requestLetterDocMap.containsKey(cv.PathOnClient)) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = requestLetterDocMap.get(cv.PathOnClient);
                    conDocLink.ContentDocumentId = cv.contentDocumentId;
                    conDocLink.shareType = 'V';
                    conDocLink.Visibility = 'AllUsers';
                    contentDocLinkList.add(conDocLink);

                    Request_Letter__c requestLetter = new Request_Letter__c();
                    requestLetter.id = requestLetterDocMap.get(cv.PathOnClient);
                    requestLetter.ContentDocumentId__c = cv.contentDocumentId;
                    updateRequestLetters.add(requestLetter);
                }
            }
        }
        if(contentDocLinkList.size() > 0) {
            insert contentDocLinkList;
        }
        if(updateRequestLetters.size() > 0) {
            update updateRequestLetters;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : semdEmailToGroups
    @description    : send email to a group of users
    @param          : Map<String,Set<Id>> groupNameToRecordIdListMap, String templateApiName
    @return         : void
    ********************************************************
    */
    public static void semdEmailToGroups(Map<String,Set<Id>> groupNameToRecordIdListMap, String templateApiName){
        Map<String,Id> groupNameAndIdMap = new Map<String,Id>();
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Id templateId = [select id,name from EmailTemplate where developername = : templateApiName].id;
        Map<Id, List<Id>> mapOfGroupIdWithUsers = new Map<Id, List<Id>>();
        Messaging.SingleEmailMessage singleEmailMessage;
        
        for(Group publicGroup : [SELECT Id, Name, DeveloperName 
                                 FROM Group WHERE Type =: NC_Constant.PUBLIC_GROUP_TYPE 
                                 AND DeveloperName IN: groupNameToRecordIdListMap.keySet()]) {
                                     groupNameAndIdMap.put(publicGroup.DeveloperName,publicGroup.Id);
                                 }
        
        for(GroupMember groupmemberRecord : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN: groupNameAndIdMap.values()]){
            if(!mapOfGroupIdWithUsers.containsKey(groupmemberRecord.GroupId)){
                mapOfGroupIdWithUsers.put(groupmemberRecord.GroupId, new List<Id>());
            }
            mapOfGroupIdWithUsers.get(groupmemberRecord.GroupId).add(groupmemberRecord.UserOrGroupId);
        }
        
        for(String groupName : groupNameAndIdMap.keySet()){
            if(groupNameToRecordIdListMap.containsKey(groupName)){
                for(Id recordId : groupNameToRecordIdListMap.get(groupName)){
                    //if(mapOfGroupIdWithUsers.containskey(groupNameAndIdMap.get(groupName))){
                    if(mapOfGroupIdWithUsers.containskey(recordId)){
                        //for(Id userId: mapOfGroupIdWithUsers.get(groupNameAndIdMap.get(groupName))){
                         for(Id userId: mapOfGroupIdWithUsers.get(recordId)){
                            singleEmailMessage = Messaging.renderStoredEmailTemplate(templateId,userId,recordId);
                            singleEmailMessage.setTargetObjectId(userId);
                            singleEmailMessage.setSaveAsActivity(false);
                            singleEmailMessageList.add(singleEmailMessage); 
                        } 
                    }
                    
                }
            }
        }  
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailToUser
    @description    : send email to a user
    @param          : Map<Id,Set<Id>> userIdToRecordIdMap, String templateApiName
    @return         : void
    ********************************************************
    */
    public static void sendEmailToUser(Map<Id,Set<Id>> userIdToRecordIdMap, String templateApiName){
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Id templateId = [select id,name from EmailTemplate where developername = : templateApiName].id;
        Messaging.SingleEmailMessage singleEmailMessage;
        for(Id userId : userIdToRecordIdMap.keySet()){
            for(Id recordId : userIdToRecordIdMap.get(userId)){
                singleEmailMessage = Messaging.renderStoredEmailTemplate(templateId,userId,recordId);
                singleEmailMessage.setTargetObjectId(userId);
                singleEmailMessage.setSaveAsActivity(false);
                singleEmailMessageList.add(singleEmailMessage);
            }
        }
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);
    }

    /*
    *********************************************************
    @Method Name    : notifieBudgetManagerOnBudgetLow
    @description    : send Email Method to send Bulk Emails to budget Managers
    @param          : List<NC_BudgetManagementController.budgetNotifier> budgetNotfierList
    @return         : void
    ********************************************************
    */
    public static void notifieBudgetManagerOnBudgetLow(List<NC_BudgetManagementController.budgetNotifier> budgetNotfierList) {
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();

        for(NC_BudgetManagementController.budgetNotifier budgetNotifierRecord : budgetNotfierList){
            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
            singleEmailMessage.setSubject('Low Budget, Please review!');
            singleEmailMessage.setTargetObjectId(budgetNotifierRecord.UserId);
            singleEmailMessage.setHtmlBody(budgetNotifierRecord.budgetMessage + budgetNotifierRecord.budgetURL);
            singleEmailMessage.setSaveAsActivity(false);
            singleEmailMessageList.add(singleEmailMessage);
        }
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);

    }

    /*
    *********************************************************
    @Method Name    : notifieResourceLoanOwner
    @description    : send Email Method to Resource loan owner
    @param          : Map<Id, String> mapOfOwnerWithMessage
    @return         : void
    ********************************************************
    */
    public static void notifieResourceLoanOwner(Map<Id, String> mapOfOwnerWithMessage) {
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();

        for(Id OwnerId : mapOfOwnerWithMessage.keySet()){
            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
            singleEmailMessage.setSubject('Resource available');
            singleEmailMessage.setTargetObjectId(OwnerId);
            singleEmailMessage.setHtmlBody(mapOfOwnerWithMessage.get(OwnerId));
            singleEmailMessage.setSaveAsActivity(false);
            singleEmailMessageList.add(singleEmailMessage);
        }
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);

    }
    
    /*
    *********************************************************
    @Method Name    : notifieOwnerForDifferentRegionalCenter
    @description    : send Email Method to notify the user for different regional center.
    @param          : Map<Id,Case> assetToNewRequestMap,List<Asset__c> assetToSendRecordList
    @return         : void
    ********************************************************
    */
    public static void notifieOwnerForDifferentRegionalCenter(Map<Id,Case> assetToNewRequestMap,List<Asset__c> assetToSendRecordList){
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        Map<Id,String> regionalCenterIdToNameMap = NC_Utility.getRegionalCenterIdToNameMap();
        for(Asset__c assetRecord : assetToSendRecordList){
            Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();
            singleEmailMessage.setSubject('Asset Reassigned');
            singleEmailMessage.setTargetObjectId(assetRecord.Request__r.OwnerId);
            singleEmailMessage.setHtmlBody('The item with Asset number '+ assetRecord.Name +' assigned to complete the Request number '+assetToNewRequestMap.get(assetRecord.Id).CaseNumber +' is being reassigned from '+ regionalCenterIdToNameMap.get(assetRecord.Request__r.Regional_Center__c) +'. Please contact '+ regionalCenterIdToNameMap.get( assetToNewRequestMap.get(assetRecord.Id).Regional_Center__c) +'  to confirm the location of item, and arrange for shipment to your Regional Center.');
            singleEmailMessage.setSaveAsActivity(false);
            singleEmailMessageList.add(singleEmailMessage);
        }
        Messaging.SendEmailResult [] result = Messaging.sendEmail(singleEmailMessageList);
    }
    
    
}