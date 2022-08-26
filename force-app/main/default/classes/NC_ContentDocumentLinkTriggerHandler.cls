/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_ContentDocumentLinkTriggerHandler {
    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'After Insert' trigger event
    @param          : List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap){
       // getAttachmentIdAfterInsert(contentDocumentList,oldMap);
    }

    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap){
        getAttachmentIdAfterInsert(contentDocumentList,oldMap);
    }

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap){
        
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap){

        
    }

    /*
    *********************************************************
    @Method Name    : afterDelete
    @description    : calling this method on 'after Delete' trigger event
    @param          : Map<Id, ContentDocumentLink> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterDelete(Map<Id, ContentDocumentLink> oldMap){

        
    }

    /*
    *********************************************************
    @Method Name    : getAttachmentIdAfterInsert
    @description    : Get attachment id and store it in communication access request
    @param          : List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap
    @return         : void
    ********************************************************
    */
    public static void getAttachmentIdAfterInsert(List<ContentDocumentLink> contentDocumentList, Map<Id, ContentDocumentLink> oldMap){
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        Id communicationAccessRequestRecordId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Map<Id,Id> recordIdToFileIdSet = new Map<Id,Id>();
        List<ContentDocumentLink> toUpdate = new List<ContentDocumentLink>();
        Set<Id> communicationRequestId = new Set<Id>();
        for(ContentDocumentLink att:contentDocumentList){
            if(att.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Communication_Access_Request__c'){
             att.Visibility = 'AllUsers';
            
             communicationRequestId.add(att.LinkedEntityId);  
             recordIdToFileIdSet.put(att.LinkedEntityId, att.ContentDocumentId );
             }
         }

     
            
        List<Communication_Access_Request__c > communicationAccessList =new List<Communication_Access_Request__c>();
        //Cannot apply CRUDCheck
        for(Communication_Access_Request__c com:[SELECT Id,File_Record_Id_s__c,Files_Uploaded__c FROM Communication_Access_Request__c WHERE Id IN:communicationRequestId]){
         if(com.File_Record_Id_s__c!=null){
         com.File_Record_Id_s__c = com.File_Record_Id_s__c +'\n'+(URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordIdToFileIdSet.get(com.Id));
         com.Files_Uploaded__c = com.Files_Uploaded__c + '\n' +('https://'+domains[0].Domain +'/'+recordIdToFileIdSet.get(com.Id));
         }
         else{
             com.File_Record_Id_s__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordIdToFileIdSet.get(com.Id);
             com.Files_Uploaded__c = 'https://'+domains[0].Domain +'/'+recordIdToFileIdSet.get(com.Id);
            // com.File_Record_Id_s__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordIdToFileIdSet.get(com.Id);
         }
         communicationAccessList.add(com);
        }
        if(communicationAccessList.size()>0){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Communication_Access_Request__c', communicationAccessList, 'update', true,'NC_ContentDocumentLinkTriggerHandler','getAttachmentIdAfterInsert');
            update objectDecision.getRecords();
           // update communicationAccessList;
        }
        // if(toUpdate.size()>0){
        //     update toUpdate;
        //  }  
    }

   
}