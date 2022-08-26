/**
* @description       : Test class for NC_NDBEDPConditionofAcceptanceCtrl
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@IsTest
public class NC_NDBEDPConditionofAcceptanceCtrlTest {
    
    /*
*********************************************************
@Method Name    : makeData
@description    : Create data to be used in this class
********************************************************
*/
    @TestSetup
    public static void makeData(){
        
        Id recordId = NC_Utility.RecordTypeUtilityMethod('Account','Assessor');
        Account acc=new Account();
        acc.RecordTypeId=recordId;
        acc.Email__c='test@gmail.com';
        acc.Name='Test';
        acc.BillingCity='city';
        acc.BillingCountry='United States';
        acc.BillingState='Alabama';
        acc.BillingPostalCode='12345';
        acc.BillingStreet='123 Street';
        acc.Active__c=true;
        insert acc;
        
        Contact con=new Contact(); 
        con.LastName='Test Con';
        insert con;
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        cas.Assessor_Comment__c ='test';
        cas.Comments__c ='';
        insert cas;
        
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;        
    }
    
    /*
*********************************************************
@Method Name    : saveCommentDate
@description    : Verify ndbedp condition of acceptance data save
********************************************************
*/
    @isTest
    public static void saveCommentDate(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        String result = NC_NDBEDPConditionofAcceptanceCtrl.saveData('{"alternatecontact":"","applicantsSignature":"","onlineAssessor":false,"personCompletingInformation":"","phoneNumberofalternatecontact":"","relationship":"","relationshipofalternatecontact":"","signed":"00Pr0000004MWBWEA4","attestationdate":"2022-03-22","frombutton":"fromaccept","requestId":"'+cas.Id+'\"}');
        system.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : fetchSignatureTest
@description    : Verify signature document for request
********************************************************
*/
    @isTest
    public static void fetchSignatureTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Id result = NC_NDBEDPConditionofAcceptanceCtrl.fetchSignature(cas.Id);
        System.assertEquals(false, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getEquipmentDetailsTest
@description    : Verify selected equipments for ndbedp request
********************************************************
*/
    @isTest
    public static void getEquipmentDetailsTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Boolean result = NC_NDBEDPConditionofAcceptanceCtrl.getEquipmentDetails(cas.Id);
        System.assertEquals(null, result);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getConsumerNameFromRequestTest
@description    : Verify consumer name related to request
********************************************************
*/
    @isTest
    public static void getConsumerNameFromRequestTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case result = NC_NDBEDPConditionofAcceptanceCtrl.getConsumerNameFromRequest(cas.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getAccountFromRequestTest
@description    : Verify account details related to request
********************************************************
*/
    @isTest
    public static void getAccountFromRequestTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case result = NC_NDBEDPConditionofAcceptanceCtrl.getAccountFromRequest(cas.Id);
        System.assertEquals(true, result.External_Assessor__c!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getAcceptedValuefromRequestTest
@description    : Verify accepted value related to request
********************************************************
*/
    @isTest
    public static void getAcceptedValuefromRequestTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Case result = NC_NDBEDPConditionofAcceptanceCtrl.getAcceptedValuefromRequest(cas.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getStatusTest
@description    : Verify request status
********************************************************
*/
    @isTest
    public static void getStatusTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        String result = NC_NDBEDPConditionofAcceptanceCtrl.getStatus(cas.Id);
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getTodaysDateTest
@description    : Verify today's date
********************************************************
*/
    @isTest
    public static void getTodaysDateTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Date result = NC_NDBEDPConditionofAcceptanceCtrl.getTodaysDate();
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : fetchFieldsTest
@description    : Verify condition of acceptance field values
********************************************************
*/
    @isTest
    public static void fetchFieldsTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        NC_NDBEDPConditionofAcceptanceCtrl.RequestDataWrapper result = NC_NDBEDPConditionofAcceptanceCtrl.fetchFields(cas.Id);
        System.assertEquals(null, result.attestationdate);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : requestEquipmentsforRequestTest
@description    : Verify equipments for ndbedp request
********************************************************
*/
    @isTest
    public static void requestEquipmentsforRequestTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        NC_NDBEDPConditionofAcceptanceCtrl.requestEquipmentsforRequest(cas.Id);
        System.assertEquals(true,(NC_NDBEDPConditionofAcceptanceCtrl.requestEquipmentsforRequest(cas.Id)).size()!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveCommentDataTest
@description    : Verify comments for reject condition of acceptance
********************************************************
*/
    @isTest
    public static void saveCommentDataTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        NC_NDBEDPConditionofAcceptanceCtrl.saveCommentData('{"comments":"test","requestId":"'+cas.Id+'\"}');
        Case result =[SELECT Id,Comments__c FROM Case LIMIT 1];
        system.assertEquals('test', result.Comments__c);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : rejectRecordsTest
@description    : Verify NDBEDP request reject scenario
********************************************************
*/
    @isTest
    public static void rejectRecordsTest(){
        Case request = TestDataUtility.createNDBEDPCase(false);
        request.Vision_Assessment__c = true;
        request.Audio_Gram__c = true;
        request.Status = 'Pending Documents';
        insert request;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments('');
        req.setObjectId(request.id);
        Approval.process(req);
        
        Test.startTest();
        Request_Equipment__c reqEquipment = new Request_Equipment__c(Quantity__c = '1');
        NC_NDBEDPConditionofAcceptanceCtrl.RequestEquipments wrap = new NC_NDBEDPConditionofAcceptanceCtrl.RequestEquipments(reqEquipment);
        NC_NDBEDPConditionofAcceptanceCtrl.rejectRecords(new Set<Id>{request.id});
        System.debug('-->'+[SELECT status FROM Case WHERE id =: request.id]);
        Test.stopTest();
    }
}