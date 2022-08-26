/**
 * @description       : Send email to NDBEDP Admin
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_GenerateMatrequestStatusMail implements Database.Batchable<sObject>,Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id,Request__c, MatReqStatus__c, Request__r.Final_Equipment_Shipped_Date__c,Request__r.NDBEDP_Trainer__c,Request__r.NDBEDP_Trainer__r.Email__c FROM Request_Equipment__c WHERE MatReqStatus__c = \'Closed\' AND LastActionCode__c =\'SHC\' ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Request_Equipment__c> requestEquipmentList) {
        EmailTemplate template = [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName = 'NC_NDBEDP_40_to_52_days_MatRequestClosed_Email' LIMIT 1];
        List<Case> caseUpdateList = new List<Case>();

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Request_Equipment__c caseValue : requestEquipmentList){
            if(caseValue.Request__r.Final_Equipment_Shipped_Date__c.daysBetween(Date.today()) >=40 && caseValue.Request__r.Final_Equipment_Shipped_Date__c.daysBetween(Date.today()) <52 ){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                List<String> emailList = new List<String>();
               
                User user=new User();
                for(User u :[SELECT Id,Email,UserRole.Name FROM User WHERE UserRole.Name='NDBEDP Administrator' and IsActive=true]){
                    if(u.Email!=null){
                        emailList.add(u.Email);
                    }
                    user=u;
                }

                List<Id> caseIdList=new List<Id>();
                for(Request_Equipment__c cas :requestEquipmentList){
                    caseIdList.add(cas.Request__c);
                }
                for(Authorization__c auth:[SELECT Id,Vendor__c,Vendor__r.Email__c FROM Authorization__c WHERE Request__c IN :caseIdList AND RecordType.DeveloperName  = 'NDBEDP_Training'] ){
                    if(auth.Vendor__c!=null && auth.Vendor__r.Email__c!=null){
                        emailList.add(auth.Vendor__r.Email__c);
                    }
                }

                // if(caseValue.Request__r.NDBEDP_Trainer__c!=null && caseValue.Request__r.NDBEDP_Trainer__r.Email__c!=null ){
                //     emailList.add(caseValue.Request__r.NDBEDP_Trainer__r.Email__c);
                // }  
                Messaging.SingleEmailMessage newMail= Messaging.renderStoredEmailTemplate(template.id,user.id,caseValue.Request__c); 
                String htmlBody = newMail.HTMLBody;
                message.setHtmlBody(htmlBody);
                message.setTemplateID(template.Id);  
                message.setSubject(newMail.Subject); 
                
                if(emailList.size()>0){
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);    
                messages.add(message); 
                }
                //String plainBody = template.Body;
                // String htmlBody = template.HTMLBody;
                //htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                //message.setPlainTextBody(plainBody);   
                // emailList.add(userIdToMap.get(caseValue.External_Assessor_User__c));
                
            }
    }
    if(messages.size()>0 ){
        Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
        
    }
    }
    public void execute(SchedulableContext sc) {
        // NC_GenerateMatrequestStatusMail batchObject = new NC_GenerateMatrequestStatusMail ();
        // database.executebatch(batchObject);
    }

    public void finish(Database.BatchableContext bc) {

    }
   
}