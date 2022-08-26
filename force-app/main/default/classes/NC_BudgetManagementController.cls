/*
**   Class Name: NC_BudgetManagementController
**   Description: Budeget Management Utility
**
**     Date            New/Modified           User                 Identifier               Description
**   06-08-2020             New             Shubham Dadhich
*/
public with sharing class NC_BudgetManagementController {

    public static Id AuthorizationWeatherRadioRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_WEATHER_RADIO);
    public static Id AuthorizationHearingAidRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_HEARING_AID);
    public static Id AuthorizationOtherRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_EDS_INVOICE);
    public static Id AuthorizationSubHearingAidRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_SUB_HEARING_AID);
    public static Id AuthorizationCommunicationrequestId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
    public static Id invoiceCommunicationId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', NC_Constant.COMMUNICATION_ACCESS_REQUEST);
    public static Id AuthorizationTrainingVendorIncoiveId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Training_Vendor');
    public static Id invoiceTrainingVendorId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Training_Vendor_Invoice');
    public static Id AuthorizationCAPTELRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', NC_Constant.AUTHORIZATION_RECORDTYPE_CAPTEL);
    public static Id AuthorizationEquipmentRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Authorization__c', 'Equipment');
        
    public static Id invoiceEquipmentRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Equipment');
    public static Id invoiceAssessmentRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Assessment');
    public static Id invoiceAssessorTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'Assessor_Training_Installation');
    public static Id invoiceAdditionalTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Additional_Training');
    public static Id invoiceNDBEDPDeliveryRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Delivey');
    public static Id invoiceNDBEDPFollowUpRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Follow_Up');
    public static Id invoiceNDBEDPPickupRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Pick_up');
    public static Id invoiceNDBEDPTrainingRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Training');
    public static Id invoiceNDBEDPTrainingEventRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Invoice__c', 'NDBEDP_Training_Event');
    public static Set<Id> ndbedpInvoiceIds = new Set<Id>{invoiceEquipmentRecordTypeId, invoiceAssessmentRecordTypeId, 
        invoiceAssessorTrainingRecordTypeId, invoiceAdditionalTrainingRecordTypeId, invoiceNDBEDPDeliveryRecordTypeId, 
        invoiceNDBEDPFollowUpRecordTypeId, invoiceNDBEDPPickupRecordTypeId, invoiceNDBEDPTrainingRecordTypeId, invoiceNDBEDPTrainingEventRecordTypeId, invoiceCommunicationId};
        
    /*
    *********************************************************
    @Method Name    : validateBudgetAmount
    @description    : Validate if suffcient Budget Amount is available else update Authorization status to Hold
    @param          : Set<Id> setOfAuthorizationId
    @return         : void
    ********************************************************
    */
    public static void validateBudgetAmount(Set<Id> setOfAuthorizationId){
        Map<Id, Budget_Management__c> mapOfBudgetManagement = new Map<Id, Budget_Management__c>();
        List<Authorization__c> listOfAuthorization = new List<Authorization__c>();
        List<Authorization__c> listOfAuthorizationUpdated = new List<Authorization__c>();
        for(Authorization__c authRecord : [SELECT Id, Status__c, CreatedDate,Total_Authorized_Amount__c, RecordTypeId FROM Authorization__c WHERE Id IN: setOfAuthorizationId WITH SECURITY_ENFORCED]){
            listOfAuthorization.add(authRecord);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetManagement.put(budgetManagementRecord.Id, budgetManagementRecord);
        }
        for(Authorization__c authRecord  : listOfAuthorization){
            Date authorizationDate = Date.newInstance(authRecord.CreatedDate.year(),authRecord.CreatedDate.month(), authRecord.CreatedDate.day());
            Boolean budgetRecordFound = False;
            for(Id idBudget : mapOfBudgetManagement.keySet()){
                if(mapOfBudgetManagement.get(idBudget).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(idBudget).End_Date_Fiscal_Year__c >= authorizationDate){
                    if(((authRecord.RecordTypeId == AuthorizationHearingAidRecordTypeId || authRecord.RecordTypeId == AuthorizationSubHearingAidRecordTypeId)
                         && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.HEARING_AID_BUDGET) ||
                       (authRecord.RecordTypeId == AuthorizationWeatherRadioRecordTypeId  && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET) ||
                       (authRecord.RecordTypeId == AuthorizationCAPTELRecordTypeId  && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.CAPTEL) ||
                       (authRecord.RecordTypeId == AuthorizationOtherRecordTypeId  && mapOfBudgetManagement.get(idBudget).Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && mapOfBudgetManagement.get(idBudget).Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET) ||
                       (authRecord.RecordTypeId == AuthorizationEquipmentRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.NDBEDP_BUDGET)){
                          budgetRecordFound = true;
                      }
                    if((authRecord.RecordTypeId == AuthorizationHearingAidRecordTypeId || authRecord.RecordTypeId == AuthorizationSubHearingAidRecordTypeId) && mapOfBudgetManagement.get(idBudget).Amount_Remaining__c < 1600 && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.HEARING_AID_BUDGET ){
                        authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        listOfAuthorizationUpdated.add(authRecord);
                    }
                    if(authRecord.RecordTypeId == AuthorizationWeatherRadioRecordTypeId && mapOfBudgetManagement.get(idBudget).Amount_Remaining__c < authRecord.Total_Authorized_Amount__c && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET){
                        authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        listOfAuthorizationUpdated.add(authRecord);
                    }
                    if(authRecord.RecordTypeId == AuthorizationOtherRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && mapOfBudgetManagement.get(idBudget).Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET && mapOfBudgetManagement.get(idBudget).Amount_Remaining__c < authRecord.Total_Authorized_Amount__c){
                        authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        listOfAuthorizationUpdated.add(authRecord);
                    }
                    
                    if(authRecord.RecordTypeId == AuthorizationCAPTELRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.CAPTEL && mapOfBudgetManagement.get(idBudget).Amount_Remaining__c < authRecord.Total_Authorized_Amount__c){
                        authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        listOfAuthorizationUpdated.add(authRecord);
                    }
                    
                }
            }
            if(budgetRecordFound == False){
                authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                listOfAuthorizationUpdated.add(authRecord);
            }
        }
        if(!listOfAuthorizationUpdated.isEmpty()){
            for(Authorization__c auth: listOfAuthorizationUpdated) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', listOfAuthorizationUpdated, 'update', true,'NC_BudgetManagementController','validateBudgetAmount');
            update objectDecision.getRecords();
        }
    
    }

    /*
    *********************************************************
    @Method Name    : updateBudgetAmount
    @description    : Deduct Budget Amount and link budget to Authorization
    @param          : Set<Id> setOfAuthorizationId
    @return         : void
    ********************************************************
    */
    public static void updateBudgetAmount(Set<Id> setOfAuthorizationId){
        Map<Id, Budget_Management__c> mapOfBudgetManagement = new Map<Id, Budget_Management__c>();
        List<Budget_Management__c> listOfBudgetManagementToUpdate = new List<Budget_Management__c>();
        Map<Id, Decimal> maofRemaingAmountBudget = new Map<Id, Decimal>();

        List<Authorization__c> listOfAuthorization = new List<Authorization__c>();
        for(Authorization__c authRecord : [SELECT Id, Status__c, CreatedDate, Total_Authorized_Amount__c, RecordTypeId FROM Authorization__c WHERE Id IN: setOfAuthorizationId WITH SECURITY_ENFORCED]){
            listOfAuthorization.add(authRecord);
        }

        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Amount_Utilized__c, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c,OwnerId FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetManagement.put(budgetManagementRecord.Id, budgetManagementRecord);
            maofRemaingAmountBudget.put(budgetManagementRecord.Id, budgetManagementRecord.Amount_Remaining__c);
        }

        for(Authorization__c authRecord  : listOfAuthorization){
            if(authRecord.Status__c == NC_Constant.APPROVED){
                Date authorizationDate = Date.newInstance(authRecord.CreatedDate.year(),authRecord.CreatedDate.month(), authRecord.CreatedDate.day());
                for(Id idBudget : mapOfBudgetManagement.keySet()){
                    if(mapOfBudgetManagement.get(idBudget).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(idBudget).End_Date_Fiscal_Year__c >= authorizationDate){
                        if((authRecord.RecordTypeId == AuthorizationHearingAidRecordTypeId || authRecord.RecordTypeId == AuthorizationSubHearingAidRecordTypeId)&& mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.HEARING_AID_BUDGET ){
                            if(maofRemaingAmountBudget.get(idBudget) - 1600 > 0){
                                mapOfBudgetManagement.get(idBudget).Amount_Utilized__c += 1600;
                                listOfBudgetManagementToUpdate.add(mapOfBudgetManagement.get(idBudget));
                                authRecord.Budget_Management__c = idBudget;
                                maofRemaingAmountBudget.put(idBudget, maofRemaingAmountBudget.get(idBudget)-1600);
                            }else{
                                authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                            }
                        }
                        if(authRecord.RecordTypeId == AuthorizationWeatherRadioRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET ){
                            if(maofRemaingAmountBudget.get(idBudget) - authRecord.Total_Authorized_Amount__c > 0){
                                mapOfBudgetManagement.get(idBudget).Amount_Utilized__c += authRecord.Total_Authorized_Amount__c;
                                listOfBudgetManagementToUpdate.add(mapOfBudgetManagement.get(idBudget));
                                authRecord.Budget_Management__c = idBudget;
                                maofRemaingAmountBudget.put(idBudget, maofRemaingAmountBudget.get(idBudget)-authRecord.Total_Authorized_Amount__c);
                            }else{
                                authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                            } 
                        }
                        if(authRecord.RecordTypeId == AuthorizationCAPTELRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.CAPTEL){
                            if(maofRemaingAmountBudget.get(idBudget) - authRecord.Total_Authorized_Amount__c > 0){
                                mapOfBudgetManagement.get(idBudget).Amount_Utilized__c += authRecord.Total_Authorized_Amount__c;
                                listOfBudgetManagementToUpdate.add(mapOfBudgetManagement.get(idBudget));
                                authRecord.Budget_Management__c = idBudget;
                                maofRemaingAmountBudget.put(idBudget, maofRemaingAmountBudget.get(idBudget)-authRecord.Total_Authorized_Amount__c);
                            } else {
                                authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                            }
                        }
                        if(authRecord.RecordTypeId == AuthorizationOtherRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && mapOfBudgetManagement.get(idBudget).Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET ){
                            
                            if(authRecord.RecordTypeId == AuthorizationCAPTELRecordTypeId && mapOfBudgetManagement.get(idBudget).Budget_Type__c == NC_Constant.CAPTEL){
                                if(maofRemaingAmountBudget.get(idBudget) - authRecord.Total_Authorized_Amount__c > 0){
                                    mapOfBudgetManagement.get(idBudget).Amount_Utilized__c += authRecord.Total_Authorized_Amount__c;
                                    listOfBudgetManagementToUpdate.add(mapOfBudgetManagement.get(idBudget));
                                    authRecord.Budget_Management__c = idBudget;
                                    maofRemaingAmountBudget.put(idBudget, maofRemaingAmountBudget.get(idBudget)-authRecord.Total_Authorized_Amount__c);
                                } else {
                                    authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                                }
                            } else {
                                if(maofRemaingAmountBudget.get(idBudget) - authRecord.Total_Authorized_Amount__c > 0){
                                    mapOfBudgetManagement.get(idBudget).Amount_Utilized__c += authRecord.Total_Authorized_Amount__c;
                                    listOfBudgetManagementToUpdate.add(mapOfBudgetManagement.get(idBudget));
                                    authRecord.Budget_Management__c = idBudget;
                                    maofRemaingAmountBudget.put(idBudget, maofRemaingAmountBudget.get(idBudget)-authRecord.Total_Authorized_Amount__c);
                                }else{
                                    authRecord.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        UPDATE mapOfBudgetManagement.values();
        for(Authorization__c auth: listOfAuthorization) {
            auth.Update_If_Vendor_Inactive__c = true;
        }
        SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', listOfAuthorization, 'update', true,'NC_BudgetManagementController','updateBudgetAmount');
        update objectDecision.getRecords();
     }

    /*
    *********************************************************
    @Method Name    : validateBudgetForInvoice
    @description    : Validate budget amount and update Invoice status to hold if insufficient budget
    @param          : List<invoice__c> listOfInvoice, Map<id, Invoice__c> newMap
    @return         : void
    ********************************************************
    */
    public static void validateBudgetForInvoice(List<invoice__c> listOfInvoice, Map<id, Invoice__c> newMap){
        Map<Id, Invoice__c> mapOfinvoiceWithAuth = new Map<Id, Invoice__c>();
        Map<Id, Boolean> budgetRecordFoundMap = new Map<Id, Boolean>();
        
        for(Invoice__c invoicerecord : [SELECT Id, Authorization__r.CreatedDate,Authorization__r.Total_Authorized_Amount__c, Payment_Date__c, Authorization__r.RecordTypeId, Total_Amount_Billed__c FROM Invoice__c WHERE Id IN:listOfInvoice WITH SECURITY_ENFORCED]){
            if(newMap.containsKey(invoicerecord.id)) {
                invoicerecord.Payment_Date__c = newMap.get(invoicerecord.id).Payment_Date__c;
            }
            mapOfinvoiceWithAuth.put(invoicerecord.Id, invoicerecord);
            budgetRecordFoundMap.put(invoicerecord.Id,False);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment WITH SECURITY_ENFORCED]){
            for(Id invoiceId : mapOfinvoiceWithAuth.keySet()){
                if(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c != null){
                    Date invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.year(),mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.month(), mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.day());
                    if(budgetManagementRecord.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagementRecord.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                        budgetRecordFoundMap.put(invoiceId, True);
                        if((mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationHearingAidRecordTypeId || mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationSubHearingAidRecordTypeId) && budgetManagementRecord.Amount_Remaining__c < mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == NC_Constant.HEARING_AID_BUDGET){
                            newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                        if(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationWeatherRadioRecordTypeId && budgetManagementRecord.Amount_Remaining__c < mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET){
                            newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                        if(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationCAPTELRecordTypeId && budgetManagementRecord.Amount_Remaining__c < mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == NC_Constant.CAPTEL){
                            newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                        if(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationOtherRecordTypeId && budgetManagementRecord.Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && budgetManagementRecord.Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET && budgetManagementRecord.Amount_Remaining__c < mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c){
                            newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                    }
                }
            }
        }
        for(Id invoiceId : budgetRecordFoundMap.keySet()){
            if(budgetRecordFoundMap.get(invoiceId) == FALSE){
                newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updteBudgetFromInvoice
    @description    : Update Budget Amount for invoice and create task
    @param          : List<invoice__c> listOfInvoice, Map<id, Invoice__c> newMap
    @return         : void
    ********************************************************
    */
    public static void updteBudgetFromInvoice(List<invoice__c> listOfInvoice){
        Map<Id, Invoice__c> mapOfinvoiceWithAuth = new Map<Id, Invoice__c>();
        List<Budget_Management__c> listOfBudgetToBeUpdate = new List<Budget_Management__c>();
        Map<Id, Budget_Management__c> mapOfBudgetManagement = new Map<Id, Budget_Management__c>();
        List<Task> listOfTaskToCreate = new List<Task>();

        for(Invoice__c invoicerecord : [SELECT Id, Authorization__r.Total_Authorized_Amount__c, Status__c, Authorization__r.CreatedDate, Payment_Date__c, Authorization__r.RecordTypeId, Total_Amount_Billed__c FROM Invoice__c WHERE Id IN:listOfInvoice AND Status__c !=: NC_Constant.INVOICE_STATUS_HOLD WITH SECURITY_ENFORCED]){
            mapOfinvoiceWithAuth.put(invoicerecord.Id, invoicerecord);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Amount_Utilized__c, OwnerId, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment WITH SECURITY_ENFORCED ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetManagement.put(budgetManagementRecord.Id, budgetManagementRecord);
        }
        for(Id invoiceId : mapOfinvoiceWithAuth.keySet()){
            if(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c !=  null && mapOfinvoiceWithAuth.get(invoiceId).Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                Date authorizationDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.CreatedDate.year(),mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.CreatedDate.month(), mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.CreatedDate.day());
                Date invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.year(),mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.month(), mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.day());
                Boolean invoicePaid = false;
                for(Id budgetId : mapOfBudgetManagement.keySet()){
                    if((mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationHearingAidRecordTypeId || mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationSubHearingAidRecordTypeId) && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.HEARING_AID_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - 1600) + mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= 1600;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }
                    if(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationWeatherRadioRecordTypeId  && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.Total_Authorized_Amount__c) + mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.Total_Authorized_Amount__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }
                    if(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationCAPTELRecordTypeId && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.CAPTEL){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.Total_Authorized_Amount__c) + mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.Total_Authorized_Amount__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }
                    if(mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.RecordTypeId == AuthorizationOtherRecordTypeId && mapOfBudgetManagement.get(budgetId).Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && mapOfBudgetManagement.get(budgetId).Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.Total_Authorized_Amount__c) + mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= mapOfinvoiceWithAuth.get(invoiceId).Authorization__r.Total_Authorized_Amount__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }
                }
            }
            
        }
        if(!listOfBudgetToBeUpdate.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetToBeUpdate, 'update', true,'NC_BudgetManagementController','updteBudgetFromInvoice');
            update objectDecision.getRecords();
            UPDATE mapOfinvoiceWithAuth.values();
        }

        if(!listOfTaskToCreate.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Task', listOfTaskToCreate, 'insert', true,'NC_BudgetManagementController','updteBudgetFromInvoice');
            insert objectDecision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : cancelAuthorizationToUpdateBudget
    @description    : Canceld Authorization To Update Budget
    @param          : List<Authorization__c> listOfAuthorization
    @return         : void
    ********************************************************
    */
    public static void cancelAuthorizationToUpdateBudget(List<Authorization__c> listOfAuthorization){
        List<Budget_Management__c> listOfBudgetToBeUpdate = new List<Budget_Management__c>();
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Amount_Utilized__c, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment ORDER BY Start_Date_Fiscal_Year__c DESC]){
            for(Authorization__c authRecord : listOfAuthorization){
                Date authorizationDate =  Date.newInstance(authRecord.CreatedDate.year(),authRecord.CreatedDate.month(), authRecord.CreatedDate.day());
                if(budgetManagementRecord.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagementRecord.End_Date_Fiscal_Year__c >= authorizationDate){
                    if((authRecord.RecordTypeId == AuthorizationHearingAidRecordTypeId || authRecord.RecordTypeId == AuthorizationSubHearingAidRecordTypeId) && budgetManagementRecord.Budget_Type__c == NC_Constant.HEARING_AID_BUDGET){
                        budgetManagementRecord.Amount_Utilized__c  = (budgetManagementRecord.Amount_Utilized__c - 1600);
                        listOfBudgetToBeUpdate.add(budgetManagementRecord);
                    }
                    if(authRecord.RecordTypeId == AuthorizationWeatherRadioRecordTypeId  && budgetManagementRecord.Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET){
                        budgetManagementRecord.Amount_Utilized__c  = (budgetManagementRecord.Amount_Utilized__c - authRecord.Total_Authorized_Amount__c);
                        listOfBudgetToBeUpdate.add(budgetManagementRecord);
                    }
                    if(authRecord.RecordTypeId == AuthorizationOtherRecordTypeId && budgetManagementRecord.Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && budgetManagementRecord.Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET){
                        budgetManagementRecord.Amount_Utilized__c  = (budgetManagementRecord.Amount_Utilized__c - authRecord.Total_Authorized_Amount__c);
                        listOfBudgetToBeUpdate.add(budgetManagementRecord);
                    }
                }
            }
        }
        if(!listOfBudgetToBeUpdate.isEmpty()){
            //SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetToBeUpdate, 'update', true,'NC_BudgetManagementController','cancelAuthorizationToUpdateBudget');
            update listOfBudgetToBeUpdate;
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAllHoldAuthorizationsAndInvoice
    @description    : Update all hold Authorization and Invoice to Paid and adjust amount in Budget Management
    @param          : String jsonList
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void updateAllHoldAuthorizationsAndInvoice(String jsonList){
        Map<Id, Authorization__c> mapOfAuthorization = new Map<id, Authorization__c>();
        Map<Id, Invoice__c> mapOfInvoice = new Map<id, Invoice__c>();
        List<Budget_Management__c> listOfBudgetManagementToUpdate = new List<Budget_Management__c>();
        List<Budget_Management__c> listOfBudgetManagement = new List<Budget_Management__c>();
        Map<Id, Decimal> amountRemainingBudget = new Map<Id, Decimal>();
        
        listOfBudgetManagement = (List<Budget_Management__c>)JSON.deserialize(jsonList, List<Budget_Management__c>.class);
        for(Budget_Management__c budget : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Amount_Remaining__c, Amount_Utilized__c, Budget_Type__c,OwnerId FROM Budget_Management__c WHERE Budget_Type__c IN: NC_Constant.listOfBudgetTypeForEquipment WITH SECURITY_ENFORCED ORDER BY Start_Date_Fiscal_Year__c DESC]){
            amountRemainingBudget.put(budget.Id, budget.Amount_Remaining__c);
            listOfBudgetManagementToUpdate.add(budget);
        }
        // Authorization
        for(Authorization__c authRecord : [SELECT Id, CreatedDate, RecordTypeId, Total_Authorized_Amount__c, Status__c FROM Authorization__c WHERE Status__c =: NC_Constant.AUTHORIZATION_STATUS_HOLD AND RecordTypeId !=: AuthorizationCommunicationrequestId WITH SECURITY_ENFORCED]){
            mapOfAuthorization.put(authRecord.Id, authRecord);
        }

        for(Budget_Management__c budgetManagement : listOfBudgetManagementToUpdate){
            for(Id idAuth : mapOfAuthorization.keySet()){
                Date authorizationDate =  Date.newInstance(mapOfAuthorization.get(idAuth).CreatedDate.year(),mapOfAuthorization.get(idAuth).CreatedDate.month(), mapOfAuthorization.get(idAuth).CreatedDate.day());
                if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                    if((mapOfAuthorization.get(idAuth).RecordTypeId == AuthorizationHearingAidRecordTypeId || mapOfAuthorization.get(idAuth).RecordTypeId == AuthorizationSubHearingAidRecordTypeId) && budgetManagement.Budget_Type__c == NC_Constant.HEARING_AID_BUDGET){
                        if((amountRemainingBudget.get(budgetManagement.Id) - 1600) > 0){
                            budgetManagement.Amount_Utilized__c  += 1600;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-1600);
                        }
                    }
                    if(mapOfAuthorization.get(idAuth).RecordTypeId == AuthorizationWeatherRadioRecordTypeId  && budgetManagement.Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET){
                        if((amountRemainingBudget.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c);
                        }
                        
                    }
                    if(mapOfAuthorization.get(idAuth).RecordTypeId == AuthorizationCAPTELRecordTypeId && budgetManagement.Budget_Type__c == NC_Constant.CAPTEL){
                        if((amountRemainingBudget.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c);
                        }
                    }
                    if(mapOfAuthorization.get(idAuth).RecordTypeId == AuthorizationOtherRecordTypeId && budgetManagement.Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && budgetManagement.Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET){
                        if((amountRemainingBudget.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfAuthorization.get(idAuth).Total_Authorized_Amount__c);
                        }
                    }
                }
            }
        }
        SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetManagementToUpdate, 'update', true,'NC_BudgetManagementController','updateAllHoldAuthorizationsAndInvoice');
        update objectDecision.getRecords();
        UPDATE mapOfAuthorization.values();


        // Invoices
        List<Budget_Management__c> listOfBudgetManagementToUpdateInvoice = new List<Budget_Management__c>();
        List<Task> listOfTaskToCreate = new List<Task>();
        for(Invoice__c invoice : [SELECT Id, Payment_Date__c, Authorization__r.RecordTypeId, Authorization__r.CreatedDate,Authorization__r.Total_Authorized_Amount__c, Total_Amount_Billed__c, Status__c FROM Invoice__c WHERE Status__c =: NC_Constant.INVOICE_STATUS_HOLD AND RecordTypeId !=: invoiceCommunicationId AND Authorization__c != null WITH SECURITY_ENFORCED]){
            mapOfInvoice.put(invoice.Id, invoice);
        }

        for(Id idInvoice : mapOfInvoice.keySet()){
            if(mapOfInvoice.get(idInvoice).Payment_Date__c != null && mapOfInvoice.get(idInvoice).Status__c == NC_Constant.INVOICE_STATUS_HOLD){
                Date invoiceIssueDate =  Date.newInstance(mapOfInvoice.get(idInvoice).Payment_Date__c.year(),mapOfInvoice.get(idInvoice).Payment_Date__c.month(), mapOfInvoice.get(idInvoice).Payment_Date__c.day());
                Date authorizationDate =  Date.newInstance(mapOfInvoice.get(idInvoice).Authorization__r.CreatedDate.year(),mapOfInvoice.get(idInvoice).Authorization__r.CreatedDate.month(), mapOfInvoice.get(idInvoice).Authorization__r.CreatedDate.day());
                Boolean invoicePaid = false;
                for(Budget_Management__c budgetManagement : listOfBudgetManagementToUpdate){
                    if((mapOfInvoice.get(idInvoice).Authorization__r.RecordTypeId == AuthorizationHearingAidRecordTypeId || mapOfInvoice.get(idInvoice).Authorization__r.RecordTypeId == AuthorizationSubHearingAidRecordTypeId) && budgetManagement.Budget_Type__c == NC_Constant.HEARING_AID_BUDGET){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - 1600) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                                invoicePaid = true;
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                if((amountRemainingBudget.get(budgetManagement.Id) - 1600) > 0){
                                    budgetManagement.Amount_Utilized__c  -=  1600;
                                }else{
                                    listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, 1600, 'Hearing AID Budget', budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                                }
                            }
                        }
                    }
                    if(mapOfInvoice.get(idInvoice).Authorization__r.RecordTypeId == AuthorizationWeatherRadioRecordTypeId  && budgetManagement.Budget_Type__c == NC_Constant.WEATHER_RADIO_BUDGET){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                                invoicePaid = true;
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c) > 0){
                                    budgetManagement.Amount_Utilized__c  -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c;
                                }else{
                                    listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c, 'Weather Radio Budget', budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                                }
                            }
                        }
                    }
                    if(mapOfInvoice.get(idInvoice).Authorization__r.RecordTypeId == AuthorizationCAPTELRecordTypeId  && budgetManagement.Budget_Type__c == NC_Constant.CAPTEL){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                                invoicePaid = true;
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c) > 0){
                                    budgetManagement.Amount_Utilized__c  -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c;
                                }else{
                                    listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c, 'CAPTEL Budget', budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                                }
                            }
                        }
                    }
                    if(mapOfInvoice.get(idInvoice).Authorization__r.RecordTypeId == AuthorizationOtherRecordTypeId && budgetManagement.Budget_Type__c != NC_Constant.HEARING_AID_BUDGET && budgetManagement.Budget_Type__c != NC_Constant.WEATHER_RADIO_BUDGET){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c) > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                amountRemainingBudget.put(budgetManagement.Id, amountRemainingBudget.get(budgetManagement.Id)-mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                                invoicePaid = true;
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                if((amountRemainingBudget.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c) > 0){
                                    budgetManagement.Amount_Utilized__c  -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c;
                                }else{
                                    listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount__c, 'Telecommunication Budget', budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                                }
                            }
                        }
                    }
                }
            }
        }

        UPDATE mapOfInvoice.values();
        SObjectAccessDecision objectDecision6 = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetManagementToUpdate, 'update', true,'NC_BudgetManagementController','updateAllHoldAuthorizationsAndInvoice');
        update objectDecision6.getRecords();
        if(!listOfTaskToCreate.isEmpty()){
            SObjectAccessDecision objectDecision1 = SecurityLibrary.getAccessibleData('Task', listOfTaskToCreate, 'insert', true,'NC_BudgetManagementController','updateAllHoldAuthorizationsAndInvoice');
            insert objectDecision1.getRecords();
        }
    }


    /* ----------------------- Staffing Budget Management ----------------------- */ 


    /*
    *********************************************************
    @Method Name    : validateBudgetForAuthorizationForStaffing
    @description    : Validate Budget When Authorization is Paid
    @param          : List<Authorization__c> listofAuthorization
    @return         : void
    ********************************************************
    */
    public static void validateBudgetForAuthorizationForStaffing(List<Authorization__c> listofAuthorization){
        Boolean isUpdated = false;
        Map<Id,Boolean> authorizationIdToBudgetRecordFoundMap = new Map<Id,Boolean>();
        List<Authorization__c> authorizationList = new List<Authorization__c>();
        authorizationList = [SELECT Id, Budget_Management__c, Status__c, CreatedDate, Vendor_Type__c, Total_Authorized_Amount_Staffing__c FROM Authorization__c WHERE Id IN : listofAuthorization WITH SECURITY_ENFORCED];
        for(Authorization__c authorizationReocrd : authorizationList){
            authorizationIdToBudgetRecordFoundMap.put(authorizationReocrd.Id, False);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForStaffing ORDER BY Start_Date_Fiscal_Year__c DESC]){
            for(Authorization__c authorization : authorizationList){
                Date authorizationDate = Date.newInstance(authorization.CreatedDate.year(),authorization.CreatedDate.month(), authorization.CreatedDate.day());
                if(budgetManagementRecord.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagementRecord.End_Date_Fiscal_Year__c >= authorizationDate){
                    authorizationIdToBudgetRecordFoundMap.put(authorization.Id, True);
                    if(authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR && budgetManagementRecord.Amount_Remaining__c < authorization.Total_Authorized_Amount_Staffing__c && budgetManagementRecord.Budget_Type__c == 'Interpreters Budget'){
                        isUpdated = true;
                        authorization.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                    }
                    if(authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP && budgetManagementRecord.Amount_Remaining__c < authorization.Total_Authorized_Amount_Staffing__c && budgetManagementRecord.Budget_Type__c == 'SSP Budget'){
                        isUpdated = true;
                        authorization.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                    }
                    if(authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART && budgetManagementRecord.Amount_Remaining__c < authorization.Total_Authorized_Amount_Staffing__c && budgetManagementRecord.Budget_Type__c == 'CART Budget'){
                        isUpdated = true;
                        authorization.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                    }
                    if(authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_TRAINING_VENDOR && budgetManagementRecord.Amount_Remaining__c < authorization.Total_Authorized_Amount_Staffing__c && budgetManagementRecord.Budget_Type__c == 'Training Vendor Budget'){
                        isUpdated = true;
                        authorization.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                    }
                    if(authorization.Vendor_Type__c == NC_Constant.CAPTEL && budgetManagementRecord.Amount_Remaining__c < authorization.Total_Authorized_Amount_Staffing__c && budgetManagementRecord.Budget_Type__c == 'CAPTEL'){
                        isUpdated = true;
                        authorization.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                    }
                }
            }
        }
        for(Authorization__c authorization : authorizationList){
            if(authorizationIdToBudgetRecordFoundMap.get(authorization.Id) == FALSE){
                 isUpdated = true;
				 authorization.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
            }
        }
        if(isUpdated){
            for(Authorization__c auth: authorizationList) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', authorizationList, 'update', true,'NC_BudgetManagementController','validateBudgetForAuthorizationForStaffing');
            update objectDecision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAuthorizationBudgetStaffing
    @description    : Update Budget When Authorization is Paid
    @param          : List<Authorization__c> listofAuthorization
    @return         : void
    ********************************************************
    */
    public static void updateAuthorizationBudgetStaffing(List<Authorization__c> listofAuthorization){
        Boolean isUpdated = false;
        List<Budget_Management__c> listOfBudgetManagementToUpdate = new List<Budget_Management__c>();
        Map<Id, Decimal> mapOfRemainingBudgetAmount = new Map<Id, Decimal>();
        List<Authorization__c> authorizationList = new List<Authorization__c>();
        authorizationList = [SELECT Id, Budget_Management__c, Status__c, CreatedDate, Vendor_Type__c, Total_Authorized_Amount_Staffing__c FROM Authorization__c WHERE Id IN : listofAuthorization WITH SECURITY_ENFORCED];
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Start_Date_Fiscal_Year__c, Amount_Utilized__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c,OwnerId FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForStaffing ORDER BY Start_Date_Fiscal_Year__c DESC]){
            listOfBudgetManagementToUpdate.add(budgetManagementRecord);
            mapOfRemainingBudgetAmount.put(budgetManagementRecord.Id, budgetManagementRecord.Amount_Remaining__c);
        }
        for(Budget_Management__c budgetManagementRecord : listOfBudgetManagementToUpdate){
            for(Authorization__c authorization : authorizationList){
                Date authorizationDate = Date.newInstance(authorization.CreatedDate.year(),authorization.CreatedDate.month(), authorization.CreatedDate.day());
                if(budgetManagementRecord.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagementRecord.End_Date_Fiscal_Year__c >= authorizationDate){
                    if(authorization.Status__c == NC_Constant.APPROVED && authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR && budgetManagementRecord.Budget_Type__c == 'Interpreters Budget'){
                        isUpdated = true;
                        if(mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c > 0){
                            authorization.Budget_Management__c = budgetManagementRecord.Id;
                            budgetManagementRecord.Amount_Utilized__c += authorization.Total_Authorized_Amount_Staffing__c;
                            mapOfRemainingBudgetAmount.put(budgetManagementRecord.Id,mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c);
                        }else{
                            authorization.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        }
                    }
                    if(authorization.Status__c == NC_Constant.APPROVED && authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP && budgetManagementRecord.Budget_Type__c == 'SSP Budget'){
                        isUpdated = true;
                        if(mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c > 0){
                            authorization.Budget_Management__c = budgetManagementRecord.Id;
                            budgetManagementRecord.Amount_Utilized__c += authorization.Total_Authorized_Amount_Staffing__c;
                            mapOfRemainingBudgetAmount.put(budgetManagementRecord.Id,mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c);
                        }else{
                            authorization.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        }
                    }
                    if(authorization.Status__c == NC_Constant.APPROVED && authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART && budgetManagementRecord.Budget_Type__c == 'CART Budget'){
                        isUpdated = true;
                        if(mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c > 0){
                            authorization.Budget_Management__c = budgetManagementRecord.Id;
                            budgetManagementRecord.Amount_Utilized__c += authorization.Total_Authorized_Amount_Staffing__c;
                            mapOfRemainingBudgetAmount.put(budgetManagementRecord.Id,mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c);
                        }else{
                            authorization.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        }
                    }
                    if(authorization.Status__c == NC_Constant.APPROVED && authorization.Vendor_Type__c == NC_Constant.VENDOR_TYPE_TRAINING_VENDOR && budgetManagementRecord.Budget_Type__c == 'Training Vendor Budget'){
                        isUpdated = true;
                        if(mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c > 0){
                            authorization.Budget_Management__c = budgetManagementRecord.Id;
                            budgetManagementRecord.Amount_Utilized__c += authorization.Total_Authorized_Amount_Staffing__c;
                            mapOfRemainingBudgetAmount.put(budgetManagementRecord.Id,mapOfRemainingBudgetAmount.get(budgetManagementRecord.Id) - authorization.Total_Authorized_Amount_Staffing__c);
                        }else{
                            authorization.Status__c = NC_Constant.AUTHORIZATION_STATUS_HOLD;
                        }
                    }
                }
            }
        }
        if(isUpdated){
            for(Authorization__c auth: authorizationList) {
                auth.Update_If_Vendor_Inactive__c = true;
            }
            //Error in ISS
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Authorization__c', authorizationList, 'update', true,'NC_BudgetManagementController','updateAuthorizationBudgetStaffing');
            update objectDecision.getRecords();
            update listOfBudgetManagementToUpdate;
        }
    }

    /*
    *********************************************************
    @Method Name    : validateBudgetForInvoiceForStaffing
    @description    : Validate Budget When Invoice is Paid
    @param          : List<invoice__c> listOfInvoice
    @return         : void
    ********************************************************
    */
    public static void validateBudgetForInvoiceForStaffing(List<invoice__c> listOfInvoice){
        Map<Id, Invoice__c> mapOfinvoiceWithAuth = new Map<Id, Invoice__c>();
        Map<Id, Boolean> invoiceToBudgetRecordFound = new Map<Id, Boolean>();
        for(Invoice__c invoice : listOfInvoice){
            invoiceToBudgetRecordFound.put(invoice.Id,False);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c,OwnerId FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForStaffing WITH SECURITY_ENFORCED ORDER BY Start_Date_Fiscal_Year__c DESC]){
            for(Invoice__c invoice : listOfInvoice){
                if(invoice.Payment_Date__c != null){
                    Date invoiceIssueDate = Date.newInstance(invoice.Payment_Date__c.year(),invoice.Payment_Date__c.month(), invoice.Payment_Date__c.day());
                    if(budgetManagementRecord.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagementRecord.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                        invoiceToBudgetRecordFound.put(invoice.Id,True);
                        if(invoice.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR && budgetManagementRecord.Amount_Remaining__c < invoice.Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == 'Interpreters Budget'){
                            invoice.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                        if(invoice.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP && budgetManagementRecord.Amount_Remaining__c < invoice.Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == 'SSP Budget'){
                            invoice.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                        if(invoice.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART && budgetManagementRecord.Amount_Remaining__c < invoice.Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == 'CART Budget'){
                            invoice.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                        if(invoice.Vendor_Type__c == 'Training Vendor' && budgetManagementRecord.Amount_Remaining__c < invoice.Total_Amount_Billed__c && budgetManagementRecord.Budget_Type__c == 'Training Vendor Budget'){
                            invoice.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                    }
                }
            } 
        }
        for(Invoice__c invoice : listOfInvoice){
            if(invoiceToBudgetRecordFound.get(invoice.Id) == FALSE){
                invoice.Status__c = NC_Constant.INVOICE_STATUS_HOLD;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updteBudgetFromInvoiceStaffing
    @description    : Validate Budget When Invoice is Paid
    @param          : Set<Id> setOfIncvoiceId
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void updteBudgetFromInvoiceStaffing(Set<Id> setOfIncvoiceId){
        List<Budget_Management__c> listOfBudgetToBeUpdate = new List<Budget_Management__c>();
        Map<Id, Budget_Management__c> mapOfBudgetManagement = new Map<Id, Budget_Management__c>();
        List<Task> listOfTaskToCreate = new List<Task>();

        List<Invoice__c> listOfInvoice = [SELECT Id,Budget_Management__c, Authorization__r.CreatedDate, Authorization__r.Total_Authorized_Amount_Staffing__c, Authorization__c, Vendor_Type__c, Payment_Date__c, Total_Amount_Billed__c,Status__c FROM Invoice__c WHERE Id IN : setOfIncvoiceId AND Status__c !=: NC_Constant.INVOICE_STATUS_HOLD WITH SECURITY_ENFORCED ];
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Amount_Utilized__c, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c, OwnerId FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForStaffing WITH SECURITY_ENFORCED ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetManagement.put(budgetManagementRecord.Id, budgetManagementRecord);
        }

        for(Invoice__c invoice : listOfInvoice){
            if(invoice.Payment_Date__c !=  null && invoice.Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                Boolean invoicePaid = false;
                for(Id budgetId : mapOfBudgetManagement.keySet()){
                    Date invoiceIssueDate = Date.newInstance(invoice.Payment_Date__c.year(),invoice.Payment_Date__c.month(), invoice.Payment_Date__c.day());
                    Date authorizationDate = Date.newInstance(invoice.Authorization__r.CreatedDate.year(),invoice.Authorization__r.CreatedDate.month(), invoice.Authorization__r.CreatedDate.day());
                    if(invoice.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.INTERPRETERS_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - invoice.Authorization__r.Total_Authorized_Amount_Staffing__c) + invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= invoice.Authorization__r.Total_Authorized_Amount_Staffing__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }else if(invoice.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.SSP_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - invoice.Authorization__r.Total_Authorized_Amount_Staffing__c) + invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= invoice.Authorization__r.Total_Authorized_Amount_Staffing__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }else if(invoice.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.CART_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - invoice.Authorization__r.Total_Authorized_Amount_Staffing__c) + invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= invoice.Authorization__r.Total_Authorized_Amount_Staffing__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }else if(invoice.Vendor_Type__c == 'Training Vendor' && mapOfBudgetManagement.get(budgetId).Budget_Type__c == 'Training Vendor Budget'){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate && mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  = (mapOfBudgetManagement.get(budgetId).Amount_Utilized__c - invoice.Authorization__r.Total_Authorized_Amount_Staffing__c) + invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += invoice.Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            invoice.Budget_Management__c = budgetId;
                            invoicePaid = true;
                        }else if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= authorizationDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= authorizationDate){
                            if(invoicePaid){
                                mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  -= invoice.Authorization__r.Total_Authorized_Amount_Staffing__c;
                                listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            }
                        }
                    }
                }
            }
        }
        if(!listOfBudgetToBeUpdate.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetToBeUpdate, 'update', true,'NC_BudgetManagementController','updteBudgetFromInvoiceStaffing');
            update objectDecision.getRecords();
            SObjectAccessDecision objectDecision3 = SecurityLibrary.getAccessibleData('Invoice__c', listOfInvoice, 'update', true,'NC_BudgetManagementController','updteBudgetFromInvoiceStaffing');
            update objectDecision3.getRecords();
            
        }

        if(!listOfTaskToCreate.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Task', listOfTaskToCreate, 'insert', true,'NC_BudgetManagementController','updteBudgetFromInvoiceStaffing');
            insert objectDecision.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : updateAllInvoiceAndAuthStaffing
    @description    : Canceld Authorization To Update Budget
    @param          : String jsonList
    @return         : void
    ********************************************************
    */
    @future(callout=true)
    public static void  updateAllInvoiceAndAuthStaffing(String jsonList){
        Map<Id, Authorization__c> mapOfAuthorization = new Map<id, Authorization__c>();
        Map<Id, Invoice__c> mapOfInvoice = new Map<id, Invoice__c>();
        List<Budget_Management__c> listOfBudgetManagement = new List<Budget_Management__c>();
        List<Budget_Management__c> listOfBudgetManagementToUpdate = new List<Budget_Management__c>();
        listOfBudgetManagement = (List<Budget_Management__c>)JSON.deserialize(jsonList, List<Budget_Management__c>.class);
        Map<Id, Decimal> mapOfBudgetandRemainingAmount = new Map<Id, Decimal>();
        List<String> typeOfBudget = new List<String>();
        
        for(Budget_Management__c budget : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Amount_Remaining__c, Amount_Utilized__c, Budget_Type__c,OwnerId FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForStaffing WITH SECURITY_ENFORCED ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetandRemainingAmount.put(budget.Id, budget.Amount_Remaining__c);
            listOfBudgetManagementToUpdate.add(budget);
        }

        // Authorization
        for(Authorization__c authRecord : [SELECT Id, CreatedDate, RecordTypeId, Vendor_Type__c, Total_Authorized_Amount_Staffing__c, Status__c FROM Authorization__c WHERE Status__c =: NC_Constant.AUTHORIZATION_STATUS_HOLD AND (RecordTypeId =: AuthorizationCommunicationrequestId OR RecordTypeId =: AuthorizationTrainingVendorIncoiveId ) WITH SECURITY_ENFORCED]){
            mapOfAuthorization.put(authRecord.Id, authRecord);
        }
        for(Budget_Management__c budgetManagement : listOfBudgetManagementToUpdate){
            for(Id idAuth : mapOfAuthorization.keySet()){
                Date authorizationDate =  Date.newInstance(mapOfAuthorization.get(idAuth).CreatedDate.year(),mapOfAuthorization.get(idAuth).CreatedDate.month(), mapOfAuthorization.get(idAuth).CreatedDate.day());
                if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                    if(mapOfAuthorization.get(idAuth).Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR && budgetManagement.Budget_Type__c == NC_Constant.INTERPRETERS_BUDGET){
                        if((mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c);
                        }
                    }else if(mapOfAuthorization.get(idAuth).Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP  && budgetManagement.Budget_Type__c == NC_Constant.SSP_BUDGET){
                        if((mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c);
                        }
                        
                    }else if(mapOfAuthorization.get(idAuth).Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART && budgetManagement.Budget_Type__c == NC_Constant.CART_BUDGET){
                        if((mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c);
                        }
                    }else if(mapOfAuthorization.get(idAuth).Vendor_Type__c == 'Training Vendor' && budgetManagement.Budget_Type__c == 'Training Vendor Budget'){
                        if((mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c) > 0){
                            budgetManagement.Amount_Utilized__c  += mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c;
                            mapOfAuthorization.get(idAuth).Status__c = NC_Constant.APPROVED;
                            mapOfAuthorization.get(idAuth).Budget_Management__c = budgetManagement.Id;
                            mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfAuthorization.get(idAuth).Total_Authorized_Amount_Staffing__c);
                        }
                    }
                }
            }
        }
        
        UPDATE mapOfAuthorization.values();
        SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetManagementToUpdate, 'update', true,'NC_BudgetManagementController','updateAllInvoiceAndAuthStaffing');
        update objectDecision.getRecords();
        
        // Invoices
        for(Invoice__c invoice : [SELECT Id, Payment_Date__c, Authorization__r.Vendor_Type__c, Authorization__r.CreatedDate,Authorization__r.Total_Authorized_Amount_Staffing__c, Total_Amount_Billed__c, Status__c FROM Invoice__c WHERE Status__c =: NC_Constant.INVOICE_STATUS_HOLD AND (RecordTypeId =: invoiceCommunicationId OR RecordTypeId =: invoiceTrainingVendorId)  WITH SECURITY_ENFORCED]){
            mapOfInvoice.put(invoice.Id, invoice);
        }
        List<Task> listOfTaskToCreate = new List<Task>();

        for(Id idInvoice : mapOfInvoice.keySet()){
            if(mapOfInvoice.get(idInvoice).Payment_Date__c != null && mapOfInvoice.get(idInvoice).Status__c == NC_Constant.INVOICE_STATUS_HOLD){
                Date invoiceIssueDate =  Date.newInstance(mapOfInvoice.get(idInvoice).Payment_Date__c.year(),mapOfInvoice.get(idInvoice).Payment_Date__c.month(), mapOfInvoice.get(idInvoice).Payment_Date__c.day());
                Date authorizationDate =  Date.newInstance(mapOfInvoice.get(idInvoice).Authorization__r.CreatedDate.year(),mapOfInvoice.get(idInvoice).Authorization__r.CreatedDate.month(), mapOfInvoice.get(idInvoice).Authorization__r.CreatedDate.day());
                for(Budget_Management__c budgetManagement : listOfBudgetManagementToUpdate){
                    if(mapOfInvoice.get(idInvoice).Authorization__r.Vendor_Type__c == NC_Constant.VENDOR_TYPE_INTERPRETOR && budgetManagement.Budget_Type__c == NC_Constant.INTERPRETERS_BUDGET){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c > 0){
                                budgetManagement.Amount_Utilized__c -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c;
                            }else{
                                listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c, NC_Constant.INTERPRETERS_BUDGET, budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                            }
                        }
                    }
                    if(mapOfInvoice.get(idInvoice).Authorization__r.Vendor_Type__c == NC_Constant.VENDOR_TYPE_SSP && budgetManagement.Budget_Type__c == NC_Constant.SSP_BUDGET){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c > 0){
                                budgetManagement.Amount_Utilized__c  -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c;
                            }else{
                                listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c, NC_Constant.SSP_BUDGET, budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                            }
                        }
                    }
                    if(mapOfInvoice.get(idInvoice).Authorization__r.Vendor_Type__c == NC_Constant.VENDOR_TYPE_CART && budgetManagement.Budget_Type__c == NC_Constant.CART_BUDGET){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c > 0){
                                budgetManagement.Amount_Utilized__c -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c;
                            }else{
                                listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c, NC_Constant.CART_BUDGET, budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                            }
                        }
                    }if(mapOfInvoice.get(idInvoice).Authorization__r.Vendor_Type__c == 'Training Vendor' && budgetManagement.Budget_Type__c == 'Training Vendor Budget'){
                        if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate && budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  = (budgetManagement.Amount_Utilized__c - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c) + mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagement.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c > 0){
                                budgetManagement.Amount_Utilized__c  += mapOfInvoice.get(idInvoice).Total_Amount_Billed__c;
                                mapOfInvoice.get(idInvoice).Status__c = NC_Constant.INVOICE_PAID_STATUS;
                                mapOfInvoice.get(idInvoice).Budget_Management__c = budgetManagement.Id;
                                mapOfBudgetandRemainingAmount.put(budgetManagement.Id,mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Total_Amount_Billed__c);
                            }
                        }else if(budgetManagement.Start_Date_Fiscal_Year__c <= authorizationDate && budgetManagement.End_Date_Fiscal_Year__c >= authorizationDate){
                            if(mapOfBudgetandRemainingAmount.get(budgetManagement.Id) - mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c > 0){
                                budgetManagement.Amount_Utilized__c -= mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c;
                            }else{
                                listOfTaskToCreate.add(createTaskForBudget(budgetManagement.OwnerId, budgetManagement.Id, mapOfInvoice.get(idInvoice).Authorization__r.Total_Authorized_Amount_Staffing__c, 'Training Vendor Budget', budgetManagement.Start_Date_Fiscal_Year__c, budgetManagement.End_Date_Fiscal_Year__c));
                            }
                        }
                    }
                } 
            }
        }

        UPDATE mapOfInvoice.values();
        SObjectAccessDecision objectDecision5 = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetManagementToUpdate, 'update', true,'NC_BudgetManagementController','updateAllInvoiceAndAuthStaffing');
        update objectDecision5.getRecords();
        if(!listOfTaskToCreate.isEmpty()){
            SObjectAccessDecision objectDecision4 = SecurityLibrary.getAccessibleData('Task', listOfTaskToCreate, 'insert', true,'NC_BudgetManagementController','updateAllInvoiceAndAuthStaffing');
            insert objectDecision4.getRecords();
        }
    }

    /*
    *********************************************************
    @Method Name    : createTaskForBudget
    @description    : Create task if Budget Amount not able to adjust by System
    @param          : Id assignId, Id WhatId, Decimal Amount, String BudgetType, Date startDate, Date endDate
    @return         : Task
    ********************************************************
    */
    public static Task createTaskForBudget(Id assignId, Id WhatId, Decimal Amount, String BudgetType, Date startDate, Date endDate){
        Task taskFoBudget = new Task();
        taskFoBudget.OwnerId = assignId;
        taskFoBudget.WhatId = WhatId;
        taskFoBudget.Status = 'Open';
        taskFoBudget.Subject = 'System can not adjust the Budget Amount for the previous year Authorization.';
        taskFoBudget.Description = 'System is not able to adjust amount(' + Amount +') on the '+BudgetType+' for year ' + startDate + ' - ' + endDate + 'Please update your budget amount and adjust it manually.';
        return taskFoBudget;
    }
    
    /*
    *********************************************************
    @Method Name    : validateBudgetForNDBEDPInvoice
    @description    : validate budget for NDBEDP Invoices and put hold if insufficient budget
    @param          : List<invoice__c> listOfInvoice, Map<id, Invoice__c> newMap
    @return         : void
    ********************************************************
    */
    public static void validateBudgetForNDBEDPInvoice(List<invoice__c> listOfInvoice, Map<id, Invoice__c> newMap){
        Map<Id, Invoice__c> mapOfinvoiceWithAuth = new Map<Id, Invoice__c>();
        Map<Id, Boolean> budgetRecordFoundMap = new Map<Id, Boolean>();
        
        for(Invoice__c invoicerecord : [SELECT Id, lastModifiedDate,RecordTypeId, Authorization__r.CreatedDate,Authorization__r.Total_Authorized_Amount__c, Payment_Date__c, Authorization__r.RecordTypeId, Total_Amount_Billed__c, Total_Amount_to_Pay_NDBEDP__c FROM Invoice__c WHERE Id IN:listOfInvoice]){
            mapOfinvoiceWithAuth.put(invoicerecord.Id, invoicerecord);
            budgetRecordFoundMap.put(invoicerecord.Id,False);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment WITH SECURITY_ENFORCED]){
            for(Id invoiceId : mapOfinvoiceWithAuth.keySet()){
                if(newMap.containsKey(invoiceId)) {
                    mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c = newMap.get(invoiceId).Payment_Date__c;
                }
                Date invoiceIssueDate;
                //if(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c != null){
                    if(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c != null){
                        invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.year(),mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.month(), mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.day());
                    } else {
                        invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.year(),mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.month(), mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.day());
                    }
                    //Date invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.year(),mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.month(), mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.day());
                    if(budgetManagementRecord.Start_Date_Fiscal_Year__c <= invoiceIssueDate && budgetManagementRecord.End_Date_Fiscal_Year__c >= invoiceIssueDate){
                        budgetRecordFoundMap.put(invoiceId, True);
                        if(mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId == invoiceEquipmentRecordTypeId && budgetManagementRecord.Budget_Type__c == NC_Constant.NDBEDP_BUDGET){ //&& budgetManagementRecord.Amount_Remaining__c < mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c
                            //newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        } else if(ndbedpInvoiceIds.contains(mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId) && budgetManagementRecord.Budget_Type__c == NC_Constant.NDBEDP_BUDGET){ //&& budgetManagementRecord.Amount_Remaining__c < mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_to_Pay_NDBEDP__c
                            //newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
                        }
                    }
                //}
            }
        }
        for(Id invoiceId : budgetRecordFoundMap.keySet()){
            if(budgetRecordFoundMap.get(invoiceId) == FALSE){
                newMap.get(invoiceId).Status__c = NC_Constant.INVOICE_STATUS_HOLD;
            }
        }
    }

    /*
    *********************************************************
    @Method Name    : updteBudgetFormNDBEDPInvoice
    @description    : Update budget for NDBEDP Invoices and put hold if insufficient budget
    @param          : Set<Id> invoiceIds
    @return         : void
    ********************************************************
    */
    public static void updteBudgetFormNDBEDPInvoice(Set<Id> invoiceIds){
        Map<Id, Invoice__c> mapOfinvoiceWithAuth = new Map<Id, Invoice__c>();
        List<Budget_Management__c> listOfBudgetToBeUpdate = new List<Budget_Management__c>();
        Map<Id, Budget_Management__c> mapOfBudgetManagement = new Map<Id, Budget_Management__c>();

        for(Invoice__c invoicerecord : [SELECT Id, RecordTypeId, lastModifiedDate, Authorization__r.Total_Authorized_Amount__c, Status__c, Authorization__r.CreatedDate, Payment_Date__c, Authorization__r.RecordTypeId, Total_Amount_Billed__c, Total_Amount_to_Pay_NDBEDP__c FROM Invoice__c WHERE Id IN:invoiceIds AND Status__c !=: NC_Constant.INVOICE_STATUS_HOLD]){
            mapOfinvoiceWithAuth.put(invoicerecord.Id, invoicerecord);
        }
        for(Budget_Management__c budgetManagementRecord : [SELECT Id, Amount_Utilized__c, OwnerId, Start_Date_Fiscal_Year__c, End_Date_Fiscal_Year__c, Budget_Type__c, Amount_Remaining__c FROM Budget_Management__c WHERE Budget_Type__c IN : NC_Constant.listOfBudgetTypeForEquipment WITH SECURITY_ENFORCED ORDER BY Start_Date_Fiscal_Year__c DESC]){
            mapOfBudgetManagement.put(budgetManagementRecord.Id, budgetManagementRecord);
        }
        for(Id invoiceId : mapOfinvoiceWithAuth.keySet()){
            if(mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate !=  null && mapOfinvoiceWithAuth.get(invoiceId).Status__c != NC_Constant.INVOICE_STATUS_HOLD){
                Date invoiceIssueDate;
                if(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c != null){
                    invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.year(),mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.month(), mapOfinvoiceWithAuth.get(invoiceId).Payment_Date__c.day());
                } else {
                    invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.year(),mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.month(), mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.day());
                }
                //Date invoiceIssueDate = Date.newInstance(mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.year(),mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.month(), mapOfinvoiceWithAuth.get(invoiceId).lastModifiedDate.day());
                Boolean invoicePaid = false;
                for(Id budgetId : mapOfBudgetManagement.keySet()){
                    if(invoiceEquipmentRecordTypeId == mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.NDBEDP_BUDGET) {
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_Billed__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                        }
                    } else if(ndbedpInvoiceIds.contains(mapOfinvoiceWithAuth.get(invoiceId).RecordTypeId) && mapOfBudgetManagement.get(budgetId).Budget_Type__c == NC_Constant.NDBEDP_BUDGET){
                        if(mapOfBudgetManagement.get(budgetId).Start_Date_Fiscal_Year__c <= invoiceIssueDate && mapOfBudgetManagement.get(budgetId).End_Date_Fiscal_Year__c >= invoiceIssueDate){
                            mapOfBudgetManagement.get(budgetId).Amount_Utilized__c  += mapOfinvoiceWithAuth.get(invoiceId).Total_Amount_to_Pay_NDBEDP__c;
                            listOfBudgetToBeUpdate.add(mapOfBudgetManagement.get(budgetId));
                            mapOfinvoiceWithAuth.get(invoiceId).Budget_Management__c = budgetId;
                        }
                    }
                }
            }
            
        }
        if(!listOfBudgetToBeUpdate.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('Budget_Management__c', listOfBudgetToBeUpdate, 'update', true,'NC_BudgetManagementController','updteBudgetFromInvoice');
            update objectDecision.getRecords();
            UPDATE mapOfinvoiceWithAuth.values();
        }
    }
    
    public class budgetNotifier{
        public String UserId;
        public String BudgetId;
        public String budgetMessage;
        public String budgetURL;
        public String budgetName;

        public budgetNotifier(){
            UserId = '';
            BudgetId = '';
            budgetMessage = '';
            budgetURL = '';
            budgetName = '';
        }

    }
}