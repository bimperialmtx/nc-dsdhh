/**
 * @description       : Send Email to External Assessor user
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public class NC_GenerateAssessmentEmail implements Database.Batchable<sObject>,Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id,CaseNumber,Assessor_Invitation_Accepted_Date__c,Assessor_Result__c,External_Assessor_User__c,External_Assessor_User__r.Email,Status FROM Case WHERE Status = \'Pending Assessment\' AND Assessor_Result__c =\'Accept\' AND Assessor_Invitation_Accepted_Date__c!=null AND External_Assessor_User__c!=null AND External_Assessor_User__r.Email!=null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Case> caseList) {
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        List<Id> userIdList = new List<Id>();
        Map<Id,String> userIdToMap = new Map<Id,String>();
        Map<Id,String> userIdToRoleMap = new Map<Id,String>();
        for(Case caseValue:caseList){
            if(caseValue.Status == 'Pending Assessment' && caseValue.Assessor_Result__c == 'Accept' && caseValue.External_Assessor_User__c!=null){
                userIdList.add(caseValue.External_Assessor_User__c);
            }
        }
        for(User use:[SELECT Id,Email,UserRole.DeveloperName FROM User WHERE Id IN:userIdList AND Email !=null AND UserRole.DeveloperName!=null]){
            userIdToMap.put(use.Id,use.Email);
            userIdToRoleMap.put(use.Id,use.UserRole.DeveloperName);
        }
        
        EmailTemplate template = [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName = 'NC_NDBEDP_45_to_60_days_Assessment_Email' LIMIT 1];
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Case caseValue:caseList){
            if(caseValue.Assessor_Invitation_Accepted_Date__c.daysBetween(Date.today()) >45 && caseValue.Assessor_Invitation_Accepted_Date__c.daysBetween(Date.today()) <60 ){
                List<String> emailList = new List<String>();
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+caseValue.Id;
                String URLValue= 'https://'+domains[0].Domain +'/s/assessoracceptance?Id=' +caseValue.Id;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                String plainBody = template.Body;
                String htmlBody = template.HtmlValue;
                // if(caseValue.External_Assessor__c!=null){
                //     if(userIdToRoleMap.get(caseValue.External_Assessor_User__c)=='NDBEDP_Coordinator'){
                //         plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl);
                //         htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                //     }
                //     else{
                //         plainBody = plainBody.replace('{!Case.Assessor_Result__c}',URLValue);
                //         htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',URLValue); 
                //     }
                // }
                // if(caseValue.Internal_Assessor__c!=null){
                //     plainBody = plainBody.replace('{!Case.Assessor_Result__c}',baseUrl);
                //     htmlBody = htmlBody.replace('{!Case.Assessor_Result__c}',baseUrl); 
                // }
                plainBody = plainBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber );
                htmlBody = htmlBody.replace('{!Case.CaseNumber}',caseValue.CaseNumber);  
                htmlBody = htmlBody.replace('{!$Label.Email_Template_Logo}',Label.Email_Template_Logo); 
                message.setHtmlBody(htmlBody);
                message.setPlainTextBody(plainBody);   
                message.setTemplateID(template.Id);  
                message.setSubject('Please Complete the assessment form');      
                emailList.add(userIdToMap.get(caseValue.External_Assessor_User__c));
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false);    
                messages.add(message);   
                
            }
        }
        if(messages.size()>0 ){
            Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);

        }
    }
    public void execute(SchedulableContext sc) {
        NC_GenerateAssessmentEmail batchObject = new NC_GenerateAssessmentEmail ();
        database.executebatch(batchObject);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}