/**
* @description       : Test class for NC_ItemsToApproveController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ItemsToApproveControllerTest {

    /*
    *********************************************************
    @Method Name    : getSubmittedRecordsTest
    @description    : Verify items pending for approval and process records
    ********************************************************
    */
    static testmethod void getSubmittedRecordsTest() {
        Account rcObj = TestDataUtility.createRegionalCenter(true);
        
        Id commReqId = Schema.SObjectType.Communication_Access_Request__c.getRecordTypeInfosByDeveloperName().get('Generic_Request').getRecordTypeId();
        Communication_Access_Request__c carObj = TestDataUtility.createCommunicationAcessRequest(true, commReqId, 'SSP', rcObj.id);
        
        Id externalStaffId = Schema.SObjectType.Staffing_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staff').getRecordTypeId();
        Staffing_Request__c staffReqObj = TestDataUtility.createStaffingRequest(true, externalStaffId, carObj.id, '1');
        
        Id externalStaffUserId = Schema.SObjectType.Staffing_User_Request__c.getRecordTypeInfosByDeveloperName().get('External_Staffing_User_Request').getRecordTypeId();
        //Staffing_User_Request__c staffUserRedObj = TestDataUtility.createStaffingUserRequest(true, externalStaffUserId, staffReqObj.id);
        Staffing_User_Request__c staffUserRedObj = new Staffing_User_Request__c();
        staffUserRedObj.RecordTypeId=externalStaffUserId;
        staffUserRedObj.Staffing_Request__c=staffReqObj.id;
        staffUserRedObj.Booked_Time_Same_As_Service_Time__c=true;
        insert staffUserRedObj;
        
        List<NC_ItemsToApproveController.SubmittedRecordsWrapper> resultList = NC_ItemsToApproveController.getSubmittedRecords();
        System.assertNotEquals(0, resultList.size());
        
        List<String> lstWorkItemIds = new List<String>();
        for(NC_ItemsToApproveController.SubmittedRecordsWrapper wrap: resultList) {
            lstWorkItemIds.add(wrap.workItemId);
        }
        String result = NC_ItemsToApproveController.processRecords(lstWorkItemIds, 'Approve');
        System.assertEquals('Selected records are Approved successfully', result);
    }
}