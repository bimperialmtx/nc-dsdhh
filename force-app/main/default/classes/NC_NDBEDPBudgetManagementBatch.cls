/**
 * @description       : Update all hold Invoices to Paid when NDBEDP budget available
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_NDBEDPBudgetManagementBatch implements Database.Batchable<sObject>,Schedulable{

    Id invoiceEquipmentRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
    Id invoiceAssessmentRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessment').getRecordTypeId();
    Id invoiceAssessorTrainingRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Assessor_Training_Installation').getRecordTypeId();
    Id invoiceNDBEDPDeliveryRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Delivey').getRecordTypeId();
    Id invoiceNDBEDPFollowUpRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Follow_Up').getRecordTypeId();
    Id invoiceNDBEDPPickupRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Pick_up').getRecordTypeId();
    Id invoiceNDBEDPTrainingRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training').getRecordTypeId();
    Id invoiceNDBEDPTrainingEventRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training_Event').getRecordTypeId();
    Id invoiceAdditionalTrainingRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();
    Id invoiceCommunicationId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get(NC_Constant.COMMUNICATION_ACCESS_REQUEST).getRecordTypeId();

    Set<Id> ndbedpInvoiceTypes = new Set<Id>{invoiceEquipmentRecordTypeId, invoiceAssessmentRecordTypeId, 
    invoiceAssessorTrainingRecordTypeId, invoiceAdditionalTrainingRecordTypeId, invoiceNDBEDPDeliveryRecordTypeId, 
    invoiceNDBEDPFollowUpRecordTypeId, invoiceNDBEDPPickupRecordTypeId, invoiceNDBEDPTrainingRecordTypeId, invoiceNDBEDPTrainingEventRecordTypeId};

    Set<String> vendorTypes = new Set<String>{'NDBEDP SSP', 'NDBEDP CART', 'NDBEDP Interpreters'};

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT name, RecordTypeId, recordType.Developername, Vendor_Type__c, lastModifiedDate, Authorization__r.Total_Authorized_Amount__c, Status__c, Authorization__r.CreatedDate, Payment_Date__c, Authorization__r.RecordTypeId, Total_Amount_Billed__c, Total_Amount_to_Pay_NDBEDP__c from Invoice__c WHERE Status__c = \'Hold\' AND (recordTypeId IN: ndbedpInvoiceTypes OR (recordTypeId =: invoiceCommunicationId AND Vendor_Type__c IN: vendorTypes))';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Invoice__c> invoiceList) {
        if(invoiceList.size() > 0) {
            updteNDBEDPInvoiceBudget(invoiceList);
        }
    }

    public void updteNDBEDPInvoiceBudget(List<invoice__c> invoiceList){
        Map<Id, Invoice__c> mapOfinvoiceWithAuth = new Map<Id, Invoice__c>();
        List<Budget_Management__c> listOfBudgetToBeUpdate = new List<Budget_Management__c>();
        Map<Id, Budget_Management__c> mapOfBudgetToBeUpdate = new Map<Id, Budget_Management__c>();
        Map<Id, Budget_Management__c> mapOfBudgetManagement = new Map<Id, Budget_Management__c>();

        for(Invoice__c invoicerecord : invoiceList){
            mapOfinvoiceWithAuth.put(invoicerecord.Id, invoicerecord);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Amount_Utilized__c, OwnerId, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetManagement.put(budgetManagementRecord.Id, budgetManagementRecord);
        }
        for(Id invoiceId : mapOfinvoiceWithAuth.keySet()){
            if(mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate != null){
                Date invoiceIssueDate;
                if(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c != null) {
                    invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.year(),mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.month(), mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.day());
                } else {
                    invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.year(),mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.month(), mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.day());
                }
                Boolean invoicePaid = false;
                for(Id budgetId : mapOfBudgetManagement.keySet()){
                    if(invoiceEquipmentRecordTypeId == mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.NDBEDP_BUDGET) {
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            mapOfinvoiceWithAuth.get(invoiceId).Status__c = 'Paid';
                        }
                    } else if(invoiceCommunicationId == mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId && vendorTypes.contains(mapOfinvoiceWithAuth.get(invoiceId).Vendor_Type__c) && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.NDBEDP_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_to_Pay_NDBEDP__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            mapOfinvoiceWithAuth.get(invoiceId).Status__c = 'Paid';
                        }
                    } else if(ndbedpInvoiceTypes.contains(mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId) && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.NDBEDP_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_to_Pay_NDBEDP__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            mapOfinvoiceWithAuth.get(invoiceId).Status__c = 'Paid';
                        }
                    }
                }
            }
            
        }
        for(Budget_Management__c budget: listOfBudgetToBeUpdate) {
			mapOfBudgetToBeUpdate.put(budget.id, budget);
        }
       
        if(!mapOfBudgetToBeUpdate.values().isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', mapOfBudgetToBeUpdate.values(), 'update', true,'NC_BudgetManagementController','updteBudgetFromInvoice');
            update objectDecision.getRecords();
            UPDATE mapOfinvoiceWithAuth.values();
        }
    }

    public void execute(SchedulableContext sc) {
        NC_NDBEDPBudgetManagementBatch batchObject = new NC_NDBEDPBudgetManagementBatch ();
        database.executebatch(batchObject);
    }

    public void finish(Database.BatchableContext bc) {
        //finish
    }
}