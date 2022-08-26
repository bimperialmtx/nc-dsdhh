/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 09-09-2021
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_InvoiceLineItemPortalCrtl {
    /*
    *********************************************************
    @Method Name    : checkRecordType
    @description    : Check record type of invoice based on record id
    @param          : Id invoiceId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> checkRecordType(Id invoiceId){
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            
            if(invoiceId!=null){
              Invoice__c inv=[SELECT Id,RecordType.DeveloperName, Vendor_Type__c FROM Invoice__c WHERE Id=:invoiceId WITH SECURITY_ENFORCED LIMIT 1];
              
              if(inv.RecordType.DeveloperName=='Communication_Access_Request' && (inv.Vendor_Type__c == 'NDBEDP SSP' || inv.Vendor_Type__c == 'NDBEDP CART' || inv.Vendor_Type__c == 'NDBEDP Interpreters')) {
                  resultMap.put('NDBEDPLineItem', true);
              } else if(inv.RecordType.DeveloperName=='Assessment' || inv.RecordType.DeveloperName =='Assessor_Training_Installation' || inv.RecordType.DeveloperName=='NDBEDP_Additional_Training' || inv.RecordType.DeveloperName=='NDBEDP_Delivey' || inv.RecordType.DeveloperName=='NDBEDP_Follow_Up' || inv.RecordType.DeveloperName=='NDBEDP_Pick_up' || inv.RecordType.DeveloperName=='NDBEDP_Training' || inv.RecordType.DeveloperName=='NDBEDP_Training_Event') {
                  resultMap.put('NDBEDPLineItem', true);
              } else if(inv.RecordType.DeveloperName=='Communication_Access_Request' || inv.RecordType.DeveloperName=='Training_Vendor_Invoice') {
                  //resultMap.put('CommunicationLineItem', true);
                  resultMap.put('NDBEDPLineItem', true);
              } else if(inv.RecordType.DeveloperName=='CAPTEL'|| inv.RecordType.DeveloperName=='EDS' || inv.RecordType.DeveloperName=='Equipment' || inv.RecordType.DeveloperName=='Hearing_AID' || inv.RecordType.DeveloperName=='Sub_Hearing_AID' || inv.RecordType.DeveloperName=='Weather_Radio') {
                  resultMap.put('EDSLineItem', true);
              }	
           /*
           if(inv.RecordType.DeveloperName=='Assessment' || inv.RecordType.DeveloperName =='Assessor_Training_Installation' || inv.RecordType.DeveloperName=='Communication_Access_Request' || inv.RecordType.DeveloperName=='NDBEDP_Additional_Training' || inv.RecordType.DeveloperName=='NDBEDP_Delivey' || inv.RecordType.DeveloperName=='NDBEDP_Follow_Up' || inv.RecordType.DeveloperName=='NDBEDP_Pick_up' || inv.RecordType.DeveloperName=='NDBEDP_Training' || inv.RecordType.DeveloperName=='Training_Vendor_Invoice'){
             result=true;
           }
           else if(inv.RecordType.DeveloperName=='CAPTEL'|| inv.RecordType.DeveloperName=='EDS' || inv.RecordType.DeveloperName=='Equipment' || inv.RecordType.DeveloperName=='Hearing_AID' || inv.RecordType.DeveloperName=='Sub_Hearing_AID' || inv.RecordType.DeveloperName=='Weather_Radio'){
               result=false;
           }*/
         	}
         } catch (Exception e) {
             //throw new AuraHandledException(e.getMessage());
             resultMap.put('Error', e.getMessage());
         }
         return resultMap;
    }
}