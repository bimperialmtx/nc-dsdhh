/*
*   Class Name: NC_InvoiceLineItemStaffing
*   Description: Controller for NC_InvoiceLineItemStaffing Component
*
*   Date              New/Modified            User                 Identifier                Description
*   06/11/2020         updated                Shubham Dadhich
*/
public with sharing class NC_InvoiceLineItemStaffingController {
    
    /*
    *********************************************************
    @Method Name    : getAllLineItems
    @description    : Method to get all the child Invoice Line Items
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> getAllLineItems(Id recordId){
        Id CommunicationRecordTypeIdInvoice =  NC_Utility.RecordTypeUtilityMethod('Invoice__c',  NC_Constant.INVOICE_RECORDTYPE_COMMUNICATION);
        Map<String,Object> result = new Map<String,Object>();
        List<LineItemWrapper> lineItemListWrapperList = new List<LineItemWrapper>();
        LineItemWrapper invoiceLineItem;
        Decimal totalAmountBilled = 0;
        Decimal totalAmountBilledFinal=0;
        for(Invoice_Line_Item__c selectedLineItem :[SELECT id,Name, Sequence__c,Billed_Amount_Editable__c, Is_Editable__c, Quantity__c, Amount_Authorized__c,Amount_Billed__c,Equipment_Name__c, Invoice__r.RecordTypeId , Maximum_Quantity__c, Invoice__r.Comment__c FROM Invoice_Line_Item__c WHERE Invoice__c =: recordId WITH SECURITY_ENFORCED ORDER BY Sequence__c Asc]){
            Boolean otherCommentVisible = selectedLineItem.Equipment_Name__c == 'Other' ? true : false;
            String otherComment = selectedLineItem.Invoice__r.Comment__c;
            invoiceLineItem = new LineItemWrapper(selectedLineItem.Id, selectedLineItem.Equipment_Name__c, selectedLineItem.Amount_Authorized__c == NULL ? 0.0 : selectedLineItem.Amount_Authorized__c, selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c, selectedLineItem.Quantity__c, selectedLineItem.Is_Editable__c, selectedLineItem.Billed_Amount_Editable__c, selectedLineItem.Maximum_Quantity__c!=NULL ? selectedLineItem.Maximum_Quantity__c : 999999999, otherCommentVisible, otherComment, selectedLineItem.Sequence__c);
            lineItemListWrapperList.add(invoiceLineItem);   
            totalAmountBilled += selectedLineItem.Amount_Billed__c;
            totalAmountBilledFinal = totalAmountBilled;
            totalAmountBilled = totalAmountBilledFinal.setScale(2);
        }
        result.put('lineItemListWrapperList',lineItemListWrapperList);
        result.put('totalAmountBilled',totalAmountBilled);
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : updateAllLineItems
    @description    : Method to update the Invoice line Items
    @param          : String lineItemData, String recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> updateAllLineItems(String lineItemData, String recordId){
        
        Map<String,Object> result = new Map<String,Object>();
        List<LineItemWrapper> lineItemListWrapperList = (List<LineItemWrapper>) JSON.deserialize(lineItemData, List<LineItemWrapper>.class);
        List<Invoice_Line_Item__c> invoiceLineItemToUpdate = new List<Invoice_Line_Item__c>();
        Map<Id,LineItemWrapper> invoiceLineItemIdToWrapperMap = new Map<Id,LineItemWrapper>();
        LineItemWrapper invoiceLineItem;
        Decimal totalAmountBilled = 0.0;
        Decimal totalAmountBilledFinal=0.0;
        String otherComment=null;
         
        Invoice__c invoice = [SELECT Id,Comment__c, Regular_Service_Hours__c, Enhanced_Service_Hours__c, Excess_Hotel_Cost__c, Enhanced_Hours__c, Dinner__c, Parking__c, Breakfast__c, Lunch__c, Hotels__c, Mileage__c, Standard_Hours__c FROM Invoice__c WHERE Id =:recordId WITH SECURITY_ENFORCED ];
        for(LineItemWrapper lineItemSelected : lineItemListWrapperList){
            invoiceLineItemIdToWrapperMap.put(lineItemSelected.invoiceLineItemId,lineItemSelected);
        }
        lineItemListWrapperList.clear();
        for(Invoice_Line_Item__c selectedLineItem :[SELECT id,Name, Is_Editable__c, Billed_Amount_Editable__c, Quantity__c, Amount_Authorized__c, Amount_Billed__c,Equipment_Name__c, Returned__c , Maximum_Quantity__c, Sequence__c FROM Invoice_Line_Item__c WHERE Id In: invoiceLineItemIdToWrapperMap.keySet() WITH SECURITY_ENFORCED ORDER BY Name Asc]){
            if(selectedLineItem.Amount_Billed__c != invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled){
                if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Parking'){
                    invoice.Parking__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Hotels'){
                    invoice.Hotels__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName.contains('Enhanced')){
                    if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Enhanced Service Hours') {
                        invoice.Enhanced_Service_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                    } else {
                        invoice.Enhanced_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                    }
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Regular Service Hours'){
                    invoice.Regular_Service_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Dinner'){
                    invoice.Dinner__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Lunch'){
                    invoice.Lunch__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Mileage'){
                    invoice.Mileage__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Breakfast'){
                    invoice.Breakfast__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Service Hours'){
                    invoice.Service_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Travel Time'){
                    invoice.Travel_Time__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName.contains('Standard')){
                    invoice.Standard_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Food'){
                    invoice.Food__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Lodging'){
                    invoice.Lodging__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Other'){
                    invoice.Other__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Excess hotel Cost'){
                    invoice.Excess_Hotel_Cost__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                }else{
                }
                selectedLineItem.Quantity__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantity; 
                selectedLineItem.Amount_Billed__c = (invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled).setScale(2);
            }   
            totalAmountBilled += selectedLineItem.Amount_Billed__c;
            totalAmountBilledFinal = totalAmountBilled;
            totalAmountBilled = totalAmountBilledFinal.setScale(2);
			Boolean otherCommentVisible = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).otherCommentVisible;
            if(invoiceLineItemIdToWrapperMap.containsKey(selectedLineItem.Id) && invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).otherComment != null) {
                otherComment = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).otherComment;
            }            
            invoiceLineItem = new LineItemWrapper(selectedLineItem.Id, selectedLineItem.Equipment_Name__c, selectedLineItem.Amount_Authorized__c == NULL ? 0.0 : selectedLineItem.Amount_Authorized__c,selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c, selectedLineItem.Quantity__c, selectedLineItem.Is_Editable__c, selectedLineItem.Billed_Amount_Editable__c, selectedLineItem.Maximum_Quantity__c != NULL ? selectedLineItem.Maximum_Quantity__c : 999999999, otherCommentVisible, otherComment, selectedLineItem.Sequence__c);
            lineItemListWrapperList.add(invoiceLineItem);
            invoiceLineItemToUpdate.add(selectedLineItem);    
        }
        if(invoiceLineItemToUpdate.size()>0){
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', invoiceLineItemToUpdate, 'update', true, 'NC_InvoiceLineItemStaffingController', 'updateAllLineItems');
            update decision.getRecords();
            //Update invoiceLineItemToUpdate;
            //invoiceLineItemToUpdate[0].id = decision.getRecords()[0].id;

            invoice.comment__c = otherComment;
            SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoice}, 'update', true, 'NC_InvoiceLineItemStaffingController','updateAllLineItems');
            update decision1.getRecords();
           // invoice.id = decision1.getRecords()[0].id;
           //Update invoice;
        }
        lineItemListWrapperList.sort();
        result.put('lineItemListWrapperList',lineItemListWrapperList);  
        result.put('totalAmountBilled',totalAmountBilled);
        
        return result;
        
    }

    /*
    * Class Name: LineItemWrapper
    * Description: This is a Wrapper class of Invoice line Items
    */
    
    public class LineItemWrapper implements Comparable{
        @AuraEnabled public String lineItemName;
        @AuraEnabled public Id invoiceLineItemId;
        @AuraEnabled public Decimal amountAuthorized;
        @AuraEnabled public Decimal amountBilled ;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Boolean isEditable;
        @AuraEnabled public Boolean isBilledEditable;
        @AuraEnabled public Decimal maximumValue;
        @AuraEnabled public Decimal sequnce;
        @AuraEnabled public Boolean otherCommentVisible;
        @AuraEnabled public String otherComment;  
        
        public Integer compareTo(Object objToCompare) {
            return Integer.valueOf(sequnce - ((LineItemWrapper)objToCompare).sequnce);
        }
        
        /*
        * Parameterized Constructor
        * @param: Id invoiceLineItemId, String lineItemName, Decimal amountAuthorized, Decimal amountBilled, String equipmentName, Boolean isReturned, Integer quantity
        */
        public LineItemWrapper(Id invoiceLineItemId, String lineItemName, Decimal amountAuthorized, Decimal amountBilled, Decimal quantity, Boolean isEditable, Boolean isBilledEditable, Decimal maximumValue){
             this.lineItemName = lineItemName;
             this.invoiceLineItemId = invoiceLineItemId;
             this.amountAuthorized = amountAuthorized;
             this.amountBilled = amountBilled;
             this.quantity = quantity;
             this.isEditable = isEditable;   
             this.isBilledEditable = isBilledEditable; 
             this.maximumValue = maximumValue;   
        }
        
        public LineItemWrapper(Id invoiceLineItemId, String lineItemName, Decimal amountAuthorized, Decimal amountBilled, Decimal quantity, Boolean isEditable, Boolean isBilledEditable, Decimal maximumValue, Boolean otherCommentVisible, String otherComment, Decimal sequnce){
            this.lineItemName = lineItemName;
            this.invoiceLineItemId = invoiceLineItemId;
            this.amountAuthorized = amountAuthorized;
            this.amountBilled = amountBilled;
            this.quantity = quantity;
            this.isEditable = isEditable;   
            this.isBilledEditable = isBilledEditable; 
            this.maximumValue = maximumValue;   
            this.otherCommentVisible = otherCommentVisible;
            this.otherComment = otherComment;
            this.sequnce = sequnce;
        }
    }
}