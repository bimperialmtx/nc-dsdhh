/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
trigger NC_ContentDocumentTrigger on ContentDocument (before delete) {
    if(Trigger.isDelete && Trigger.isBefore){
        NC_ContentDocumentTriggerHandler.beforeDelete( Trigger.oldMap);
    }
}