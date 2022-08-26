/**
* @description       : Test class for NC_ResourceManagerController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ResourceManagerControllerTest {
	
    /*
    *********************************************************
    @Method Name    : createData
    @description    : Create test data to be used in this test class
    ********************************************************
    */
    @TestSetup
    public static void createData(){
        Contact con = TestDataUtility.createConsumer(true);
        Account regionalCenter = TestDataUtility.createRegionalCenter(true);
        Resource__c resource = TestDataUtility.createResource(true, 'Test Resource', 'Equipment', regionalCenter.id);
        
        Id consumerLoanTypeId = Schema.SObjectType.Resource_Loan__c.getRecordTypeInfosByDeveloperName().get('Consumer_Resource_Loan').getRecordTypeId();
        Resource_Loan__c resourceLoan = TestDataUtility.createResourceLoan(true, consumerLoanTypeId, 'Equipment', null, regionalCenter.id, con.id);
    }
    /*
    *********************************************************
    @Method Name    : resourceCheckOutTest
    @description    : Verify checkout resource validations
    ********************************************************
    */
    static testmethod void resourceCheckOutTest() {
        Resource__c resource = [SELECT id FROM Resource__c LIMIT 1];
        Resource_Loan__c resourceLoan = [SELECT category__c, Regional_Center__c FROM Resource_Loan__c LIMIT 1];
        
        PageReference pageRef = Page.NC_CheckOutresource;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(resourceLoan.Id));
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl = new NC_ResourceManagerController(sc);
        ctrl.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl.dueDate = System.today();
        ctrl.requestedResource = new Requested_Resource__c(Condition_of_Resource__c = 'Good');
        ctrl.resourceCheckOut();
        
        NC_ResourceManagerController ctrl2 = new NC_ResourceManagerController(sc);
        ctrl2.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl2.dueDate = System.today();
        //ctrl2.requestedResource = new Requested_Resource__c(Condition_of_Resource__c = 'Good');
        ctrl2.resourceCheckOut();
        
        test.stopTest();
        
        List<Requested_Resource__c> reqResourceList = [SELECT id FROM Requested_Resource__c];
        System.assertEquals(1, reqResourceList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : resourceCheckOutValidationsTest
    @description    : Verify checkout resource validations
    ********************************************************
    */
    static testmethod void resourceCheckOutValidationsTest() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Resource_Loan__c());
        NC_ResourceManagerController ctrl = new NC_ResourceManagerController(sc);
        ctrl.resourceCheckOut();
        System.assertEquals('Not a valid resource barcode number.', ctrl.errorMessage);
        
        Resource__c resource = [SELECT id FROM Resource__c LIMIT 1];
        Resource_Loan__c resourceLoan = [SELECT Category__c, Regional_Center__c FROM Resource_Loan__c LIMIT 1];
        ApexPages.StandardController sc2 = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl2 = new NC_ResourceManagerController(sc2);
        ctrl2.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl2.dueDate = System.today() - 1;
        ctrl2.resourceCheckOut();
        System.assertEquals('Due date cannot be in past',ctrl2.errorMessage);
        
        Resource_Loan__c resourceLoan2 = [SELECT Category__c FROM Resource_Loan__c LIMIT 1];
        ApexPages.StandardController sc3 = new ApexPages.StandardController(resourceLoan2);
        NC_ResourceManagerController ctrl3 = new NC_ResourceManagerController(sc3);
        ctrl3.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl3.dueDate = System.today() - 1;
        ctrl3.resourceCheckOut();
        System.assertNotEquals(null,ctrl3.errorMessage);
    }
    
    /*
    *********************************************************
    @Method Name    : resourceCheckOutValidations2Test
    @description    : Verify checkout resource validations
    ********************************************************
    */
    static testmethod void resourceCheckOutValidations2Test() {
        Account regionalCenter = [SELECT id FROM Account LIMIT 1];
        Resource__c resource = [SELECT id FROM Resource__c LIMIT 1];
        Resource_Loan__c resourceLoan = [SELECT Category__c FROM Resource_Loan__c LIMIT 1];
        resourceLoan.Category__c = null;
        update resourceLoan;
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl2 = new NC_ResourceManagerController(sc2);
        ctrl2.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl2.dueDate = System.today();
        ctrl2.resourceCheckOut();
        System.assertEquals('Category cannot be blank. Add Category to proceed with Resource Check-Out.', ctrl2.errorMessage);
        
        resourceLoan.Category__c = 'Material/Media';
        update resourceLoan;
        ApexPages.StandardController sc3 = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl3 = new NC_ResourceManagerController(sc3);
        ctrl3.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl3.dueDate = System.today();
        ctrl3.resourceCheckOut();
        System.assertEquals('You can only check-out "Material/Media" type of resources.',ctrl3.errorMessage);
        
        resourceLoan.Category__c = 'Equipment';
        resourceLoan.Regional_Center__c = TestDataUtility.createRegionalCenter(true).id;
        update resourceLoan;
        ApexPages.StandardController sc4 = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl4 = new NC_ResourceManagerController(sc4);
        ctrl4.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl4.dueDate = System.today();
        ctrl4.resourceCheckOut();
        System.assertEquals('Resource needs to be of same regional center as it is on resource loan request.',ctrl4.errorMessage);
        
        /*
        resourceLoan.Regional_Center__c = regionalCenter.id;
        update resourceLoan;
        ApexPages.StandardController sc5 = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl5 = new NC_ResourceManagerController(sc5);
        ctrl5.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl5.dueDate = System.today() - 1;
        ctrl5.resourceCheckOut();
        System.assertEquals('Due date cannot be in past',ctrl5.errorMessage);*/
    }
    
    /*
    *********************************************************
    @Method Name    : resourceCheckInTest
    @description    : Verify checkin resource validations
    ********************************************************
    */
    static testmethod void resourceCheckInTest() {
        Resource__c resource = [SELECT id FROM Resource__c LIMIT 1];
        Resource_Loan__c resourceLoan = [SELECT id FROM Resource_Loan__c LIMIT 1];
        
        Requested_Resource__c reqResource = TestDataUtility.createRequestedResoure(false, resource.id, resourceLoan.Id, 'Good', System.today());
        reqResource.State__c = 'Checked-Out';
        insert reqResource;
        
        PageReference pageRef = Page.NC_CheckInresource;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(resourceLoan.Id));
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl = new NC_ResourceManagerController(sc);
        ctrl.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl.dueDate = System.today();
        ctrl.requestedResource = reqResource;
        ctrl.resourceCheckIn();        
        ctrl.updateStatus(resourceLoan.id);
        ctrl.redirect();
        test.stopTest();
        
        List<Requested_Resource__c> reqResourceList = [SELECT id FROM Requested_Resource__c];
        System.assertEquals(1, reqResourceList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : resourceCheckInValidationsTest
    @description    : Verify checkin resource validations
    ********************************************************
    */
    static testmethod void resourceCheckInValidationsTest() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new Resource_Loan__c());
        NC_ResourceManagerController ctrl = new NC_ResourceManagerController(sc);
        ctrl.resourceCheckIn(); 
        System.assertEquals('Not a valid resource barcode number.', ctrl.errorMessage);
        
        Resource__c resource = [SELECT id FROM Resource__c LIMIT 1];
        Resource_Loan__c resourceLoan = [SELECT id FROM Resource_Loan__c LIMIT 1];
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(resourceLoan);
        NC_ResourceManagerController ctrl2 = new NC_ResourceManagerController(sc2);
        ctrl2.scanCode = [SELECT Bar_Code_Number__c FROM Resource__c WHERE id =: resource.id LIMIT 1].Bar_Code_Number__c;
        ctrl2.resourceCheckIn();
        System.assertEquals('You can not check-in a resource if it is not checked out.', ctrl2.errorMessage);
    }
}