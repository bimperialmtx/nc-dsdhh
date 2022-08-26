/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without Sharing class NC_AttendeesTriggerHandler {
    private static List<EmailTemplate> emailTemplateOutReachAssessor =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_Outreach_Assessor_Invitation_1'];
    
    /*
*********************************************************
@Method Name    : beforeInsert
@description    : Executes trigger before insert event
@param          : List<Attendees__c> newList
@return         : void
********************************************************
*/
    public static void beforeInsert(List<Attendees__c> newList){
        createCommunityAssessor(newList,null);
        externalAssessorUser(newList,null);
    }
    
    /*
*********************************************************
@Method Name    : afterInsert
@description    : Executes trigger after insert event
@param          : List<Attendees__c> newList
@return         : void
********************************************************
*/
    public static void afterInsert(List<Attendees__c> newList){
        sendEmailToAssessorAfterInsert(newList,null);
        sendEmailForAssessorAcceptance(newList, null);
        
    }
    
    /*
*********************************************************
@Method Name    : afterUpdate
@description    : Executes trigger after update event
@param          : List<Attendees__c> newList,Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void afterUpdate(List<Attendees__c> newList,Map<Id,Attendees__c> oldMap){
        sendEmailToAssessorAfterUpdate(newList,oldMap);
        createAuthorizationOnTrainerAcceptance(newList,oldMap);
        sendEmailForInvitationForAssessorAfterAcceptance(newList,oldMap);
        // externalAssessorUser(newList, oldMap);
        
    }
    
    /*
*********************************************************
@Method Name    : beforeUpdate
@description    : Executes trigger before update event
@param          : List<Attendees__c> newList,Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void beforeUpdate(List<Attendees__c> newList,Map<Id,Attendees__c> oldMap){
        
        
    }
    
    /*
*********************************************************
@Method Name    : sendEmailToAssessorAfterInsert
@description    : Send email to Assessor after it is added as Attendee
@param          : List<Attendees__c> newList,Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailToAssessorAfterInsert(List<Attendees__c> newList,Map<Id,Attendees__c> oldMap){
        List<Id> externalIdList = new List<Id>();
        List<Id> internalIdList = new List<Id>();
        List<Id> accountUserList = new List<Id>();
        Map<Id,String> externalEmailMap = new Map<Id,String>();
        Map<Id,String> internalEmailMap = new Map<Id,String>();
        Map<Id,String> internalIdToNameMap = new Map<Id,String>();
        Map<Id,String> externalIdToNameMap = new Map<Id,String>();
        for(Attendees__c attend:newList){
            if(attend.External_Assessor__c!=null  ) {
                externalIdList.add(attend.External_Assessor__c);
            }
            if(attend.Internal_Assessor__c!=null   ){
                internalIdList.add(attend.Internal_Assessor__c);
            }
        }
        if(internalIdList.size()>0){
            for(User use:[SELECT Id,Email,Name FROM User WHERE Id IN:internalIdList AND Email!=null]){
                internalEmailMap.put(use.Id,use.Email);
                internalIdToNameMap.put(use.Id,use.Name);
            }
        }
        if(externalIdList.size()>0){ 
            for(Account account:[SELECT Id,First_Name__c,Last_Name__c ,Name,Email__c,Is_Vendor_on_Portal__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :externalIdList AND Email__c!=null WITH SECURITY_ENFORCED]){
                if(account.Contacts.size()==0 ){
                    externalEmailMap.put(account.Id,account.Email__c);
                    externalIdToNameMap.put(account.Id,account.Name);
                }
                else{
                    accountUserList.add(account.Id);
                }
            }
        }
        if(accountUserList.size()>0){
            for(User userValue:[SELECT Id,Email,Name,AccountId  FROM USER WHERE AccountId IN: accountUserList AND Email!=null]){
                externalEmailMap.put(userValue.AccountId,userValue.Email);
                externalIdToNameMap.put(userValue.AccountId,userValue.Name);
                
            }
        }
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<String> emailList = new List<String>();
        for(Attendees__c attend:[SELECT Id,Name,Internal_Assessor__r.Id,External_Assessor__r.Id,Outreach_Request__r.Name FROM Attendees__c WHERE Id IN:newList]){
            if(attend.External_Assessor__c!=null   || attend.Internal_Assessor__c!=null    ){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                String plainBody = emailTemplateOutReachAssessor[0].Body;
                String htmlBody = emailTemplateOutReachAssessor[0].HtmlValue;
                if(attend.Internal_Assessor__c!=null ){
                    emailList.add(internalEmailMap.get(attend.Internal_Assessor__r.Id));
                    htmlBody = htmlBody.replace('{!Attendees__c.Name}',internalIdToNameMap.get(attend.Internal_Assessor__r.Id)); 
                    plainBody = plainBody.replace('{!Attendees__c.Name}',internalIdToNameMap.get(attend.Internal_Assessor__r.Id));
                }
                else {
                    emailList.add(externalEmailMap.get(attend.External_Assessor__r.Id));
                    htmlBody = htmlBody.replace('{!Attendees__c.Name}',externalIdToNameMap.get(attend.External_Assessor__r.Id)); 
                    plainBody = plainBody.replace('{!Attendees__c.Name}',externalIdToNameMap.get(attend.External_Assessor__r.Id)); 
                }
                
                plainBody = plainBody.replace('{!Case.CaseNumber}',attend.Outreach_Request__r.Name );
                htmlBody = htmlBody.replace('{!Case.CaseNumber}',attend.Outreach_Request__r.Name); 
                htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                message.setHtmlBody(htmlBody);
                message.setPlainTextBody(plainBody);   
                message.setTemplateID(emailTemplateOutReachAssessor[0].Id);  
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(false);
                message.setSubject('Assessor Invitation'); 
                messages.add(message);   
            }
            
        }
        if(messages.size()>0 && emailList.size()>0){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailToAssessorAfterUpdate
@description    : Send email to Assessor after it is updated as Attendee
@param          : List<Attendees__c> newList,Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailToAssessorAfterUpdate(List<Attendees__c> newList,Map<Id,Attendees__c> oldMap){
        List<Id> externalIdList = new List<Id>();
        List<Id> internalIdList = new List<Id>();
        List<Id> accountUserList = new List<Id>();
        Map<Id,String> externalEmailMap = new Map<Id,String>();
        Map<Id,String> internalEmailMap = new Map<Id,String>();
        Map<Id,String> internalIdToNameMap = new Map<Id,String>();
        Map<Id,String> externalIdToNameMap = new Map<Id,String>();
        for(Attendees__c attend:newList){
            if(attend.External_Assessor__c!=null &&  attend.External_Assessor__c!=oldMap.get(attend.Id).External_Assessor__c ) {
                externalIdList.add(attend.External_Assessor__c);
            }
            if(attend.Internal_Assessor__c!=null  && attend.Internal_Assessor__c!=oldMap.get(attend.Id).Internal_Assessor__c){
                internalIdList.add(attend.Internal_Assessor__c);
            }
        }
        if(internalIdList.size()>0){
            for(User use:[SELECT Id,Email,Name FROM User WHERE Id IN:internalIdList AND Email!=null AND IsActive=true]){
                internalEmailMap.put(use.Id,use.Email);
                internalIdToNameMap.put(use.Id,use.Name);
            }
        }
        if(externalIdList.size()>0){ 
            for(Account account:[SELECT Id,First_Name__c,Last_Name__c ,Name,Email__c,Is_Vendor_on_Portal__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :externalIdList AND Email__c!=null WITH SECURITY_ENFORCED]){
                if(account.Contacts.size()==0 ){
                    externalEmailMap.put(account.Id,account.Email__c);
                    externalIdToNameMap.put(account.Id,account.Name);
                }
                else{
                    accountUserList.add(account.Id);
                }
            }
        }
        if(accountUserList.size()>0){
            for(User userValue:[SELECT Id,Email,AccountId ,Name FROM USER WHERE AccountId IN: accountUserList AND IsActive=true AND Email!=null WITH SECURITY_ENFORCED]){
                externalEmailMap.put(userValue.AccountId,userValue.Email);
                externalIdToNameMap.put(userValue.AccountId,userValue.Name);
                
            }
        }
        
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        // List<String> emailList = new List<String>();
        for(Attendees__c attend:[SELECT Id,Name,External_Assessor__c,Internal_Assessor__c,Internal_Assessor__r.Id,External_Assessor__r.Id,Outreach_Request__r.Name FROM Attendees__c WHERE Id IN:newList WITH SECURITY_ENFORCED]){
            if((attend.External_Assessor__c!=null &&  attend.External_Assessor__c!=oldMap.get(attend.Id).External_Assessor__c)   || (attend.Internal_Assessor__c!=null  && attend.Internal_Assessor__c!=oldMap.get(attend.Id).Internal_Assessor__c) ){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                List<String> emailList = new List<String>();
                String plainBody = emailTemplateOutReachAssessor[0].Body;
                String htmlBody = emailTemplateOutReachAssessor[0].HtmlValue;
                if(attend.Internal_Assessor__c!=null ){
                    emailList.add(internalEmailMap.get(attend.Internal_Assessor__r.Id));
                    htmlBody = htmlBody.replace('{!Attendees__c.Name}',internalIdToNameMap.get(attend.Internal_Assessor__r.Id)); 
                    plainBody = plainBody.replace('{!Attendees__c.Name}',internalIdToNameMap.get(attend.Internal_Assessor__r.Id));
                }
                else {
                    emailList.add(externalEmailMap.get(attend.External_Assessor__r.Id));
                    htmlBody = htmlBody.replace('{!Attendees__c.Name}',externalIdToNameMap.get(attend.External_Assessor__r.Id)); 
                    plainBody = plainBody.replace('{!Attendees__c.Name}',externalIdToNameMap.get(attend.External_Assessor__r.Id)); 
                }
                
                plainBody = plainBody.replace('{!Case.CaseNumber}',attend.Outreach_Request__r.Name );
                htmlBody = htmlBody.replace('{!Case.CaseNumber}',attend.Outreach_Request__r.Name); 
                htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                message.setHtmlBody(htmlBody);
                message.setPlainTextBody(plainBody);   
                message.setTemplateID(emailTemplateOutReachAssessor[0].Id);  
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(false);
                message.setSubject('Assessor Invitation'); 
                messages.add(message);   
                
                
            }
            
        }
        if(messages.size()>0 ){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        }
    }
    
    /*
*********************************************************
@Method Name    : createCommunityAssessor
@description    : Create Portal user from NDBEDP Trainer
@param          : List<Attendees__c> attendeesList , Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void createCommunityAssessor(List<Attendees__c> attendeesList , Map<Id,Attendees__c> oldMap){
        Map<Id,List<Contact>> accountToContact = new Map<Id,List<Contact>>();
        List<Id> accountIdList = new List<Id>();
        List<Contact> insertContactList = new List<Contact>();
        for(Attendees__c attendeesValue:attendeesList){
            if(attendeesValue.NDBEDP_Trainer__c != null ){
                accountIdList.add(attendeesValue.NDBEDP_Trainer__c);
            }
        }
        for(Account account:[SELECT Id,First_Name__c,Last_Name__c ,Email__c,Is_Vendor_on_Portal__c,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountIdList AND Is_Vendor_on_Portal__c=true AND Status__c ='Approved' WITH SECURITY_ENFORCED]){
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
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Contact', insertContactList, 'insert', true,'NC_AttendeesTriggerHandler','createCommunityAssessor');
            insert objectDecision.getRecords();
            // Insert insertContactList;
        }
        List<Id> contactstCommunityUser = new List<Id>();
        List<Contact> lContacts = [SELECT Id,AccountId FROM Contact WHERE AccountId IN :accountIdList WITH SECURITY_ENFORCED]; 
        for(User use :[SELECT Id,Contact.Id,Name,Email FROM User WHERE (Profile.Name = 'NDBEDP Assessor' OR Profile.Name = 'Vendor Community User Profile') AND ContactId IN :lContacts]){
            contactstCommunityUser.add(use.Contact.Id);
        }
        
        //if(contactstCommunityUser)
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='NDBEDP Assessor' WITH SECURITY_ENFORCED Limit 1 ];
        List<User> InsertUserList = new List<User>();
        for(Contact con :[SELECT Id,AccountId,LastName,FirstName,Email FROM Contact WHERE AccountId IN :accountIdList WITH SECURITY_ENFORCED]){
            if(!contactstCommunityUser.contains(con.Id)){
                User user1 = new User(
                    UserName = con.Email+Integer.valueOf(Math.random()*100),
                    FirstName = con.FirstName,
                    LastName = con.LastName,
                    Alias = Integer.valueOf(Math.random()*100)+'',
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
            insert InsertUserList;
        }    
    }
    
    /*
*********************************************************
@Method Name    : externalAssessorUser
@description    : Create Portal user from External Assessor
@param          : List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void externalAssessorUser(List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap) {
        Map<Id,Id> totalAccountMap = new Map<Id,Id>();
        Map<Id,Id> totalUserToContactMap = new Map<Id,Id>();
        Map<Id,Id> totalUserToContactAdditionalTrainingMap = new Map<Id,Id>();
        
        
        for(Account account:[SELECT Id, OwnerId,(SELECT Id FROM Contacts) FROM Account WHERE Active__c = true  AND Status__c = 'Approved' AND Active__c= true WITH SECURITY_ENFORCED]){
            for(Contact con:account.Contacts){
                totalUserToContactAdditionalTrainingMap.put(account.Id,con.Id);
            }
        }
        
        for(User use:[SELECT Id,contactId,IsPortalEnabled FROM User WHERE IsPortalEnabled=true]){
            totalUserToContactMap.put(use.contactId,use.Id);
        }
        List<Account> accountList = new List<Account>();
        List<Attendees__c> AttendeesNewList = new List<Attendees__c>();
        
        List<User> userPresent =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1];
        
        for(Attendees__c AttendeesValue:AttendeesList){
            
            if(AttendeesValue.NDBEDP_Trainer__c!=null ){
                // Attendees__c AttendeesNewValue =new Attendees__c();
                //  AttendeesNewValue.Id =AttendeesValue.Id;
                if(totalUserToContactMap.get(totalUserToContactAdditionalTrainingMap.get(AttendeesValue.NDBEDP_Trainer__c))==null){
                    if(userPresent.size()>0){
                    AttendeesValue.NDBEDP_Trainer_User__c=userPresent[0].Id;
                    }
                    AttendeesValue.showInternalAssessor__c = true;
                }
                else{
                    AttendeesValue.NDBEDP_Trainer_User__c=totalUserToContactMap.get(totalUserToContactAdditionalTrainingMap.get(AttendeesValue.NDBEDP_Trainer__c));
                }
                AttendeesValue.Trainer_Result__c=null;
                //  caseNewValue.showInternalAssessor__c=true;
                //  AttendeesNewList.add(AttendeesNewValue);
                
            }
        }
        // if(AttendeesNewList.size()>0){
        //     update AttendeesNewList;
        // }
        
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForAssessorAcceptance
@description    : Send email to Assessir for invitatoin
@param          : List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailForAssessorAcceptance(List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap) {
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS' WITH SECURITY_ENFORCED];
        List<EmailTemplate> emailTemplateNDBEDPAdditionalTrainingInvitation =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_Outreach_Trainer' WITH SECURITY_ENFORCED ];
        Id ndbedpAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_NDBEP_Trainer');
        List<Id> trainerIdList = new List<Id>();
        Map<Id,String> trainerEmailMap = new Map<Id,String>();
        for(Attendees__c AttendeesValue:AttendeesList){
            if(AttendeesValue.NDBEDP_Trainer__c!=null  && AttendeesValue.recordTypeId == ndbedpAdditionalTrainingRecordTypeId){
                trainerIdList.add(AttendeesValue.NDBEDP_Trainer__c);
            }
        }
        
        if(trainerIdList.size()>0){
            for(User userValue:[SELECT Id,Email,AccountId  FROM USER WHERE AccountId IN: trainerIdList AND IsActive=true WITH SECURITY_ENFORCED]){
                trainerEmailMap.put(userValue.AccountId,userValue.Email);
                
            }
        }
        
        List<User> userPresent =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1];
        
        List<CaseShare> csShareList = new List<CaseShare>();
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<String> emailList = new List<String>();
        for(Attendees__c AttendeesValue:[SELECT Id,RecordTypeId,NDBEDP_Trainer_User__r.Name,Outreach_Request__r.Start_Date_of_Event__c,Outreach_Request__r.End_Date_of_Event__c,NDBEDP_Trainer__c,Name,Contact__c FROM Attendees__c WHERE Id IN:AttendeesList WITH SECURITY_ENFORCED]){
            if(AttendeesValue.NDBEDP_Trainer__c!=null ) {
                String URLValue= 'https://'+domains[0].Domain +'/s/assessoracceptance?Id=' +AttendeesValue.Id;
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+AttendeesValue.Id;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                if(AttendeesValue.NDBEDP_Trainer__c!=null && AttendeesValue.RecordTypeId == ndbedpAdditionalTrainingRecordTypeId){
                    String plainBody = emailTemplateNDBEDPAdditionalTrainingInvitation[0].Body;
                    String htmlBody = emailTemplateNDBEDPAdditionalTrainingInvitation[0].HtmlValue;
                    if(trainerEmailMap.size()==0){
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl );
                        plainBody = plainBody.replace('{!Case.Source}',String.valueOf(AttendeesValue.Outreach_Request__r.Start_Date_of_Event__c  ) );
                        plainBody = plainBody.replace('{!Case.Reason}',String.valueOf(AttendeesValue.Outreach_Request__r.End_Date_of_Event__c )  );
                        plainBody = plainBody.replace('{!Case.Contact}','');
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                        htmlBody = htmlBody.replace('{!Case.Source}',String.valueOf(AttendeesValue.Outreach_Request__r.Start_Date_of_Event__c  ) );
                        htmlBody = htmlBody.replace('{!Case.Reason}',String.valueOf(AttendeesValue.Outreach_Request__r.End_Date_of_Event__c  ) );
                        htmlBody = htmlBody.replace('{!Case.Contact}','');
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        if(userPresent.size()>0){
                        emailList.add(userPresent[0].Email);
                        }
                        message.setHtmlBody(htmlBody);
                        message.setPlainTextBody(plainBody);   
                        message.setTemplateID(emailTemplateNDBEDPAdditionalTrainingInvitation[0].Id);   
                        message.setSubject('Trainer Invitation');    
                    }
                    else{
                        plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue );
                        plainBody = plainBody.replace('{!Case.Source}',String.valueOf(AttendeesValue.Outreach_Request__r.Start_Date_of_Event__c )  );
                        plainBody = plainBody.replace('{!Case.Reason}',String.valueOf(AttendeesValue.Outreach_Request__r.End_Date_of_Event__c )  );
                        plainBody = plainBody.replace('{!Case.Contact}',AttendeesValue.NDBEDP_Trainer_User__r.Name );
                        htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                        htmlBody = htmlBody.replace('{!Case.Source}',String.valueOf(AttendeesValue.Outreach_Request__r.Start_Date_of_Event__c )  );
                        htmlBody = htmlBody.replace('{!Case.Reason}',String.valueOf(AttendeesValue.Outreach_Request__r.End_Date_of_Event__c )  );
                        htmlBody = htmlBody.replace('{!Case.Contact}',AttendeesValue.NDBEDP_Trainer_User__r.Name );
                        htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                        emailList.add(trainerEmailMap.get(AttendeesValue.NDBEDP_Trainer__c));
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
                
                message.setTargetObjectId(AttendeesValue.Contact__c);  
                message.setTreatTargetObjectAsRecipient(false);
                message.setSaveAsActivity(false);
                messages.add(message);
            }
        }
        if(messages.size()>0 && emailList.size()>0){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        }
        
        if( csShareList != null && csShareList.size() != 0 ) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('CaseShare', csShareList, 'insert', true,'NC_AttendeesTriggerHandler','sendEmailForAssessorAcceptance');
            insert objectDecision.getRecords();
            // insert csShareList;
            
        }
        // }
        
        
    }
    
    /*
*********************************************************
@Method Name    : createAuthorization
@description    : Create Authorization record based on Attendees record
@param          : Attendees__c attendeesRecord, String authRecordTypeId
@return         : Authorization__c
********************************************************
*/
    public static Authorization__c createAuthorization(Attendees__c attendeesRecord, String authRecordTypeId) {
        Authorization__c authRecord = new Authorization__c();
        authRecord.recordTypeId = authRecordTypeId;
        authRecord.Vendor__c = attendeesRecord.NDBEDP_Trainer__c;
        authRecord.Trainer_Administrator_User__c=attendeesRecord.NDBEDP_Trainer_User__c;
        authRecord.Outreach_Request__c = attendeesRecord.Outreach_Request__c;
        authRecord.Status__c = 'Approved';
        // if(caseRecord.TRC_UserRole__c == 'NDBEDP_Coordinator' || caseRecord.TRC_UserRole__c == 'Deaf_Services_Specialist' || caseRecord.TRC_UserRole__c == 'Deaf_Blind_Services_Specialist'){
        //     authRecord.Authorization_Email_Link__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseRecord.Id;
        // }
        // else{
        //     authRecord.Authorization_Email_Link__c =  'https://'+domains[0].Domain +'/' +caseRecord.Id;
        // }
        return authRecord;
        
    }
    //     createAuthorization(Attendees__c attendeesRecord, String authRecordTypeId)
    // authRecordTypeId = 'NDBEDP Training Event'
    
    /*
*********************************************************
@Method Name    : createAuthorizationOnTrainerAcceptance
@description    : Create Authorization record based on Attendees record and insert
@param          : List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void createAuthorizationOnTrainerAcceptance(List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap){
        List<Authorization__c> listOfAuthorization = new List<Authorization__c>();
        Id authorizationRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Training_Event');
        for(Attendees__c attendee :[SELECT Id,NDBEDP_Trainer__c,NDBEDP_Trainer_User__c,Trainer_Result__c,Outreach_Request__c FROM Attendees__c WHERE Id IN:AttendeesList WITH SECURITY_ENFORCED]){
            if(attendee.Trainer_Result__c == 'Accept' && attendee.Trainer_Result__c!=oldMap.get(attendee.Id).Trainer_Result__c){
                listOfAuthorization.add(createAuthorization( attendee,  authorizationRecordTypeId));
            }
        }
        if(listOfAuthorization.size()>0){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', listOfAuthorization, 'insert', true,'NC_AttendeesTriggerHandler','createAuthorizationOnTrainerAcceptance');
            insert objectDecision.getRecords();
            // Insert listOfAuthorization;
        }
    }
    
    /*
*********************************************************
@Method Name    : sendEmailForInvitationForAssessorAfterAcceptance
@description    : Send email to assessor after acceptance of invitation
@param          : List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap
@return         : void
********************************************************
*/
    public static void sendEmailForInvitationForAssessorAfterAcceptance(List<Attendees__c> AttendeesList, Map<Id,Attendees__c> oldMap) {
        Id ndbedpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Attendees__c','Attendees_For_NDBEP_Trainer');
        
        // User userValue =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1];
        List<Id> ndbedpAcceptList = new List<Id>();
        List<Id> ndbedpRejectList = new List<Id>();
        Map<Id,String> externalEmailMap = new Map<Id,String>();
        Map<Id,String> internalEmailMap = new Map<Id,String>();
        Map<Id,String> trainerEmailMap = new Map<Id,String>();
        for(Attendees__c AttendeesValue:AttendeesList){
            if(AttendeesValue.Trainer_Result__c!=null && oldMap.get(AttendeesValue.Id).Trainer_Result__c!=AttendeesValue.Trainer_Result__c && AttendeesValue.Trainer_Result__c == 'Accept' && AttendeesValue.RecordtypeId == ndbedpRecordTypeId){
                ndbedpAcceptList.add(AttendeesValue.Id);
                // caseValue.Assessor_Invitation_Accepted_Date__c = Date.today();
            }
            if(AttendeesValue.Trainer_Result__c!=null && oldMap.get(AttendeesValue.Id).Trainer_Result__c!=AttendeesValue.Trainer_Result__c && AttendeesValue.Trainer_Result__c == 'Reject' && AttendeesValue.RecordtypeId == ndbedpRecordTypeId){
                ndbedpRejectList.add(AttendeesValue.Id);
            }
        }
        
        List<User> userPresent =[SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' AND Profile.Name ='Assistant' AND isActive=true LIMIT 1 ];
        
        List<EmailTemplate> emailTemplateNDBEDPEquipmentInvitationAccept =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_OutReach_Invitation_Accepted_1' WITH SECURITY_ENFORCED];
        List<EmailTemplate> emailTemplateNDBEDPEquipmentInvitationReject =  [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='NC_NDBEDP_outreach_Request_Invitation_Rejected_1' WITH SECURITY_ENFORCED ];
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        List<String> emailList = new List<String>();
        for(Attendees__c AttendeesValue:[SELECT Id,RecordTypeId,Trainer_Result__c,NDBEDP_Trainer_User__r.Name,Outreach_Request__r.Start_Date_of_Event__c,Outreach_Request__r.End_Date_of_Event__c,NDBEDP_Trainer__c,Name,Contact__c FROM Attendees__c WHERE Id IN:AttendeesList WITH SECURITY_ENFORCED]){
            if(AttendeesValue.Trainer_Result__c!=null && oldMap.get(AttendeesValue.Id).Trainer_Result__c!=AttendeesValue.Trainer_Result__c ){
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                // String plainBody = '' ;
                // String htmlBody ='';
                if(ndbedpAcceptList.size()>0){
                    String plainBody = emailTemplateNDBEDPEquipmentInvitationAccept[0].Body;
                    String htmlBody = emailTemplateNDBEDPEquipmentInvitationAccept[0].HtmlValue;
                    if(Case.External_Assessor_User__c!=null && AttendeesValue.NDBEDP_Trainer_User__c!=null){
                    plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',AttendeesValue.NDBEDP_Trainer_User__r.Name);
                    htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',AttendeesValue.NDBEDP_Trainer_User__r.Name); 
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',AttendeesValue.Name );
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',AttendeesValue.Name); 
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPEquipmentInvitationAccept[0].Id);  
                    message.setSubject('Invitation Accepted'); 
                }
                else if(ndbedpRejectList.size()>0){
                    String plainBody = emailTemplateNDBEDPEquipmentInvitationReject[0].Body;
                    String htmlBody = emailTemplateNDBEDPEquipmentInvitationReject[0].HtmlValue;
                    if(Case.External_Assessor_User__c!=null && AttendeesValue.NDBEDP_Trainer_User__c!=null){
                    plainBody = plainBody.replace('{!Case.External_Assessor_User__c}',AttendeesValue.NDBEDP_Trainer_User__r.Name);
                    htmlBody = htmlBody.replace('{!Case.External_Assessor_User__c}',AttendeesValue.NDBEDP_Trainer_User__r.Name); 
                    }
                    plainBody = plainBody.replace('{!Case.CaseNumber}',AttendeesValue.Name );
                    htmlBody = htmlBody.replace('{!Case.CaseNumber}',AttendeesValue.Name);
                    htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo);  
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateNDBEDPEquipmentInvitationReject[0].Id);
                    message.setSubject('Invitation Rejected');   
                }
                                    
                if(userPresent.size()>0){
                emailList.add(userPresent[0].Email);
                }
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);    
                messages.add(message);
            }
        }
        if(messages.size()>0 && emailList.size()>0){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        }
        
        
        
    }  
}