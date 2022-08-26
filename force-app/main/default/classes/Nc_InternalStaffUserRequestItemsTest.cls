/**
* @description       : Test class for Nc_InternalStaffUserRequestItems
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class Nc_InternalStaffUserRequestItemsTest {

    /*
    *********************************************************
    @Method Name    : updateAllStaffItemsTest
    @description    : Verify line item update for internal staff request
    ********************************************************
    */
    static testmethod void updateAllStaffItemsTest() {
        Account regionalCenter = TestDataUtility.createRegionalCenter(true);
        Id carTypeId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c commRequest = TestDataUtility.createCommunicationAcessRequest(true, carTypeId, 'Interpreters', regionalCenter.id);
        
        Id internalStaffTypeId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staff').getRecordTypeId();
        Staffing_Request__c staffRequest = TestDataUtility.createStaffingRequest(false, internalStaffTypeId, commRequest.id, '1');
        staffRequest.Number_of_Interpreters_Needed__c = '1';
        insert staffRequest;
        
        Id internalStaffUserTypeId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('Internal_Staffing_User_Request').getRecordTypeId();
        Staffing_User_Request__c staffUserRequest = TestDataUtility.createStaffingUserRequest(false, internalStaffUserTypeId, staffRequest.id);
        staffUserRequest.User__c = UserInfo.getUserId();
        insert staffUserRequest;
        
        String data = '[{"fieldApiName": "Breakfast__c", "fieldLabel": "Breakfast", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": true}, {"fieldApiName": "Lunch__c", "fieldLabel": "Lunch", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": true}, {"fieldApiName": "Mileage__c", "fieldLabel": "Mileage", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": true}, {"fieldApiName": "Dinner__c", "fieldLabel": "Dinner", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": true}, {"fieldApiName": "Hotels__c", "fieldLabel": "Hotels", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": true}, {"fieldApiName": "Excess_Hotel_Cost__c", "fieldLabel": "Excess_Hotel_Cost", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": false}, {"fieldApiName": "Parking__c", "fieldLabel": "Parking", "quantity": 0, "amountAuthorized": 0, "amountAuthorizedOver99Miles": 0, "amountBilled": 0, "isEditable": false}]';
        Map<String,Object> resultMap = Nc_InternalStaffUserRequestItemsClass.updateAllStaffItems(staffUserRequest.id, data, '0');
        System.assertNotEquals(0, resultMap.size());
    }
}