/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_ContentDocumentTriggerHandler {
    /*
    *********************************************************
    @Method Name    : beforeDelete
    @description    : calling this method on 'before Delete' trigger event
    @param          : Map<Id, ContentDocument> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeDelete(Map<Id, ContentDocument> oldMap){
        getAttachmentIdBeforeDelete(oldMap);
        
    }

    /*
    *********************************************************
    @Method Name    : getAttachmentIdBeforeDelete
    @description    : Get attachment id before delete and store in communication access request
    @param          : Map<Id, ContentDocument> oldMap
    @return         : void
    ********************************************************
    */
    public static void getAttachmentIdBeforeDelete( Map<Id, ContentDocument> oldMap){
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS' WITH SECURITY_ENFORCED];
        Id communicationAccessRequestRecordId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Map<Id,Id> recordIdToFileIdSet = new Map<Id,Id>();
        Set<Id> communicationRequestId = new Set<Id>();
        Set<Id> contentDocumentSet = new Set<Id>();
           for(ContentDocument att:oldMap.values()){
            contentDocumentSet.add(att.Id);
            }

            for(ContentDocumentLink contentLink :[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentSet WITH SECURITY_ENFORCED]){
                communicationRequestId.add(contentLink.LinkedEntityId);
                recordIdToFileIdSet.put(contentLink.LinkedEntityId,contentLink.ContentDocumentId);
            }
               
           List<Communication_Access_Request__c > communicationAccessList =new List<Communication_Access_Request__c>();

           for(Communication_Access_Request__c com:[SELECT Id,File_Record_Id_s__c,Files_Uploaded__c FROM Communication_Access_Request__c WHERE Id IN:communicationRequestId]){//WITH SECURITY_ENFORCED
            if(com.File_Record_Id_s__c!=null){
            com.File_Record_Id_s__c = com.File_Record_Id_s__c.remove(URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordIdToFileIdSet.get(com.Id));
            com.Files_Uploaded__c = com.Files_Uploaded__c.remove('https://'+domains[0].Domain +'/'+recordIdToFileIdSet.get(com.Id));
            }
           communicationAccessList.add(com);
           }
           if(communicationAccessList.size()>0){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Communication_Access_Request__c', communicationAccessList, 'update', true,'NC_ContentDocumentTriggerHandler','getAttachmentIdBeforeDelete');
            update objectDecision.getRecords();
             //  update communicationAccessList;
           }  
    }
}