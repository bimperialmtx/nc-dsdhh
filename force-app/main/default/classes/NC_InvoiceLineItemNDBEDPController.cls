/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public with sharing class NC_InvoiceLineItemNDBEDPController {
    
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
        Id trainingVendorId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Training_Vendor_Invoice').getRecordTypeId();
        Set<Id> authMapIds = new Set<Id>{CommunicationRecordTypeIdInvoice, trainingVendorId};
        Map<String,Object> result = new Map<String,Object>();
        Map<String, Object> authorizedCostMap = new Map<String, Object>();
        List<LineItemNDBEDPWrapper> lineItemListWrapperList = new List<LineItemNDBEDPWrapper>();
        LineItemNDBEDPWrapper invoiceLineItem;
        Decimal totalAmountToPay = 0;
        //Decimal totalAmountAuthorizedFinal=0;
        Decimal totalAmountBilled = 0;
        //Decimal totalAmountBilledFinal=0;

        for(Invoice_Line_Item__c selectedLineItem :[SELECT id, Name, Equipment_Name__c, Amount_Authorized__c,
                                                    Quantity__c, Amount_Billed__c, Is_Editable__c, Billed_Amount_Editable__c,
                                                    Quantity_to_Pay__c, Amount_to_Pay__c, Is_Quantity_to_Pay_Editable__c, Amount_to_Pay_Editable__c,
                                                    Sequence__c, Invoice__r.RecordTypeId , Maximum_Quantity__c, Invoice__r.Comment__c,
                                                    Invoice__r.Authorization__r.Standard_Hours__c, Invoice__r.Authorization__r.Enhanced_Hours__c, Invoice__r.Authorization__r.TASL_Standard_Hours__c, Invoice__r.Authorization__r.TASL_Enhanced_Hours__c,
                                                    Invoice__r.Authorization__r.Mileage__c, Invoice__r.Authorization__r.Lunch__c, Invoice__r.Authorization__r.Hotels__c, Invoice__r.Authorization__r.Parking__c, Invoice__r.Authorization__r.Breakfast__c,
                                                    Invoice__r.Authorization__r.Dinner__c, Invoice__r.Authorization__r.Excess_Hotel_Cost__c, Invoice__r.Authorization__r.Travel_Time__c, Invoice__r.Authorization__r.Hours__c
                                                    FROM Invoice_Line_Item__c WHERE Invoice__c =: recordId WITH SECURITY_ENFORCED ORDER BY Sequence__c Asc]){
            Boolean otherCommentVisible = selectedLineItem.Equipment_Name__c == 'Other' ? true : false;
            String otherComment = selectedLineItem.Invoice__r.Comment__c;
            if(authMapIds.contains(selectedLineItem.Invoice__r.RecordTypeId)) {
            	createAuthorizedCostMap(selectedLineItem, authorizedCostMap);   
            }
            Set<String> accessForBilledSet = new Set<String>();
                                                        Set<String> accessForPaySet = new Set<String>();
                                                        Invoice_Line_Items_Field_Accessibility__mdt accessForBilled = [select id, DeveloperName, User_Roles__c  from Invoice_Line_Items_Field_Accessibility__mdt WHERE DeveloperName = 'Quantity_Amount_Billed_Edit_Access'];
                                                        if(accessForBilled.User_Roles__c != null) {
                                                            for(String userRole: accessForBilled.User_Roles__c.split(';')) {
                                                                accessForBilledSet.add(userRole.trim());
                                                            }
                                                        }
                                                        Invoice_Line_Items_Field_Accessibility__mdt accessForPay = [select id, DeveloperName, User_Roles__c  from Invoice_Line_Items_Field_Accessibility__mdt WHERE DeveloperName = 'Quantity_Amount_to_Pay_Edit_Access'];
                                                        if(accessForPay.User_Roles__c != null) {
                                                            for(String userRole: accessForPay.User_Roles__c.split(';')) {
                                                                accessForPaySet.add(userRole.trim());
                                                            }
                                                        }
                                                        
                                                        User userDetails =[SELECT Id, Name, Profile.Name, UserRole.DeveloperName, IsPortalEnabled FROM User where Id=: UserInfo.getUserId()];
                                                        if(!accessForBilledSet.contains(userDetails.UserRole.DeveloperName) && userDetails.profile.Name != 'System Administrator' && !userDetails.IsPortalEnabled) {
                                                            selectedLineItem.Is_Editable__c = selectedLineItem.Is_Editable__c ? false: selectedLineItem.Is_Editable__c;
                                                            selectedLineItem.Billed_Amount_Editable__c = selectedLineItem.Billed_Amount_Editable__c ? false : selectedLineItem.Billed_Amount_Editable__c;
                                                        }
                                                        if(!accessForPaySet.contains(userDetails.UserRole.DeveloperName) && userDetails.profile.Name != 'System Administrator') {
                                                            selectedLineItem.Is_Quantity_to_Pay_Editable__c = selectedLineItem.Is_Quantity_to_Pay_Editable__c ? false: selectedLineItem.Is_Quantity_to_Pay_Editable__c;
                                                            selectedLineItem.Amount_to_Pay_Editable__c = selectedLineItem.Amount_to_Pay_Editable__c ? false : selectedLineItem.Amount_to_Pay_Editable__c;
                                                        }
            invoiceLineItem = new LineItemNDBEDPWrapper(selectedLineItem.Id, selectedLineItem.Equipment_Name__c, selectedLineItem.Amount_Authorized__c,
            selectedLineItem.Quantity__c, selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c, selectedLineItem.Is_Editable__c, selectedLineItem.Billed_Amount_Editable__c,
            selectedLineItem.Quantity_to_Pay__c, selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c, selectedLineItem.Is_Quantity_to_Pay_Editable__c, selectedLineItem.Amount_to_Pay_Editable__c,
            selectedLineItem.Maximum_Quantity__c!=NULL ? selectedLineItem.Maximum_Quantity__c : 999999999, otherCommentVisible, otherComment, selectedLineItem.Sequence__c);

            lineItemListWrapperList.add(invoiceLineItem);

            selectedLineItem.Amount_Billed__c = selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c;
            totalAmountBilled += selectedLineItem.Amount_Billed__c;
            //totalAmountAuthorizedFinal = totalAmountAuthorized;
            totalAmountBilled = totalAmountBilled.setScale(2);
            
            selectedLineItem.Amount_to_Pay__c = selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c;
            totalAmountToPay += selectedLineItem.Amount_to_Pay__c;
            //totalAmountBilledFinal = totalAmountBilled;
            totalAmountToPay = totalAmountToPay.setScale(2);
        }
        result.put('lineItemListWrapperList',lineItemListWrapperList);
        result.put('totalAmountBilled',totalAmountBilled);
        result.put('totalAmountToPay',totalAmountToPay);
        result.put('authorizedCostMap', authorizedCostMap);
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : createAuthorizedCostMap
    @description    : Create cost map with key as name and value as cost
    @param          : Invoice_Line_Item__c lineItem, Map<String, Object> authorizedCostMap
    @return         : void
    ********************************************************
    */
    public static void createAuthorizedCostMap (Invoice_Line_Item__c lineItem, Map<String, Object> authorizedCostMap) {
        if(lineItem.Equipment_Name__c == 'Standard Rate' || lineItem.Equipment_Name__c == 'Standard hours') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Standard_Hours__c);
        } else if(lineItem.Equipment_Name__c == 'Enhanced Rate' || lineItem.Equipment_Name__c == 'Enhanced hours') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Enhanced_Hours__c);
        } else if(lineItem.Equipment_Name__c == 'TASL Standard hours') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.TASL_Standard_Hours__c);
        } else if(lineItem.Equipment_Name__c == 'TASL Enhanced hours') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.TASL_Enhanced_Hours__c);
        } else if(lineItem.Equipment_Name__c == 'Mileage') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Mileage__c);
        } else if(lineItem.Equipment_Name__c == 'Lunch') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Lunch__c);
        } else if(lineItem.Equipment_Name__c == 'Hotels') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Hotels__c);
        } else if(lineItem.Equipment_Name__c == 'Parking') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Parking__c);
        } else if(lineItem.Equipment_Name__c == 'Breakfast') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Breakfast__c);
        } else if(lineItem.Equipment_Name__c == 'Dinner') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Dinner__c);
        } else if(lineItem.Equipment_Name__c == 'Excess Hotel Cost') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Excess_Hotel_Cost__c);
        } else if(lineItem.Equipment_Name__c == 'Travel Time') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Travel_Time__c);
        } else if(lineItem.Equipment_Name__c == 'Hours') {
            authorizedCostMap.put(lineItem.Equipment_Name__c, lineItem.Invoice__r.Authorization__r.Hours__c);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getInvoiceEditableData
    @description    : Decide whether user can modify line items or not
    @param          : 
    @return         : Map<String, Set<String>>
    ********************************************************
    */
    public static Map<String, Set<String>> getInvoiceEditableData() {
        Map<String, Set<String>> resultMap = new Map<String, Set<String>>();
        Set<String> accessForBilledSet = new Set<String>();
        Set<String> accessForPaySet = new Set<String>();
        Invoice_Line_Items_Field_Accessibility__mdt accessForBilled = [select id, DeveloperName, User_Roles__c  from Invoice_Line_Items_Field_Accessibility__mdt WHERE DeveloperName = 'Quantity_Amount_Billed_Edit_Access'];
        if(accessForBilled.User_Roles__c != null) {
            for(String userRole: accessForBilled.User_Roles__c.split(';')) {
                accessForBilledSet.add(userRole.trim());
            }
        }
        Invoice_Line_Items_Field_Accessibility__mdt accessForPay = [select id, DeveloperName, User_Roles__c  from Invoice_Line_Items_Field_Accessibility__mdt WHERE DeveloperName = 'Quantity_Amount_to_Pay_Edit_Access'];
        if(accessForPay.User_Roles__c != null) {
            for(String userRole: accessForPay.User_Roles__c.split(';')) {
                accessForPaySet.add(userRole.trim());
            }
        }

        resultMap.put('accessForBilledSet', accessForBilledSet);
        resultMap.put('accessForPaySet', accessForPaySet);
        return resultMap;
    }

    /*
    *********************************************************
    @Method Name    : updateAllLineItems
    @description    : Method to update the Invoice line Items
    @param          : String lineItemData, String recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> updateAllLineItems(String lineItemData, String recordId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            List<LineItemNDBEDPWrapper> lineItemListWrapperList = (List<LineItemNDBEDPWrapper>) JSON.deserialize(lineItemData, List<LineItemNDBEDPWrapper>.class);
            List<Invoice_Line_Item__c> invoiceLineItemToUpdate = new List<Invoice_Line_Item__c>();
            Map<Id,LineItemNDBEDPWrapper> invoiceLineItemIdToWrapperMap = new Map<Id,LineItemNDBEDPWrapper>();
            LineItemNDBEDPWrapper invoiceLineItem;
            Decimal totalAmountBilled = 0.0;
            //Decimal totalAmountBilledFinal=0.0;
            Decimal totalAmountToPay = 0.0;
            String otherComment=null;
            
            Invoice__c invoice = [SELECT Id, Comment__c, Regular_Service_Hours__c, Enhanced_Service_Hours__c, Service_Hours__c, Travel_Time__c, Food__c, Lodging__c, Other__c, Excess_Hotel_Cost__c, Enhanced_Hours__c, Dinner__c, Parking__c, Breakfast__c, Lunch__c, Hotels__c, Mileage__c, Standard_Hours__c FROM Invoice__c WHERE Id =:recordId WITH SECURITY_ENFORCED ];
            for(LineItemNDBEDPWrapper lineItemSelected : lineItemListWrapperList){
                invoiceLineItemIdToWrapperMap.put(lineItemSelected.invoiceLineItemId,lineItemSelected);
            }
            lineItemListWrapperList.clear();
            
            Map<String, Set<String>> configMap = getInvoiceEditableData();
            Set<String> accessForBilledSet = configMap.get('accessForBilledSet');
            Set<String> accessForPaySet = configMap.get('accessForPaySet');
            Boolean isBilledEditable = true;
            Boolean isPayEditable = true;

            User userDetails =[SELECT Id, Name, Profile.Name, UserRole.DeveloperName, IsPortalEnabled FROM User where Id=: UserInfo.getUserId()];
            if(!accessForBilledSet.contains(userDetails.UserRole.DeveloperName) && userDetails.profile.Name != 'System Administrator' && !userDetails.IsPortalEnabled) {
                isBilledEditable = false;
            }
            if(!accessForPaySet.contains(userDetails.UserRole.DeveloperName) && userDetails.profile.Name != 'System Administrator') {
                isPayEditable = false;
            }

            for(Invoice_Line_Item__c selectedLineItem :[SELECT id, Name, Equipment_Name__c, Amount_Authorized__c,
                                Quantity__c, Amount_Billed__c, Is_Editable__c, Billed_Amount_Editable__c,
                                Quantity_to_Pay__c, Amount_to_Pay__c, Is_Quantity_to_Pay_Editable__c, Amount_to_Pay_Editable__c,
                                Sequence__c, Invoice__r.RecordTypeId , Maximum_Quantity__c, Invoice__r.Comment__c
                            FROM Invoice_Line_Item__c WHERE Id In: invoiceLineItemIdToWrapperMap.keySet() WITH SECURITY_ENFORCED ORDER BY Name Asc]){
                               
                for(Id lineItemId: invoiceLineItemIdToWrapperMap.keySet()) {
                    if(invoiceLineItemIdToWrapperMap.containsKey(selectedLineItem.Id)) {
                        LineItemNDBEDPWrapper wrap = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id);
                        if(!isBilledEditable && isPayEditable) {
                            wrap.quantityToBill = selectedLineItem.Quantity__c;
                            wrap.amountBilled = selectedLineItem.Amount_Billed__c;
                        }
                        if(isBilledEditable && !isPayEditable) {
                            wrap.quantityToPay = selectedLineItem.Quantity_to_Pay__c;
                            wrap.amountToPay = selectedLineItem.Amount_to_Pay__c;
                        }
                        if(!isBilledEditable && !isPayEditable) {
                            wrap.quantityToBill = selectedLineItem.Quantity__c;
                            wrap.amountBilled = selectedLineItem.Amount_Billed__c;
                            wrap.quantityToPay = selectedLineItem.Quantity_to_Pay__c;
                            wrap.amountToPay = selectedLineItem.Amount_to_Pay__c;
                        }
                    }
                }
                if(selectedLineItem.Amount_Billed__c != invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled || selectedLineItem.Amount_to_Pay__c != invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountToPay){
                    if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Parking'){
                        invoice.Parking__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Hotels'){
                        invoice.Hotels__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName.contains('Enhanced')){
                        if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Enhanced Service Hours') {
                            invoice.Enhanced_Service_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                        } else {
                            invoice.Enhanced_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                        }
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Regular Service Hours'){
                        invoice.Regular_Service_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Dinner'){
                        invoice.Dinner__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Lunch'){
                        invoice.Lunch__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Mileage'){
                        invoice.Mileage__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Breakfast'){
                        invoice.Breakfast__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Service Hours'){
                        invoice.Service_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName == 'Travel Time'){
                        invoice.Travel_Time__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    }else if(invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).lineItemName.contains('Standard')){
                        invoice.Standard_Hours__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
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
                    selectedLineItem.Quantity__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToBill;
                    selectedLineItem.Amount_Billed__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled;
                    selectedLineItem.Quantity_to_Pay__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).quantityToPay; 
                    selectedLineItem.Amount_to_Pay__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountToPay;
                }
                totalAmountBilled += selectedLineItem.Amount_Billed__c;
                //totalAmountBilledFinal = totalAmountBilled;
                totalAmountBilled = totalAmountBilled.setScale(2);

                selectedLineItem.Amount_to_Pay__c = selectedLineItem.Amount_to_Pay__c == null ? 0.0 : selectedLineItem.Amount_to_Pay__c;
                totalAmountToPay += selectedLineItem.Amount_to_Pay__c;
                //totalAmountBilledFinal = totalAmountBilled;
                totalAmountToPay = totalAmountToPay.setScale(2);

                Boolean otherCommentVisible = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).otherCommentVisible;
                if(invoiceLineItemIdToWrapperMap.containsKey(selectedLineItem.Id) && invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).otherComment != null) {
                    otherComment = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).otherComment;
                }
                invoiceLineItem = new LineItemNDBEDPWrapper(selectedLineItem.Id, selectedLineItem.Equipment_Name__c, selectedLineItem.Amount_Authorized__c == NULL ? 0.0 : selectedLineItem.Amount_Authorized__c,
                selectedLineItem.Quantity__c, selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c, selectedLineItem.Is_Editable__c, selectedLineItem.Billed_Amount_Editable__c,
                selectedLineItem.Quantity_to_Pay__c, selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c, selectedLineItem.Is_Quantity_to_Pay_Editable__c, selectedLineItem.Amount_to_Pay_Editable__c,
                selectedLineItem.Maximum_Quantity__c != NULL ? selectedLineItem.Maximum_Quantity__c : 999999999, otherCommentVisible, otherComment, selectedLineItem.Sequence__c);

                lineItemListWrapperList.add(invoiceLineItem);
                invoiceLineItemToUpdate.add(selectedLineItem);    
            }
            if(invoiceLineItemToUpdate.size()>0){
                //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', invoiceLineItemToUpdate, 'update', true, 'NC_InvoiceLineItemStaffingController', 'updateAllLineItems');
                //update decision.getRecords();
                if(Schema.SobjectType.Invoice_Line_Item__c.isUpdateable()) {
                    update invoiceLineItemToUpdate;   
                } else {
                    result.put('error', 'Invoice Line Item not updateable');
                }
                //invoiceLineItemToUpdate[0].id = decision.getRecords()[0].id;

                invoice.comment__c = otherComment;
                //SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoice}, 'update', true, 'NC_InvoiceLineItemStaffingController','updateAllLineItems');
                //update decision1.getRecords();
                // invoice.id = decision1.getRecords()[0].id;
                invoice = replaceZeroToBlank(invoice);
                //Update invoice;
                SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoice}, 'update', true ,'NC_InvoiceLineItemNDBEDPController' ,'updateAllLineItems');
                update decision1.getRecords();
                invoice.id = decision1.getRecords()[0].id;

            }
            lineItemListWrapperList.sort();
            result.put('lineItemListWrapperList',lineItemListWrapperList);  
            result.put('totalAmountBilled',totalAmountBilled);
            result.put('totalAmountToPay',totalAmountToPay);
        } catch (Exception e) {
            result.put('error', e.getMessage());
        }
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : replaceZeroToBlank
    @description    : Replace zero with blank
    @param          : Invoice__c invoice
    @return         : Invoice__c
    ********************************************************
    */
    public static Invoice__c replaceZeroToBlank(Invoice__c invoice) {
        if(invoice.Service_Hours__c == 0) {
            invoice.Service_Hours__c = null;
        }
        if(invoice.Regular_Service_Hours__c == 0) {
            invoice.Regular_Service_Hours__c = null;
        }
        if(invoice.Enhanced_Service_Hours__c == 0) {
            invoice.Enhanced_Service_Hours__c = null;
        }
        if(invoice.Travel_Time__c == 0) {
            invoice.Travel_Time__c = null;
        }
        if(invoice.Mileage__c == 0) {
            invoice.Mileage__c = null;
        }
        if(invoice.Food__c == 0) {
            invoice.Food__c = null;
        }
        if(invoice.Lodging__c == 0) {
            invoice.Lodging__c = null;
        }
        if(invoice.Other__c == 0) {
            invoice.Other__c = null;
        }
        return invoice;
    }
    
    /*
    * Class Name: LineItemNDBEDPWrapper
    * Description: This is a Wrapper class of Invoice line Items
    */
    public class LineItemNDBEDPWrapper implements Comparable{
        @AuraEnabled public String lineItemName;
        @AuraEnabled public Id invoiceLineItemId;
        @AuraEnabled public Decimal amountAuthorized;
        @AuraEnabled public Decimal quantityToBill;
        @AuraEnabled public Decimal amountBilled ;
        @AuraEnabled public Boolean isQuantityToBillEditable;
        @AuraEnabled public Boolean isAmountToBillEditable;
        @AuraEnabled public Decimal quantityToPay;
        @AuraEnabled public Decimal amountToPay ;
        @AuraEnabled public Boolean isQuantityToPayEditable;
        @AuraEnabled public Boolean isAmountToPayEditable;
        @AuraEnabled public Decimal maximumValue;
        @AuraEnabled public Decimal sequnce;
        @AuraEnabled public Boolean otherCommentVisible;
        @AuraEnabled public String otherComment;
        
        public Integer compareTo(Object objToCompare) {
            return Integer.valueOf(sequnce - ((LineItemNDBEDPWrapper)objToCompare).sequnce);
        }

        public LineItemNDBEDPWrapper(Id invoiceLineItemId, String lineItemName, Decimal amountAuthorized,
            Decimal quantityToBill, Decimal amountBilled, Boolean isQuantityToBillEditable, Boolean isAmountToBillEditable, 
            Decimal quantityToPay, Decimal amountToPay, Boolean isQuantityToPayEditable, Boolean isAmountToPayEditable, 
            Decimal maximumValue, Boolean otherCommentVisible, String otherComment, Decimal sequnce){
            this.lineItemName = lineItemName;
            this.invoiceLineItemId = invoiceLineItemId;
            this.amountAuthorized = amountAuthorized;
            
            //Quantity and Amount to Billed
            this.quantityToBill = quantityToBill;
            this.amountBilled = amountBilled;
            this.isQuantityToBillEditable = isQuantityToBillEditable;
            this.isAmountToBillEditable = isAmountToBillEditable;
            
            //Quantity and Amount to Pay
            this.quantityToPay = quantityToPay;
            this.amountToPay = amountToPay;
            this.isQuantityToPayEditable = isQuantityToPayEditable;
            this.isAmountToPayEditable = isAmountToPayEditable;
            
            this.maximumValue = maximumValue;   
            this.otherCommentVisible = otherCommentVisible;
            this.otherComment = otherComment;
            this.sequnce = sequnce;
       }
    }
}