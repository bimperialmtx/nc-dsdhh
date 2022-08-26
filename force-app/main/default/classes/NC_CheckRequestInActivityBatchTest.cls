/**
* @description       : Verify request inactivity follow up
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_CheckRequestInActivityBatchTest {
    
    static testmethod void batchTest() {
        Contact con = TestDataUtility.createConsumer(true);
        
        Id equipmentRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case edsRequest = TestDataUtility.createCase(true, equipmentRequestId, con.id, 'EDS', 'Hearing Aid');
        
        try{
            Test.startTest();
            NC_CheckRequestInActivityBatch batch = new NC_CheckRequestInActivityBatch();
            Database.executeBatch(batch);
            batch.finish(null);
            Case cas=[SELECT Id,Status FROM Case LIMIT 1];
            System.assertEquals('Submitted', cas.Status);
            Test.stopTest();
        }
        Catch(Exception e){
        }
        
    }
}