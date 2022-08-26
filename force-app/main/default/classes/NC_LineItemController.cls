/*
*   Class Name: NC_LineItemController
*   Description: Controller for NC_LineItem Component
*
*   Date              New/Modified            User                 Identifier                Description
*   28/05/2020         updated        hiten.aggarwal@mtxb2b.com
*/
public with sharing class NC_LineItemController {
    
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
        Id hearingAidTypeInvoice =  NC_Utility.RecordTypeUtilityMethod('Invoice__c',  'Hearing_AID');
        Id recordTypeofInvoice;
        Decimal totalAmountAuthorized = -1;
        Decimal totalAmountAuthorizedReturned = -1;
        Decimal totalAmountBilled = 0;
        Decimal totalAmountToPay = 0;
        String recordTypeName;
        Map<String,Object> result = new Map<String,Object>();
        Boolean isHearingAid = false;
        List<LineItemWrapper> lineItemListWrapperList = new List<LineItemWrapper>();
        LineItemWrapper invoiceLineItem;
        for(Invoice_Line_Item__c selectedLineItem :[SELECT id,Name, Invoice__c, Amount_Authorized__c, Invoice__r.RecordType.DeveloperName, Billed_Amount_Editable__c, Amount_to_Pay_Editable__c,
                                                    Amount_Billed__c, Amount_to_Pay__c, Equipment_Name__c, Invoice__r.RecordTypeId, Returned__c, Invoice__r.Status__c
                                                    FROM Invoice_Line_Item__c WHERE Invoice__c =: recordId WITH SECURITY_ENFORCED
                                                    ORDER BY Name Asc]){
                                                        
            recordTypeofInvoice = recordTypeofInvoice == NULL ? selectedLineItem.Invoice__r.RecordTypeId != NULL ? selectedLineItem.Invoice__r.RecordTypeId : NULL : recordTypeofInvoice;
            recordTypeName = selectedLineItem.Invoice__r.RecordType.DeveloperName;
            selectedLineItem.Billed_Amount_Editable__c = true;
            selectedLineItem.Amount_to_Pay_Editable__c = true;
                                                        
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
                                                            selectedLineItem.Billed_Amount_Editable__c = selectedLineItem.Billed_Amount_Editable__c ? false : selectedLineItem.Billed_Amount_Editable__c;
                                                        }
                                                        if(!accessForPaySet.contains(userDetails.UserRole.DeveloperName) && userDetails.profile.Name != 'System Administrator') {
                                                            selectedLineItem.Amount_to_Pay_Editable__c = selectedLineItem.Amount_to_Pay_Editable__c ? false : selectedLineItem.Amount_to_Pay_Editable__c;
                                                        }
                                                        
            if(selectedLineItem.Invoice__r.RecordTypeId == hearingAidTypeInvoice){
                if(selectedLineItem.Invoice__r.Status__c == 'Returned'){
                    if(selectedLineItem.Returned__c){
                        invoiceLineItem = new LineItemWrapper(selectedLineItem.Id, selectedLineItem.Name, selectedLineItem.Amount_Authorized__c, 
                                                              selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c,
                                                              selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c,
                                                              selectedLineItem.Equipment_Name__c, False);
                        
                        invoiceLineItem.amountBilledEditable = selectedLineItem.Billed_Amount_Editable__c;
                        invoiceLineItem.amountToPayEditable = selectedLineItem.Amount_to_Pay_Editable__c;
                        totalAmountBilled += selectedLineItem.Amount_Billed__c == null ? 0 : selectedLineItem.Amount_Billed__c ;
                        totalAmountToPay += selectedLineItem.Amount_to_Pay__c == null ? 0 : selectedLineItem.Amount_to_Pay__c;
                        lineItemListWrapperList.add(invoiceLineItem);  
                    }
                }else{
                    if(!selectedLineItem.Returned__c){
                        invoiceLineItem = new LineItemWrapper(selectedLineItem.Id, selectedLineItem.Name, selectedLineItem.Amount_Authorized__c, 
                                                              selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c,
                                                              selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c,
                                                              selectedLineItem.Equipment_Name__c, False);
                        
                        invoiceLineItem.amountBilledEditable = selectedLineItem.Billed_Amount_Editable__c;
                        invoiceLineItem.amountToPayEditable = selectedLineItem.Amount_to_Pay_Editable__c;
                        totalAmountBilled += selectedLineItem.Amount_Billed__c == null ? 0 : selectedLineItem.Amount_Billed__c ;
                        totalAmountToPay += selectedLineItem.Amount_to_Pay__c == null ? 0 : selectedLineItem.Amount_to_Pay__c;
                        lineItemListWrapperList.add(invoiceLineItem);  
                    }
                }
 			                                                      
            }else{
                invoiceLineItem = new LineItemWrapper(selectedLineItem.Id, selectedLineItem.Name, selectedLineItem.Amount_Authorized__c, 
                                                      selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c,
                                                      selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c,
                                                      selectedLineItem.Equipment_Name__c, selectedLineItem.Returned__c);
                
                invoiceLineItem.amountBilledEditable = selectedLineItem.Billed_Amount_Editable__c;
                invoiceLineItem.amountToPayEditable = selectedLineItem.Amount_to_Pay_Editable__c;
                totalAmountBilled += selectedLineItem.Amount_Billed__c == null ? 0 : selectedLineItem.Amount_Billed__c;
                totalAmountToPay += selectedLineItem.Amount_to_Pay__c == null ? 0 : selectedLineItem.Amount_to_Pay__c;
                
                lineItemListWrapperList.add(invoiceLineItem);  
            }
                                           
        }
        if(recordTypeofInvoice == hearingAidTypeInvoice){
        	totalAmountAuthorized = getTotalAmountAuthorized();
        	totalAmountAuthorizedReturned = getTotalAmountAuthorizedReturned();
        }
		
        Invoice__c invoiceRecordData = [SELECT Id, RecordTypeId, Status__c FROM Invoice__c WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
        if(totalAmountBilled == 0){
            if(invoiceRecordData.RecordTypeId == hearingAidTypeInvoice && invoiceRecordData.Status__c != 'Returned'){
                //totalAmountBilled = totalAmountAuthorized;
            }else if(invoiceRecordData.RecordTypeId == hearingAidTypeInvoice && invoiceRecordData.Status__c == 'Returned'){
                //totalAmountBilled = totalAmountAuthorizedReturned;
            }
        }
        Boolean isNDBEDP = recordTypeName == 'Equipment' ? true : false;
        result.put('isNDBEDP',isNDBEDP);
        result.put('totalAmountAuthorized',totalAmountAuthorized);
        result.put('totalAmountAuthorizedReturned',totalAmountAuthorizedReturned);
        result.put('lineItemListWrapperList',lineItemListWrapperList);
        result.put('isHearingAid',invoiceRecordData.RecordTypeId == hearingAidTypeInvoice ? true : false);
        result.put('status', invoiceRecordData.Status__c);
        result.put('total',totalAmountBilled);
        result.put('totalAmountToPay', totalAmountToPay);
        result.put('invoiceApproved', invoiceRecordData.Status__c != NULL && invoiceRecordData.Status__c == 'Approved');
        return result;
    }

    /*
    *********************************************************
    @Method Name    : updateAllLineItems
    @description    : Method to update the Invoice line Items
    @param          : String lineItemData
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> updateAllLineItems(String lineItemData){
        
        Map<String,Object> result = new Map<String,Object>();
        List<LineItemWrapper> lineItemListWrapperList = (List<LineItemWrapper>) JSON.deserialize(lineItemData, List<LineItemWrapper>.class);
        List<Invoice_Line_Item__c> invoiceLineItemToUpdate = new List<Invoice_Line_Item__c>();
        Map<Id,LineItemWrapper> invoiceLineItemIdToWrapperMap = new Map<Id,LineItemWrapper>();
        LineItemWrapper invoiceLineItem;
        Decimal totalAmountBilled = 0.0;
        Decimal totalAmountToPay = 0.0;

        for(LineItemWrapper lineItemSelected : lineItemListWrapperList){
            invoiceLineItemIdToWrapperMap.put(lineItemSelected.invoiceLineItemId,lineItemSelected);
        }
        lineItemListWrapperList.clear();
        
        Map<String, Set<String>> configMap = NC_InvoiceLineItemNDBEDPController.getInvoiceEditableData();
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
        
        for(Invoice_Line_Item__c selectedLineItem :[SELECT id,Name, Amount_Authorized__c,
                                                    Amount_Billed__c, Amount_to_Pay__c, Equipment_Name__c, Returned__c  
                                                    FROM Invoice_Line_Item__c WHERE Id In: invoiceLineItemIdToWrapperMap.keySet() WITH SECURITY_ENFORCED
                                                    ORDER BY Name Asc]){
                                                     
                for(Id lineItemId: invoiceLineItemIdToWrapperMap.keySet()) {
                    if(invoiceLineItemIdToWrapperMap.containsKey(selectedLineItem.Id)) {
                        LineItemWrapper wrap = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id);
                        if(!isBilledEditable && isPayEditable) {
                            wrap.amountBilled = selectedLineItem.Amount_Billed__c == null ? 0 : selectedLineItem.Amount_Billed__c;
                        }
                        if(isBilledEditable && !isPayEditable) {
                            wrap.amountToPay = selectedLineItem.Amount_to_Pay__c == null ? 0 : selectedLineItem.Amount_to_Pay__c;
                        }
                        if(!isBilledEditable && !isPayEditable) {
                            wrap.amountBilled = selectedLineItem.Amount_Billed__c == null ? 0 : selectedLineItem.Amount_Billed__c;
                            wrap.amountToPay = selectedLineItem.Amount_to_Pay__c == null ? 0 : selectedLineItem.Amount_to_Pay__c;
                        }
                    }
                }                                       
                if(selectedLineItem.Amount_Billed__c != invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled){
                    selectedLineItem.Amount_Billed__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountBilled; 
                }
                if(selectedLineItem.Amount_to_Pay__c != invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountToPay){
                    selectedLineItem.Amount_to_Pay__c = invoiceLineItemIdToWrapperMap.get(selectedLineItem.Id).amountToPay; 
                }
                totalAmountBilled += selectedLineItem.Amount_Billed__c ;
                totalAmountToPay += selectedLineItem.Amount_to_Pay__c ;
                invoiceLineItem = new LineItemWrapper(selectedLineItem.Id, selectedLineItem.Name, selectedLineItem.Amount_Authorized__c, 
                                                                      selectedLineItem.Amount_Billed__c == NULL ? 0.0 : selectedLineItem.Amount_Billed__c,
                                                                      selectedLineItem.Amount_to_Pay__c == NULL ? 0.0 : selectedLineItem.Amount_to_Pay__c,
                                                                       selectedLineItem.Equipment_Name__c, selectedLineItem.Returned__c);
                                                        
                lineItemListWrapperList.add(invoiceLineItem);
                invoiceLineItemToUpdate.add(selectedLineItem);    
        }
        if(invoiceLineItemToUpdate.size()>0){
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', invoiceLineItemToUpdate, 'update', true, 'NC_LineItemController','updateAllLineItems');
            update decision.getRecords();
            //Update invoiceLineItemToUpdate;
        }
        result.put('lineItemListWrapperList',lineItemListWrapperList);  
        return result;
        
    }

    /*
    *********************************************************
    @Method Name    : getTotalAmountAuthorized
    @description    : Get total amount authorized for Hearing Aid invoice
    @param          : 
    @return         : Decimal
    ********************************************************
    */
    private static Decimal getTotalAmountAuthorized(){
        Decimal totalAmountAuthorized = -1;

        List<Hearing_Aid_Sub_Item__mdt> hearingAidSubItemList = [SELECT Id, Amount_Authorized__c, 
                                                                  Validation_Amount__c,Is_Return_Item__c 
                                                                  FROM Hearing_Aid_Sub_Item__mdt 
                                                                  WHERE Validation_Amount__c = TRUE AND Is_Return_Item__c = FALSE ];
        if(hearingAidSubItemList.size() > 0){
            totalAmountAuthorized = hearingAidSubItemList[0].Amount_Authorized__c;
        }
        return totalAmountAuthorized;
    }

    /*
    *********************************************************
    @Method Name    : getTotalAmountAuthorizedReturned
    @description    : Get total amount authorized for Hearing Aid invoice returned
    @param          : 
    @return         : Decimal
    ********************************************************
    */
    private static Decimal getTotalAmountAuthorizedReturned(){
        Decimal totalAmountAuthorized = -1;
        List<Hearing_Aid_Sub_Item__mdt> hearingAidSubItemList = [SELECT Id, Amount_Authorized__c, 
                                                                  Validation_Amount__c,Is_Return_Item__c 
                                                                  FROM Hearing_Aid_Sub_Item__mdt 
                                                                  WHERE Validation_Amount__c = TRUE AND Is_Return_Item__c = true ];
        if(hearingAidSubItemList.size() > 0){
            totalAmountAuthorized = hearingAidSubItemList[0].Amount_Authorized__c;
        }
        return totalAmountAuthorized;
    }
    /*
    * Class Name: LineItemWrapper
    * Description: This is a Wrapper class of Invoice line Items
    */
    
    public class LineItemWrapper{
        @AuraEnabled public String lineItemName;
        @AuraEnabled public Id invoiceLineItemId;
        @AuraEnabled public Decimal amountAuthorized;
        @AuraEnabled public Boolean amountBilledEditable;
        @AuraEnabled public Decimal amountBilled;
        @AuraEnabled public Boolean amountToPayEditable;
        @AuraEnabled public Decimal amountToPay;
        @AuraEnabled public String equipmentName;
        @AuraEnabled public Boolean isReturned;
        
        /*
        * Parameterized Constructor
        * @param: Id invoiceLineItemId, String lineItemName, 
        *         Decimal amountAuthorized, Decimal amountBilled, 
        *         String equipmentName
        */
        public LineItemWrapper(Id invoiceLineItemId, String lineItemName, 
                               Decimal amountAuthorized, Decimal amountBilled, 
                               String equipmentName, Boolean isReturned){
             this.lineItemName = lineItemName;
             this.invoiceLineItemId = invoiceLineItemId;
             this.amountAuthorized = amountAuthorized;
             this.amountBilled = amountBilled;
             this.equipmentName = equipmentName;
             this.isReturned = isReturned;                      
        }

        public LineItemWrapper(Id invoiceLineItemId, String lineItemName, 
                               Decimal amountAuthorized, Decimal amountBilled, Decimal amountToPay,
                               String equipmentName, Boolean isReturned){
             this.lineItemName = lineItemName;
             this.invoiceLineItemId = invoiceLineItemId;
             this.amountAuthorized = amountAuthorized;
             this.amountBilled = amountBilled;
             this.amountToPay = amountToPay;
             this.equipmentName = equipmentName;
             this.isReturned = isReturned;                      
        }
        
        public LineItemWrapper(Id invoiceLineItemId, String lineItemName, 
                               Decimal amountAuthorized, Boolean amountBilledEditable, Decimal amountBilled, Boolean amountToPayEditable, Decimal amountToPay,
                               String equipmentName, Boolean isReturned){
             this.lineItemName = lineItemName;
             this.invoiceLineItemId = invoiceLineItemId;
             this.amountAuthorized = amountAuthorized;
             this.amountBilledEditable = amountBilledEditable;
             this.amountBilled = amountBilled;
             this.amountToPayEditable = amountToPayEditable;
             this.amountToPay = amountToPay;
             this.equipmentName = equipmentName;
             this.isReturned = isReturned;                      
        }
    }
}