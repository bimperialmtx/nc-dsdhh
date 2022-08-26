/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-13-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_MentoringRequestTriggerHandler {

    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : execute before update trigger event
    @param          : List<Mentoring_Request__c> newList, Map<Id, Mentoring_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Mentoring_Request__c> newList, Map<Id, Mentoring_Request__c> oldMap){
        createRequestComment(newList, oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : createRequestComment
    @description    : Create request comment when comments is changed
    @param          : List<Mentoring_Request__c> newList, Map<Id, Mentoring_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void createRequestComment(List<Mentoring_Request__c> newList, Map<Id, Mentoring_Request__c> oldMap) {
        List<Request_comment__c> requestCommentList = new List<Request_comment__c>();
        for(Mentoring_Request__c request: newList) {
            if(request.Comments__c != null && request.Comments__c != oldMap.get(request.id).Comments__c) {
                Request_comment__c requestComment = new Request_comment__c();
                requestComment.Internal_Comments__c = request.Comments__c;
                requestComment.Mentoring_Request__c = request.Id;
                requestCommentList.add(requestComment);
                request.Comments__c = null;
            }
        }
        if(requestCommentList.size() > 0) {
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Request_comment__c', requestCommentList, 'insert', true, 'NC_MentoringRequestTriggerHandler', 'createRequestComment');
           	insert objectDecision.getRecords();
        }
    }
    
}