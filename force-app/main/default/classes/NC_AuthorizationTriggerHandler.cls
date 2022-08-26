/*
*   Class Name: NC_AuthorizationTriggerHandler
*   Description: Weather Radio Document For Authorization
*
*   Date            New/Modified         User                 Identifier                Description
*   29/05/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_AuthorizationTriggerHandler {
   
    public static Id authorizationEquipmentRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','Equipment');
    public static Id authorizationAssessorRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','Assessment');
    public static Id authorizationNDBEDPTrainingRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c','NDBEDP_Training');
    public static Set<Id> authRecordTypeSet = new Set<Id>{authorizationEquipmentRecordType, authorizationAssessorRecordType, authorizationNDBEDPTrainingRecordType};
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : Executed Trigger before update event
    @param          : List<Authorization__c> newList, Map<Id, Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Authorization__c> newList, Map<Id, Authorization__c> oldMap){
  		 cancelAuthorization(newList,oldMap);
          checkActiveVendor(newList,oldMap);
        populateNDBEDPVendor(newList,oldMap);
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : Executed Trigger after update event
    @param          : List<Authorization__c> newAuthorizationList, Map<Id, Authorization__c> oldMapAuthorization
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Authorization__c> newAuthorizationList, Map<Id, Authorization__c> oldMapAuthorization){
        List<Authorization__c> lisOfReturnedAuthorization = new List<Authorization__c>();
        List<Authorization__c> lisOfCanceledAuthorization = new List<Authorization__c>();
        for(Authorization__c authorization : newAuthorizationList){
            if(oldMapAuthorization.get(authorization.Id).Status__c != authorization.Status__c && authorization.Status__c == NC_Constant.AUTHORIZATION_STATUS_RETURNED){
                lisOfReturnedAuthorization.add(authorization);
            }
            if(oldMapAuthorization.get(authorization.Id).Status__c != authorization.Status__c && authorization.Status__c == NC_Constant.AUTHORIZATION_STATUS_CANCELED){
                lisOfCanceledAuthorization.add(authorization);
            }
        }
        if(!lisOfReturnedAuthorization.isEmpty()){
            updateRelatedInvoices(lisOfReturnedAuthorization);
        }
        if(!lisOfCanceledAuthorization.isEmpty()){
            NC_BudgetManagementController.cancelAuthorizationToUpdateBudget(lisOfCanceledAuthorization);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : populateNDBEDPVendor
    @description    : Populate default NDBEDP vendor for NDBEDP invoices
    @param          : List<Authorization__c> newList, Map<Id, Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void populateNDBEDPVendor(List<Authorization__c> newList, Map<Id, Authorization__c> oldMap){
        for(Authorization__c authorizationRecord : newList){
            if(authorizationRecord.recordTypeId == authorizationEquipmentRecordType
            && authorizationRecord.Vendor__c == null && Label.NDBEDPVendor != 'null') {
                authorizationRecord.Vendor__c = Label.NDBEDPVendor;
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : cancelAuthorization
    @description    : Cancel Authorizarion validations
    @param          : List<Authorization__c> newList, Map<Id, Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void cancelAuthorization(List<Authorization__c> newList, Map<Id, Authorization__c> oldMap){
        Id AuthorizationTrainingVendorIncoiveId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
        Id AuthorizationCommunicationrequestId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
        Boolean cancelStatusUpdated = False;
        for(Authorization__c authorizationRecord : newList){
            if(oldMap != NULL //&& (authorizationRecord.RecordTypeId == AuthorizationTrainingVendorIncoiveId || authorizationRecord.RecordTypeId == AuthorizationCommunicationrequestId)
               && ((oldMap.get(authorizationRecord.Id).Cancel_Authorization__c != authorizationRecord.Cancel_Authorization__c  && authorizationRecord.Cancel_Authorization__c)
               || (oldMap.get(authorizationRecord.Id).Status__c != authorizationRecord.Status__c && authorizationRecord.Status__c == 'Cancelled')) ){
                   if(authorizationRecord.Cancelled_Reason__c  == NULL && authorizationRecord.RecordTypeId == AuthorizationCommunicationrequestId){
                       authorizationRecord.addError('Select a cancel reason before canceling authorization.');
                   }
                   if(authorizationRecord.Cancelled_Comment__c  == NULL && authorizationRecord.RecordTypeId != AuthorizationCommunicationrequestId){
                       authorizationRecord.addError('Provide a Cancelled Comment before canceling authorization.');
                   }
                   if(authorizationRecord.Cancelled_Reason__c == 'Assignment Cancelled (In route/Arrived)' && authorizationRecord.Vendor_Type__c == 'SSP'){
                       authorizationRecord.addError('SSP can not select Assignment Cancelled (In route/Arrived) as Cancelled reason.');
                   }
                   if((authorizationRecord.Status__c != 'Approved' &&  authorizationRecord.Status__c != 'Cancelled') && (authorizationRecord.Cancel_Authorization__c 
                                                                                                                        && !oldMap.get(authorizationRecord.Id).Cancel_Authorization__c )){
                       authorizationRecord.addError('Authorization can not be Cancelled before Approval.');
                   }else if(authorizationRecord.Cancel_Authorization__c && !oldMap.get(authorizationRecord.Id).Cancel_Authorization__c){
                       cancelStatusUpdated = True ;
                       authorizationRecord.Status__c = 'Cancelled';
                   }else if((oldMap.get(authorizationRecord.Id).Status__c != 'Approved' && oldMap.get(authorizationRecord.Id).Status__c != 'Cancelled') && authorizationRecord.Status__c == 'Cancelled' ){
                       authorizationRecord.addError('Authorization can not be Cancelled before Approval.');
                   }else if(oldMap.get(authorizationRecord.Id).Status__c != authorizationRecord.Status__c && authorizationRecord.Status__c == 'Cancelled'){
                       authorizationRecord.Cancel_Authorization__c = True;
                   }
                   
            }
        } 
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnInsertUpdateUnDelete
    @description    : Roll Up On Insert Update and Undelete
    @param          : List<Authorization__c> listOfAuthorizationNew, Map<Id, Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void rollUpOnInsertUpdateUnDelete(List<Authorization__c> listOfAuthorizationNew, Map<Id, Authorization__c> oldMap){
        Id AuthCommunicationRecord = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_COMMUNICATION);
        List<Authorization__c> listOfAuthorizationToBeAdded = new List<Authorization__c>();
        for(Authorization__c auth : listOfAuthorizationNew){
           // if(oldMap != null && auth.RecordTypeId == AuthCommunicationRecord && auth.Total_Authorized_Amount__c != oldMap.get(auth.Id).Total_Authorized_Amount__c){
            if( auth.RecordTypeId == AuthCommunicationRecord && auth.Total_Authorized_Amount_Staffing__c != NULL){
                listOfAuthorizationToBeAdded.add(auth);
            }else if(auth.RecordTypeId == AuthCommunicationRecord ){
                listOfAuthorizationToBeAdded.add(auth);
            }
        }
        List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'Total_Authorized_Amount_Staffing__c','CACL_Total_Cost__c')};
        NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfAuthorizationToBeAdded, 'Authorization__c', 'Communication_Access_Request__c', 'Communication_Access_Request__c', '');
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnDelete
    @description    : Roll Up On Delete
    @param          : List<Authorization__c> listOfAuthorizationOld
    @return         : void
    ********************************************************
    */
    public static void rollUpOnDelete(List<Authorization__c> listOfAuthorizationOld){
        Id AuthCommunicationRecord = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_COMMUNICATION);
        List<Authorization__c> listOfAuthorizationToBeAdded = new List<Authorization__c>();
        for(Authorization__c auth : listOfAuthorizationOld){
            if(auth.RecordTypeId == AuthCommunicationRecord ){
                listOfAuthorizationToBeAdded.add(auth);
            }
        }
        List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'Total_Authorized_Amount__c','CACL_Total_Cost__c')};
        for(Authorization__c auth: listOfAuthorizationToBeAdded) {
            auth.Update_If_Vendor_Inactive__c = true;
        }
        NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfAuthorizationToBeAdded,'Authorization__c', 'Communication_Access_Request__c', 'Communication_Access_Request__c', '');
    }
    
    /*
    *********************************************************
    @Method Name    : updateRelatedInvoices
    @description    : Update related invoices status to Returned
    @param          : List<Authorization__c> newAuthorizationList
    @return         : void
    ********************************************************
    */
    public static void updateRelatedInvoices(List<Authorization__c> newAuthorizationList){
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        for(Invoice__c Invoice : [SELECT Id, Status__c FROM Invoice__c WHERE Authorization__c IN : newAuthorizationList WITH SECURITY_ENFORCED]){
            Invoice.Status__c = NC_Constant.INVOICE_STATUS_RETURNED;
            invoiceList.add(Invoice);
        }
        SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Invoice__c', invoiceList, 'update', true,'NC_AuthorizationTriggerHandler','updateRelatedInvoices');
        update objectDecision.getRecords();
       
    }

    public static Boolean inactiveVendorUpdate = false;
    
    /*
    *********************************************************
    @Method Name    : checkActiveVendor
    @description    : Validate active/inactive vendor update scenarios
    @param          : List<Authorization__c> newAuthorizationList,Map<Id, Authorization__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void checkActiveVendor(List<Authorization__c> newAuthorizationList,Map<Id, Authorization__c> oldMap){
        for(Authorization__c authorizationRecord : newAuthorizationList){
            if(!authRecordTypeSet.contains(authorizationRecord.recordTypeId)) {
                if(oldMap != null && (NC_InvoiceTriggerHandler.processB3flow == null || (NC_InvoiceTriggerHandler.processB3flow != null && !NC_InvoiceTriggerHandler.processB3flow))
                && (authorizationRecord.Vendor_Status__c == 'Vendor Update In Progress')){
                    authorizationRecord.addError('Authorization is locked as vendor update is in progress');
                }
                //Total_Authorized_Amount__c
                if(!authorizationRecord.Update_If_Vendor_Inactive__c && !inactiveVendorUpdate && oldMap.get(authorizationRecord.id).Total_Authorized_Amount__c == authorizationRecord.Total_Authorized_Amount__c
                    && (NC_InvoiceTriggerHandler.processB3flow == null || (NC_InvoiceTriggerHandler.processB3flow != null && !NC_InvoiceTriggerHandler.processB3flow))
                && authorizationRecord.Status__c != 'Vendor Update In Progress' 
                && !authorizationRecord.Vendor_Active__c ){
                    //authorizationRecord.addError('It cannot be updated because the vendor is inactive');
                }
                if(oldMap != null && !authorizationRecord.Update_If_Vendor_Inactive__c && !inactiveVendorUpdate && oldMap.get(authorizationRecord.id).Total_Authorized_Amount__c == authorizationRecord.Total_Authorized_Amount__c
                    &&  (NC_InvoiceTriggerHandler.processB3flow == null || (NC_InvoiceTriggerHandler.processB3flow != null && !NC_InvoiceTriggerHandler.processB3flow))
                && oldMap.get(authorizationRecord.id).Status__c == 'Vendor Update In Progress' 
                && (authorizationRecord.Vendor_Status__c == 'Submitted and Rejected' || authorizationRecord.Vendor_Status__c == 'Submitted and Error' 
                        || (authorizationRecord.Vendor_MM102_error__c != null && authorizationRecord.Vendor_NCAS_Status__c == null)
                        || (authorizationRecord.Vendor_Status__c == 'Pending Approval' &&  authorizationRecord.Vendor_NCAS_Status__c == 'N – record not in NCAS'))){
                    //authorizationRecord.addError('It cannot be updated because the vendor is inactive');
                }
                if(authorizationRecord.Update_If_Vendor_Inactive__c) {
                    authorizationRecord.Update_If_Vendor_Inactive__c = false;
                    inactiveVendorUpdate = true;
                }
            }
        }
    }
    
        /*
    * Method Name: checkActiveVendor
    * Description: To Update Authorization
    * @param: List<Authorization__c> newAuthorizationList,Map<Id, Authorization__c> oldMap
    * @return void
    
    public static void checkActiveVendor(List<Authorization__c> newAuthorizationList,Map<Id, Authorization__c> oldMap){
        for(Authorization__c authorizationRecord : newAuthorizationList){
            if(oldMap != null && (NC_InvoiceTriggerHandler.processB3flow == null || (NC_InvoiceTriggerHandler.processB3flow != null && !NC_InvoiceTriggerHandler.processB3flow))
               && (authorizationRecord.Vendor_Status__c == 'Vendor Update In Progress')){
                authorizationRecord.addError('Authorization is locked as vendor update is in progress');
            }
            if(!authorizationRecord.Update_If_Vendor_Inactive__c && !inactiveVendorUpdate && oldMap.get(authorizationRecord.id).Total_Authorized_Amount__c == authorizationRecord.Total_Authorized_Amount__c
               && (NC_InvoiceTriggerHandler.processB3flow == null || (NC_InvoiceTriggerHandler.processB3flow != null && !NC_InvoiceTriggerHandler.processB3flow))
               && authorizationRecord.Status__c != 'Vendor Update In Progress' 
               && !authorizationRecord.Vendor_Active__c ){
                //authorizationRecord.addError('It cannot be updated because the vendor is inactive');
            }
            if(oldMap != null && !authorizationRecord.Update_If_Vendor_Inactive__c && !inactiveVendorUpdate && oldMap.get(authorizationRecord.id).Total_Authorized_Amount__c == authorizationRecord.Total_Authorized_Amount__c
               && (NC_InvoiceTriggerHandler.processB3flow == null || (NC_InvoiceTriggerHandler.processB3flow != null && !NC_InvoiceTriggerHandler.processB3flow))
               && oldMap.get(authorizationRecord.id).Status__c == 'Vendor Update In Progress' 
               && (authorizationRecord.Vendor_Status__c == 'Submitted and Rejected' || authorizationRecord.Vendor_Status__c == 'Submitted and Error' 
                    || (authorizationRecord.Vendor_MM102_error__c != null && authorizationRecord.Vendor_NCAS_Status__c == null)
                    || (authorizationRecord.Vendor_Status__c == 'Pending Approval' &&  authorizationRecord.Vendor_NCAS_Status__c == 'N – record not in NCAS'))){
                //authorizationRecord.addError('It cannot be updated because the vendor is inactive');
            }
            if(authorizationRecord.Update_If_Vendor_Inactive__c) {
                authorizationRecord.Update_If_Vendor_Inactive__c = false;
                inactiveVendorUpdate = true;
            }
        }
    }*/
    
}