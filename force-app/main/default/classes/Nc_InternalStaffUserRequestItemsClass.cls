/*
*   Class Name: NC_InvoiceLineItemStaffing
*   Description: Controller for NC_InvoiceLineItemStaffing Component
*
*   Date              New/Modified            User                 Identifier                Description
*   12/06/2020         New                   Hiten
*/
public without sharing class Nc_InternalStaffUserRequestItemsClass {

    /*
    *********************************************************
    @Method Name    : updateAllStaffItems
    @description    : Method to update the Invoice line Items
    @param          : Id recordId, String internalStaffItemList, String totalAmountBilled
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> updateAllStaffItems(Id recordId, String internalStaffItemList, String totalAmountBilled){
        Decimal totalAmount = (Decimal) JSON.deserialize(totalAmountBilled, Decimal.class);
        List<InternalStaffItemWrapper> internalStaffItemData = (List<InternalStaffItemWrapper>) JSON.deserialize(internalStaffItemList, List<InternalStaffItemWrapper>.class);
        Staffing_User_Request__c staffingUserRequest = [ SELECT Id,RecordTypeId, Breakfast__c, Lunch__c, Mileage__c, Dinner__c, Hotels__c, 
                                                         Excess_Hotel_Cost__c, Parking__c, Amount_Authorization_Type__c, Total_Amount_billed__c,
                                                         Total_Authorized_Amount__c
                                                         FROM Staffing_User_Request__c WHERE ID =: recordId WITH SECURITY_ENFORCED];
        staffingUserRequest.Total_Amount_Billed__c = totalAmount;
        for(InternalStaffItemWrapper  staffItem: internalStaffItemData){
            if(staffItem.isEditable){
                if(staffItem.fieldApiName == 'Breakfast__c'){
                     staffingUserRequest.Breakfast__c = staffItem.quantity;
                }else if(staffItem.fieldApiName == 'Lunch__c'){
                    staffingUserRequest.Lunch__c = staffItem.quantity;
                }else if(staffItem.fieldApiName == 'Mileage__c'){
                     staffingUserRequest.Mileage__c = staffItem.quantity;
                }else if(staffItem.fieldApiName == 'Dinner__c'){
                     staffingUserRequest.Dinner__c = staffItem.quantity;
                }else if(staffItem.fieldApiName == 'Hotels__c'){
                     staffingUserRequest.Hotels__c = staffItem.quantity;
                }
            }else{
                if(staffItem.fieldApiName == 'Excess_Hotel_Cost__c'){
                    staffingUserRequest.Excess_Hotel_Cost__c = staffItem.amountBilled;
                }else if(staffItem.fieldApiName == 'Parking__c'){
                    staffingUserRequest.Parking__c = staffItem.amountBilled;
                }
            }
        }
        
       // Update staffingUserRequest;
        SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Staffing_User_Request__c', new List<Staffing_User_Request__c>{staffingUserRequest}, 'update', true, 'Nc_InternalStaffUserRequestItemsClass', 'updateAllStaffItems');
        update decision.getRecords();
        Map<String,Object> result = getAllInternalStaffItems(recordId);
        return result;
    }
    
    /*
    *********************************************************
    @Method Name    : getAllInternalStaffItems
    @description    : Method to get all the child Invoice Line Items
    @param          : Id recordId
    @return         : Map<String, Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> getAllInternalStaffItems(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        Map<String,InternalStaffItemWrapper> fieldApiNameToWrapper = new Map<String,InternalStaffItemWrapper>();
        List<InternalStaffItemWrapper> iternalStaffWrapperList = new List<InternalStaffItemWrapper>();
        Map<String,String> fieldToLabelMap = NC_Constant.fieldToLabelMap;
        boolean mileageLessThanNintyNine = false;
        InternalStaffItemWrapper singleInternalStaffItemWrapper;
        Staffing_User_Request__c staffingUserRequest = [SELECT Id,RecordTypeId, Breakfast__c, Lunch__c, Mileage__c, Dinner__c, Hotels__c, 
                                                        Excess_Hotel_Cost__c, Parking__c, Amount_Authorization_Type__c, Total_Amount_billed__c
                                                        FROM Staffing_User_Request__c WHERE ID =: recordId WITH SECURITY_ENFORCED];
        if(staffingUserRequest.Mileage__c != NULL && staffingUserRequest.Mileage__c < 100){
            mileageLessThanNintyNine = true;
        }
        staffingUserRequest.Breakfast__c = staffingUserRequest.Breakfast__c != NULL ?  staffingUserRequest.Breakfast__c :  0;
        staffingUserRequest.Lunch__c = staffingUserRequest.Lunch__c != NULL ?  staffingUserRequest.Lunch__c :  0;
        staffingUserRequest.Dinner__c = staffingUserRequest.Dinner__c != NULL ?  staffingUserRequest.Dinner__c :  0;
        staffingUserRequest.Mileage__c = staffingUserRequest.Mileage__c != NULL ?  staffingUserRequest.Mileage__c :  0;
        staffingUserRequest.Hotels__c = staffingUserRequest.Hotels__c != NULL ?  staffingUserRequest.Hotels__c :  0;
        staffingUserRequest.Excess_Hotel_Cost__c = staffingUserRequest.Excess_Hotel_Cost__c != NULL ?  staffingUserRequest.Excess_Hotel_Cost__c :  0;
        staffingUserRequest.Total_Amount_billed__c = staffingUserRequest.Total_Amount_billed__c != NULL ?  staffingUserRequest.Total_Amount_billed__c :  0;
            
        Decimal totalAmountBilled = staffingUserRequest.Total_Amount_billed__c != NULL ? staffingUserRequest.Total_Amount_billed__c : 0;
        
        for(Internal_Staff_Line_Item__mdt iternalStaffLineItem :  [SELECT id, In_State_Amount_Authorized__c,   
                                                                   Out_of_State_Amount_Authorized__c, 
                                                                   field_API_Name__c, Is_Not_Editable__c,Sequence__c,
                                                                   Field_label__c, 
                                                                   DeveloperName 
                                                                   FROM Internal_Staff_Line_Item__mdt WITH SECURITY_ENFORCED Order by Sequence__c ]){
                                                                       
            if(!fieldApiNameToWrapper.containsKey(iternalStaffLineItem.field_API_Name__c)){
                singleInternalStaffItemWrapper = new InternalStaffItemWrapper();
                
                if(staffingUserRequest.Amount_Authorization_Type__c == 'In State'){
                    if(iternalStaffLineItem.DeveloperName == 'Mileage_cost_100_miles_and_over'){
                        singleInternalStaffItemWrapper.amountAuthorized = iternalStaffLineItem.In_State_Amount_Authorized__c;
                        singleInternalStaffItemWrapper.amountAuthorizedOver99Miles = iternalStaffLineItem.In_State_Amount_Authorized__c;
                    }else{ 
                        singleInternalStaffItemWrapper.amountAuthorized = iternalStaffLineItem.In_State_Amount_Authorized__c;
                        singleInternalStaffItemWrapper.amountAuthorizedOver99Miles = iternalStaffLineItem.In_State_Amount_Authorized__c;
                    }
                }else{
                    if(iternalStaffLineItem.DeveloperName == 'Mileage_cost_100_miles_and_over'){
                        singleInternalStaffItemWrapper.amountAuthorized = iternalStaffLineItem.Out_of_State_Amount_Authorized__c;
                        singleInternalStaffItemWrapper.amountAuthorizedOver99Miles = iternalStaffLineItem.Out_of_State_Amount_Authorized__c; 
                    }else{ 
                        singleInternalStaffItemWrapper.amountAuthorized = iternalStaffLineItem.Out_of_State_Amount_Authorized__c;
                        singleInternalStaffItemWrapper.amountAuthorizedOver99Miles = iternalStaffLineItem.Out_of_State_Amount_Authorized__c;
                    }
                    
                }                                                          
                singleInternalStaffItemWrapper.fieldApiName = iternalStaffLineItem.field_API_Name__c;
                singleInternalStaffItemWrapper.fieldLabel = iternalStaffLineItem.Field_label__c;
                
                
                
                if(iternalStaffLineItem.Is_Not_Editable__c){
                    singleInternalStaffItemWrapper.amountBilled = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c));
                    singleInternalStaffItemWrapper.amountBilled = singleInternalStaffItemWrapper.amountBilled != NULL ? singleInternalStaffItemWrapper.amountBilled :0;
                    singleInternalStaffItemWrapper.quantity = 1;
                    singleInternalStaffItemWrapper.isEditable = false;                                                       
                }else{
                    if(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c) != NULL){
                        if(mileageLessThanNintyNine){
                          singleInternalStaffItemWrapper.amountBilled = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c)) * singleInternalStaffItemWrapper.amountAuthorized ;
                        }else{
                          singleInternalStaffItemWrapper.amountBilled = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c)) * singleInternalStaffItemWrapper.amountAuthorizedOver99Miles ;  
                        }
                    }
                    singleInternalStaffItemWrapper.quantity = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c));
                    singleInternalStaffItemWrapper.isEditable = true;   
                }
                fieldApiNameToWrapper.put( iternalStaffLineItem.field_API_Name__c ,singleInternalStaffItemWrapper);                                                           
            }else{
                singleInternalStaffItemWrapper = fieldApiNameToWrapper.get(iternalStaffLineItem.field_API_Name__c);
                if(staffingUserRequest.Amount_Authorization_Type__c == 'In State'){
                    if(iternalStaffLineItem.DeveloperName == 'Mileage_cost_100_miles_and_over'){
                        singleInternalStaffItemWrapper.amountAuthorizedOver99Miles = iternalStaffLineItem.In_State_Amount_Authorized__c;
                    }else{ 
                        singleInternalStaffItemWrapper.amountAuthorized = iternalStaffLineItem.In_State_Amount_Authorized__c;
                    }
                }else{
                    if(iternalStaffLineItem.DeveloperName == 'Mileage_cost_100_miles_and_over'){
                        singleInternalStaffItemWrapper.amountAuthorizedOver99Miles = iternalStaffLineItem.Out_of_State_Amount_Authorized__c; 
                    }else{ 
                        singleInternalStaffItemWrapper.amountAuthorized = iternalStaffLineItem.Out_of_State_Amount_Authorized__c; 
                    }
                    
                }  
                if(iternalStaffLineItem.Is_Not_Editable__c){
                    singleInternalStaffItemWrapper.amountBilled = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c));
                    singleInternalStaffItemWrapper.amountBilled = singleInternalStaffItemWrapper.amountBilled != NULL ? singleInternalStaffItemWrapper.amountBilled :0;
                    singleInternalStaffItemWrapper.quantity = 1;
                    singleInternalStaffItemWrapper.isEditable = false;                                                       
                }else{
                    if(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c) != NULL){
                        if(mileageLessThanNintyNine){
                            singleInternalStaffItemWrapper.amountBilled = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c)) * singleInternalStaffItemWrapper.amountAuthorized ;
                        }else{
                            singleInternalStaffItemWrapper.amountBilled = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c)) * singleInternalStaffItemWrapper.amountAuthorizedOver99Miles ;  
                        }
                    }
                    singleInternalStaffItemWrapper.quantity = Integer.valueOf(staffingUserRequest.get(iternalStaffLineItem.field_API_Name__c));
                    singleInternalStaffItemWrapper.isEditable = true;   
                }
               fieldApiNameToWrapper.put( iternalStaffLineItem.field_API_Name__c ,singleInternalStaffItemWrapper); 
            }            
        }
        iternalStaffWrapperList = fieldApiNameToWrapper.values();
        result.put('mileageLessThanNintyNine',mileageLessThanNintyNine);
        result.put('iternalStaffWrapperList',iternalStaffWrapperList);
        result.put('totalAmountBilled',totalAmountBilled);
        return result; 
    }
    

   /*
    * Class Name: LineItemWrapper
    * Description: This is a Wrapper class of Invoice line Items
    */
    
    public class InternalStaffItemWrapper{
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public String fieldLabel;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal amountAuthorized;
        @AuraEnabled public Decimal amountAuthorizedOver99Miles;
        @AuraEnabled public Decimal amountBilled;
        @AuraEnabled public Boolean isEditable;
        
        public InternalStaffItemWrapper(){
            this.fieldApiName = '';
            this.fieldLabel = '';
            this.quantity = 0;
            this.amountAuthorized = 0;
            this.amountAuthorizedOver99Miles = 0;
            this.amountBilled = 0;
            this.isEditable = TRUE; 
        }       
        
    }
    
}