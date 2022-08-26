/*
*   Class Name: NC_Create_Invoice_and_InvoiceLineItem
*   Description: Create Invoice And Invoice Line Item
*
*   Date              New/Modified            User                 Identifier                Description
*   27/05/2020           New            Shubham Dadhich(mtx)
*/
public with sharing class NC_Create_Invoice_and_InvoiceLineItem {
    /*
    *********************************************************
    @Method Name    : createInvoiceAndInvoiceLineItem
    @description    : Create Invoice And Invoice Line Item
    @param          : String recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object>  createInvoiceAndInvoiceLineItem(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        String msg = '';
        try{
        Authorization__c authorizationRecord = [SELECT Id, Trainer_Administrator_User__c,Request__r.TRC_UserRole__c,External_Assessor_User__c, Status__c, Vendor_Type__c, End_Service_Date_Time__c,Cancelled_Reason__c, Contains_Hearing_Aid__c, RecordTypeId, RecordType.DeveloperName, Vendor__c, Consumer__c, Regional_Center__c, Request__c, Request__r.MatReqStatus__c, Request__r.CaseNumber FROM Authorization__c WHERE Id=: recordId]; //WITH SECURITY_ENFORCED
        List<Invoice__c> invoiceList = [SELECT Id,Authorization__c FROM Invoice__c WHERE Authorization__c =: authorizationRecord.Id WITH SECURITY_ENFORCED];
        if(invoiceList.size()>0){
           result.put('result',NC_Constant.INVOICE_ALREADY_PRESENT); 
           return result;
        }
        if(authorizationRecord.Vendor_Type__c ==  NC_Constant.VENDOR_TYPE_CART && DateTime.now() > authorizationRecord.End_Service_Date_Time__c + 30){
           result.put('result',NC_Constant.INVOICE_CART_CANT_BE_CREATED_AFTER_THIRTY_DAYES); 
           return result;
        }
      /* Uncomment Before Moving to Production
       * if(authorizationRecord.Vendor_Type__c ==  NC_Constant.VENDOR_TYPE_INTERPRETOR && DateTime.now() < authorizationRecord.End_Service_Date_Time__c){
            result.put('result','Interpreter can not submit invoice until after the Service End Date.'); 
            return result;
        } */
        if(authorizationRecord.Status__c !=  'Approved' && authorizationRecord.Status__c !=  'Cancelled' ){
            result.put('result','Authorization should be approved or cancelled reason should be provided before creating invoice'); 
            return result;
        }
        Id authorizationCommunicationrequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_COMMUNICATION);
        Id authorizationAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_ASSESSOR);
        Id authorizationAssessorTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_ASSESSOR_TRAINING);
        Id authorizationNDBEDPTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_NDBEDP_TRAINING);
        Id authorizationNDBEDPPickupTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_NDBEDP_PICK_UP);
        Id authorizationNDBEDPDeliveryRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_NDBEDP_DELIVERY);
        Id TrainingVendorUserRecordType = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
        Id authorizationNDBEDPFollowupRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Follow_Up');
        Id authorizationNDBEDPAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Additional_Training');
        Id authorizationNDBEDPTrainingEventRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Training_Event');
        Id authorizationNDBEDPEquipmentRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Equipment');
        Set<Id> excludeAssetAuthTypeId = new Set<Id>{authorizationAssessorRecordTypeId, authorizationAssessorTrainingRecordTypeId, authorizationNDBEDPTrainingRecordTypeId, authorizationNDBEDPFollowupRecordTypeId, authorizationNDBEDPPickupTypeId, authorizationNDBEDPDeliveryRecordTypeId,authorizationNDBEDPAdditionalTrainingRecordTypeId, authorizationNDBEDPTrainingEventRecordTypeId};
            
        if(authorizationRecord.recordTypeId == authorizationNDBEDPEquipmentRecordTypeId && authorizationRecord.Request__c != null && authorizationRecord.Request__r.MatReqStatus__c != 'Closed') {
            result.put('result', authorizationRecord.Request__r.CaseNumber + ' MatReqStatus should be Closed before creating an Invoice');
            return result;
        }
            
        if(authorizationRecord.RecordTypeId != authorizationCommunicationrequestRecordTypeId && authorizationRecord.RecordTypeId !=  TrainingVendorUserRecordType && !excludeAssetAuthTypeId.contains(authorizationRecord.RecordTypeId)){
            List<Asset__c> assetList = new List<Asset__c>();
            Invoice__c invoiceRecord = new Invoice__c();
            List<Invoice_Line_Item__c> listOfInvoiceLineItem = new List<Invoice_Line_Item__c>();
            Set<String> assetStatusSet = new Set<String>{NC_Constant.ASSET_STATUS_EQUIPMENT_DEFECTIVE, NC_Constant.ASSET_STATUS_EQUIPMENT_UNAVAILABLE};
            List<Asset__c> assetRecordList = [SELECT Id, recordTypeId, Status__c, Equipment_Received_Date__c,Amount_Authorized__c, Equipment__r.Equipment_Name__c, Authorization__c, Equipment__c FROM  Asset__c WHERE Authorization__c =: recordId AND Status__c NOT IN: assetStatusSet WITH SECURITY_ENFORCED];
            if(assetRecordList.isEmpty() && !excludeAssetAuthTypeId.contains(authorizationRecord.RecordTypeId)){
                result.put('result','No Working Asset associated to this Authorization'); 
                return result;
            }
            if(authorizationRecord.recordTypeId != authorizationNDBEDPEquipmentRecordTypeId && !assetRecordList.isEmpty()) {
                Set<String> assetStatus = new Set<String>{'Created', 'Pending Approval', 'Returned', 'Cancelled', 'Rejected' , 'Pending Shipment', 'Shipped', 'Received'};
                for(Asset__c asset: assetRecordList){
                    if(assetStatus.contains(asset.Status__c)) {
                        result.put('result','Asset status should be Equipment Working before creating an Invoice'); 
                        return result;
                    }
                }
            }
            //Create Invoice Record
            invoiceRecord.Authorization__c = authorizationRecord.Id;
            invoiceRecord.Status__c = NC_Constant.INVOICE_STATUS_CREATED;
            if(!assetRecordList.isEmpty() && authorizationRecord.RecordType.DeveloperName != NC_Constant.AUTHORIZATION_RECORDTYPE_HEARING_AID){
                invoiceRecord.Consumer_Signed_Date__c = assetRecordList[0].Equipment_Received_Date__c;
            }
            invoiceRecord.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', authorizationRecord.RecordType.DeveloperName);
            if(authorizationRecord.recordTypeId == authorizationNDBEDPEquipmentRecordTypeId) {
                invoiceRecord.Status__c = 'Pending NDBEDP Coordinator';
                invoiceRecord.vendor__c = authorizationRecord.Vendor__c;
            }
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoiceRecord}, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createInvoiceAndInvoiceLineItem');
            INSERT decision.getRecords();
           invoiceRecord.id = decision.getRecords()[0].id;
           
            Map<Id, Request_Equipment__c> equipmentDetailsMap = new Map<Id, Request_Equipment__c>();
            if(Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId() == invoiceRecord.recordTypeId) {
             	for(Request_Equipment__c reqEqp: [SELECT Equipment__c, UnitPrice__c, Ordered_Quantity__c, Shipping__c, Equipment_Amount_Authorized__c FROM Request_Equipment__c WHERE Request__c =: authorizationRecord.Request__c WITH SECURITY_ENFORCED]) {
                    equipmentDetailsMap.put(reqEqp.Equipment__c, reqEqp);
                }   
            }
            
            //Getting Asset record To Insert Invoice
            for(Asset__c assetRecord : assetRecordList){
                Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
                invoiceLineItemRecord.Amount_Authorized__c = assetRecord.Amount_Authorized__c == null ? 0 : assetRecord.Amount_Authorized__c;
                invoiceLineItemRecord.Asset__c = assetRecord.Id;
                invoiceLineItemRecord.Invoice__c = invoiceRecord.Id;
                invoiceLineItemRecord.Equipment_Name__c = assetRecord.Equipment__r.Equipment_Name__c;
                if(Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId() == invoiceRecord.recordTypeId && equipmentDetailsMap.containsKey(assetRecord.Equipment__c)) {
                    Decimal unitPrice = equipmentDetailsMap.get(assetRecord.Equipment__c).UnitPrice__c != null ? equipmentDetailsMap.get(assetRecord.Equipment__c).UnitPrice__c : equipmentDetailsMap.get(assetRecord.Equipment__c).Equipment_Amount_Authorized__c;
                    invoiceLineItemRecord.Amount_Authorized__c = unitPrice * equipmentDetailsMap.get(assetRecord.Equipment__c).Ordered_Quantity__c;
                    Decimal shippingCost = equipmentDetailsMap.get(assetRecord.Equipment__c).Shipping__c != null ? equipmentDetailsMap.get(assetRecord.Equipment__c).Shipping__c : 0;
                    invoiceLineItemRecord.Amount_Billed__c = invoiceLineItemRecord.Amount_Authorized__c + shippingCost;
                }
                listOfInvoiceLineItem.add(invoiceLineItemRecord);
            }
    
            if(authorizationRecord.Contains_Hearing_Aid__c){
                for(Hearing_Aid_Sub_Item__mdt hearingAidSubItem : [SELECT Id, MasterLabel, Amount_Authorized__c, Validation_Amount__c,Is_Return_Item__c FROM Hearing_Aid_Sub_Item__mdt ]){
                    if(!hearingAidSubItem.Validation_Amount__c){
                        Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
                        invoiceLineItemRecord.Amount_Authorized__c = hearingAidSubItem.Amount_Authorized__c;
                        invoiceLineItemRecord.Invoice__c = invoiceRecord.Id;
                        invoiceLineItemRecord.Returned__c = hearingAidSubItem.Is_Return_Item__c;
                        invoiceLineItemRecord.Equipment_Name__c = hearingAidSubItem.MasterLabel;
                        listOfInvoiceLineItem.add(invoiceLineItemRecord);
                    }
                }
            }
            SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', listOfInvoiceLineItem, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createInvoiceAndInvoiceLineItem');
            INSERT decision1.getRecords();
          
            result.put('result','Success');
            return result;
        }else if(authorizationRecord.RecordTypeId ==  TrainingVendorUserRecordType){
            if(authorizationRecord.Status__c == NC_Constant.AUTHORIZATION_STATUS_CANCELED && authorizationRecord.Cancelled_Reason__c == NC_Constant.CANCEL_STATUS_AUTTHORIZATION_BY_DHH || authorizationRecord.Cancelled_Reason__c == 'Extenuating Circumstances'){
                result.put('result',NC_Constant.CANCELED_INTERPRETER_ERROR_MESSAGE_DHH);
                return result;
            }else{
                createTrainingVendorInvoice(authorizationCommunicationrequestRecordTypeId, recordId);
                result.put('result','Success');
                return result;
            }
            
        }else if(excludeAssetAuthTypeId.contains(authorizationRecord.RecordTypeId)){	
            createNDBEDPInvoice(authorizationRecord);	
            result.put('result','Success');	
            return result;	
        }else{
            if(authorizationRecord.Status__c == NC_Constant.AUTHORIZATION_STATUS_CANCELED){
                if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART ){
                    result.put('result',NC_Constant.CANCELED_CART_ERROR_MESSAGE);
                    return result;
                }else if((authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP) && authorizationRecord.Cancelled_Reason__c == NC_Constant.CANCEL_STATUS_AUTTHORIZATION_BY_DHH){
                    result.put('result',NC_Constant.CANCELED_INTERPRETER_ERROR_MESSAGE_DHH);
                    return result;
                }else{
                    createCommunicationInvoice(authorizationCommunicationrequestRecordTypeId, recordId);
                    result.put('result','Success');
                    return result;
                }
            }else{
                
                createCommunicationInvoice(authorizationCommunicationrequestRecordTypeId, recordId);
                result.put('result','Success');
                return result;
            }
        }
        }catch(DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    *********************************************************
    @Method Name    : getQuantityAndAmountInState
    @description    : Create a Map For Quantity and Amount Billed for In State
    @param          : Invoice__c invoiceRecord, Invoice_line_item_for__mdt invoiceLineItem
    @return         : Map<String, Decimal>
    ********************************************************
    */
    public static Map<String, Decimal> getQuantityAndAmountInState(Invoice__c invoiceRecord, Invoice_line_item_for__mdt invoiceLineItem){
        Map<String, Decimal> mapOfQuantityAndAmount = new Map<String, Decimal>();
        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Hotels__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Hotels__c * invoiceLineItem.In_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Breakfast__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Breakfast__c * invoiceLineItem.In_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Dinner__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Dinner__c * invoiceLineItem.In_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Lunch__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Lunch__c * invoiceLineItem.In_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Mileage__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Mileage__c * invoiceLineItem.In_State_Amount_Authorized__c);
        }
        return mapOfQuantityAndAmount;
    }

    /*
    *********************************************************
    @Method Name    : getQuantityAndAmountOutState
    @description    : Create a Map For Quantity and Amount Billed for Out State
    @param          : Invoice__c invoiceRecord, Invoice_line_item_for__mdt invoiceLineItem
    @return         : Map<String, Decimal>
    ********************************************************
    */
    public static Map<String, Decimal> getQuantityAndAmountOutState(Invoice__c invoiceRecord, Invoice_line_item_for__mdt invoiceLineItem){
        Map<String, Decimal> mapOfQuantityAndAmount = new Map<String, Decimal>();
        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Hotels__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Hotels__c * invoiceLineItem.Out_of_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Breakfast__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Breakfast__c * invoiceLineItem.Out_of_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Dinner__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Dinner__c * invoiceLineItem.Out_of_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Lunch__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Lunch__c * invoiceLineItem.Out_of_State_Amount_Authorized__c);
        }else if(NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Mileage__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Mileage__c * invoiceLineItem.Out_of_State_Amount_Authorized__c);
        }
        return mapOfQuantityAndAmount;
    }
    
    /*
    *********************************************************
    @Method Name    : getQuantityAndAmountNDBEDP
    @description    : Create a Map For Quantity and Amount Billed for NDBEDP
    @param          : Invoice__c invoiceRecord, NDBEDP_Invoice_Line_Item__mdt invoiceLineItem
    @return         : Map<String, Decimal>
    ********************************************************
    */
    public static Map<String, Decimal> getQuantityAndAmountNDBEDP(Invoice__c invoiceRecord, NDBEDP_Invoice_Line_Item__mdt invoiceLineItem){
        Map<String, Decimal> mapOfQuantityAndAmount = new Map<String, Decimal>();
        if('Mileage' == invoiceLineItem.MasterLabel){
            invoiceRecord.Mileage__c = invoiceRecord.Mileage__c != null ? invoiceRecord.Mileage__c : 0;
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Mileage__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Mileage__c * invoiceLineItem.Amount_Per_Hour__c);
        }else if('Service Hours' == invoiceLineItem.MasterLabel){
            invoiceRecord.Service_Hours__c = invoiceRecord.Service_Hours__c != null ? invoiceRecord.Service_Hours__c : 0;
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Service_Hours__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Service_Hours__c * invoiceLineItem.Amount_Per_Hour__c);
        }else if('Travel Time' == invoiceLineItem.MasterLabel){
            invoiceRecord.Travel_Time__c = invoiceRecord.Travel_Time__c != null ? invoiceRecord.Travel_Time__c : 0;
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Travel_Time__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Travel_Time__c * invoiceLineItem.Amount_Per_Hour__c);
        }else if('Regular Service Hours' == invoiceLineItem.MasterLabel){
            invoiceRecord.Regular_Service_Hours__c = invoiceRecord.Regular_Service_Hours__c != null ? invoiceRecord.Regular_Service_Hours__c : 0;
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Regular_Service_Hours__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Regular_Service_Hours__c * invoiceLineItem.Amount_Per_Hour__c);
        }else if('Enhanced Service Hours' == invoiceLineItem.MasterLabel){
            invoiceRecord.Enhanced_Service_Hours__c = invoiceRecord.Enhanced_Service_Hours__c != null ? invoiceRecord.Enhanced_Service_Hours__c : 0;
            mapOfQuantityAndAmount.put('Quantity', invoiceRecord.Enhanced_Service_Hours__c);
            mapOfQuantityAndAmount.put('Amount Billed', invoiceRecord.Enhanced_Service_Hours__c * invoiceLineItem.Amount_Per_Hour__c);
        }
        return mapOfQuantityAndAmount;
    }

    /*
    *********************************************************
    @Method Name    : calculateHours
    @description    : Calculate hours based on decimals
    @param          : Decimal hours, Decimal amountAuthorized
    @return         : decimal
    ********************************************************
    */
    public static decimal calculateHours(Decimal hours, Decimal amountAuthorized){
        String hoursString = String.valueOf(hours);
        String afterDecimal = hoursString.substringAfter('.');
        String beforeDecimal = hoursString.substringBefore('.');
        Decimal amount = Decimal.valueOf(beforeDecimal) * (amountAuthorized == null ? 0 : amountAuthorized);
        Decimal extraAmount = 0;
        if(afterDecimal != '00' && afterDecimal !=''){
            if(afterDecimal == '50'){
                afterDecimal = '30';
            }else if(afterDecimal == '40'){
                afterDecimal = '30';
            }else if(afterDecimal == '20'){
                afterDecimal = '15';
            }
            Decimal amountCalculation = amountAuthorized / 4;
            if(Decimal.valueOf(afterDecimal) == 15 && amountAuthorized != null){
                extraAmount = amountCalculation;
            }else if(Decimal.valueOf(afterDecimal) == 30 && amountAuthorized != null){
                extraAmount = amountCalculation * 2;
            }else if(Decimal.valueOf(afterDecimal) == 45 && amountAuthorized != null){
                extraAmount = amountCalculation * 3;
            }
            amount += extraAmount;
        }
        return amount;
    }

    /*
    *********************************************************
    @Method Name    : createInvoiceLineItemNDBEDPUtility
    @description    : Create Invoice Line Item object
    @param          : Decimal quantity, Decimal amountBilled, Decimal quantityToPay, Decimal amountToPay, String MasterLabel, Id invoiceRecordId, Decimal amount, Boolean IsEditable, Boolean IsBilledEditable, Boolean isQuantityToPayEditable, Boolean isAmountToPayEditable, Decimal sequence
    @return         : Invoice_Line_Item__c
    ********************************************************
    */
    public static Invoice_Line_Item__c createInvoiceLineItemNDBEDPUtility(Decimal quantity, Decimal amountBilled, Decimal quantityToPay, Decimal amountToPay, String MasterLabel, Id invoiceRecordId, Decimal amount, Boolean IsEditable, Boolean IsBilledEditable, Boolean isQuantityToPayEditable, Boolean isAmountToPayEditable, Decimal sequence){
        Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
        invoiceLineItemRecord.Quantity__c = quantity;
        invoiceLineItemRecord.Amount_Billed__c = amountBilled;
        invoiceLineItemRecord.Quantity_to_Pay__c = quantityToPay;
        invoiceLineItemRecord.Amount_to_Pay__c = amountToPay;
        invoiceLineItemRecord.Equipment_Name__c = MasterLabel;
        invoiceLineItemRecord.Invoice__c = invoiceRecordId;
        invoiceLineItemRecord.Amount_Authorized__c = amount == null ? 0 : amount;
        invoiceLineItemRecord.Is_Editable__c = IsEditable;
        invoiceLineItemRecord.Billed_Amount_Editable__c = IsBilledEditable;
        invoiceLineItemRecord.Is_Quantity_to_Pay_Editable__c = isQuantityToPayEditable;
        invoiceLineItemRecord.Amount_to_Pay_Editable__c = isAmountToPayEditable;
        invoiceLineItemRecord.Sequence__c = sequence;
        return invoiceLineItemRecord;
    }
    
    /*
    *********************************************************
    @Method Name    : createInvoiceLineItemNDBEDPUtility
    @description    : Create Invoice Line Item object
    @param          : Decimal quantity, Decimal amountBilled, Decimal quantityToPay, Decimal amountToPay, String MasterLabel, Id invoiceRecordId, Decimal amount, Boolean IsEditable, Boolean IsBilledEditable, Boolean isQuantityToPayEditable, Boolean isAmountToPayEditable, Decimal sequence, Decimal maximamQuantity
    @return         : Invoice_Line_Item__c
    ********************************************************
    */
    public static Invoice_Line_Item__c createInvoiceLineItemNDBEDPUtility(Decimal quantity, Decimal amountBilled, Decimal quantityToPay, Decimal amountToPay, String MasterLabel, Id invoiceRecordId, Decimal amount, Boolean IsEditable, Boolean IsBilledEditable, Boolean isQuantityToPayEditable, Boolean isAmountToPayEditable, Decimal sequence, Decimal maximamQuantity){
        Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
        invoiceLineItemRecord.Quantity__c = quantity;
        invoiceLineItemRecord.Amount_Billed__c = amountBilled;
        invoiceLineItemRecord.Quantity_to_Pay__c = quantityToPay;
        invoiceLineItemRecord.Amount_to_Pay__c = amountToPay;
        invoiceLineItemRecord.Equipment_Name__c = MasterLabel;
        invoiceLineItemRecord.Invoice__c = invoiceRecordId;
        invoiceLineItemRecord.Amount_Authorized__c = amount == null ? 0 : amount;
        invoiceLineItemRecord.Is_Editable__c = IsEditable;
        invoiceLineItemRecord.Billed_Amount_Editable__c = IsBilledEditable;
        invoiceLineItemRecord.Is_Quantity_to_Pay_Editable__c = isQuantityToPayEditable;
        invoiceLineItemRecord.Amount_to_Pay_Editable__c = isAmountToPayEditable;
        invoiceLineItemRecord.Sequence__c = sequence;
        invoiceLineItemRecord.Maximum_Quantity__c = maximamQuantity;
        return invoiceLineItemRecord;
    }
    /*
    * Method Name: createInvoiceLineItemUtility
    * Description:  Create Invoice Line
    * @param:   
    * @return Invoice_Line_Item__c
    */
	/*
    public static Invoice_Line_Item__c createInvoiceLineItemUtility(Decimal quantity, Decimal amountBilled, String MasterLabel, Id invoiceRecordId, Decimal amount, Boolean IsEditable, Boolean IsBilledEditable, Decimal sequence){
        Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
        invoiceLineItemRecord.Quantity__c = quantity;
        invoiceLineItemRecord.Amount_Billed__c = amountBilled;
        invoiceLineItemRecord.Equipment_Name__c = MasterLabel;
        invoiceLineItemRecord.Invoice__c = invoiceRecordId;
        invoiceLineItemRecord.Amount_Authorized__c = amount == null ? 0 : amount;
        invoiceLineItemRecord.Is_Editable__c = IsEditable;
        invoiceLineItemRecord.Billed_Amount_Editable__c = IsBilledEditable;
        invoiceLineItemRecord.Sequence__c = sequence;
        return invoiceLineItemRecord;
    }*/
    /*
    * Method Name: createInvoiceLineItemUtility
    * Description:  Create Invoice Line
    * @param:   
    * @return Invoice_Line_Item__c
    */
    /*
    public static Invoice_Line_Item__c createInvoiceLineItemUtility(Decimal quantity, Decimal amountBilled, String MasterLabel, Id invoiceRecordId, Decimal amount, Boolean IsEditable, Boolean IsBilledEditable, Decimal sequence, Decimal maximamQuantity){
        Invoice_Line_Item__c invoiceLineItemRecord = new Invoice_Line_Item__c();
        invoiceLineItemRecord.Quantity__c = quantity;
        invoiceLineItemRecord.Amount_Billed__c = amountBilled;
        invoiceLineItemRecord.Equipment_Name__c = MasterLabel;
        invoiceLineItemRecord.Invoice__c = invoiceRecordId;
        invoiceLineItemRecord.Amount_Authorized__c = amount == null ? 0 : amount;
        invoiceLineItemRecord.Is_Editable__c = IsEditable;
        invoiceLineItemRecord.Billed_Amount_Editable__c = IsBilledEditable;
        invoiceLineItemRecord.Sequence__c = sequence;
        invoiceLineItemRecord.Maximum_Quantity__c = maximamQuantity;
        return invoiceLineItemRecord;
    }*/
    
    /*
    *********************************************************
    @Method Name    : createTrainingVendorInvoice
    @description    : Create Training vendor invoice
    @param          : Id vendorRecordTypeAuth, String recordId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void createTrainingVendorInvoice(Id vendorRecordTypeAuth, String recordId){
        Invoice__c invoiceRecordToInsert = new Invoice__c();
        Invoice__c invoiceRecord= new Invoice__c();
        List<Invoice_Line_Item__c> listOfInvoiceLineItem = new List<Invoice_Line_Item__c>();
        Authorization__c authorizationRecord = [SELECT Id, Hours__c, Travel_Time__c, Vendor_Type__c, Vendor__c,Status__c,Cancelled_Reason__c FROM Authorization__c WHERE Id=: recordId WITH SECURITY_ENFORCED];
        
        invoiceRecordToInsert.Authorization__c = authorizationRecord.Id;
        invoiceRecordToInsert.Status__c = NC_Constant.INVOICE_STATUS_CREATED;
        invoiceRecordToInsert.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Training_Vendor_Invoice');
        //invoiceRecordToInsert.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
        invoiceRecordToInsert.Vendor_Type__c = authorizationRecord.Vendor_Type__c;
        invoiceRecordToInsert.Vendor__c = authorizationRecord.Vendor__c;
        invoiceRecordToInsert.Hours__c = authorizationRecord.Hours__c;
        invoiceRecordToInsert.Travel_Time__c = authorizationRecord.Travel_Time__c;
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoiceRecordToInsert}, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createTrainingVendorInvoice');
        INSERT decision.getRecords();
        invoiceRecordToInsert.id = decision.getRecords()[0].id;
        // INSERT invoiceRecordToInsert;
        
        invoiceRecord = [SELECT Id,Status__c,Vendor_Type__c,Vendor__c, Hours__c, Travel_Time__c,Cancelled_Reason__c FROM Invoice__c WHERE Id =: invoiceRecordToInsert.Id WITH SECURITY_ENFORCED LIMIT 1];
        
        if(authorizationRecord.Status__c != NC_Constant.AUTHORIZATION_STATUS_CANCELED){
            if(authorizationRecord.Vendor_Type__c == 'Training Vendor'){
                for(Training_Vendor_Invoice_Line_Item__mdt invoiceLineItem : [SELECT Id,Amount_Per_Hour__c,  Vendor_Type__c, DeveloperName ,MasterLabel FROM Training_Vendor_Invoice_Line_Item__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                    if( invoiceLineItem.DeveloperName == 'Hours'){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Hours__c , invoiceLineItem.Amount_Per_Hour__c * invoiceRecord.Hours__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c , True, False, true, false, 1  ));    
                    }else if( invoiceLineItem.DeveloperName == 'Travel_Time'){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Travel_Time__c , invoiceLineItem.Amount_Per_Hour__c * invoiceRecord.Travel_Time__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c , True, False, true, false, 2  ));      
                    }
                    
                }                
            }
        }else if(authorizationRecord.Status__c == NC_Constant.AUTHORIZATION_STATUS_CANCELED && authorizationRecord.Vendor_Type__c == 'Training Vendor'){
            for(Training_Vendor_Invoice_Line_Item__mdt invoiceLineItem : [SELECT Id,Amount_Per_Hour__c,  Vendor_Type__c, DeveloperName ,MasterLabel FROM Training_Vendor_Invoice_Line_Item__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                if(authorizationRecord.Cancelled_Reason__c == 'Cancelled due to Weather'){
                    if( invoiceLineItem.DeveloperName == 'Hours' && invoiceRecord.Hours__c != NULL){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Hours__c/2 , invoiceLineItem.Amount_Per_Hour__c * (invoiceRecord.Hours__c/2), null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c, True, False, true, false, 1,invoiceRecord.Hours__c/2  ));    
                    }else if( invoiceLineItem.DeveloperName == 'Travel_Time' && invoiceRecord.Travel_Time__c != NULL){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Travel_Time__c/2 , invoiceLineItem.Amount_Per_Hour__c * (invoiceRecord.Travel_Time__c/2), null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c, True, False, true, false, 2,invoiceRecord.Travel_Time__c/2  ));      
                    }
                }else if(authorizationRecord.Cancelled_Reason__c == 'Cancelled within 24 hrs'){
                    if( invoiceLineItem.DeveloperName == 'Hours' && invoiceRecord.Hours__c >= 1.5){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1.5 , invoiceLineItem.Amount_Per_Hour__c * 1.5, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c, True, False, true, false, 1 ,1.5 ));    
                    }else if(invoiceLineItem.DeveloperName == 'Hours' && invoiceRecord.Hours__c < 1.5){
                         listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Hours__c , invoiceLineItem.Amount_Per_Hour__c * invoiceRecord.Hours__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c , True, False, true, false, 1,1.5  ));    
                    }else if( invoiceLineItem.DeveloperName == 'Travel_Time' && invoiceRecord.Travel_Time__c >= 1.5){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1.5 , invoiceLineItem.Amount_Per_Hour__c * 1.5, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c, True, False, true, false, 2,1.5  ));      
                    }else if(invoiceLineItem.DeveloperName == 'Travel_Time' && invoiceRecord.Travel_Time__c < 1.5){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Travel_Time__c , invoiceLineItem.Amount_Per_Hour__c * invoiceRecord.Travel_Time__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c , True, False, true, false, 2,1.5  ));      
                    }
                }else if(authorizationRecord.Cancelled_Reason__c == 'Cannot Perform Training'){
                    if( invoiceLineItem.DeveloperName == 'Hours'){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Hours__c/2 , invoiceLineItem.Amount_Per_Hour__c * (invoiceRecord.Hours__c/2), null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c, True, False, true, false, 1,invoiceRecord.Hours__c/2  ));    
                    }/*else if( invoiceLineItem.DeveloperName == 'Travel_Time'){
                        listOfInvoiceLineItem.add(createInvoiceLineItemUtility(invoiceRecord.Travel_Time__c/2 , invoiceLineItem.Amount_Per_Hour__c * (invoiceRecord.Travel_Time__c/2), invoiceLineItem.MasterLabel, invoiceRecord.Id,invoiceLineItem.Amount_Per_Hour__c , True, False,2  ));      
                    }*/
                }
            }
        }
        if(!listOfInvoiceLineItem.isEmpty()){
            SObjectAccessDecision decision3 =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', listOfInvoiceLineItem, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createTrainingVendorInvoice');
            insert decision3.getRecords();
            //INSERT listOfInvoiceLineItem;
        }
                
     }
    
    /*
    *********************************************************
    @Method Name    : createNDBEDPInvoice
    @description    : Create NDBEDP invoice
    @param          : Authorization__c authorizationRecord
    @return         : void
    ********************************************************
    */
    public static void createNDBEDPInvoice(Authorization__c authorizationRecord){
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        List<Invoice_Line_Item__c> listOfInvoiceLineItem = new List<Invoice_Line_Item__c>();
        Id authorizationAssessorRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_ASSESSOR);
        Id authorizationAssessorTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_ASSESSOR_TRAINING);
        Id authorizationNDBEDPPickupTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_NDBEDP_PICK_UP);
        Id authorizationNDBEDPDeliveryRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_NDBEDP_DELIVERY);
        Id authorizationNDBEDPFollowupRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Follow_Up');
        Id authorizationNDBEDPAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Additional_Training');
        Id authorizationNDBEDPTrainingAndInstallationRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Training');
        Id authorizationNDBEDPTrainingEventRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Training_Event');
        Set<Id> excludeAssetAuthTypeId = new Set<Id>{authorizationAssessorRecordTypeId,  authorizationNDBEDPFollowupRecordTypeId, authorizationNDBEDPPickupTypeId, authorizationNDBEDPDeliveryRecordTypeId,authorizationAssessorTrainingRecordTypeId};
        //Create Invoice Record
        Invoice__c invoiceRecord = new Invoice__c();
        invoiceRecord.Authorization__c = authorizationRecord.id;
        invoiceRecord.Status__c = NC_Constant.INVOICE_STATUS_CREATED;
        if(excludeAssetAuthTypeId.contains(authorizationRecord.recordtypeId)){
            invoiceRecord.External_Assessor_User__c =authorizationRecord.External_Assessor_User__c;
        }
        if(authorizationRecord.recordtypeId == authorizationNDBEDPAdditionalTrainingRecordTypeId || authorizationRecord.recordtypeId == authorizationNDBEDPTrainingAndInstallationRecordTypeId || authorizationRecord.recordtypeId == authorizationNDBEDPTrainingEventRecordTypeId){
            invoiceRecord.Trainer_Administrator_User__c =authorizationRecord.Trainer_Administrator_User__c;
        }
        if(authorizationRecord.Request__r.TRC_UserRole__c == 'NDBEDP_Coordinator' || authorizationRecord.Request__r.TRC_UserRole__c == 'Deaf_Services_Specialist' || authorizationRecord.Request__r.TRC_UserRole__c == 'Deaf_Blind_Services_Specialist'){
            invoiceRecord.Invoice_Email_Link__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+authorizationRecord.Request__r.Id;
        }else{
            invoiceRecord.Invoice_Email_Link__c = 'https://'+domains[0].Domain +'/' +authorizationRecord.Request__r.Id;
        }
        invoiceRecord.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', authorizationRecord.RecordType.DeveloperName);
        Set<String> costTypeSet = new Set<String>{NC_Constant.INVOICE_LINE_ITEM_MILEAGE, 'Service Hours', 'Travel Time', 'Regular Service Hours', 'Enhanced Service Hours'};
        
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoiceRecord}, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createInvoiceAndInvoiceLineItem');
        INSERT decision.getRecords();
        invoiceRecord.id = decision.getRecords()[0].id;

        invoiceRecord = [SELECT Id, Regular_Service_Hours__c, Enhanced_Service_Hours__c, Travel_Time__c, Food__c, Lodging__c, Other__c, Service_Hours__c, Hotels__c, Breakfast__c, Service_Type__c, Dinner__c,Lunch__c,Mileage__c, Parking__c, Excess_Hotel_Cost__c, Standard_Hours__c, Enhanced_Hours__c FROM Invoice__c WHERE Id =: invoiceRecord.Id WITH SECURITY_ENFORCED LIMIT 1];

        if(true) {
            for(NDBEDP_Invoice_Line_Item__mdt invoiceLineItem : [SELECT DeveloperName, Sequence__c, MasterLabel, Amount_Per_Hour__c, InvoiceType__c FROM NDBEDP_Invoice_Line_Item__mdt WHERE InvoiceType__c =: authorizationRecord.RecordType.DeveloperName]){
                if(costTypeSet.contains(invoiceLineItem.MasterLabel)){ //NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel || 'Service Hours' == invoiceLineItem.MasterLabel || 'Travel Time' == invoiceLineItem.MasterLabel
                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountNDBEDP(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountNDBEDP(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecord.Id, invoiceLineItem.Amount_Per_Hour__c, true, false, true, false,invoiceLineItem.Sequence__c));
                }else if('Food' == invoiceLineItem.MasterLabel){
                    invoiceRecord.Food__c = invoiceRecord.Food__c != null ? invoiceRecord.Food__c : 0;
                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Food__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id, invoiceLineItem.Amount_Per_Hour__c, false, true, false, true, invoiceLineItem.Sequence__c));
                }else if('Lodging' == invoiceLineItem.MasterLabel){
                    invoiceRecord.Lodging__c = invoiceRecord.Lodging__c != null ? invoiceRecord.Lodging__c : 0;
                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Lodging__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id, invoiceLineItem.Amount_Per_Hour__c, false, true, false, true, invoiceLineItem.Sequence__c));
                }else if('Other' == invoiceLineItem.MasterLabel){
                    invoiceRecord.Other__c = invoiceRecord.Other__c != null ? invoiceRecord.Other__c : 0;
                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Other__c, null, null, invoiceLineItem.MasterLabel, invoiceRecord.Id, invoiceLineItem.Amount_Per_Hour__c, false, true, false, true, invoiceLineItem.Sequence__c));
                }
            }
        }

        if(!listOfInvoiceLineItem.isEmpty()){
            SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', listOfInvoiceLineItem, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createCommunicationInvoice');
            insert decision1.getRecords();
        }
    }
    
    /*
    *********************************************************
    @Method Name    : createCommunicationInvoice
    @description    : Create Invoice And Invoice Line Item for Communication Access Request
    @param          : Id communicationrecordTypeAuth, String recordId
    @return         : void
    ********************************************************
    */
    @AuraEnabled
    public static void createCommunicationInvoice(Id communicationrecordTypeAuth, String recordId){
        Invoice__c invoiceRecordToInsert = new Invoice__c();
        Invoice__c invoiceRecord= new Invoice__c();
        List<Invoice_Line_Item__c> listOfInvoiceLineItem = new List<Invoice_Line_Item__c>();
        Authorization__c authorizationRecord = [SELECT Id, TASL_Standard_Hours__c, TASL_Enhanced_Hours__c, Excess_Hotel_Cost__c, Enhanced_Hours__c, Dinner__c, Parking__c, Breakfast__c, Lunch__c, Hotels__c, Mileage__c, Standard_Hours__c,Inclusive_Flat_Fee_Amount__c, All_Inclusive_Flat_Fee__c, Is_Individual__c,Status__c, Cancelled_Reason__c, RecordTypeId, Vendor__r.License_Type__c, Amount_Authorization_Type__c, RecordType.DeveloperName, Vendor__c, Vendor_Type__c, Vendor__r.Individual__c FROM Authorization__c WHERE Id=: recordId WITH SECURITY_ENFORCED];
        
        invoiceRecordToInsert.Authorization__c = authorizationRecord.Id;
        invoiceRecordToInsert.Status__c = NC_Constant.INVOICE_STATUS_CREATED;
        invoiceRecordToInsert.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
        invoiceRecordToInsert.Vendor_Type__c = authorizationRecord.Vendor_Type__c;
        invoiceRecordToInsert.Vendor__c = authorizationRecord.Vendor__c;
        invoiceRecordToInsert.Excess_Hotel_Cost__c = authorizationRecord.Excess_Hotel_Cost__c;
        invoiceRecordToInsert.Enhanced_Hours__c = authorizationRecord.Enhanced_Hours__c;
        invoiceRecordToInsert.Parking__c = authorizationRecord.Parking__c;
        invoiceRecordToInsert.Dinner__c = authorizationRecord.Dinner__c;
        invoiceRecordToInsert.Breakfast__c = authorizationRecord.Breakfast__c;
        invoiceRecordToInsert.Lunch__c = authorizationRecord.Lunch__c;
        invoiceRecordToInsert.Hotels__c = authorizationRecord.Hotels__c;
        invoiceRecordToInsert.Mileage__c = authorizationRecord.Mileage__c;
        invoiceRecordToInsert.Standard_Hours__c = authorizationRecord.Standard_Hours__c;
        invoiceRecordToInsert.TASL_Standard__c = authorizationRecord.TASL_Standard_Hours__c == null ? 0 : authorizationRecord.TASL_Standard_Hours__c;
        invoiceRecordToInsert.TASL_Enhanced__c = authorizationRecord.TASL_Enhanced_Hours__c == null ? 0 : authorizationRecord.TASL_Enhanced_Hours__c;
        
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Invoice__c', new List<Invoice__c>{invoiceRecordToInsert}, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createCommunicationInvoice');
        INSERT decision.getRecords();
        invoiceRecordToInsert.id = decision.getRecords()[0].Id;
        // INSERT invoiceRecordToInsert;

        invoiceRecord = [SELECT Id,TASL_Standard__c, TASL_Enhanced__c, Hotels__c, Breakfast__c, Service_Type__c, Dinner__c,Lunch__c,Mileage__c, Parking__c, Excess_Hotel_Cost__c, Standard_Hours__c, Enhanced_Hours__c FROM Invoice__c WHERE Id =: invoiceRecordToInsert.Id WITH SECURITY_ENFORCED LIMIT 1];
        
        // Status is != Canceled
        if(authorizationRecord.Status__c != NC_Constant.AUTHORIZATION_STATUS_CANCELED){
            // Interpreter
            if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR){
                String interpreterType = (authorizationRecord.Vendor__r.Individual__c == true ? NC_Constant.INTERPRETER_TYPE_INDIVIDUAL : NC_Constant.INTERPRETER_TYPE_AGENCY);
                for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, Sequence__c, MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c AND Interpreter_Type__c =: interpreterType]){
                    if(authorizationRecord.All_Inclusive_Flat_Fee__c){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, authorizationRecord.Inclusive_Flat_Fee_Amount__c, null, null, 'All Inclusive Flat Fee', invoiceRecordToInsert.Id, 0, false, true, false, true, invoiceLineItem.Sequence__c));
                        break;
                    }else{
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else{
                                if(authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, invoiceRecord.Standard_Hours__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Standard'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Standard__c, invoiceRecord.TASL_Standard__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'TASL Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Enhanced'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Enhanced__c, invoiceRecord.TASL_Enhanced__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'TASL Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }else{
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, invoiceRecord.Enhanced_Hours__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && !authorizationRecord.Is_Individual__c && invoiceRecord.Standard_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && !authorizationRecord.Is_Individual__c && invoiceRecord.Enhanced_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                            }
                        }else{
                            //Out State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else{
                                if(authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Standard'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Standard__c, invoiceRecord.TASL_Standard__c * (invoiceLineItem.Out_of_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'TASL Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Enhanced'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Enhanced__c, invoiceRecord.TASL_Enhanced__c * (invoiceLineItem.Out_of_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'TASL Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }else{
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                    }
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && !authorizationRecord.Is_Individual__c){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && !authorizationRecord.Is_Individual__c){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                            }
                        }
                    }
                    
                }
            // CART    
            }else if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART){
                for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, Sequence__c, MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                    if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                        //In State
                        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                        }else{
                            if(invoiceRecord.Service_Type__c != null && invoiceRecord.Service_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }else{
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                            }
                            
                        }
                    }else{
                        //Out State
                        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null,  invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                        }else{
                            if(invoiceRecord.Service_Type__c != null && invoiceRecord.Service_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }else{
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                            }
                        }
                    }
                }
            // NDBEDP Interpreters
            } else if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR){
                String interpreterType = (authorizationRecord.Vendor__r.Individual__c == true ? NC_Constant.INTERPRETER_TYPE_INDIVIDUAL : NC_Constant.INTERPRETER_TYPE_AGENCY);
                for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, Sequence__c, MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c AND Interpreter_Type__c =: interpreterType]){
                    if(authorizationRecord.All_Inclusive_Flat_Fee__c){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, authorizationRecord.Inclusive_Flat_Fee_Amount__c, null, null, 'All Inclusive Flat Fee', invoiceRecordToInsert.Id, 0, false, true, false, true, invoiceLineItem.Sequence__c));
                        break;
                    }else{
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true,false, true,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                            }else{
                                if(authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, invoiceRecord.Standard_Hours__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Standard'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Standard__c, invoiceRecord.TASL_Standard__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'TASL Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Enhanced'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Enhanced__c, invoiceRecord.TASL_Enhanced__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'TASL Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                    }else{
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, invoiceRecord.Enhanced_Hours__c * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                    }
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && !authorizationRecord.Is_Individual__c && invoiceRecord.Standard_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c, invoiceLineItem.In_State_Amount_Authorized__c), 0 , null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && !authorizationRecord.Is_Individual__c && invoiceRecord.Enhanced_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c, invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                            }
                        }else{
                            //Out State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true,false, true,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true,false, true,invoiceLineItem.Sequence__c));
                            }else{
                                if(authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false,true, false,invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Standard'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Standard__c, calculateHours(invoiceRecord.TASL_Standard__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'TASL Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false,true, false,invoiceLineItem.Sequence__c));
                                    }else if(invoiceLineItem.Rate__c == 'TASL Enhanced'){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.TASL_Enhanced__c, calculateHours(invoiceRecord.TASL_Enhanced__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'TASL Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false,true, false,invoiceLineItem.Sequence__c));
                                    }else{
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false,true, false,invoiceLineItem.Sequence__c));
                                    }
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && !authorizationRecord.Is_Individual__c){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false,true, false,invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && !authorizationRecord.Is_Individual__c){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false,true, false,invoiceLineItem.Sequence__c));
                                }
                            }
                        }
                    }
                    
                }
            // NDBEDP CART
            } else if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_CART){
                for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, Sequence__c, MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                    if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                        //In State
                        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                        }else{
                            if(invoiceRecord.Service_Type__c != null && invoiceRecord.Service_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }else{
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                            }
                            
                        }
                    }else{
                        //Out State
                        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true,false, true,invoiceLineItem.Sequence__c));
                        }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                            listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                        }else{
                            if(invoiceRecord.Service_Type__c != null && invoiceRecord.Service_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }else{
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                            }
                        }
                    }
                }
            // NDBEDP SSP
            } else if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_SSP){
                for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, MasterLabel,Sequence__c, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                    if(authorizationRecord.All_Inclusive_Flat_Fee__c){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, authorizationRecord.Inclusive_Flat_Fee_Amount__c, null, null, 'All Inclusive Flat Fee', invoiceRecordToInsert.Id, 0, false, true, false, true,invoiceLineItem.Sequence__c));
                        break;
                    }else{
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                            }else{
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && invoiceRecord.Standard_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && invoiceRecord.Enhanced_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                            }
                        }else{
                            //Out State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(null, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true,invoiceLineItem.Sequence__c));
                            }else{
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && invoiceRecord.Standard_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && invoiceRecord.Enhanced_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false,invoiceLineItem.Sequence__c));
                                }
                            }
                        }
                    }
                    
                }
            // SSP
            } else{
                for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, MasterLabel,Sequence__c, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                    if(authorizationRecord.All_Inclusive_Flat_Fee__c){
                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, authorizationRecord.Inclusive_Flat_Fee_Amount__c, null, null, 'All Inclusive Flat Fee', invoiceRecordToInsert.Id, 0, false, true, false, true, invoiceLineItem.Sequence__c));
                        break;
                    }else{
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else{
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && invoiceRecord.Standard_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && invoiceRecord.Enhanced_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                            }
                        }else{
                            //Out State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else{
                                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && invoiceRecord.Standard_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && invoiceRecord.Enhanced_Hours__c != null){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), 0, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                                }
                            }
                        }
                    }
                    
                }
            }
        }else{
            //Canceled Staus
            if(authorizationRecord.Cancelled_Reason__c == NC_Constant.CANCEL_STATUS_AUTTHORIZATION_WEATHER){
                if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR){
                    String interpreterType = (authorizationRecord.Vendor__r.Individual__c == true ? NC_Constant.INTERPRETER_TYPE_INDIVIDUAL : NC_Constant.INTERPRETER_TYPE_AGENCY);
                    for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, MasterLabel, Sequence__c, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c AND Interpreter_Type__c =: interpreterType]){
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(authorizationRecord.Vendor__r.Individual__c && authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Standard_Hours__c/2), calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Standard_Hours__c/2)));
                                }
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Enhanced_Hours__c/2), calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Enhanced_Hours__c/2)));
                                }
                            }else if(!authorizationRecord.Vendor__r.Individual__c){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c/2, calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c/2));
                                }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c/2, calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c/2));
                                }
                            }
                        }else{
                            //Out State
                            if(authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Standard_Hours__c/2), calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Standard_Hours__c/2)));
                                }
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Enhanced_Hours__c/2), calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Enhanced_Hours__c/2)));
                                }
                            }else if(!authorizationRecord.Vendor__r.Individual__c){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c/2, calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c/2));
                                }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c/2, calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c/2));
                                }
                            }
                        }
                    }  
                }else{
                    //SSP //Change
                    for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, MasterLabel,Sequence__c, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE && invoiceRecord.Standard_Hours__c >= 2){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((2), calculateHours(2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }else if(invoiceLineItem.MasterLabel == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE && invoiceRecord.Standard_Hours__c < 2){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE && invoiceRecord.Enhanced_Hours__c >= 2){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((2), calculateHours(2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }else if(invoiceLineItem.MasterLabel == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE && invoiceRecord.Enhanced_Hours__c < 2){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }
                            //Keeping Normal Mileage
                            if( NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel && invoiceRecord.Mileage__c != NULL){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }
                            
                        }else{
                            //Out State
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE && invoiceRecord.Standard_Hours__c >= 2){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((2), calculateHours(2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }else if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY && invoiceRecord.Standard_Hours__c < 2){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                                }
                                
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE && invoiceRecord.Enhanced_Hours__c >= 2){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((2), calculateHours(2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }else if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY && invoiceRecord.Enhanced_Hours__c < 2){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,2));
                            }
                            //Keeping Normal Mileage
                            if( NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel && invoiceRecord.Mileage__c != NULL){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }
                        }
                    }
                }
            }else if(authorizationRecord.Cancelled_Reason__c ==  NC_Constant.CANCEL_STATUS_AUTTHORIZATION_CANCELLED){
                if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR){
                    String interpreterType = (authorizationRecord.Vendor__r.Individual__c == true ? NC_Constant.INTERPRETER_TYPE_INDIVIDUAL : NC_Constant.INTERPRETER_TYPE_AGENCY);
                    for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id,Sequence__c, MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c AND Interpreter_Type__c =: interpreterType]){
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(authorizationRecord.Vendor__r.Individual__c && authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Standard_Hours__c), calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                }
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Enhanced_Hours__c), calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                }
                            }else if(!authorizationRecord.Vendor__r.Individual__c){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                }
                            }
                        }else{
                            //Out State
                            if(authorizationRecord.Vendor__r.Individual__c && authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Standard_Hours__c), calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                }
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Enhanced_Hours__c), calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                }
                            }else if(!authorizationRecord.Vendor__r.Individual__c){
                                if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                    listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                }
                            }
                        }
                    }   
                }else if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP){
                    //SSP
                    for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id,Sequence__c, MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c]){
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Standard_Hours__c/2), calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Standard_Hours__c/2)));
                            }
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Enhanced_Hours__c/2), calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Enhanced_Hours__c/2)));
                            }
                            
                        }else{
                            //Out State
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Standard_Hours__c/2), calculateHours(invoiceRecord.Standard_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Standard_Hours__c/2)));
                            }
                            if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility((invoiceRecord.Enhanced_Hours__c/2), calculateHours(invoiceRecord.Enhanced_Hours__c/2,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,(invoiceRecord.Enhanced_Hours__c/2)));
                            }
                        }
                    }
                }
            }else if(authorizationRecord.Cancelled_Reason__c == NC_Constant.CANCEL_STATUS_AUTTHORIZATION_ASSIGNMENT){
                // Interpreter
                if(authorizationRecord.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR){
                    String interpreterType = (authorizationRecord.Vendor__r.Individual__c == true ? NC_Constant.INTERPRETER_TYPE_INDIVIDUAL : NC_Constant.INTERPRETER_TYPE_AGENCY);
                    for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id,Sequence__c ,MasterLabel, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, Interpreter_Type__c, Rate__c FROM Invoice_line_item_for__mdt WHERE Vendor_Type__c =: authorizationRecord.Vendor_Type__c AND Interpreter_Type__c =: interpreterType]){
                        if(authorizationRecord.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                            //In State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountInState(invoiceRecord, invoiceLineItem).get('Amount Billed'), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else{
                                //Values With Max Size
                                if(authorizationRecord.Vendor__r.Individual__c && authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                    }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                    }
                                }else if(!authorizationRecord.Vendor__r.Individual__c){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                    }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                    }
                                }
                            }
                        }else{
                            //Out State
                            if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel || NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Quantity'), getQuantityAndAmountOutState(invoiceRecord, invoiceLineItem).get('Amount Billed'), null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Parking__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
                                listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(1, invoiceRecord.Excess_Hotel_Cost__c, null, null, invoiceLineItem.MasterLabel, invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, false, true, false, true, invoiceLineItem.Sequence__c));
                            }else{
                                //Values With Max Size
                                if(authorizationRecord.Vendor__r.Individual__c && authorizationRecord.Vendor__r.License_Type__c != null && authorizationRecord.Vendor__r.License_Type__c == invoiceLineItem.MasterLabel){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                    }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.Out_of_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.Out_of_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                    }
                                }else if(!authorizationRecord.Vendor__r.Individual__c){
                                    if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Standard_Hours__c, calculateHours(invoiceRecord.Standard_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Standard hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Standard_Hours__c));
                                    }if( invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_ENHANCED_RATE){
                                        listOfInvoiceLineItem.add(createInvoiceLineItemNDBEDPUtility(invoiceRecord.Enhanced_Hours__c, calculateHours(invoiceRecord.Enhanced_Hours__c,invoiceLineItem.In_State_Amount_Authorized__c), null, null, 'Enhanced hours', invoiceRecordToInsert.Id, invoiceLineItem.In_State_Amount_Authorized__c, true, false, true, false, invoiceLineItem.Sequence__c,invoiceRecord.Enhanced_Hours__c));
                                    }
                                }
                            }
                        }
                    }   
                }
            }
        }
        
        
        if(!listOfInvoiceLineItem.isEmpty()){
            SObjectAccessDecision decision1 =  SecurityLibrary.getAccessibleData('Invoice_Line_Item__c', listOfInvoiceLineItem, 'insert', true,'NC_Create_Invoice_and_InvoiceLineItem','createCommunicationInvoice');
            insert decision1.getRecords();
            //INSERT listOfInvoiceLineItem;
        }
    }
}