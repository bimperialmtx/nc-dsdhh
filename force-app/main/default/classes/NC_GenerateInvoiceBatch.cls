/*
**   Class Name: NC_GenerateInvoiceBatch
**   Description: Batch class for generating pdf for all paid Invoices
**
**     Date            New/Modified           User                 Identifier                Description
**   14-04-2021             New          Ruchit Goswami
*/
public class NC_GenerateInvoiceBatch implements Database.Batchable<sObject>,Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Payment_Reference_Number__c,Authorization__r.Vendor__c, Authorization__r.Vendor__r.Name, Authorization__r.Vendor__r.Email__c from Invoice__c WHERE Invoice_Generated__c = false AND Status__c = \'Paid\' AND Payment_Reference_Number__c != null AND Authorization__r.Vendor__r.Active__c = true ORDER BY Payment_Reference_Number__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Invoice__c> invoiceList) {

        List<Invoice__c> updatedInvoiceList = new List<Invoice__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<String, Set<Account>> vendorCheckMap = new Map<String, Set<Account>>();

        for(Invoice__c invoice: invoiceList) {
            if(vendorCheckMap.containsKey(invoice.Payment_Reference_Number__c+'')) {
                vendorCheckMap.get(invoice.Payment_Reference_Number__c+'').add(invoice.Authorization__r.Vendor__r);
            } else {
                vendorCheckMap.put(invoice.Payment_Reference_Number__c+'', new Set<Account>{invoice.Authorization__r.Vendor__r});
            }
            invoice.Invoice_Generated__c = true;
            updatedInvoiceList.add(invoice);
        }

        String portalUrl = '';
        List<Network> networkList = [SELECT id FROM Network WHERE Name = 'Deaf and Hard of Hearing Services Vendor' LIMIT 1];
        if(networkList != null && networkList.size() > 0){
            portalUrl = Network.getLoginUrl(networkList[0].id);
        }
        
        EmailTemplate template = [SELECT Body,Subject FROM EmailTemplate WHERE Name = 'Vendor Check Statement' LIMIT 1];
        
        Pagereference pagereference = Page.NC_InvoiceDetails;

        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<C1_Check_Statement__c> checkStatementList = new List<C1_Check_Statement__c>();
        Map<String, String> checkStatementDocMap = new Map<String, String>();
        
        for(String checkNo: vendorCheckMap.keySet()) {
            for(Account vendor: vendorCheckMap.get(checkNo)) {
                pagereference.getParameters().put('id', vendor.id);
                pagereference.getParameters().put('CheckNo', checkNo);

                ContentVersion conVer = new ContentVersion();
                conVer.Check_Statement__c = true;
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = checkNo + '-' + Date.today().format() + '.pdf';
                conVer.Title = checkNo + '-' + Date.today().format();
                if(Test.isRunningTest()) {
                    conVer.VersionData = Blob.valueOf('test data');
                } else {
                 	conVer.VersionData = pagereference.getContentAsPDF();   
                }
                contentVersionList.add(conVer);

                C1_Check_Statement__c checkStatement = new C1_Check_Statement__c();
                checkStatement.Vendor__c = vendor.id;
                checkStatement.Name = conVer.Title;
                checkStatementList.add(checkStatement);

                if(vendor.Email__c != null){
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(checkNo + '-' + Date.today().format() + '.pdf');
                    efa.setBody(conVer.VersionData);
    
                    mails.add(addVendorEmails(template, checkNo, vendor, efa, portalUrl));
                }
            }
        }

        if(checkStatementList.size() > 0) {
            insert checkStatementList;
            for (C1_Check_Statement__c checkStatement : checkStatementList) {
                checkStatementDocMap.put(checkStatement.name + '.pdf', checkStatement.id);
            }
        }

        List<String> contentVersionIds = new List<String>();
        if (contentVersionList.size() > 0) {
            Database.SaveResult[] srList = Database.insert(contentVersionList);
            for (Database.SaveResult sr : srList) {
                contentVersionIds.add(sr.getId());
            }
        }

        List<C1_Check_Statement__c> updateCheckStatements = new List<C1_Check_Statement__c>();
        Set<Id> checkStatementSet = new Set<Id>();
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        if (contentVersionIds.size() > 0) {
            for (ContentVersion cv: [SELECT contentDocumentId, pathOnClient FROM ContentVersion WHERE Id in :contentVersionIds]) {
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                if (checkStatementDocMap.containsKey(cv.pathOnClient) && !checkStatementSet.contains(checkStatementDocMap.get(cv.pathOnClient))) {
                    conDocLink.LinkedEntityId = checkStatementDocMap.get(cv.pathOnClient);

                    C1_Check_Statement__c checkStatement = new C1_Check_Statement__c();
                    checkStatement.Id = conDocLink.LinkedEntityId;
                    checkStatement.ContentDocumentId__c = cv.contentDocumentId;
                    updateCheckStatements.add(checkStatement);
                    checkStatementSet.add(conDocLink.LinkedEntityId);
                } else {
                    continue;
                }
                conDocLink.ContentDocumentId = cv.contentDocumentId;
                conDocLink.shareType = 'V';
                conDocLink.Visibility = 'AllUsers';
                contentDocLinkList.add(conDocLink);
            }
        }

        if (contentDocLinkList.size() > 0) {
            Database.insert(contentDocLinkList);

            if(updatedInvoiceList.size() > 0){
                Database.update(updatedInvoiceList);
            }
        }
        if (mails.size() > 0) {
            Messaging.sendEmail(mails);
        }
        if (updateCheckStatements.size() > 0) {
            
            update updateCheckStatements;
        }
    }

    public Messaging.SingleEmailMessage addVendorEmails(EmailTemplate template, String checkNo, Account vendor,
                                                        Messaging.EmailFileAttachment efa, String portalUrl) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //checkNo = Decimal.valueOf(checkNo) + '';
        String templateBody = template.body.replace('{!Authorization__c.Vendor_Name__c}', vendor.Name)
                                            .replace('{!Invoice__c.Payment_Reference_Number__c}', checkNo)
                                            .replace('{portalLink}', portalUrl);

        mail.setToAddresses(new List<String>{vendor.Email__c});
        mail.setSubject(template.subject);
        mail.setPlainTextBody(templateBody);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{efa});
        return mail;
    }

    public void execute(SchedulableContext sc) {
        NC_GenerateInvoiceBatch batchObject = new NC_GenerateInvoiceBatch ();
        database.executebatch(batchObject);
    }

    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}