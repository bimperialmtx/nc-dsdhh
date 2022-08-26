/**
* @description       : Test class for NC_ResourceTransferController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ResourceTransferControllerTest {
    
    /*
*********************************************************
@Method Name    : getRegionalCenterTest
@description    : Verify regional center of related resource
********************************************************
*/
    static testmethod void getRegionalCenterTest() {
        Account regionalCenter = TestDataUtility.createRegionalCenter(true);
        Account regionalCenter2 = TestDataUtility.createRegionalCenter(false);
        regionalCenter2.Name = 'Test RC';
        insert regionalCenter2;
        Resource__c resource = TestDataUtility.createResource(true, 'Test Resource', 'Equipment', regionalCenter.id);
        Map<String,Object> resultMap = NC_ResourceTransferController.getRegionalCenter(resource.id);
        System.assertNotEquals(null, resultMap.get('result'));
        resource.Status__c='In Process';
        update resource;
        
        Map<String,Object> resultMap2 = NC_ResourceTransferController.getRegionalCenter(resource.id);
        System.assertEquals(false, resultMap2.get('result')!=null);
    }
    
    /*
*********************************************************
@Method Name    : transferResourceToRegionalTest
@description    : Verify transfer of resource to another regional center
********************************************************
*/
    static testmethod void transferResourceToRegionalTest() {
        test.startTest();
        Account regionalCenter = TestDataUtility.createRegionalCenter(true);
        Resource__c resource = TestDataUtility.createResource(true, 'Test Resource', 'Equipment', regionalCenter.id);
        NC_ResourceTransferController.transferResourceToRegional(resource.id, regionalCenter.id);
        test.stopTest();
        Resource__c resource1 = [SELECT Status__c FROM Resource__c WHERE id =: resource.id];
        System.assertEquals('Pending Shipment', resource1.Status__c);
    }
}