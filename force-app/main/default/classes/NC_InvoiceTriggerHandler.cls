/*
*   Class Name: NC_InvoiceTriggerHandler
*   Description: Invice Trigger Handler
*
*   Date              New/Modified            User                 Identifier                Description
*   27/05/2020           New            Shubham Dadhich(mtx)
*   05/06/2020           New            Hiten Aggarwal(mtx)
*   022/04/2021          New            Upendra Dubey(mtx)
*/
public with sharing class NC_InvoiceTriggerHandler {

    private static String checkCanceledCode = '0004';
    private static Id assessorTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_ASSESSMENT);
    private static Id assessorTrainingTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_ASSESSOR_TRAINING);
    private static Id equipmentTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_EQUIPMENT);
    private static Id ndbedpTrainingTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_TRAINING);
    private static Id ndbedpTrainingEventTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Training_Event');
    private static Id ndbedpPickupTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_PICK_UP);
    private static Id ndbedpDeliveryTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_DELIVERY);
    private static Id ndbedpAdditionalTrainingTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_ADDITIONAL_TRAINING);
    private static Id ndbedpFollowTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_NDBEDP_FOLLOWUP);
    private static Set<Id> assessorTypeIds = new Set<Id>{assessorTypeId, assessorTrainingTypeId, ndbedpFollowTypeId, ndbedpPickupTypeId, ndbedpDeliveryTypeId,ndbedpAdditionalTrainingTypeId};
    private static Set<Id> excludeVendorTypes = new Set<Id>{assessorTypeId, assessorTrainingTypeId, equipmentTypeId, ndbedpTrainingTypeId, ndbedpTrainingEventTypeId, ndbedpPickupTypeId, ndbedpDeliveryTypeId};
    public static Set<Id> ndbedpInvoiceIds = new Set<Id>{equipmentTypeId, assessorTypeId, 
        assessorTrainingTypeId, ndbedpTrainingTypeId, ndbedpTrainingEventTypeId, ndbedpPickupTypeId, ndbedpDeliveryTypeId,
        ndbedpAdditionalTrainingTypeId, ndbedpFollowTypeId};
    public static Set<String> ndbedpVendorTypes = new Set<String>{'NDBEDP SSP', 'NDBEDP Interpreters', 'NDBEDP CART'};
    // public static void beforeUpdate(List<Invoice__c> newInvoiceList ,Map<Id, Invoice__c> oldMap, Map<Id, Invoice__c> newMap){
    //     populateStatusForReturn(newInvoiceList , oldMap,newMap);
    //   //  createDuplicateInvoiceWhenCheckIsreturned(newInvoiceList , oldMap);
    // }
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before Update' trigger event
    @param          : List<Invoice__c> newInvoiceList ,Map<Id, Invoice__c> oldMap, Map<Id, Invoice__c> newMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Invoice__c> newInvoiceList ,Map<Id, Invoice__c> oldMap, Map<Id, Invoice__c> newMap){

        checkActiveVendor(newInvoiceList, oldMap);
        checkTheOwnerOfRequest(newInvoiceList, oldMap);
        validateRecord(newInvoiceList, oldMap);
        totalBilledAmountValidate(newInvoiceList,oldMap);
        populateStatusForReturn(newInvoiceList,oldMap);
        updateInvoiceResolutionNoteRequired(newInvoiceList);
        validateNDBEDPTrainingInvoice(newInvoiceList,oldMap);
        validateEquipmentInvoice(newInvoiceList,oldMap);
        validateCheckCancel(newInvoiceList,oldMap);
        updateStatusWhenpaid(newInvoiceList,oldMap);
        upadateStatustoPendingControllersoffice(newInvoiceList,oldMap);
        validateAmountToPay(newInvoiceList,oldMap);
        
        //validate Budget
        Id invoiceCommunicationId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
        Id invoiceTravelingVendorId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Training_Vendor_Invoice');
        List<Invoice__c> listOfInvoiceToBeUpdated = new List<Invoice__c>();
        List<Invoice__c> listOfInvoiceToBeUpdatedStaffing = new List<Invoice__c>();
        List<Invoice__c> ndbedpInvoiceToBeUpdated = new List<Invoice__c>();
        Map<Invoice__c,Id> invoiceToBudgetMap = new Map<Invoice__c,Id>();
        for(Invoice__c invoiceRecord : newInvoiceList){
            if(ndbedpInvoiceIds.contains(invoiceRecord.RecordTypeId) && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS && oldMap.get(invoiceRecord.id).Status__c != NC_Constant.INVOICE_STATUS_HOLD) {
                ndbedpInvoiceToBeUpdated.add(invoiceRecord);
            }else if(invoiceRecord.RecordTypeId == invoiceCommunicationId && ndbedpVendorTypes.contains(invoiceRecord.Vendor_Type__c) && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS && oldMap.get(invoiceRecord.id).Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                ndbedpInvoiceToBeUpdated.add(invoiceRecord);
            }else if(invoiceRecord.RecordTypeId != invoiceCommunicationId && invoiceRecord.RecordTypeId != invoiceTravelingVendorId && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS && oldMap.get(invoiceRecord.id).Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                listOfInvoiceToBeUpdated.add(invoiceRecord);
            }else if(invoiceRecord.RecordTypeId == invoiceTravelingVendorId && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS && oldMap.get(invoiceRecord.id).Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                listOfInvoiceToBeUpdatedStaffing.add(invoiceRecord);
            }else if(invoiceRecord.RecordTypeId == invoiceCommunicationId && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS && oldMap.get(invoiceRecord.id).Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                listOfInvoiceToBeUpdatedStaffing.add(invoiceRecord);
            }
            
			//Budget Refunding
            if(oldMap.get(invoiceRecord.id).Refund__c != invoiceRecord.Refund__c && invoiceRecord.Budget_Management__c != NULL){
                invoiceToBudgetMap.put(invoiceRecord,invoiceRecord.Budget_Management__c);
            }
        }
        if(!invoiceToBudgetMap.isEmpty()){
            Map<Id,Budget_Management__c> budgetMap = new Map<Id,Budget_Management__c>(
             [SELECT Id,Amount_Utilized__c FROM Budget_Management__c WHERE Id IN: invoiceToBudgetMap.values()]
            );
            for(Invoice__c invoiceRecord : invoiceToBudgetMap.keySet()){
                if(budgetMap.containsKey(invoiceToBudgetMap.get(invoiceRecord))){
                    Budget_Management__c budget = budgetMap.get(invoiceToBudgetMap.get(invoiceRecord));
                    Decimal oldAmount = oldMap.get(invoiceRecord.id).Refund__c != NULL ? oldMap.get(invoiceRecord.id).Refund__c : 0;
                    Decimal newAmount = invoiceRecord.Refund__c != NULL ? invoiceRecord.Refund__c : 0;
                    budget.Amount_Utilized__c = budget.Amount_Utilized__c - (newAmount - oldAmount);
                    budgetMap.put(budget.Id,budget);
                }
            }
            if(!budgetMap.isEmpty()){
               Update budgetMap.values(); 
            }
        }
        
        if(!listOfInvoiceToBeUpdated.isEmpty()){
            NC_BudgetManagementController.validateBudgetForInvoice(listOfInvoiceToBeUpdated, newMap);
        }
        if(!listOfInvoiceToBeUpdatedStaffing.isEmpty()){
            NC_BudgetManagementController.validateBudgetForInvoiceForStaffing(listOfInvoiceToBeUpdatedStaffing);
        }
        if(!ndbedpInvoiceToBeUpdated.isEmpty()) {
            //Invoice Status to Hold if insufficient Budget
            NC_BudgetManagementController.validateBudgetForNDBEDPInvoice(ndbedpInvoiceToBeUpdated, newMap);
        }
    }
    
    public static Boolean processB3flow = null;

    /*
    *********************************************************
    @Method Name    : updateInvoiceResolutionNoteRequired
    @description    : Invoice Resolution note required validation
    @param          : List<Invoice__c> newList
    @return         : void
    ********************************************************
    */
    public static void updateInvoiceResolutionNoteRequired(List<Invoice__c> newList){
        for(Invoice__c incRecord : newList){
             if(incRecord.Resolution_Checkbox__c == true && incRecord.Resolution_Note__c == null && incRecord.Coordinator_Feedback_Required__c) {
                incRecord.addError('Canceled Invoice Resolution note required before approval');
             }
         }
    }       

    /*
    *********************************************************
    @Method Name    : checkTheOwnerOfRequest
    @description    : Checking for invoice Creater and Submitter
    @param          : List<Invoice__c> newList, Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void checkTheOwnerOfRequest(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap){
        for(Invoice__c invoiceRecord : newList){
            if(oldMap != NULL && oldMap.get(invoiceRecord.Id).Status__c !=  invoiceRecord.Status__c 
               && (invoiceRecord.Status__c == 'Pending Approval' || invoiceRecord.Status__c == 'Pending EDS Program Assistant')
               && invoiceRecord.OwnerId != UserInfo.getUserId()
               && oldMap.get(invoiceRecord.Id).Status__c != 'Vendor Update In Progress'){
                //invoiceRecord.addError('The Invoice has already been created by another user. ');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateStatusWhenpaid
    @description    : Update status to paid when paid selected
    @param          : List<Invoice__c> newList, Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void updateStatusWhenpaid(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap){
        for(Invoice__c invoiceRecord : newList){
            if(invoiceRecord.Paid__c && oldMap.get(invoiceRecord.Id).Paid__c!= invoiceRecord.Paid__c 
               && assessorTypeIds.contains(invoiceRecord.RecordTypeId) ){
                invoiceRecord.Status__c = 'Paid';
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Invoice__c> newInvoiceList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Invoice__c> newInvoiceList,Map<Id, Invoice__c> oldMap){
        Id invoiceCommunicationId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
        List<Invoice__c> listOfInvoiceToBeUpdated = new List<Invoice__c>();
        List<Invoice__c> listOfInvoiceToBeUpdatedStaffing = new List<Invoice__c>();
        List<Invoice__c> ndbedpInvoiceToBeUpdated = new List<Invoice__c>();
        Id invoiceTravelingVendorId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Training_Vendor_Invoice');
        for(Invoice__c invoiceRecord : newInvoiceList){
            if(invoiceRecord.Budget_Management__c == null && ndbedpInvoiceIds.contains(invoiceRecord.RecordTypeId) && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS) {
                ndbedpInvoiceToBeUpdated.add(invoiceRecord);
            }else if(invoiceRecord.RecordTypeId == invoiceCommunicationId && ndbedpVendorTypes.contains(invoiceRecord.Vendor_Type__c) && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS){
                ndbedpInvoiceToBeUpdated.add(invoiceRecord);
            }else if(invoiceRecord.Budget_Management__c == null && invoiceRecord.RecordTypeId != invoiceCommunicationId && invoiceRecord.RecordTypeId != invoiceTravelingVendorId  && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS){
                listOfInvoiceToBeUpdated.add(invoiceRecord);
            }else if(invoiceRecord.Budget_Management__c == null && invoiceRecord.RecordTypeId == invoiceTravelingVendorId && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS){
                 listOfInvoiceToBeUpdatedStaffing.add(invoiceRecord);
            }
            else if(invoiceRecord.Budget_Management__c == null && invoiceRecord.RecordTypeId == invoiceCommunicationId && oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c && invoiceRecord.Status__c == NC_Constant.INVOICE_PAID_STATUS){
                listOfInvoiceToBeUpdatedStaffing.add(invoiceRecord);
            }
        }
        if(!listOfInvoiceToBeUpdated.isEmpty()){
            NC_BudgetManagementController.updteBudgetFromInvoice(listOfInvoiceToBeUpdated);
        }
        if(!listOfInvoiceToBeUpdatedStaffing.isEmpty()){
            Set<Id> setOfIdInvoice = new Set<Id>();
            for(Invoice__c invoice : listOfInvoiceToBeUpdatedStaffing){
                setOfIdInvoice.add(invoice.id);
            }
            NC_BudgetManagementController.updteBudgetFromInvoiceStaffing(setOfIdInvoice);
        }
        if(!ndbedpInvoiceToBeUpdated.isEmpty()) {
            Set<Id> setOfIdInvoice = new Set<Id>();
            for(Invoice__c invoice : ndbedpInvoiceToBeUpdated){
                setOfIdInvoice.add(invoice.id);
            }
            NC_BudgetManagementController.updteBudgetFormNDBEDPInvoice(setOfIdInvoice);
        }
        submitPaymentErrorInvoiceForApproval(newInvoiceList, oldMap);
    }

    /*
    *********************************************************
    @Method Name    : submitPaymentErrorInvoiceForApproval
    @description    : Submit NCAS Error Invoice for approval
    @param          : List<Invoice__c> newList, Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void submitPaymentErrorInvoiceForApproval(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap) {
        Set<Id> sendForApprovalIds = new Set<Id>();
        
        for(invoice__c invoiceRecord: newList) {
            if(oldMap != NULL 
                && invoiceRecord.Status__c == 'Submitted and Rejected'
                && oldMap.get(invoiceRecord.Id).MM110_error_reason__c != invoiceRecord.MM110_error_reason__c
                && invoiceRecord.MM110_error_reason__c != null) {
                    sendForApprovalIds.add(invoiceRecord.Id);
            }
        }
        if(sendForApprovalIds.size() > 0) {
            submitForApproval(sendForApprovalIds);
        }
    }

    /*
    *********************************************************
    @Method Name    : submitForApproval
    @description    : Submit record for approval
    @param          : Set<Id> recordIds
    @return         : void
    ********************************************************
    */
    public static void submitForApproval(Set<Id> recordIds) {
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(Id recordId: recordIds){   
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('');
            req.setObjectId(recordId);      
            processList.add(req);
        }
        Approval.process(processList);
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnInsertUpdateUnDelete
    @description    : Roll Up On Insert Update and Undelete
    @param          : List<Invoice__c> invoiceRecordListNew, Map<Id, Invoice__c> invoiceRecordOldMap
    @return         : void
    ********************************************************
    */
    public static void rollUpOnInsertUpdateUnDelete(List<Invoice__c> invoiceRecordListNew, Map<Id, Invoice__c> invoiceRecordOldMap){
        Id InvoiceRecordTypeCommunication = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_RECORDTYPE_COMMUNICATION);
        List<Invoice__c> listOfInvoiceToBeupdated = new List<Invoice__c>();
        for(Invoice__c invoice : invoiceRecordListNew){
            if(invoiceRecordOldMap != null && invoice.RecordTypeId == InvoiceRecordTypeCommunication && invoice.Total_Amount_Billed__c != invoiceRecordOldMap.get(invoice.Id).Total_Amount_Billed__c){
                listOfInvoiceToBeupdated.add(invoice);
            }else if(invoice.RecordTypeId == InvoiceRecordTypeCommunication ){
                listOfInvoiceToBeupdated.add(invoice);
            }
        }
        List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'Total_Amount_Billed__c', 'Total_Billed_Amount__c')};
        NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfInvoiceToBeupdated, 'Invoice__c', 'Authorization__c', 'Authorization__c', '');
    }

    /*
    *********************************************************
    @Method Name    : rollUpOnDelete
    @description    : Roll Up On Delete
    @param          : List<Invoice__c> listOfOldInvoice
    @return         : void
    ********************************************************
    */
    public static void rollUpOnDelete(List<Invoice__c> listOfOldInvoice){
        Id InvoiceRecordTypeCommunication = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.INVOICE_RECORDTYPE_COMMUNICATION);
        List<Invoice__c> listOfInvoiceToBeupdated = new List<Invoice__c>();
        for(Invoice__c invoice : listOfOldInvoice){
            if(invoice.RecordTypeId == InvoiceRecordTypeCommunication ){
                listOfInvoiceToBeupdated.add(invoice);
            }
        }
        List<NC_RollupUtility.fieldDefinition> fieldDefinitions = new list<NC_RollupUtility.fieldDefinition> {new NC_RollupUtility.fieldDefinition('SUM', 'Total_Amount_Billed__c', 'Total_Billed_Amount__c')};
        NC_RollupUtility.rollUpTrigger(fieldDefinitions, listOfInvoiceToBeupdated, 'Invoice__c', 'Authorization__c', 'Authorization__c', '');
    }

    /*
    *********************************************************
    @Method Name    : upadateStatustoPendingControllersoffice
    @description    : update status to pending controller office
    @param          : List<Invoice__c> newInvoiceList, Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
     public static void upadateStatustoPendingControllersoffice(List<Invoice__c> newInvoiceList, Map<Id, Invoice__c> oldMap) {
        Id invoiceCommunicationId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
        for(Invoice__c invoiceRecord : newInvoiceList){
        if((invoiceRecord.Vendor_Type__C == 'SSP' || invoiceRecord.Vendor_Type__C == 'CART' || invoiceRecord.Vendor_Type__C == 'NDBEDP SSP' || invoiceRecord.Vendor_Type__C == 'NDBEDP CART') && invoiceRecord.Status__c=='Pending Approval' && invoiceRecord.RecordTypeId == invoiceCommunicationId){
            if(invoiceRecord.Status__c=='Pending Approval' && invoiceRecord.Owner_Regional_Center__c!= System.Label.Home_Office && oldMap.get(invoiceRecord.id).Coordinator_Feedback_Required__c != invoiceRecord.Coordinator_Feedback_Required__c){
           if(!(invoiceRecord.Owner_Regional_Center__c == System.Label.Home_Office && invoiceRecord.Status__c!= 'Vendor Update In Progress' && String.ISBLANK(invoiceRecord.MM110_error_reason__c))){
                            invoiceRecord.Status__c='Pending Controller Office Approval';
               }
            }
         }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateRecord
    @description    : Validate Record for Submit For Approval record Type Should be Hearing Aid
    @param          : List<Invoice__c> newInvoiceList, Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateRecord(List<Invoice__c> newInvoiceList, Map<Id, Invoice__c> oldMap) {
        Id invoiceRecordTypeIdEDS = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_EDS_INVOICE);
        Id invoiceRecordTypeIdHearingAid = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_HEARING_AID);
        Id invoiceRecordTypeIdSubHearingAid = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_SUB_HEARING_AID);
        Id invoiceRecordTypeIdWeatherRadio = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_WEATHER_RADIO);
        Id invoiceRecordTypeIdCommunicationAccess = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_COMMUNICATION);
        Id invoiceRecordTypeIdTrainingVendor = NC_Utility.RecordTypeUtilityMethod('Invoice__c','Training_Vendor_Invoice');
        Id invoiceRecordTypeIdCAPTEL = NC_Utility.RecordTypeUtilityMethod('Invoice__c','CAPTEL');

        Id NDBEDPAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_NDBEDP_ASSESSMENT);
        Boolean dayHearingAid = false;
        Boolean dayWeatherRadio = false;
        Boolean dayOther = false;
        for(Invoice__c invoiceRecord : newInvoiceList){
            if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT && invoiceRecord.Consumer_Signed_Date__c == null && invoiceRecord.RecordTypeId == invoiceRecordTypeIdHearingAid){
                invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_CONSUMER_SIGNED_DATE_HA);
            }else if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT && invoiceRecord.Consumer_Signed_Date_For_Other__c == null && invoiceRecord.RecordTypeId != invoiceRecordTypeIdHearingAid && invoiceRecord.RecordTypeId != invoiceRecordTypeIdTrainingVendor &&invoiceRecord.Vendor_Type__c!='SSP'){
                invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_CONSUMER_SIGNED_DATE);
            }else{
                if(invoiceRecord.Consumer_Signed_Date__c != null || invoiceRecord.Consumer_Signed_Date_For_Other__c != null){
                    if((invoiceRecord.recordTypeId == invoiceRecordTypeIdHearingAid || invoiceRecord.recordTypeId == invoiceRecordTypeIdSubHearingAid) && invoiceRecord.Consumer_Signed_Date__c != null && invoiceRecord.Consumer_Signed_Date__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_HEARING_AID_INVOICE) <= System.today()){
                        dayHearingAid = true;
                    }
                    if(invoiceRecord.recordTypeId == invoiceRecordTypeIdWeatherRadio && invoiceRecord.Consumer_Signed_Date_For_Other__c != null && invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_WEATHER_RADIO_INVOICE) <= System.today()){
                        //invoiceRecord.Consumer_Signed_Date__c = invoiceRecord.Consumer_Signed_Date_For_Other__c;
                        dayWeatherRadio = true;
                    }
                    if((invoiceRecord.recordTypeId == invoiceRecordTypeIdEDS || invoiceRecord.recordTypeId == invoiceRecordTypeIdCAPTEL) && invoiceRecord.Consumer_Signed_Date_For_Other__c != null && invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_OTHERS_INVOICE) <= System.today()){
                        //invoiceRecord.Consumer_Signed_Date__c = invoiceRecord.Consumer_Signed_Date_For_Other__c;
                        dayOther = true;
                    }
                }
                //(invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && invoiceRecord.Status__c =='Pending Approval'
                //|| invoiceRecord.Status__c =='Approved')
                if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT
                    && invoiceRecord.RecordTypeId != invoiceRecordTypeIdCommunicationAccess
                    &&  !invoiceRecord.Vendor_Invoice_Uploaded__c && invoiceRecord.RecordTypeId != invoiceRecordTypeIdTrainingVendor
                    && !excludeVendorTypes.contains(invoiceRecord.recordTypeId)){
                    invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_VENDOR_INVOICE_UPLOADED);
                }
                if(!invoiceRecord.SSP_Invoice__c && invoiceRecord.Expense_Indicator__c == 'SSP' && invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && (invoiceRecord.Status__c =='Pending Approval' || invoiceRecord.Status__c =='Approved')) {
                    invoiceRecord.addError('SSP Invoice document should be uploaded');
                }
                if(!invoiceRecord.Interpreter_Invoice__c && invoiceRecord.Expense_Indicator__c == 'INT' && invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && (invoiceRecord.Status__c =='Pending Approval' || invoiceRecord.Status__c =='Approved')) {
                    invoiceRecord.addError('Interpreter Invoice document should be uploaded');
                }
                if(!invoiceRecord.CART_Invoice__c && invoiceRecord.Expense_Indicator__c == 'CRT' && invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && (invoiceRecord.Status__c =='Pending Approval' || invoiceRecord.Status__c =='Approved')) {
                    invoiceRecord.addError('CART Invoice document should be uploaded');
                }
                if(!invoiceRecord.NDBEDP_SSP_Invoice__c && invoiceRecord.Expense_Indicator__c == 'DBS' && invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && (invoiceRecord.Status__c =='Pending Approval' || invoiceRecord.Status__c =='Approved')) {
                    invoiceRecord.addError('NDBEDP SSP Invoice document should be uploaded');
                }
                if(!invoiceRecord.NDBEDP_Interpreter_Invoice__c && invoiceRecord.Expense_Indicator__c == 'DBI' && invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && (invoiceRecord.Status__c =='Pending Approval' || invoiceRecord.Status__c =='Approved')) {
                    invoiceRecord.addError('NDBEDP Interpreter Invoice document should be uploaded');
                }
                if(!invoiceRecord.NDBEDP_CART_Invoice__c && invoiceRecord.Expense_Indicator__c == 'DBC' && invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess && (invoiceRecord.Status__c =='Pending Approval' || invoiceRecord.Status__c =='Approved')) {
                    invoiceRecord.addError('NDBEDP CART Invoice document should be uploaded');
                }
                if( invoiceRecord.RecordTypeId == invoiceRecordTypeIdTrainingVendor && invoiceRecord.Status__c =='Pending Approval'
                   && ( !invoiceRecord.Consumer_Evaluation_Survey__c || !invoiceRecord.Program_Training_Report__c)){
                       invoiceRecord.addError('Invoice document should be uploaded.');
                }
                    
    
                if(invoiceRecord.RecordTypeId == invoiceRecordTypeIdHearingAid || invoiceRecord.RecordTypeId == invoiceRecordTypeIdSubHearingAid){
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT && !invoiceRecord.Manufacture_Invoice_Uploaded__c){
                        invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_MANUFACTURE_INVOICE_UPLOADED);
                    }
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT &&  !dayHearingAid && invoiceRecord.Consumer_Signed_Date__c != null){
                        String submitdate = invoiceRecord.Consumer_Signed_Date__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_HEARING_AID_INVOICE).month() + '-' + invoiceRecord.Consumer_Signed_Date__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_HEARING_AID_INVOICE).day() + '-' + invoiceRecord.Consumer_Signed_Date__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_HEARING_AID_INVOICE).year();
                        invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_SUBMIT_APPROVAL_DAYS + submitdate);
                    }
                }
    
                if(invoiceRecord.RecordTypeId == invoiceRecordTypeIdWeatherRadio){
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT &&  (invoiceRecord.Tracking_Number__c == null || invoiceRecord.Tracking_Number__c.trim() == '')){
                        invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_TRACKING_NUMBER);
                    }
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT &&  !dayWeatherRadio && invoiceRecord.Consumer_Signed_Date_For_Other__c != null){
                        String submitdate = invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_WEATHER_RADIO_INVOICE).month() + '-' + invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_WEATHER_RADIO_INVOICE).day() + '-' + invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_WEATHER_RADIO_INVOICE).year();
                        invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_SUBMIT_APPROVAL_DAYS + submitdate);
                    }
                }
    
                if(invoiceRecord.RecordTypeId == invoiceRecordTypeIdEDS || invoiceRecord.RecordTypeId == invoiceRecordTypeIdCAPTEL){
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT &&  (invoiceRecord.Tracking_Number__c == null || invoiceRecord.Tracking_Number__c.trim() == '')){
                        invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_TRACKING_NUMBER);
                    }
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_EDS_PROGRAM_ASSISTANT &&  !dayOther && invoiceRecord.Consumer_Signed_Date_For_Other__c != null){
                        String submitdate = invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_OTHERS_INVOICE).month() + '-' + invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_OTHERS_INVOICE).day() + '-' + invoiceRecord.Consumer_Signed_Date_For_Other__c.addDays(NC_Constant.APPROVAL_DAYS_FOR_OTHERS_INVOICE).year();
                        invoiceRecord.addError(NC_Constant.INVOICE_TRIGGER_ERROR_SUBMIT_APPROVAL_DAYS + submitdate);
                    }
                }
                /* Uncomment Before Moving to Production
                if(invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccess){
                    if(invoiceRecord.Status__c == NC_Constant.INVOICE_STATUS_PENDING_APPROVAL && invoiceRecord.End_Service_Date_Time__c > System.now() ){
                        invoiceRecord.addError('You cannot submit invoice for approval before ' + invoiceRecord.End_Service_Date_Time__c);
                    }
                }
				*/
            }

            // NDBEDP Assessor validation 
            if(assessorTypeIds.contains(invoiceRecord.RecordTypeId) 
                && (invoiceRecord.status__c == 'Ready For Payment' && oldMap.get(invoiceRecord.Id).status__c == 'Pending NDBEDP Coordinator') && (invoiceRecord.NDBEDP_Coordinator_Comment__c == null)){
                    invoiceRecord.addError(NC_Constant.INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COORDINATOR_COMMENT);

            }else if(assessorTypeIds.contains(invoiceRecord.RecordTypeId)  && (invoiceRecord.status__c == 'Created' && oldMap.get(invoiceRecord.Id).status__c == 'Pending NDBEDP Coordinator' &&  invoiceRecord.NDBEDP_Coordinator_Comment__c == null)){
                invoiceRecord.addError(NC_Constant.INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COMMENT_REJECT); 
                
            }
            if(assessorTypeIds.contains(invoiceRecord.RecordTypeId)  && invoiceRecord.status__c == 'Created' && oldMap.get(invoiceRecord.Id).status__c != InvoiceRecord.status__c){
                invoiceRecord.NDBEDP_Coordinator_Comment__c = '';
            }
            
       }
    }
    
    /*
    *********************************************************
    @Method Name    : totalBilledAmountValidate
    @description    : Total amount to pat required validation
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void totalBilledAmountValidate(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap){
       //list<recordType> equipmentrecordType  = [SELECT Name, DeveloperName, Id, IsActive, SobjectType FROM RecordType WHERE DeveloperName = 'Equipment' AND SobjectType = 'Invoice__c'];        
        for(Invoice__c invoiceRecord : newList){  
          //if(invoiceRecord.RecordTypeId != equipmentrecordType[0].id){
              
          if(oldMap != NULL && oldMap.get(invoiceRecord.Id).Status__c != invoiceRecord.Status__c 
            && (invoiceRecord.Status__c == 'Pending Approval' || invoiceRecord.Status__c == 'Pending EDS Program Assistant')){                           
                if(invoiceRecord.Total_Amount_Billed__c == 0){
                    invoiceRecord.addError('Please update the invoice line items before submitting it for approval.');
                }
            }
            if(oldMap != NULL && oldMap.get(invoiceRecord.Id).Status__c == 'Pending EDS Program Coordinator' && invoiceRecord.Status__c == 'Pending Controller Office Approval' && invoiceRecord.Total_Amount_to_Pay_NDBEDP__c == 0) {
          		invoiceRecord.addError('Amount to Pay is required before approval');
          	}
        }
    }
    
    /*
    *********************************************************
    @Method Name    : populateStatusForReturn
    @description    : Populate Status to Returned when Return_Invoice is True
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void populateStatusForReturn(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap){
        Id invoiceRecordTypeIdHearingAid = NC_Utility.RecordTypeUtilityMethod('Invoice__c',NC_Constant.INVOICE_RECORDTYPE_HEARING_AID);
        Id invoiceRecordTypeIdCommunicationAccessRequest = NC_Utility.RecordTypeUtilityMethod('Invoice__c','Communication_Access_Request');
        Id invoiceRecordTypeIdTrainingVendorInvoice = NC_Utility.RecordTypeUtilityMethod('Invoice__c','Training_Vendor_Invoice');
        
        List<Invoice__c> newInvoiceList = new List<Invoice__c>();
        for(Invoice__c invoiceRecord : newList){
            if(oldMap != NULL && invoiceRecord.RecordTypeId == invoiceRecordTypeIdHearingAid
             && oldMap.get(invoiceRecord.Id).Return_Invoice__c != invoiceRecord.Return_Invoice__c
             && invoiceRecord.Return_Invoice__c){
                 invoiceRecord.Status__c = 'Returned';
             }
             if(oldMap != NULL 
             && oldMap.get(invoiceRecord.Id).Payment_Reference_Number__c != invoiceRecord.Payment_Reference_Number__c
             && invoiceRecord.Payment_Reference_Number__c != null
             ){
                 invoiceRecord.Status__c = 'Paid';
             }
            if(oldMap != NULL 
            //  && (oldMap.get(invoiceRecord.Id).Check_Canceled_Code__c != invoiceRecord.Check_Canceled_Code__c
            //  && invoiceRecord.Check_Canceled_Code__c != null) 

            && ((oldMap.get(invoiceRecord.id).Manually_Cancel_in_NCAS__c != invoiceRecord.Manually_Cancel_in_NCAS__c
                || oldMap.get(invoiceRecord.id).MM110_error_reason__c != invoiceRecord.MM110_error_reason__c)
                && invoiceRecord.Manually_Cancel_in_NCAS__c
                && invoiceRecord.NCAS_Status__c == 'X – Error' 
                && invoiceRecord.MM110_error_reason__c != null)
            || (oldMap.get(invoiceRecord.id).NCAS_Status__c != invoiceRecord.NCAS_Status__c
                && invoiceRecord.NCAS_Status__c == 'C - Invoice canceled'
                && invoiceRecord.Check_Canceled_Code__c != null)
            || ((oldMap.get(invoiceRecord.id).NCAS_Status__c != invoiceRecord.NCAS_Status__c || oldMap.get(invoiceRecord.id).Status__c != invoiceRecord.Status__c)
                && invoiceRecord.NCAS_Status__c == 'C - Invoice canceled'
                && invoiceRecord.Status__c == 'Canceled')){
                  //If NCAS status equals X error
                  Invoice__c invoice = invoiceRecord.clone();
                if(invoiceRecord.NCAS_Status__c == 'X – Error' && invoiceRecord.Manually_Cancel_in_NCAS__c){
                    invoiceRecord.Status__c='Submitted and Error';
                }
                else{
                    invoiceRecord.Status__c = 'Canceled';
                    invoice.Resolution_Checkbox__c = true;
                }
                
                if(invoiceRecord.RecordTypeId == invoiceRecordTypeIdCommunicationAccessRequest || invoiceRecord.RecordTypeId == invoiceRecordTypeIdTrainingVendorInvoice ) {
                    invoice.Status__c =  'Pending Approval';
                } else if(invoiceRecord.RecordTypeId == ndbedpTrainingTypeId || invoiceRecord.RecordTypeId == ndbedpAdditionalTrainingTypeId || invoiceRecord.RecordTypeId == ndbedpTrainingEventTypeId) {
                    invoice.Status__c =  'Created';
                } else if(invoiceRecord.RecordTypeId == equipmentTypeId) {
                    invoice.Status__c =  'Submitted and Error';
                } else {
                    invoice.Status__c =  'Pending EDS Program Coordinator';
                }
                invoice.Invoice_Generated__c = false;
                invoice.Error__c = null;
                invoice.Check_Returned__c = false;
                invoice.Manually_Cancel_in_NCAS__c = false;
                invoice.Manually_Cancel_check_in_NCAS__c = false;
                invoice.Reason_for_the_Cancellation__c = invoice.Check_Lost__c ? invoice.Reason_for_the_Cancellation__c : null;
                invoice.Check_Canceled_Code__c = null;   
                invoice.Payment_Reference_Number__c=null;
                invoice.Payment_Date__c=null;
                invoice.Payment_Type_Code__c=null;
                invoice.NCAS_Status__c=null;
                invoice.Resolution_Note__c = null;
                invoice.Check_Status__c = null;
                newInvoiceList.add(invoice);
            }
            if(oldMap != NULL 
             && oldMap.get(invoiceRecord.Id).NCAS_Status__c != invoiceRecord.NCAS_Status__c
             && invoiceRecord.NCAS_Status__c == 'N – record not in NCAS') {
                invoiceRecord.MM110_error_reason__c = null;
                invoiceRecord.Coordinator_Feedback_Required__c = false;
                invoiceRecord.Coordinator_Feedback__c = null;
                invoiceRecord.Invoice_Generated__c = false;
                invoiceRecord.Status__c = 'Submitted and Rejected';
            }
            //If status equals Submitted and Error
            if(oldMap != NULL 
             && oldMap.get(invoiceRecord.Id).NCAS_Status__c != invoiceRecord.NCAS_Status__c
             && invoiceRecord.NCAS_Status__c == 'X – Error') {
                invoiceRecord.MM110_error_reason__c = null;
                invoiceRecord.Coordinator_Feedback_Required__c = false;
                invoiceRecord.Coordinator_Feedback__c = null;
                invoiceRecord.Invoice_Generated__c = false;
                invoiceRecord.Status__c = 'Submitted and Error';
            }
             if(oldMap != NULL 
                && oldMap.get(invoiceRecord.Id).Status__c == 'Submitted and Error' && invoiceRecord.Status__c == 'Submitted and Error'
               	&& oldMap.get(invoiceRecord.Id).Manually_Cancel_in_NCAS__c && oldMap.get(invoiceRecord.Id).MM110_error_reason__c != null){
                     invoiceRecord.addError('Cannot update the record as the status is Submitted and Error');
                }

            if(oldMap != NULL 
            && oldMap.get(invoiceRecord.Id).Status__c == 'Submitted and Rejected'
            && (invoiceRecord.Status__c == 'Pending EDS Program Coordinator' || invoiceRecord.Status__c == 'Pending Approval')
            && invoiceRecord.MM110_error_reason__c == null) {
                invoiceRecord.addError('MM110 Error Reason required before approval to EDS Program Coordinator');
            }
             //If status equals Submitted and Error

            if(oldMap != NULL 
            && oldMap.get(invoiceRecord.Id).Status__c == 'Submitted and Error'
            && (invoiceRecord.Status__c == 'Pending EDS Program Coordinator' || invoiceRecord.Status__c == 'Pending Approval')
            && (invoiceRecord.MM110_error_reason__c == null  || invoiceRecord.Manually_Cancel_in_NCAS__c == false) ) {
                invoiceRecord.addError('MM110 Error Reason and Manually Cancel in NCAS Checkbox are requried before approval to EDS Program Coordinator');
            }
            //end
            if(oldMap != NULL 
            && invoiceRecord.NCAS_Status__c == 'N – record not in NCAS'
            && oldMap.get(invoiceRecord.Id).Coordinator_Feedback_Required__c != invoiceRecord.Coordinator_Feedback_Required__c
            && invoiceRecord.Coordinator_Feedback_Required__c
            && invoiceRecord.Coordinator_Feedback__c == null) {
                invoiceRecord.addError('Action Taken to resolve is required before approval');
            }
              //If status equals Submitted and Error
            if(oldMap != NULL 
            && invoiceRecord.MM110_error_reason__c != null
            && invoiceRecord.Coordinator_Feedback_Required__c
            && invoiceRecord.Coordinator_Feedback__c == null) {
                invoiceRecord.addError('Action Taken to resolve is required before approval');
            }
            //end
        }

        if(newInvoiceList.size() > 0) {
            if(Schema.sObjectType.Invoice__c.isCreateable()){
                insert newInvoiceList;
                //createInvoiceLineItems(newInvoiceList);
                Map<String, Map<String,String>> invoiceMap = new Map<String, Map<String,String>>();
                Map<String, String> checkLostInvoiceMap = new Map<String, String>();
                Map<String, String> invoiceClonedMap = new Map<String, String>();
                for(Invoice__c invoice: newInvoiceList){
                    invoiceClonedMap.put(invoice.getCloneSourceId(), invoice.id);
        
                    if(invoice.Check_Lost__c){
                        checkLostInvoiceMap.put(invoice.getCloneSourceId(), invoice.id);
                    }
                }
                invoiceMap.put('cloneMap', invoiceClonedMap);
                invoiceMap.put('checkLostMap', checkLostInvoiceMap);
                createInvoiceLineItems(JSON.serialize(invoiceMap));
            } else {
                throw new NC_Custom_Exception('You don\'t have access to insert Invoice__c');
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceLineItems
    @description    : clone invoice line items
    @param          : String invoiceString
    @return         : void
    ********************************************************
    */
    @future
    public static void createInvoiceLineItems(String invoiceString) {
        List<Invoice_Line_Item__c> clonedLineItemList = new List<Invoice_Line_Item__c>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        List<String> invoiceLineItemFields = getCreatableObjectFields('Invoice_Line_Item__c');
        String queryFields = getFieldsAsString(invoiceLineItemFields);
        
        Map<String, Map<String,String>> invoiceMap = (Map<String,Map<String,String>>)JSON.deserialize(invoiceString, Map<String,Map<String,String>>.class);
        Map<String, String> invoiceClonedMap = invoiceMap.get('cloneMap');
        Map<String, String> checkLostInvoiceMap = invoiceMap.get('checkLostMap');
        
        Set<String> invoiceIdSet = invoiceClonedMap.keySet();
        String query = 'SELECT ' + String.escapeSingleQuotes(queryFields) + ' FROM Invoice_Line_Item__c WHERE Invoice__c IN: invoiceIdSet';

        if(queryFields != null && invoiceClonedMap.keySet().size() > 0){
            List<Invoice_Line_Item__c> existingLineItems = (List<Invoice_Line_Item__c>) Database.query(query);
            for(Invoice_Line_Item__c invoiceLineItem: existingLineItems) {
                if(invoiceClonedMap.containsKey(invoiceLineItem.Invoice__c)){
                    Invoice_Line_Item__c lineItem = invoiceLineItem.clone();
                    lineItem.Invoice__c = invoiceClonedMap.get(invoiceLineItem.Invoice__c);
                    clonedLineItemList.add(lineItem);
                }
            }

            cdlList = cloneContentDocumentLinks(invoiceClonedMap, checkLostInvoiceMap);
        }
        
        if(clonedLineItemList.size() > 0) {
            insert clonedLineItemList;
        }

        if(Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            insert cdlList;
        }

        //Send for Approval
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(String invId: invoiceClonedMap.values()){   
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('');
            req.setObjectId(invId);      
            processList.add(req);
        }
        Approval.process(processList);
    }
	/*
    public static void createInvoiceLineItems(List<Invoice__c> newInvoiceList) {
        List<Invoice_Line_Item__c> clonedLineItemList = new List<Invoice_Line_Item__c>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

        List<String> invoiceLineItemFields = getCreatableObjectFields('Invoice_Line_Item__c');
        String queryFields = getFieldsAsString(invoiceLineItemFields);

        Map<String, String> checkLostInvoiceMap = new Map<String, String>();
        Map<String, String> invoiceClonedMap = new Map<String, String>();
        for(Invoice__c invoice: newInvoiceList){
            invoiceClonedMap.put(invoice.getCloneSourceId(), invoice.id);

            if(invoice.Check_Lost__c){
                checkLostInvoiceMap.put(invoice.getCloneSourceId(), invoice.id);
            }
        }

        Set<String> invoiceIdSet = invoiceClonedMap.keySet();
        String query = 'SELECT ' + String.escapeSingleQuotes(queryFields) + ' FROM Invoice_Line_Item__c WHERE Invoice__c IN: invoiceIdSet';

        if(queryFields != null && invoiceClonedMap.keySet().size() > 0){
            List<Invoice_Line_Item__c> existingLineItems = (List<Invoice_Line_Item__c>) Database.query(query);
            for(Invoice_Line_Item__c invoiceLineItem: existingLineItems) {
                if(invoiceClonedMap.containsKey(invoiceLineItem.Invoice__c)){
                    Invoice_Line_Item__c lineItem = invoiceLineItem.clone();
                    lineItem.Invoice__c = invoiceClonedMap.get(invoiceLineItem.Invoice__c);
                    clonedLineItemList.add(lineItem);
                }
            }

            cdlList = cloneContentDocumentLinks(invoiceClonedMap, checkLostInvoiceMap);
        }
        
        if(clonedLineItemList.size() > 0) {
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', clonedLineItemList, 'insert', true, 'NC_InvoiceTriggerHandler', 'createInvoiceLineItems');
            insert decision.getRecords();
        }

        if(Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            insert cdlList;
        }

        //Send for Approval
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        for(Invoice__c inv: newInvoiceList){   
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('');
            req.setObjectId(inv.id);      
            processList.add(req);
        }
        Approval.process(processList);
    }*/

    /*
    *********************************************************
    @Method Name    : cloneContentDocumentLinks
    @description    : clone contentdocumentlinks
    @param          : Map<String, String> linkedEntityMap, Map<String, String> checkLostInvoiceMap
    @return         : List<ContentDocumentLink>
    ********************************************************
    */
    public static List<ContentDocumentLink> cloneContentDocumentLinks(Map<String, String> linkedEntityMap, Map<String, String> checkLostInvoiceMap) {
        List<ContentDocumentLink> returnCdlList = new List<ContentDocumentLink>();
        Map<String, Invoice__c> updateInvoiceMap = new Map<String, Invoice__c>();

        List<String> cdlFieldList = getCreatableObjectFields('ContentDocumentLink');
        String queryFields = getFieldsAsString(cdlFieldList);

        Set<String> parentIds = linkedEntityMap.keySet();
        String query = 'SELECT ' + String.escapeSingleQuotes(queryFields) + ',ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN: parentIds';

        if(queryFields != null && parentIds.size() > 0){
            List<ContentDocumentLink> cdlList = (List<ContentDocumentLink>) Database.query(query);
            Set<String> affidavitOfLossSet = new Set<String>();
            for(ContentDocumentLink cdl: cdlList) {
                if(linkedEntityMap.containsKey(cdl.LinkedEntityId)){
                    if(cdl.ContentDocument.Title == 'Affidavit of loss' && checkLostInvoiceMap.size() > 0 && checkLostInvoiceMap.keySet().contains(cdl.LinkedEntityId) && !updateInvoiceMap.containsKey(cdl.LinkedEntityId)){
                        Invoice__c invoice = new Invoice__c();
                        if(!Test.isRunningTest()){
                        invoice.id = linkedEntityMap.get(cdl.LinkedEntityId);
                        }
                        invoice.Check_Lost__c=false;
                        invoice.Affidavit_of_loss_uploaded__c = false;
                        invoice.Reason_for_the_Cancellation__c = null;
                        updateInvoiceMap.put(cdl.LinkedEntityId, invoice);
                        continue;
                    }
                    ContentDocumentLink newCdl = cdl.clone();
                    newCdl.LinkedEntityId = linkedEntityMap.get(cdl.LinkedEntityId);
                    returnCdlList.add(newCdl);
                }
            }
            if(updateInvoiceMap.size() > 0){
                Database.update(updateInvoiceMap.values());
            }
        }
        return returnCdlList;
    }

    /*
    *********************************************************
    @Method Name    : getCreatableObjectFields
    @description    : get all creatable fields for object
    @param          : String objectName
    @return         : List<String>
    ********************************************************
    */
    public static List<String> getCreatableObjectFields(String objectName) {
        Schema.SObjectType sobjType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> MapofField = sobjType.getDescribe().fields.getMap();
        List<String> objectFields = new List<String>();
        if (MapofField != null) {
            for (Schema.SObjectField ft : MapofField.values()) {
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isCreateable()) {
                    objectFields.add(fd.getName());
                }
            }
        }
        return objectFields;
    }

    /*
    *********************************************************
    @Method Name    : getFieldsAsString
    @description    : Get string from list
    @param          : List<String> fieldList
    @return         : String
    ********************************************************
    */
    public static String getFieldsAsString(List<String> fieldList) {
        String fieldString = '';
        for(String field: fieldList) {
            fieldString += field + ', ';
        }
        fieldString = fieldString.substring(0, fieldString.length()-2);
        return fieldString;
    }   

    /*
    *********************************************************
    @Method Name    : checkActiveVendor
    @description    : Vendor update in progress validation
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void checkActiveVendor(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap){
		Set<String> invStatusSet = new Set<String>{'Paid', 'Canceled', 'Submitted and Error'};
        Set<Id> excludeInvoices = new Set<Id>{assessorTypeId, assessorTrainingTypeId, ndbedpPickupTypeId, ndbedpDeliveryTypeId};
        processB3flow = false;
        for(Invoice__c invoice : newList){
            //if((invoice.Status__c == 'Approved' || invoice.Status__c == 'Paid') && !invoice.Sent_to_NCAS__c && invoice.NCAS_Status__c != null){
            if(((invoice.Status__c == 'Approved' || invoice.Status__c == 'Paid' || invoice.Status__c == 'Submitted and Error') 
                && (!invoice.Sent_to_NCAS__c && invoice.NCAS_Status__c != null) || (!invoice.Sent_to_NCAS__c && (invoice.Payment_Date__c != oldMap.get(invoice.id).Payment_Date__c || invoice.Payment_Reference_Number__c  != oldMap.get(invoice.id).Payment_Reference_Number__c  || invoice.Payment_Type_Code__c  != oldMap.get(invoice.id).Payment_Type_Code__c || invoice.Check_Canceled_Code__c  != oldMap.get(invoice.id).Check_Canceled_Code__c ) ))
              || (invoice.Status__c == 'Pending Approval' && invoice.MM110_error_reason__c != null && invoice.Coordinator_Feedback__c == null)){
                //Process B2 & B3 flow
                processB3flow = true;
            } else {
            	if(invoice.Vendor_Status__c == 'Vendor Update In Progress' && !invStatusSet.contains(invoice.Status__c) && !excludeInvoices.contains(invoice.recordTypeId)) {
                    invoice.addError(NC_Constant.INVOICE_UPDATE_IN_PROGRESS);
                }
                if (invoice.Status__c != 'Vendor Update In Progress' && !invoice.Vendor_Active__c && !excludeInvoices.contains(invoice.recordTypeId)){
                    //invoice.addError('It cannot be updated because the vendor is inactive');
                }
                if(oldMap.get(invoice.id).Status__c == 'Vendor Update In Progress' 
                && (invoice.Vendor_Status__c == 'Submitted and Rejected' || invoice.Vendor_Status__c == 'Submitted and Error'
                    || (invoice.Vendor_MM102_error__c != null && invoice.Vendor_NCAS_Status__c == null)
                    || (invoice.Vendor_Status__c == 'Pending Approval' &&  invoice.Vendor_NCAS_Status__c == 'N – record not in NCAS'))) {
                    invoice.addError('It cannot be updated because the vendor is inactive');
                }
                Set<String> invoiceStatusSet = new Set<String>{'Pending EDS Program Assistant', 'Pending EDS Program Coordinator', 'Pending Controller Office Approval', 'Pending Approval'};
                if(invoiceStatusSet.contains(invoice.Status__c) && invoice.Booked_End_Date_Time__c != null && invoice.Booked_End_Date_Time__c > System.now()) {
                    invoice.addError('Invoices can\'t be submitted until the Staffing User Request Booked End Date/Time has passed');
                }   
            }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateNDBEDPTrainingInvoice
    @description    : validate NDBEDP Training invoice flow
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
   public static void validateNDBEDPTrainingInvoice(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap) {
        Id ndbedpTrainingTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Training');
        Id ndbedpAdditionalTrainingTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Additional_Training');
        Id ndbedpTrainingEventTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Training_Event');
        Set<Id> trainerInvoiceIds = new Set<Id>{ndbedpTrainingTypeId, ndbedpAdditionalTrainingTypeId, ndbedpTrainingEventTypeId};
        
        for(Invoice__c invoice: newList) {
            if (trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.Status__c == 'Pending NDBEDP Coordinator'
            && oldMap.get(invoice.id).Status__c == 'Created'
            && (!invoice.Consumer_Evaluation__c || !invoice.Program_Trainer_Report__c)) {
                invoice.addError('Consumer Evaluation and Program Trainer documents needs to be uploaded');
            }
            if (trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.Status__c == 'Pending NDBEDP Coordinator'
            && oldMap.get(invoice.id).Status__c == 'Created'
            && invoice.Total_Amount_Billed_NDBEDP__c == 0) {
                invoice.addError('Amount Billed is required before approval');
            }
            //NDBEDP Coordinator Approve
            if(trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.NDBEDP_Coordinator_Comment__c == null
            && (oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator')
            && (invoice.Status__c == 'Pending TRP Manager')) {
                invoice.addError(NC_Constant.INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COORDINATOR_COMMENT);
            }
            //NDBEDP Coordinator Reject
            if(trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.NDBEDP_Coordinator_Comment__c == null
            && (oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator')
            && (invoice.Status__c == 'Created')) {
                invoice.addError(NC_Constant.INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COMMENT_REJECT);
            }
            //TRP Manager Reject
            if(trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.TRP_Manager_Comment__c == null
            && (oldMap.get(invoice.id).Status__c == 'Pending TRP Manager')
            && (invoice.Status__c == 'Pending NDBEDP Coordinator')) {
                invoice.addError(NC_Constant.INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_TRP_MANAGER_COMMENT_REJECT);
            }
            //TRP Manager Approve
            if(trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.TRP_Manager_Comment__c == null
            && (oldMap.get(invoice.id).Status__c == 'Pending TRP Manager')
            && (invoice.Status__c == 'Pending Controller Office Approval')) {
                invoice.addError('Please provide the TRP manager comment');
            }
            if(trainerInvoiceIds.contains(invoice.recordTypeId) && invoice.status__c == 'Pending NDBEDP Coordinator' && oldMap.get(invoice.Id).status__c != invoice.status__c){
                invoice.NDBEDP_Coordinator_Comment__c = '';
            }
            if(trainerInvoiceIds.contains(invoice.recordTypeId) && invoice.status__c == 'Pending TRP Manager' && oldMap.get(invoice.Id).status__c != invoice.status__c){
                invoice.TRP_Manager_Comment__c = '';
            }
            //Action Taken to Resolve validation
            if(trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.MM110_error_reason__c != null
            && invoice.Coordinator_Feedback__c == null
            && (oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator')
            && (invoice.Status__c == 'Pending TRP Manager')) {
                invoice.addError('Action Taken to Resolve is required');
            }
            //Canceled Invoice resolution validation
            if(trainerInvoiceIds.contains(invoice.recordTypeId)
            && invoice.Resolution_Note__c == null
            && invoice.Resolution_Checkbox__c
            && (oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator')
            && (invoice.Status__c == 'Pending TRP Manager')) {
                invoice.addError('Canceled Invoice Resolution note required before approval');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : validateEquipmentInvoice
    @description    : validate Equipment invoice flow
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateEquipmentInvoice(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap) {
        Id ndbedpEquipmentTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Equipment');
        
        for(Invoice__c invoice: newList) {
            if(invoice.recordTypeId == ndbedpEquipmentTypeId
                && invoice.NDBEDP_Coordinator_Comment__c == null
                && oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator'
                && invoice.Status__c == 'Pending Controller Office Approval') {
                    invoice.addError(NC_Constant.INVOICE_NDBEDP_TRIGGER_ERROR_NDBEDP_COORDINATOR_COMMENT);
            }

            if(invoice.recordTypeId == ndbedpEquipmentTypeId
                && invoice.Comment__c == null
                && oldMap.get(invoice.id).Status__c == 'Pending Controller Office Approval'
                && invoice.Status__c == 'Pending NDBEDP Coordinator') {
                    invoice.addError('Please provide a comment before Reject');
            }
            if(invoice.recordTypeId == ndbedpEquipmentTypeId && invoice.status__c == 'Pending Controller Office Approval' && oldMap.get(invoice.Id).status__c != invoice.status__c){
                invoice.Comment__c = '';
            }
            if(invoice.recordTypeId == ndbedpEquipmentTypeId && invoice.Status__c == 'Pending NDBEDP Coordinator' && oldMap.get(invoice.Id).status__c != invoice.status__c){
                invoice.NDBEDP_Coordinator_Comment__c = '';
            }

            if(invoice.recordTypeId == ndbedpEquipmentTypeId && oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator'
                && invoice.Status__c == 'Pending Controller Office Approval' 
                && invoice.NDBEDP_Coordinator__c == false){
                    invoice.addError('Please upload Invoice File document before approval');

            }
            //Action Taken to Resolve validation
            if(invoice.recordTypeId == ndbedpEquipmentTypeId
            && invoice.MM110_error_reason__c != null
            && invoice.Coordinator_Feedback__c == null
            && oldMap.get(invoice.id).Status__c == 'Pending NDBEDP Coordinator'
            && invoice.Status__c == 'Pending Controller Office Approval') {
                invoice.addError('Action Taken to Resolve is required');
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : validateCheckCancel
    @description    : validate Check Cancel flow
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateCheckCancel(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap) {
        List<Id> deleteAffidevitOfLosssInvoices = new List<Id>();
        List<ContentDocumentLink> deleteCdlList = new List<ContentDocumentLink>();
        for(Invoice__c invoiceRecord: newList) {
            if(oldMap.get(invoiceRecord.id).Check_Canceled_Code__c != invoiceRecord.Check_Canceled_Code__c
                && invoiceRecord.Check_Canceled_Code__c == checkCanceledCode) {
                invoiceRecord.Check_Status__c = 'Canceled';
                invoiceRecord.Status__c = 'Pending Cancellation';
            }
            if(invoiceRecord.Status__c == 'Paid'
                && ((oldMap.get(invoiceRecord.id).Check_Lost__c != invoiceRecord.Check_Lost__c && invoiceRecord.Check_Lost__c)
                    || (oldMap.get(invoiceRecord.id).Check_Returned__c != invoiceRecord.Check_Returned__c && invoiceRecord.Check_Returned__c))) {
                invoiceRecord.Check_Status__c = 'Pending Cancellation';
                invoiceRecord.Status__c = 'Pending Cancellation';
            }
            if(oldMap.get(invoiceRecord.id).Payment_Date__c != invoiceRecord.Payment_Date__c) {
                invoiceRecord.Old_Payment_Date__c = invoiceRecord.Payment_Date__c;
            }
            if(oldMap.get(invoiceRecord.id).Payment_Reference_Number__c != invoiceRecord.Payment_Reference_Number__c) {
                invoiceRecord.Old_Payment_Reference_Number__c = invoiceRecord.Payment_Reference_Number__c;
            }
            if(oldMap.get(invoiceRecord.id).Payment_Type_Code__c != invoiceRecord.Payment_Type_Code__c) {
                invoiceRecord.Old_Payment_Type_Code__c = invoiceRecord.Payment_Type_Code__c;
            }
            if((invoiceRecord.Status__c == 'Paid' || invoiceRecord.Status__c == 'Pending Cancellation')
            && oldMap.get(invoiceRecord.id).Check_Canceled_Code__c == invoiceRecord.Check_Canceled_Code__c
            && (oldMap.get(invoiceRecord.id).Payment_Date__c != invoiceRecord.Payment_Date__c
                || oldMap.get(invoiceRecord.id).Payment_Reference_Number__c != invoiceRecord.Payment_Reference_Number__c
                || oldMap.get(invoiceRecord.id).Payment_Type_Code__c != invoiceRecord.Payment_Type_Code__c)) {
                    invoiceRecord.Check_Lost__c = false;
                    invoiceRecord.Check_Returned__c = false;
                    invoiceRecord.Check_Canceled_Code__c = null;
                    invoiceRecord.Status__c = 'Paid';
                    invoiceRecord.Check_Status__c = null;
                    invoiceRecord.Reason_for_the_Cancellation__c = null;
                    invoiceRecord.Affidavit_of_loss_uploaded__c = false;
                    deleteAffidevitOfLosssInvoices.add(invoiceRecord.id);
            }
        }

        if(deleteAffidevitOfLosssInvoices.size() > 0) {
            for(ContentDocumentLink cdl: [SELECT id FROM ContentDocumentLink WHERE LinkedEntityId IN: deleteAffidevitOfLosssInvoices AND ContentDocument.Title = 'Affidavit of loss']) {
                deleteCdlList.add(cdl);
            }
        }

        if(deleteCdlList.size() > 0) {
            delete deleteCdlList;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validateAmountToPay
    @description    : validate amount to pay for all invoices
    @param          : List<Invoice__c> newList,Map<Id, Invoice__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void validateAmountToPay(List<Invoice__c> newList,Map<Id, Invoice__c> oldMap) {
        Set<Id> assessorRecordTypes = new Set<Id>{assessorTypeId, assessorTrainingTypeId, ndbedpPickupTypeId, ndbedpDeliveryTypeId, ndbedpFollowTypeId};
        Set<Id> trainerRecordTypes = new Set<Id>{ndbedpTrainingTypeId, ndbedpTrainingEventTypeId, ndbedpAdditionalTrainingTypeId};
        Id invoiceCommunicationId = SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        Set<Id> invoiceIds = new Set<Id>();
        Boolean isAmountToPayAvailable = false;
        for(invoice__c invoiceObj: newList) {
            if((assessorRecordTypes.contains(invoiceObj.recordTypeId)
                    && oldMap.get(invoiceObj.id).Status__c == 'Pending NDBEDP Coordinator'
                    && invoiceObj.Status__c == 'Ready For Payment')
                || (trainerRecordTypes.contains(invoiceObj.recordTypeId)
                    && oldMap.get(invoiceObj.id).Status__c == 'Pending NDBEDP Coordinator'
                    && invoiceObj.Status__c == 'Pending TRP Manager')
                || (invoiceObj.recordTypeId == equipmentTypeId
                    && oldMap.get(invoiceObj.id).Status__c == 'Pending NDBEDP Coordinator'
                    && invoiceObj.Status__c == 'Pending Controller Office Approval')
                || (invoiceObj.recordTypeId == invoiceCommunicationId
                    //&& ndbedpVendorTypes.contains(invoiceObj.Vendor_Type__c)
                    && oldMap.get(invoiceObj.id).Status__c == 'Pending Approval'
                    && invoiceObj.Status__c == 'Pending Controller Office Approval')) {
                        invoiceIds.add(invoiceObj.id);
            }
        }
        if(invoiceIds.size() > 0) {
            for(invoice__c invoiceObj: [SELECT recordTypeId, (SELECT Amount_to_Pay__c, Amount_Billed__c FROM Invoice_Line_Items__r) FROM invoice__c WHERE Id IN: invoiceIds WITH SECURITY_ENFORCED]) {
                isAmountToPayAvailable = false;
                for(Invoice_Line_Item__c lineItemObj: invoiceObj.Invoice_Line_Items__r) {
                    if((assessorRecordTypes.contains(invoiceObj.recordTypeId) || trainerRecordTypes.contains(invoiceObj.recordTypeId) || invoiceObj.recordTypeId == invoiceCommunicationId || invoiceObj.recordTypeId == equipmentTypeId) && lineItemObj.Amount_to_Pay__c > 0) {
                        isAmountToPayAvailable = true;
                    }
                }
                if(!isAmountToPayAvailable) {
                    Trigger.newMap.get(invoiceObj.id).addError('Amount to Pay is required before approval');
                }
            }
        }
    }
}