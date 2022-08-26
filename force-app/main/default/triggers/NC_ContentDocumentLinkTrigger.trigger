/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
trigger NC_ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert,before update,after update,after delete,before delete) {
    if(Trigger.isInsert && Trigger.isBefore){
        NC_ContentDocumentLinkTriggerHandler.beforeInsert(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        NC_ContentDocumentLinkTriggerHandler.afterInsert(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        NC_ContentDocumentLinkTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        NC_ContentDocumentLinkTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isDelete && Trigger.isBefore){
        NC_ContentDocumentLinkTriggerHandler.afterDelete( Trigger.oldMap);
    }

}