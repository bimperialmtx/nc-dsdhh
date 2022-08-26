/**
 * @description       : 
 * @author            : Saurav Nirwal
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-05-2021   Saurav Nirwal   Initial Version
**/
public with sharing class NC_InvoiceDetailsController {
    
    public Account vendorDetail {get;set;}
    public Map<String, Map<String, List<VendorDetails>>> vendorInvoiceMap {get;set;}
    public Map<String, Decimal> totalCheckAmountMap {get;set;}

    public NC_InvoiceDetailsController() {
        String checkNo;
        String checkNo1;
        String vendorId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id').escapeHtml4());
        checkNo1 =String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('checkNo').escapeHtml4());
        
        String[] splitList =checkNo1.split('\\.');
        if(checkNo1!=null ){
        checkNo = splitList[0];
   
        fetchInvoiceData(vendorId, checkNo);
        }
    }

    /*
    *********************************************************
    @Method Name    : fetchInvoiceData
    @description    : Retrieve invoice and its related authorizationa and vendor data
    @param          : String vendorId, String checkNo
    @return         : void
    ********************************************************
    */
    public void fetchInvoiceData(String vendorId, String checkNo) {
        //checkNo = Double.valueOf(checkNo) + '';
        Account vendorData = [SELECT Name, BillingStreet,
                                BillingCity,
                                BillingState,
                                BillingPostalCode,
                                BillingCountry,
                                 (SELECT id FROM Authorizations__r)
                            FROM Account WHERE id =: vendorId WITH SECURITY_ENFORCED LIMIT 1 ];

        Set<Id> authorizationIds = new Set<Id>();
        if(vendorData != null && vendorData.Authorizations__r != null){
            for(Authorization__c authorization: vendorData.Authorizations__r){
                authorizationIds.add(authorization.id);
            }
        }

        List<Authorization__c> authorizationList = [SELECT Name,
                                                        (SELECT Total_Amount_Billed__c,
                                                         	Total_Amount_Billed_NDBEDP__c,
                                                         	Total_Amount_to_Pay_NDBEDP__c,
                                                         	recordTypeId,
                                                         	Total_Amount_Authorized_HA__c,
                                                            Total_Amount_Authorized__c,
                                                            Total_Amount_Authorized_Staffing__c,
                                                            Vendor_Invoice_Number__c,
                                                            Payment_Reference_Number__c,
                                                            Name 
                                                        FROM Invoices__r
                                                        WHERE 
                                                        //Invoice_Generated__c = false
                                                       //  Payment_Reference_Number__c =: Decimal.valueOf(checkNo))
                                                        Payment_Reference_Number__c =: checkNo)

                                                        // Status__c = 'Paid' )
                                                     FROM Authorization__c WHERE id IN: vendorData.Authorizations__r WITH SECURITY_ENFORCED];
        
        vendorInvoiceMap = new Map<String, Map<String, List<VendorDetails>>>();
        
        Id hearingAidTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Hearing_AID').getRecordTypeId();
        Id subHearingAidTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Sub_Hearing_AID').getRecordTypeId();
        Set<Id> invoiceHARecTypeIds = new Set<Id>{hearingAidTypeId, subHearingAidTypeId};
            
        Id commAccessTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Communication_Access_Request').getRecordTypeId();
        
        Id trainingTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training').getRecordTypeId();
        Id addTrainingTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Additional_Training').getRecordTypeId();
        Id trainingEventTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('NDBEDP_Training_Event').getRecordTypeId();
        Set<Id> trainerInvRecTypeIds = new Set<Id>{trainingTypeId, addTrainingTypeId, trainingEventTypeId};

        for(Authorization__c authorization: authorizationList){
            Map<String, List<VendorDetails>> vendorAuthMap = new Map<String, List<VendorDetails>>();
            for(Invoice__c invoice: authorization.Invoices__r){
                VendorDetails vendorDetail = new VendorDetails();
                vendorDetail.authorizationNumber = authorization.Name;
                vendorDetail.invoiceNumber = invoice.Name;
                vendorDetail.internalInvoiceNumber = invoice.Vendor_Invoice_Number__c;
                if(invoiceHARecTypeIds.contains(invoice.recordTypeId)) {
                    vendorDetail.authorizationAmount = invoice.Total_Amount_Authorized_HA__c;
                } else if (invoice.recordTypeId == commAccessTypeId) {
                    vendorDetail.authorizationAmount = invoice.Total_Amount_Authorized_Staffing__c;
                } else if(trainerInvRecTypeIds.contains(invoice.recordTypeId)) {
                    vendorDetail.authorizationAmount = invoice.Total_Amount_Billed_NDBEDP__c;
                } else {
                    vendorDetail.authorizationAmount = invoice.Total_Amount_Authorized__c;
                }
                vendorDetail.amountPaid = invoice.Total_Amount_to_Pay_NDBEDP__c;

                if(vendorInvoiceMap.containsKey(invoice.Payment_Reference_Number__c+'')){
                    Map<String, List<VendorDetails>> authInvoiceMap = vendorInvoiceMap.get(invoice.Payment_Reference_Number__c+'');
                    if(authInvoiceMap.containsKey(authorization.Name)){
                        authInvoiceMap.get(authorization.Name).add(vendorDetail);
                    }else{
                        authInvoiceMap.put(authorization.Name, new List<VendorDetails>{vendorDetail});
                    }
                    vendorInvoiceMap.get(invoice.Payment_Reference_Number__c+'').putAll(authInvoiceMap);
                }
                else{
                    if(vendorAuthMap.containsKey(authorization.Name)){
                        vendorAuthMap.get(authorization.Name).add(vendorDetail);
                    }else{
                        vendorAuthMap.put(authorization.Name, new List<VendorDetails>{vendorDetail});
                    }
                    if(invoice.Payment_Reference_Number__c != null){
                        vendorInvoiceMap.put(invoice.Payment_Reference_Number__c+'', vendorAuthMap);
                    }
                }
            }
        }

        totalCheckAmountMap = new Map<String, Decimal>();
        for(String checkNumber: vendorInvoiceMap.keySet()){
            
            Map<String, List<VendorDetails>> authMap = vendorInvoiceMap.get(checkNo);
            Decimal totalCheckAmount = 0;
            for(String invoice: authMap.keySet()){
                for(VendorDetails vendor: authMap.get(invoice)){
                    vendor.authRowSpan = authMap.get(invoice).size() + '';
                    totalCheckAmount += vendor.amountPaid;
                }
            }
            totalCheckAmountMap.put(checkNumber, totalCheckAmount);
        }
        vendorDetail = vendorData;
    }

    public class VendorDetails {
        public String checkNumber {get;set;}
        public String totalChecAmount {get;set;}
        public String authorizationNumber {get;set;}
        public String invoiceNumber {get;set;}
        public String internalInvoiceNumber {get;set;}
        public Decimal authorizationAmount {get;set;}
        public Decimal amountPaid {get;set;}
        public String authRowSpan {get;set;}
    }
}