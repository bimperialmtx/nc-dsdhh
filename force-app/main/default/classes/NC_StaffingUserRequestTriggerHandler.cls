/*
**   Class Name: NC_StaffingUserRequestTriggerHandler
**   Description: 
**
**     Date            New/Modified           User                 Identifier                Description
**  06-04-2020             New          Hiten Aggarwal(mtx)
*/



public without sharing class NC_StaffingUserRequestTriggerHandler {
    public static Id ExternalRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c',NC_Constant.STAFFING_USER_REQUEST_EXTERNAL);
    public static Id TrainingVendorUserRecordType = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'Training_Vendor_Staffing_User_Request');
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before UPDATE' trigger event
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap){
        vendorInProgressCheck(newList,oldMap);
        conditionForSubmittingApproval(newList,oldMap);
        List<Staffing_User_Request__c> listOfStaffUserRequestExternal = new List<Staffing_User_Request__c>();
        for(Staffing_User_Request__c staffuserRequest : newList){
            if(staffuserRequest.recordTypeId == ExternalRecordTypeId && (staffuserRequest.Parking__c != oldMap.get(staffuserRequest.Id).Parking__c || staffuserRequest.Hotels__c != oldMap.get(staffuserRequest.Id).Hotels__c || staffuserRequest.Mileage__c != oldMap.get(staffuserRequest.Id).Mileage__c || staffuserRequest.Breakfast__c != oldMap.get(staffuserRequest.Id).Breakfast__c || staffuserRequest.Dinner__c != oldMap.get(staffuserRequest.Id).Dinner__c || staffuserRequest.Lunch__c != oldMap.get(staffuserRequest.Id).Lunch__c || staffuserRequest.Excess_Hotel_Cost__c != oldMap.get(staffuserRequest.Id).Excess_Hotel_Cost__c || staffuserRequest.Standard_Hours__c != oldMap.get(staffuserRequest.Id).Standard_Hours__c || staffuserRequest.Enhanced_Hours__c != oldMap.get(staffuserRequest.Id).Enhanced_Hours__c || staffuserRequest.TASL_Standard_Hours__c != oldMap.get(staffuserRequest.Id).TASL_Standard_Hours__c || staffuserRequest.TASL_Enhanced_Hours__c != oldMap.get(staffuserRequest.Id).TASL_Enhanced_Hours__c)){
                listOfStaffUserRequestExternal.add(staffuserRequest);
            }
            if(staffuserRequest.Allow_Update__c == true && staffuserRequest.Allow_Update__c == oldMap.get(staffuserRequest.id).Allow_Update__c){
                staffuserRequest.Allow_Update__c = false;
            }
        }

        if(!listOfStaffUserRequestExternal.isEmpty()){
            updateAuthorizedAmount(listOfStaffUserRequestExternal);
        }
        updateAuthorizedAmountForVendorTraing(newList,oldMap);
        validationForApprovingUserRequset(newList,oldMap);
        calculateTotalInternalCost(newList,oldMap);
        BookedTimeSameAsServiceTime(newList,oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : afterInsert
    @description    : calling this method on 'after Insert' trigger event
    @param          : List<Staffing_User_Request__c> newList
    @return         : void
    ********************************************************
    */
    public static void afterInsert(List<Staffing_User_Request__c> newList){
		fireApprovalProcess(newList); 
       // sendEmailInvitationStaffingUserRequest(newList,null);
    }

    /*
    *********************************************************
    @Method Name    : afterUpdate
    @description    : calling this method on 'after Update' trigger event
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void afterUpdate(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap){
       
        List<Staffing_User_Request__c> listOfStaffUserRequest = new List<Staffing_User_Request__c>();
        for(Staffing_User_Request__c staffuserRequest : newList){
            if((staffuserRequest.recordTypeId == ExternalRecordTypeId || staffuserRequest.recordTypeId == TrainingVendorUserRecordType) 
               && staffuserRequest.Account__c !=null 
               && (staffuserRequest.Status__c == NC_Constant.STAFF_USER_REQUEST_STATUS_APPROVED 
                   || staffuserRequest.Status__c == NC_Constant.STAFFING_USER_REQUEST_STATUS_VENDOR_APPROVED) 
               && oldMap.get(staffuserRequest.Id).Status__c != staffuserRequest.Status__c){
                listOfStaffUserRequest.add(staffuserRequest);
            }
        }

        if(!listOfStaffUserRequest.isEmpty()){
            createAuthorizationRecord(listOfStaffUserRequest);
        }
        sendEmailAfterfirstApproval(newList, oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : sendEmailAfterfirstApproval
    @description    : Send email after creation of Staffing user request
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void sendEmailAfterfirstApproval(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap) {
        Map<Id, Staffing_User_Request__c> staffUserrequestMap = new Map<Id, Staffing_User_Request__c>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(Staffing_User_Request__c staffUserRequest: newList) {
            if(staffUserRequest.recordTypeId == ExternalRecordTypeId
            && staffUserRequest.Status__c == 'Pending Approval') {
                staffUserrequestMap.put(staffUserRequest.id, staffUserRequest);
            }
        }

        if(staffUserrequestMap.size() > 0) {
            List<EmailTemplate> emailTemplateList = [SELECT Id,Name,DeveloperName,HtmlValue,Subject,Body FROM EmailTemplate WHERE DeveloperName ='Staffing_User_Request_For_External'];
            if(!emailTemplateList.isEmpty()) {
                for(Staffing_User_Request__c staffObj: [SELECT Trainer_Administrator_User__c, Trainer_Administrator_User__r.Email, Staffing_Request__r.Vendor_Type__c, Staffing_Request__r.CreatedBy.Name, Staffing_Request__r.CreatedBy.Email, Start_Service_Date_Time__c, End_Service_Date_Time__c, City__c, Approval_Internal_URL__c FROM Staffing_User_Request__c WHERE Id IN: staffUserrequestMap.keySet() WITH SECURITY_ENFORCED]) {
                    staffObj.Approval_Internal_URL__c = staffObj.Approval_Internal_URL__c != null ? staffObj.Approval_Internal_URL__c : 'https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/' + staffObj.id;
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    String plainBody = emailTemplateList[0].Body;
                    String htmlBody = emailTemplateList[0].HtmlValue;

                    plainBody = plainBody.replace('{!Staffing_Request__c.OwnerFullName}',staffObj.Staffing_Request__r.CreatedBy.Name);
                    plainBody = plainBody.replace('{!Staffing_Request__c.Vendor_Type__c}',staffObj.Staffing_Request__r.Vendor_Type__c);
                    plainBody = plainBody.replace('{!Staffing_User_Request__c.Start_Service_Date_Time__c}',staffObj.Start_Service_Date_Time__c+'');
                    plainBody = plainBody.replace('{!Staffing_User_Request__c.End_Service_Date_Time__c}',staffObj.End_Service_Date_Time__c+'');
                    plainBody = plainBody.replace('{!Staffing_User_Request__c.City__c}',staffObj.City__c);
                    plainBody = plainBody.replace('{!Staffing_User_Request__c.Approval_Internal_URL__c}',staffObj.Approval_Internal_URL__c);

                    htmlBody = htmlBody.replace('{!Staffing_Request__c.OwnerFullName}',staffObj.Staffing_Request__r.CreatedBy.Name);
                    htmlBody = htmlBody.replace('{!Staffing_Request__c.Vendor_Type__c}',staffObj.Staffing_Request__r.Vendor_Type__c);
                    htmlBody = htmlBody.replace('{!Staffing_User_Request__c.Start_Service_Date_Time__c}',staffObj.Start_Service_Date_Time__c+'');
                    htmlBody = htmlBody.replace('{!Staffing_User_Request__c.End_Service_Date_Time__c}',staffObj.End_Service_Date_Time__c+'');
                    htmlBody = htmlBody.replace('{!Staffing_User_Request__c.City__c}',staffObj.City__c);
                    htmlBody = htmlBody.replace('{!Staffing_User_Request__c.Approval_Internal_URL__c}',staffObj.Approval_Internal_URL__c);
                    
                    if(staffObj.Trainer_Administrator_User__r.Email != null) {
                        message.setToAddresses(new List<String>{staffObj.Trainer_Administrator_User__r.Email});
                    } else {
                        message.setToAddresses(new List<String>{staffObj.Staffing_Request__r.CreatedBy.Email});
                    }
                    message.setHtmlBody(htmlBody);
                    message.setPlainTextBody(plainBody);   
                    message.setTemplateID(emailTemplateList[0].Id);  
                    message.setSubject(emailTemplateList[0].Subject);
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(false);
                    messages.add(message);
                }
            }
        }
        
        if(messages.size() > 0) {
            Messaging.sendEmail(messages);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : BookedTimeSameAsServiceTime
    @description    : Booked start and end date time required validation
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void BookedTimeSameAsServiceTime(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap){
 
        for(Staffing_User_Request__c SURN : newList) {
            if(SURN.Booked_Time_Same_As_Service_Time__c){
                SURN.Booked_Start_Date_Time__c = SURN.Start_Service_Date_Time__c;
                SURN.End_Start_Date_Time__c = SURN.End_Service_Date_Time__c;
            }
            if(SURN.recordTypeId == ExternalRecordTypeId && SURN.Booked_Time_Same_As_Service_Time__c == false && oldMap.get(SURN.Id).Booked_Validation__c == SURN.Booked_Validation__c  && ( SURN.Booked_Start_Date_Time__c == NULL || SURN.End_Start_Date_Time__c == NULL)){
                 SURN.addError('Booked Start Date/Time and Booked End Date/Time are required');
             }
             if(SURN.Booked_Validation__c == true){
                SURN.Booked_Validation__c =false;
             }
        }  
    }
    
    /*
    *********************************************************
    @Method Name    : conditionForSubmittingApproval
    @description    : Cost field validation before submitting approval
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void conditionForSubmittingApproval(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap){
        Id StaffingExternalUserRecordType = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'External_Staffing_User_Request');
        for(Staffing_User_Request__c staffingRequest: newList){
            if(oldMap != NULL && oldMap.get(staffingRequest.Id).status__c != staffingRequest.status__c 
               && staffingRequest.status__c == 'Pending Vendor Approval'){
                   if(staffingRequest.RecordTypeId == StaffingExternalUserRecordType){
                       if(staffingRequest.Enhanced_Hours__c == NULL && staffingRequest.Standard_Hours__c == NULL){
                           staffingRequest.addError('Standard or Enhanced hours are required. Please also update the expenses if applicable.');
                       }
                   }else if(staffingRequest.RecordTypeId == TrainingVendorUserRecordType){
                       if(staffingRequest.Hours__c == NULL || staffingRequest.Travel_Time__c == NULL){
                           staffingRequest.addError('Hours And Travel Time Are Required.');
                       }
                   }
               }
        }
    }
    
    /*
    *********************************************************
    @Method Name    : updateAuthorizedAmountForVendorTraing
    @description    : Update Amount Authorization
    @param          : List<Staffing_User_Request__c> newList, Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void updateAuthorizedAmountForVendorTraing(List<Staffing_User_Request__c> newList, Map<Id,Staffing_User_Request__c> oldMap){
        Map<String, List<Training_Vendor_Invoice_Line_Item__mdt>> mapOfVendorTypeAndTrainingItem = new Map<String, List<Training_Vendor_Invoice_Line_Item__mdt>>();
        List<Training_Vendor_Invoice_Line_Item__mdt> trainingVendorItemsList = Training_Vendor_Invoice_Line_Item__mdt.getAll().values();
       
        Id TrainingVendorUserRecordType = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'Training_Vendor_Staffing_User_Request');
        for(Staffing_User_Request__c staffuserRequest : newList){
            
            if(staffuserRequest.recordTypeId == TrainingVendorUserRecordType && 
               (staffuserRequest.Hours__c != oldMap.get(staffuserRequest.Id).Hours__c || 
                staffuserRequest.Travel_Time__c != oldMap.get(staffuserRequest.Id).Travel_Time__c)){
                    staffuserRequest.Total_Authorized_Amount__c = 0;
                    for(Training_Vendor_Invoice_Line_Item__mdt invoiceVendorItem : trainingVendorItemsList){
                        if(invoiceVendorItem.DeveloperName == 'Hours' && staffuserRequest.Hours__c!=null){
                            staffuserRequest.Total_Authorized_Amount__c += staffuserRequest.Hours__c * invoiceVendorItem.Amount_Per_Hour__c;
                    }
                        if(invoiceVendorItem.DeveloperName == 'Travel_Time' && staffuserRequest.Travel_Time__c!=null){
                            staffuserRequest.Total_Authorized_Amount__c += staffuserRequest.Travel_Time__c * invoiceVendorItem.Amount_Per_Hour__c;
                    }
                    }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : calculateTotalInternalCost
    @description    : Calculate total cost
    @param          : List<Staffing_User_Request__c> newList, Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void calculateTotalInternalCost(List<Staffing_User_Request__c> newList, Map<Id,Staffing_User_Request__c> oldMap){
        List<Internal_Staff_Line_Item__mdt> internalSatffItemsList = Internal_Staff_Line_Item__mdt.getAll().values();
        Id internalStaffingUserRecordId = NC_Utility.RecordTypeUtilityMethod('Staffing_User_Request__c', 'Internal_Staffing_User_Request');
        List<Staffing_User_Request__c> totalInternalCost = new List<Staffing_User_Request__c>();

        for(Staffing_User_Request__c staffuserRequest : newList){
            
            if(staffuserRequest.recordTypeId == internalStaffingUserRecordId){
                    staffuserRequest.Total_Amount_Billed__c = 0;
                    for(Internal_Staff_Line_Item__mdt invoiceVendorItem : internalSatffItemsList){
                        if(staffuserRequest.Amount_Authorization_Type__c=='In State'){
                        if(invoiceVendorItem.DeveloperName == 'Breakfast' && staffuserRequest.Breakfast__c!=null){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Breakfast__c * invoiceVendorItem.In_State_Amount_Authorized__c;
                        }
                        if(invoiceVendorItem.DeveloperName == 'Dinner' && staffuserRequest.Dinner__c!=null){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Dinner__c * invoiceVendorItem.In_State_Amount_Authorized__c;
                        }
                       if(invoiceVendorItem.DeveloperName == 'Excess_Hotel_Cost' && staffuserRequest.Excess_Hotel_Cost__c!=null){
                           staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Excess_Hotel_Cost__c ;
                       }
                        if(invoiceVendorItem.DeveloperName == 'Hotels' && staffuserRequest.Hotels__c!=null){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Hotels__c * invoiceVendorItem.In_State_Amount_Authorized__c;
                        }
                        if(invoiceVendorItem.DeveloperName == 'Lunch' && staffuserRequest.Lunch__c!=null){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Lunch__c * invoiceVendorItem.In_State_Amount_Authorized__c;
                        }
                       if(invoiceVendorItem.DeveloperName == 'Parking' && staffuserRequest.Parking__c!=null){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Parking__c ;
                        }

                        if(invoiceVendorItem.DeveloperName == 'Mileage_cost_for_99_miles_and_under' && staffuserRequest.Mileage__c!=null && staffuserRequest.Mileage__c<=99){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Mileage__c * invoiceVendorItem.In_State_Amount_Authorized__c;
                        }
                        if(invoiceVendorItem.DeveloperName == 'Mileage_cost_100_miles_and_over' && staffuserRequest.Mileage__c!=null && staffuserRequest.Mileage__c>=100){
                            staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Mileage__c * invoiceVendorItem.In_State_Amount_Authorized__c;
                        }
                    }
                }

                for(Internal_Staff_Line_Item__mdt invoiceVendorItem : internalSatffItemsList){
                    if(staffuserRequest.Amount_Authorization_Type__c=='Out State'){
                    if(invoiceVendorItem.DeveloperName == 'Breakfast' && staffuserRequest.Breakfast__c!=null){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Breakfast__c * invoiceVendorItem.Out_of_State_Amount_Authorized__c;
                    }
                    if(invoiceVendorItem.DeveloperName == 'Dinner' && staffuserRequest.Dinner__c!=null){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Dinner__c * invoiceVendorItem.Out_of_State_Amount_Authorized__c;
                    }
                    if(invoiceVendorItem.DeveloperName == 'Excess_Hotel_Cost' && staffuserRequest.Excess_Hotel_Cost__c!=null){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Excess_Hotel_Cost__c ;
                    }
                    if(invoiceVendorItem.DeveloperName == 'Hotels' && staffuserRequest.Hotels__c!=null){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Hotels__c * invoiceVendorItem.Out_of_State_Amount_Authorized__c;
                    }
                    if(invoiceVendorItem.DeveloperName == 'Lunch' && staffuserRequest.Lunch__c!=null){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Lunch__c * invoiceVendorItem.Out_of_State_Amount_Authorized__c;
                    }
                    if(invoiceVendorItem.DeveloperName == 'Parking' && staffuserRequest.Parking__c!=null){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Parking__c ;
                    }

                    if(invoiceVendorItem.DeveloperName == 'Mileage_cost_for_99_miles_and_under' && staffuserRequest.Mileage__c!=null && staffuserRequest.Mileage__c<=99){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Mileage__c * invoiceVendorItem.Out_of_State_Amount_Authorized__c;
                    }
                    if(invoiceVendorItem.DeveloperName == 'Mileage_cost_100_miles_and_over' && staffuserRequest.Mileage__c!=null && staffuserRequest.Mileage__c>=100){
                        staffuserRequest.Total_Amount_Billed__c += staffuserRequest.Mileage__c * invoiceVendorItem.Out_of_State_Amount_Authorized__c;
                    }
                }
            }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAuthorizedAmount
    @description    : Update authorized amount based on in state or out state
    @param          : List<Staffing_User_Request__c> listOfStaffUserRequestExternal
    @return         : void
    ********************************************************
    */
    public static void updateAuthorizedAmount(List<Staffing_User_Request__c> listOfStaffUserRequestExternal){
        Map<String, List<Invoice_line_item_for__mdt>> mapOfVendorTypeAndInvoiceLineItem = new Map<String, List<Invoice_line_item_for__mdt>>();
        for(Invoice_line_item_for__mdt invoiceLineItem : [SELECT Id, Interpreter_Type__c, Rate__c, In_State_Amount_Authorized__c, Out_of_State_Amount_Authorized__c, Vendor_Type__c, MasterLabel FROM Invoice_line_item_for__mdt]){
            if(!mapOfVendorTypeAndInvoiceLineItem.containsKey(invoiceLineItem.Vendor_Type__c)){
                mapOfVendorTypeAndInvoiceLineItem.put(invoiceLineItem.Vendor_Type__c, new List<Invoice_line_item_for__mdt>());
            }
            mapOfVendorTypeAndInvoiceLineItem.get(invoiceLineItem.Vendor_Type__c).add(invoiceLineItem);
        }
        for(Staffing_User_Request__c staffingUserRequest : listOfStaffUserRequestExternal){
            if(staffingUserRequest.Amount_Authorization_Type__c == NC_Constant.AMOUNT_AUTHORIZED_TYPE_INSTATE){
                staffingUserRequest.Total_Authorized_Amount__c = 0;
                for(Invoice_line_item_for__mdt invoiceLineItem : mapOfVendorTypeAndInvoiceLineItem.get(staffingUserRequest.Vendor_Type__c)){
                    if((staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR) && staffingUserRequest.Is_Individual__c && invoiceLineItem.Interpreter_Type__c == 'Individual'){
                        staffingUserRequest.Total_Authorized_Amount__c += getQuantityAndAmountInState(staffingUserRequest, invoiceLineItem);
                    }else if((staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR) && !staffingUserRequest.Is_Individual__c && invoiceLineItem.Interpreter_Type__c == 'Agency'){
                        staffingUserRequest.Total_Authorized_Amount__c += getQuantityAndAmountInState(staffingUserRequest, invoiceLineItem);
                    }else if(staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART
                            || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_SSP || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_CART){
                        staffingUserRequest.Total_Authorized_Amount__c += getQuantityAndAmountInState(staffingUserRequest, invoiceLineItem);
                    }
                    
                }
            }else{
                staffingUserRequest.Total_Authorized_Amount__c = 0;
                for(Invoice_line_item_for__mdt invoiceLineItem : mapOfVendorTypeAndInvoiceLineItem.get(staffingUserRequest.Vendor_Type__c)){
                    if((staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR) && staffingUserRequest.Is_Individual__c && invoiceLineItem.Interpreter_Type__c == 'Individual'){
                        staffingUserRequest.Total_Authorized_Amount__c += getQuantityAndAmountInState(staffingUserRequest, invoiceLineItem);
                    }else if((staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR) && !staffingUserRequest.Is_Individual__c && invoiceLineItem.Interpreter_Type__c == 'Agency'){
                        staffingUserRequest.Total_Authorized_Amount__c += getQuantityAndAmountInState(staffingUserRequest, invoiceLineItem);
                    }else if(staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART
                            || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_SSP || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_CART){
                        staffingUserRequest.Total_Authorized_Amount__c += getQuantityAndAmountInState(staffingUserRequest, invoiceLineItem);
                    }
                }
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : getQuantityAndAmountInState
    @description    : Create a Map For Quantity and Amount Billed for In State
    @param          : Staffing_User_Request__c staffingUserRequest, Invoice_line_item_for__mdt invoiceLineItem
    @return         : Decimal
    ********************************************************
    */
    public static Decimal getQuantityAndAmountInState(Staffing_User_Request__c staffingUserRequest, Invoice_line_item_for__mdt invoiceLineItem){
        invoiceLineItem.In_State_Amount_Authorized__c = invoiceLineItem.In_State_Amount_Authorized__c != NULL ? invoiceLineItem.In_State_Amount_Authorized__c: 0;
        staffingUserRequest.Hotels__c = staffingUserRequest.Hotels__c != NULL ? staffingUserRequest.Hotels__c : 0;
        staffingUserRequest.Breakfast__c = staffingUserRequest.Breakfast__c !=NULL ? staffingUserRequest.Breakfast__c: 0;
        staffingUserRequest.Dinner__c= staffingUserRequest.Dinner__c != NULL ? staffingUserRequest.Dinner__c: 0;
        staffingUserRequest.Lunch__c = staffingUserRequest.Lunch__c != NULL ? staffingUserRequest.Lunch__c: 0;
        staffingUserRequest.Mileage__c = staffingUserRequest.Mileage__c != NULL ? staffingUserRequest.Mileage__c: 0;
        staffingUserRequest.Excess_Hotel_Cost__c = staffingUserRequest.Excess_Hotel_Cost__c != null ? staffingUserRequest.Excess_Hotel_Cost__c :0;
        staffingUserRequest.Parking__c = staffingUserRequest.Parking__c != null ? staffingUserRequest.Parking__c :0;
        
        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Hotels__c * invoiceLineItem.In_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel){
           return staffingUserRequest.Breakfast__c * invoiceLineItem.In_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Dinner__c * invoiceLineItem.In_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Lunch__c * invoiceLineItem.In_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Mileage__c * invoiceLineItem.In_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Excess_Hotel_Cost__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Parking__c;
        }else{
            if(staffingUserRequest.License_Type__c == invoiceLineItem.MasterLabel || staffingUserRequest.Service_Type__c == invoiceLineItem.MasterLabel){
                if(invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                    return (staffingUserRequest.Standard_Hours__c == null ? 0 : staffingUserRequest.Standard_Hours__c) * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c);
                }else if(invoiceLineItem.Rate__c == 'TASL Standard'){
                    return (staffingUserRequest.TASL_Standard_Hours__c == null ? 0 : staffingUserRequest.TASL_Standard_Hours__c) * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c);
                }else if(invoiceLineItem.Rate__c == 'TASL Enhanced'){
                    return (staffingUserRequest.TASL_Enhanced_Hours__c == null ? 0 : staffingUserRequest.TASL_Enhanced_Hours__c) * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c);
                }else{
                    return (staffingUserRequest.Enhanced_Hours__c == null ? 0 : staffingUserRequest.Enhanced_Hours__c) * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c);
                }
            }
            if((staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_SSP)
                  && !staffingUserRequest.Is_Individual__c){
                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY){
                    return (staffingUserRequest.Standard_Hours__c == null ? 0 : staffingUserRequest.Standard_Hours__c) * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c);
                }
                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY){
                    return (staffingUserRequest.Enhanced_Hours__c == null ? 0 : staffingUserRequest.Enhanced_Hours__c) * (invoiceLineItem.In_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.In_State_Amount_Authorized__c);
                }  
            }
            return 0;
        }
    }

    /*
    *********************************************************
    @Method Name    : getQuantityAndAmountOutState
    @description    : Create a Map For Quantity and Amount Billed for Out State
    @param          : Staffing_User_Request__c staffingUserRequest, Invoice_line_item_for__mdt invoiceLineItem
    @return         : Decimal
    ********************************************************
    */
    public static Decimal getQuantityAndAmountOutState(Staffing_User_Request__c staffingUserRequest, Invoice_line_item_for__mdt invoiceLineItem){
        invoiceLineItem.Out_of_State_Amount_Authorized__c = invoiceLineItem.Out_of_State_Amount_Authorized__c != NULL ? invoiceLineItem.Out_of_State_Amount_Authorized__c: 0;
        staffingUserRequest.Hotels__c = staffingUserRequest.Hotels__c != NULL ? staffingUserRequest.Hotels__c : 0;
        staffingUserRequest.Breakfast__c = staffingUserRequest.Breakfast__c !=NULL ? staffingUserRequest.Breakfast__c: 0;
        staffingUserRequest.Dinner__c= staffingUserRequest.Dinner__c != NULL ? staffingUserRequest.Dinner__c: 0;
        staffingUserRequest.Lunch__c = staffingUserRequest.Lunch__c != NULL ? staffingUserRequest.Lunch__c: 0;
        staffingUserRequest.Mileage__c = staffingUserRequest.Mileage__c != NULL ? staffingUserRequest.Mileage__c: 0;
        staffingUserRequest.Excess_Hotel_Cost__c = staffingUserRequest.Excess_Hotel_Cost__c != null ? staffingUserRequest.Excess_Hotel_Cost__c :0;
        staffingUserRequest.Parking__c = staffingUserRequest.Parking__c != null ? staffingUserRequest.Parking__c :0;

        if(NC_Constant.INVOICE_LINE_ITEM_HOTELS == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Hotels__c * invoiceLineItem.Out_of_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_BREAKFAST == invoiceLineItem.MasterLabel){
           return staffingUserRequest.Breakfast__c * invoiceLineItem.Out_of_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_DINNER == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Dinner__c * invoiceLineItem.Out_of_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_LUNCH == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Lunch__c * invoiceLineItem.Out_of_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_MILEAGE == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Mileage__c * invoiceLineItem.Out_of_State_Amount_Authorized__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_EXCESS_HOTEL == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Excess_Hotel_Cost__c;
        }else if(NC_Constant.INVOICE_LINE_ITEM_PARKING == invoiceLineItem.MasterLabel){
            return staffingUserRequest.Parking__c;
        }else{
            if(staffingUserRequest.License_Type__c == invoiceLineItem.MasterLabel || staffingUserRequest.Service_Type__c == invoiceLineItem.MasterLabel){
                if(invoiceLineItem.Rate__c == NC_Constant.INVOICE_LINE_ITEM_STANDARD_RATE){
                    return (staffingUserRequest.Standard_Hours__c == null ? 0 : staffingUserRequest.Standard_Hours__c) * (invoiceLineItem.Out_of_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.Out_of_State_Amount_Authorized__c);
                }else{
                    return (staffingUserRequest.Enhanced_Hours__c == null ? 0 : staffingUserRequest.Enhanced_Hours__c) * (invoiceLineItem.Out_of_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.Out_of_State_Amount_Authorized__c);
                }   
            }
            if((staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_INTERPRETOR || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP || staffingUserRequest.Vendor_Type__c == NC_Constant.VENDOR_TYPE_NDBEDP_SSP) && !staffingUserRequest.Is_Individual__c){
                if(invoiceLineItem.MasterLabel == NC_Constant.STANDARD_RATE_AGENCY){
                    return (staffingUserRequest.Standard_Hours__c == null ? 0 : staffingUserRequest.Standard_Hours__c) * (invoiceLineItem.Out_of_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.Out_of_State_Amount_Authorized__c);
                }
                if(invoiceLineItem.MasterLabel == NC_Constant.ENHANCED_RATE_AGENCY){
                    return (staffingUserRequest.Enhanced_Hours__c == null ? 0 : staffingUserRequest.Enhanced_Hours__c) * (invoiceLineItem.Out_of_State_Amount_Authorized__c == null ? 0 : invoiceLineItem.Out_of_State_Amount_Authorized__c);
                }  
            }
            return 0;
        }
    }

    /*
    *********************************************************
    @Method Name    : createAuthorizationRecord
    @description    : Create record for Authorization
    @param          : List<Staffing_User_Request__c> staffUserRequestList
    @return         : void
    ********************************************************
    */
    public static void createAuthorizationRecord(List<Staffing_User_Request__c> staffUserRequestList){
        List<Authorization__c> listOfAuthorization = new List<Authorization__c>();
        Set<Id> setOfIdAuth = new Set<Id>();
        Id AuthCommunicationRecord = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_COMMUNICATION);
        Id AuthTrainingVendorRecord = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
        Id authNDBEDPTrainingRecord = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'NDBEDP_Training');
        for(Staffing_User_Request__c staffRequestUser : [SELECT Id, Account__c, Staffing_Request__c, Staffing_Request__r.Communication_Access_Request__c, Staffing_Request__r.Communication_Access_Request__r.Outreach_Request__c,Staffing_Request__r.Communication_Access_Request__r.Request__c,Vendor_Type__c,Regional_Center__c,Staffing_Request__r.Communication_Access_Request__r.Request__r.ContactId, Staffing_Request__r.Communication_Access_Request__r.Request__r.Regional_Center__c, Trainer_Administrator_User__c FROM Staffing_User_Request__c WHERE Id IN : staffUserRequestList AND (Status__c =: NC_Constant.STAFF_USER_REQUEST_STATUS_APPROVED OR Status__c =: NC_Constant.STAFFING_USER_REQUEST_STATUS_VENDOR_APPROVED)]){
            Authorization__c AuthorizationRecord = new Authorization__c();
            AuthorizationRecord.Communication_Access_Request__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__c;
            AuthorizationRecord.Vendor__c = staffRequestUser.Account__c;
            AuthorizationRecord.Outreach_Request__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Outreach_Request__c;
            AuthorizationRecord.Staffing_User_Request__c = staffRequestUser.Id;
            AuthorizationRecord.Status__c = NC_Constant.APPROVED;
            AuthorizationRecord.Regional_Center__c = staffRequestUser.Regional_Center__c;
            if(staffRequestUser.Vendor_Type__c == 'Training Vendor'){
                AuthorizationRecord.RecordTypeId = AuthTrainingVendorRecord;
            } else if (staffRequestUser.Vendor_Type__c == 'NDBEDP Training') {
                AuthorizationRecord.RecordTypeId = authNDBEDPTrainingRecord;
                AuthorizationRecord.Request__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Request__c;
                AuthorizationRecord.Consumer__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Request__r.ContactId;
                AuthorizationRecord.Regional_Center__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Request__r.Regional_Center__c;
                AuthorizationRecord.Trainer_Administrator_User__c = staffRequestUser.Trainer_Administrator_User__c;
            } else if (staffRequestUser.Vendor_Type__c == 'NDBEDP SSP' || staffRequestUser.Vendor_Type__c == 'NDBEDP CART' || staffRequestUser.Vendor_Type__c == 'NDBEDP Interpreters') {
                AuthorizationRecord.RecordTypeId = AuthCommunicationRecord;
                AuthorizationRecord.Request__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Request__c;
                AuthorizationRecord.Consumer__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Request__r.ContactId;
                AuthorizationRecord.Regional_Center__c = staffRequestUser.Staffing_Request__r.Communication_Access_Request__r.Request__r.Regional_Center__c;
            } else{
                 AuthorizationRecord.RecordTypeId = AuthCommunicationRecord;
            }
            listOfAuthorization.add(AuthorizationRecord);
        }
        if(!listOfAuthorization.isEmpty()){
            for(Authorization__c auth: listOfAuthorization) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Authorization__c', listOfAuthorization, 'insert', true,'NC_StaffingUserRequestTriggerHandler','createAuthorizationRecord');
            //insert decision.getRecords();
            //listOfAuthorization = decision.getRecords();
            insert listOfAuthorization;
			shareAuthorizations(listOfAuthorization);
            for(Authorization__c auth : listOfAuthorization){
                setOfIdAuth.add(auth.Id);
            }
            NC_SendBulkEmail.sendEmailForExternalAuthorization(setOfIdAuth);
            NC_BudgetManagementController.validateBudgetForAuthorizationForStaffing(listOfAuthorization);
            NC_BudgetManagementController.updateAuthorizationBudgetStaffing(listOfAuthorization);
        }
    }
    
    /*
    *********************************************************
    @Method Name    : shareAuthorizations
    @description    : Share Authorization records
    @param          : List<Authorization__c> authList
    @return         : void
    ********************************************************
    */
    public static void shareAuthorizations(List<Authorization__c> authList) {
        Map<Id, Set<Id>> requestShareMap = new Map<Id, Set<Id>>();
        List<Authorization__Share> authShareList = new List<Authorization__Share>();
        for(Authorization__c auth: authList) {
            if(auth.Trainer_Administrator_User__c != null && auth.Trainer_Administrator_User__c!=userInfo.getUserId()) {
             	Authorization__Share authShare = new Authorization__Share();
                authShare.ParentId = auth.id;
                authShare.UserOrGroupId = auth.Trainer_Administrator_User__c;
                authShare.AccessLevel = 'Edit';
                authShare.RowCause = Schema.Authorization__Share.RowCause.Manual;
                authShareList.add(authShare);
                if(requestShareMap.containsKey(auth.Trainer_Administrator_User__c)) {
                    requestShareMap.get(auth.Trainer_Administrator_User__c).add(auth.Request__c);
                } else {
                    requestShareMap.put(auth.Trainer_Administrator_User__c, new Set<Id>{auth.Request__c});
                }
            }
        }
        if(authShareList.size() > 0) {
            //insert authShareList;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Authorization__Share', authShareList, 'insert', true,'NC_StaffingUserRequestTriggerHandler','shareAuthorizations');
            insert decision.getRecords();
        }
        List<CaseShare> caseShareList = new List<CaseShare>();
        for(Id userId: requestShareMap.keySet()) {
            for(Id requestId: requestShareMap.get(userId)) {
                if(requestId != null) {
                 	CaseShare caseShareObj = new CaseShare();
                    caseShareObj.CaseAccessLevel = 'Edit';
                    caseShareObj.CaseId = requestId;
                    caseShareObj.RowCause = Schema.CaseShare.RowCause.Manual;
                    caseShareObj.UserOrGroupId = userId;
                    caseShareList.add(caseShareObj);   
                }
            }
        }
        if(caseShareList.size() > 0) {
            //insert caseShareList;
            SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('CaseShare', caseShareList, 'insert', true,'NC_StaffingUserRequestTriggerHandler','shareAuthorizations');
            insert decision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : fireApprovalProcess
    @description    : Submit approval for records
    @param          : List<Staffing_User_Request__c> newList
    @return         : void
    ********************************************************
    */
    private static void fireApprovalProcess(List<Staffing_User_Request__c> newList){
        Map<Id,Id> staffingUserRequestToStaffingRequestId = new Map<Id, Id>();
        Map<Id,Staffing_Request__c> staffingRequestToStaffRequestMap = new Map<Id,Staffing_Request__c>();
        Map<Id,Id> staffingUserRequestToAccountId = new Map<Id,Id>();
        Map<Id,Id> accountIdToUserId = new Map<Id,Id>();
        Map<Id, Staffing_User_Request__c> updateStaffRequestMap = new Map<Id,Staffing_User_Request__c>();
        Id internalStaffRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', 'Internal_Staff');
      /*List<Group> interStaffAppproverQueueList = [select Id 
                                          from Group 
                                          where developerName = 'Internal_Staff_Vendor_Request_Approver' 
                                          and Type = 'Queue'];*/
        for(Staffing_User_Request__c staffingUser : newList){
            if(staffingUser.Staffing_Request__c != NULL){
               staffingUserRequestToStaffingRequestId.put(staffingUser.Id,staffingUser.Staffing_Request__c);
            }
            if(staffingUser.Staffing_Request__c != NULL && staffingUser.Account__c != NULL){
               staffingUserRequestToAccountId.put(staffingUser.Id,staffingUser.Account__c);
            }
        }
       
        if(staffingUserRequestToStaffingRequestId.values().size() > 0){
            for(Staffing_Request__c staffRequest : [SELECT Id, RecordTypeId, OwnerId, Vendor_Type__c FROM Staffing_Request__c WHERE Id IN: staffingUserRequestToStaffingRequestId.values() WITH SECURITY_ENFORCED]){
                staffingRequestToStaffRequestMap.put(staffRequest.Id,staffRequest);
            }
        }
        
        if(staffingUserRequestToAccountId.values().size() > 0){
            for(User user : [Select id,Contact.Account.Id from user Where Contact.Account.Id IN: staffingUserRequestToAccountId.values() AND Contact.Account.IsCustomerPortal = True]){
                accountIdToUserId.put(user.Contact.Account.Id, user.Id);
            }
        }

        List<Group> groupList = [select id, name, DeveloperName from Group WHERE Type = 'Queue' AND DeveloperName = 'NDBEDP_Program_Coordinator' LIMIT 1];

        Map<Id,String> staffingUserToVendorTypeMap = new Map<Id,String>();
        Map<Id,Id> staffingUserToWorkItemIdMap = new Map<Id,Id>();
        Map<String, String> staffUserRequestParentMap = new Map<String, String>();
        Set<Id> staffingUserRequestIdSet = new Set<Id>();
        List<Staffing_User_Request__c> StaffingUserList = new List<Staffing_User_Request__c>();
        for(Staffing_User_Request__c staffingUser : newList){
            
            if(staffingUser.Staffing_Request__c != NULL){
                //staffingUserToVendorTypeMap.put(staffingUser.id, staffingUser.Vendor_Type__c);
                Staffing_User_Request__c updateStaffRequest = new Staffing_User_Request__c();
                updateStaffRequest.id = staffingUser.id;
                updateStaffRequest.Approval_Internal_URL__c = 'https:// '+ System.URL.getSalesforceBaseUrl().getHost() + '/'+ updateStaffRequest.id; 
                if(staffingRequestToStaffRequestMap.get(staffingUserRequestToStaffingRequestId.get(staffingUser.Id)).recordTypeId == internalStaffRecordTypeId){
                    Approval.ProcessSubmitRequest singleApporvalProcess = new Approval.ProcessSubmitRequest();
                    singleApporvalProcess.setComments('You Are Invited.');
                   // staffingUser.Training_Vendor_Approver__c =staffingUser.User__c;
                    if(staffingUser.User__c!=null){
                       singleApporvalProcess.setNextApproverIds(new Id[] {staffingUser.User__c});
                    }
                    else{
                      singleApporvalProcess.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                    }
                    singleApporvalProcess.setObjectId(staffingUser.Id);
                   
                    Approval.ProcessResult result = Approval.process(singleApporvalProcess);
                }else{
                    if(accountIdToUserId.containsKey(staffingUser.Account__c)){
                        Approval.ProcessSubmitRequest singleApporvalProcess = new Approval.ProcessSubmitRequest();
                        singleApporvalProcess.setComments('You Are Invited.');
                      //  staffingUser.Training_Vendor_Approver__c =accountIdToUserId.get(staffingUser.Account__c);
                        singleApporvalProcess.setNextApproverIds(new Id[] {accountIdToUserId.get(staffingUser.Account__c)});
                        singleApporvalProcess.setObjectId(staffingUser.Id);
                        Approval.ProcessResult result = Approval.process(singleApporvalProcess);
                        staffingUserRequestIdSet.add(staffingUser.Id);
                        updateStaffRequest.id = staffingUser.id;
                        updateStaffRequest.Trainer_Administrator_User__c = accountIdToUserId.get(staffingUser.Account__c);
                        staffUserRequestParentMap.put(updateStaffRequest.id, staffingUser.Staffing_Request__c);
                    }else if(!groupList.isEmpty() && staffingRequestToStaffRequestMap.get(staffingUserRequestToStaffingRequestId.get(staffingUser.Id)).Vendor_Type__c == 'NDBEDP Training'){
                        Approval.ProcessSubmitRequest singleApporvalProcess = new Approval.ProcessSubmitRequest();
                        singleApporvalProcess.setComments('You Are Invited.');
                        singleApporvalProcess.setNextApproverIds(new Id[] {groupList[0].Id});
                      //  staffingUser.Training_Vendor_Approver__c =groupList[0].Id;
                        singleApporvalProcess.setObjectId(staffingUser.Id);
                        Approval.ProcessResult result = Approval.process(singleApporvalProcess);
                        //staffingUserRequestIdSet.add(staffingUser.Id);
                    }else{
                        Approval.ProcessSubmitRequest singleApporvalProcess = new Approval.ProcessSubmitRequest();
                        singleApporvalProcess.setComments('You Are Invited.');
                      // singleApporvalProcess.setNextApproverIds(new Id[] {interStaffAppproverQueueList[0].Id});
                       // staffingUser.Training_Vendor_Approver__c =staffingRequestToStaffRequestMap.get(staffingUser.Staffing_Request__c).OwnerID;
                       singleApporvalProcess.setNextApproverIds(new Id[] {staffingRequestToStaffRequestMap.get(staffingUser.Staffing_Request__c).OwnerID});
                        singleApporvalProcess.setObjectId(staffingUser.Id);
                        Approval.ProcessResult result = Approval.process(singleApporvalProcess);
                    }
                }
				if(updateStaffRequest.id != null) {
                    updateStaffRequestMap.put(updateStaffRequest.id, updateStaffRequest);
                }                
            }        
        } 
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        for(ProcessInstanceWorkitem processItem :  [SELECT id,processInstance.TargetObjectId  FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId IN: staffingUserRequestIdSet]){
            Staffing_User_Request__c staff = new Staffing_User_Request__c();
            staff.Id = processItem.processInstance.TargetObjectId;
            if(accountIdToUserId.get(staffingUserRequestToAccountId.get(staff.Id))==null){
                staff.Training_Vendor_Approver__c = groupList[0].Id;
                staff.Approval_Internal_URL__c = 'https:// '+ System.URL.getSalesforceBaseUrl().getHost() ; 
            }
            else{
                staff.Training_Vendor_Approver__c = accountIdToUserId.get(staffingUserRequestToAccountId.get(staff.Id));
                staff.Approval_Internal_URL__c = 'https:// '+domains[0].Domain; 
            }
            // staff.Approval_Internal_URL__c = 'https:// '+ System.URL.getSalesforceBaseUrl().getHost() ;   
            StaffingUserList.add(staff);
        }
        
        if(StaffingUserList.size() > 0) {
            for(Staffing_User_Request__c staffReq: StaffingUserList) {
                if(updateStaffRequestMap.containsKey(staffReq.id)) {
                    staffReq.Trainer_Administrator_User__c = updateStaffRequestMap.get(staffReq.id).Trainer_Administrator_User__c;
                    updateStaffRequestMap.remove(staffReq.id);
                }
            }
        }
        for(Id staffReqKey: updateStaffRequestMap.keySet()) {
            StaffingUserList.add(updateStaffRequestMap.get(staffReqKey));
        }
        
        if(!StaffingUserList.isEmpty()){
            for(Staffing_User_Request__c staffReq: StaffingUserList) {
                staffReq.Allow_Update__c = true;
                staffReq.Booked_Validation__c= true;
            }
            update StaffingUserList;
            shareStaffingRequests(StaffingUserList, staffUserRequestParentMap);
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Staffing_User_Request__c', StaffingUserList, 'update', true,'NC_StaffingUserRequestTriggerHandler','fireApprovalProcess');
            //update decision.getRecords();
        }
    }
    
    /*
    *********************************************************
    @Method Name    : shareStaffingRequests
    @description    : Share Staffing User Requests
    @param          : List<Staffing_User_Request__c> staffingUserList, Map<String, String> staffUserRequestParentMap
    @return         : void
    ********************************************************
    */
    public static void shareStaffingRequests(List<Staffing_User_Request__c> staffingUserList, Map<String, String> staffUserRequestParentMap) {
        List<Staffing_Request__Share> staffShareList = new List<Staffing_Request__Share>();
        for(Staffing_User_Request__c staffRequest: staffingUserList) {
            if(staffUserRequestParentMap.containsKey(staffRequest.id) && staffRequest.Trainer_Administrator_User__c != null && staffRequest.Trainer_Administrator_User__c != userInfo.getUserId()) {
                Staffing_Request__Share staffShare = new Staffing_Request__Share();
                staffShare.parentId = staffUserRequestParentMap.get(staffRequest.id);
                staffShare.UserOrGroupId = staffRequest.Trainer_Administrator_User__c;
                staffShare.AccessLevel = 'Read';
                staffShare.RowCause = Schema.Staffing_Request__Share.RowCause.Manual;
                staffShareList.add(staffShare);
            }
        }
        if(staffShareList.size() > 0) {
            insert staffShareList;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : validationForApprovingUserRequset
    @description    : Validation for approving staffing user request
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    private static void validationForApprovingUserRequset(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap){
        Id StaffingInternal = NC_Utility.RecordTypeUtilityMethod('Staffing_Request__c', NC_Constant.STAFFING_REQUEST_INTERNAL);
        Map<Staffing_User_Request__c,Id> staffingUserRequestToStaffingUserIdMap = new Map<Staffing_User_Request__c,Id>();
        Map<Id,Staffing_Request__c> staffingRequestIdtoStaffingRequestMap = new Map<Id,Staffing_Request__c>();
        for(Staffing_User_Request__c staffingUser : newList){
            if(oldMap != NULL 
               && (oldMap.get(staffingUser.Id).Status__c == 'Pending Staff Approval' || oldMap.get(staffingUser.Id).Status__c == 'Pending Vendor Approval')
               && staffingUser.Status__c != oldMap.get(staffingUser.Id).Status__c
               && staffingUser.Status__c != 'Rejected' && staffingUser.Status__c != 'Pending Approval'){
                   if(staffingUser.Approved_Number_of_Members__c > staffingUser.Number_of_Members_Providing__c){
                       staffingUser.addError('You can only provide members less than or equal to '+ staffingUser.Number_of_Members_Providing__c);
                   }else{
                       staffingUserRequestToStaffingUserIdMap.put(staffingUser,staffingUser.Staffing_Request__c);
                   }                
            }
        }
        if(staffingUserRequestToStaffingUserIdMap.values().size()>0){
            for(Staffing_Request__c staffingRequest : [SELECT id, Total_Members_Attending__c, Number_of_Vendors_Needed__c, 
                                                       Number_of_Interpreters_Needed__c, RecordTypeId
                                                       FROM Staffing_Request__c 
                                                       WHERE ID In: staffingUserRequestToStaffingUserIdMap.values() WITH SECURITY_ENFORCED]){
                                                           staffingRequestIdtoStaffingRequestMap.put(staffingRequest.Id,staffingRequest);
                                                       }
            
            for(Staffing_User_Request__c staffingUser : staffingUserRequestToStaffingUserIdMap.keySet()){
                if(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).RecordTypeId == StaffingInternal){
                    if(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Total_Members_Attending__c + staffingUser.Approved_Number_of_Members__c > Integer.valueOf(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Number_of_Interpreters_Needed__c)){
                        staffingUser.addError(Integer.valueOf(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Number_of_Interpreters_Needed__c) - staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Total_Members_Attending__c +' Slots only, please update the approved number of members.');
                    }
                }else{
                    if(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Total_Members_Attending__c + staffingUser.Approved_Number_of_Members__c > Integer.valueOf(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Number_of_Vendors_Needed__c)){
                        staffingUser.addError(Integer.valueOf(staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Number_of_Vendors_Needed__c) - staffingRequestIdtoStaffingRequestMap.get(staffingUser.Staffing_Request__c).Total_Members_Attending__c +' Slots only, please update the approved number of members.');
                    }
                }
            }
        }        
        
    }

    /*
    *********************************************************
    @Method Name    : vendorInProgressCheck
    @description    : Vendor in progess validation
    @param          : List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void vendorInProgressCheck(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap) {
        Set<String> surStatusSet = new Set<String>{'Vendor Approved', 'Rejected'};
        for(Staffing_User_Request__c staffUserRequest: newList) {
            if(staffUserRequest.Vendor_Status__c == 'Vendor Update In Progress' && !surStatusSet.contains(staffUserRequest.Status__c)){
                staffUserRequest.addError(NC_Constant.STAFFREQUEST_UPDATE_IN_PROGRESS);
            }
            if(staffUserRequest.Status__c != 'Vendor Update In Progress' && !staffUserRequest.Vendor_Active__c) {
                staffUserRequest.addError('It cannot be updated because the vendor is inactive');
            }
        }
    }

 /*  public static void sendEmailInvitationStaffingUserRequest(List<Staffing_User_Request__c> newList,Map<Id,Staffing_User_Request__c> oldMap) {
        List <Domain> domains = [SELECT Domain, DomainType FROM Domain WHERE DomainType = 'DNS'];
        List <Id> accountList = new List<Id>();
        Map<Id,Id> accountToContact = new Map<Id,Id>();
        Map<Id,Id> contactToUser = new Map<Id,Id>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Id trainingVendorStaffingUserRequest = NC_Utility.RecordTypeUtilityMethod('Account', 'Training_Vendor_Staffing_User_Request');
        List<EmailTemplate> emailTemplateForApprover =  [SELECT Id,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName ='NC_Staffing_user_Request_Approver_Email' ];
        for(Staffing_User_Request__c staff:newList){
            if(staff.RecordTypeId == trainingVendorStaffingUserRequest && staff.Status__c == 'Pending Approval' ){
                accountList.add(staff.Account__c);
            }
        }
        for(Account account:[SELECT Id,(SELECT Id FROM Contacts) FROM Account WHERE Id IN :accountList]){
           for(Contact con:account.Contacts){
               if(con.Id!=null && accountToContact.get(account.Id) == null){
                accountToContact.put(account.Id,con.Id);
               }
           }
        }
        for(User use:[SELECT Id,Contact.Id,Name,Email FROM User WHERE Contact.Id IN :accountToContact.values() AND IsPortalEnabled = true]){
            if(use.Email!=null && contactToUser.get(use.Contact.Id) == null){
                contactToUser.put(use.Contact.Id,use.Email);
            }
        }

        User userPresent = [SELECT Id,UserRole.Name,Email FROM User WHERE UserRole.DeveloperName = 'NDBEDP_Coordinator' LIMIT 1];
        String plainBody = emailTemplateForApprover[0].Body;
        String htmlBody = emailTemplateForApprover[0].HtmlValue;
        List<String>emailList = new List<String>();
        for(Staffing_User_Request__c staff:newList){
            if(staff.RecordTypeId == trainingVendorStaffingUserRequest && staff.Status__c == 'Pending Approval'){
                String URLValue= 'https://'+domains[0].Domain;
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+staff.Id;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if(contactToUser.get((accountToContact.get(staff.Account__c)))==null){
                    emailList.add(userPresent.Email);
                    plainBody = plainBody.replace('{{Request}}',URLValue );
                    htmlBody = htmlBody.replace('{{Request}}',URLValue); 
                }
                else{
                    emailList.add(contactToUser.get(accountToContact.get(staff.Account__c)));
                    plainBody = plainBody.replace('{{Request}}',baseUrl );
                    htmlBody = htmlBody.replace('{{Request}}',baseUrl); 
                }

                message.setHtmlBody(htmlBody);
                message.setPlainTextBody(plainBody);   
                message.setTemplateID(emailTemplateForApprover[0].Id); 
                message.setToAddresses(emailList);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                message.setSubject('Approval Request');        
                messages.add(message);  
            }
        }
            if(messages.size()>0 && emailList.size()>0){
                try {  
             Messaging.SendEmailResult[] results1 = Messaging.sendEmail(messages);
                }catch(DmlException e) {
            }
             }
    }*/

}