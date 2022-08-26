/**
* @description       : Test class for NC_ConnectEquipmentController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ConnectEquipmentControllerTest {
	
    /*
    *********************************************************
    @Method Name    : getRecordTypesTest
    @description    : Verify NDBEDP request and record types for input request id
    ********************************************************
    */
    static testmethod void getRecordTypesTest() {
        String caseId = TestDataUtility.createNDBEDPCase(true).id;
        Map<String, String> resultMap = NC_ConnectEquipmentController.getRecordTypes(caseId);
        System.assertEquals('true', resultMap.get('isNDBEDPCase'));
        System.assertEquals(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NDBEDP').getRecordTypeId()+'', resultMap.get('CaseNDBEDPId'));
    }
    
    /*
    *********************************************************
    @Method Name    : getEquipmentCategoriesTest
    @description    : Verify NDBEDP equipment categories and new equipment validations
    ********************************************************
    */
    static testmethod void getEquipmentCategoriesTest(){
        case caseObj1 = TestDataUtility.createNDBEDPCase(true);
        Map<String, Object> resultMap1 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj1.id);
        System.assertNotEquals(null, resultMap1.get('equipmentDetails'));
        
        case caseObj2 = TestDataUtility.createNDBEDPCase(false, caseObj1.ContactId);
        caseObj2.status = 'Closed';
        insert caseObj2;
        Map<String, Object> resultMap2 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj2.id);
        System.assertEquals('New Equipment cannot be added as Request status is Closed', resultMap2.get('errorMessage'));
        
        case caseObj3 = TestDataUtility.createNDBEDPCase(false, caseObj1.ContactId);
        caseObj3.status = 'Approved';
        caseObj3.MatRequestObj__c = null;
        caseObj3.InActive_Equipments__c = false;
        insert caseObj3;
        Map<String, Object> resultMap3 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj3.id);
        System.assertEquals('MatRequestObj should not be empty', resultMap3.get('errorMessage'));
        
        case caseObj4 = TestDataUtility.createNDBEDPCase(false, caseObj1.ContactId);
        caseObj4.status = 'Approved';
        caseObj4.MatRequestObj__c = 'Test';
        caseObj4.MatReqStatus__c = 'Invoiced';
        insert caseObj4;
        Map<String, Object> resultMap4 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj4.id);
        System.assertEquals('New Equipment cannot be added as MatRequest status is Invoiced', resultMap4.get('errorMessage'));
        
        case caseObj5 = TestDataUtility.createNDBEDPCase(false, caseObj1.ContactId);
        caseObj5.status = 'Approved';
        caseObj5.MatRequestObj__c = 'Test';
        caseObj5.MatRequestID__c = 'Test';
        caseObj5.MatReqStatus__c = 'Open';
        insert caseObj5;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentRequestStatusMock());
        Test.stopTest();
        Map<String, Object> resultMap5 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj5.id);
        System.assertEquals('Cannot add new Equipment as MatReqStatus is cancelled', resultMap5.get('errorMessage'));
    }
    
    /*
    *********************************************************
    @Method Name    : getEquipmentCategoriesTest
    @description    : Verify adding new equipment validations
    ********************************************************
    */
    static testmethod void getEquipmentCategoriesError1Test(){
        Contact con = TestDataUtility.createConsumer(true);
        case caseObj = TestDataUtility.createNDBEDPCase(false, con.id);
        caseObj.status = 'Approved';
        caseObj.MatRequestObj__c = 'Test';
        caseObj.MatRequestID__c = 'Test';
        caseObj.MatReqStatus__c = 'Open';
        insert caseObj;
        try {
         	Map<String, Object> resultMap1 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj.id);
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
        
        Test.setMock(HttpCalloutMock.class, new GetEquipmentRequestStatusMock1());
        try {
            test.startTest();
         	Map<String, Object> resultMap2 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj.id);
            test.stopTest();
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getEquipmentCategoriesTest
    @description    : Verify adding new equipment validations
    ********************************************************
    */
    static testmethod void getEquipmentCategoriesError2Test(){
        Contact con = TestDataUtility.createConsumer(true);
        case caseObj = TestDataUtility.createNDBEDPCase(false, con.id);
        caseObj.status = 'Approved';
        caseObj.MatRequestObj__c = 'Test';
        caseObj.MatRequestID__c = 'Test';
        caseObj.MatReqStatus__c = 'Open';
        insert caseObj;
        Test.setMock(HttpCalloutMock.class, new GetEquipmentRequestStatusMock2());
        try {
            test.startTest();
         	Map<String, Object> resultMap3 = NC_ConnectEquipmentController.getEquipmentCategories(caseObj.id);
            test.stopTest();
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    public class GetEquipmentRequestStatusMock1 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse matRequestStatusResp = new NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse();
            matRequestStatusResp.STATUS = 400;
            matRequestStatusResp.ERROR_DESCRIPTION = 'Error';
            matRequestStatusResp.count = 0;
            matRequestStatusResp.hasMoreResults = false;
            matRequestStatusResp.matRequests = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(matRequestStatusResp));
            response.setStatusCode(200);
            return response; 
        }
    }
    
    public class GetEquipmentRequestStatusMock2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
            NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse matRequestStatusResp = new NC_NDBEDPEquipmentCatalog.MatRequestStatusResponse();
            matRequestStatusResp.STATUS = 200;
            matRequestStatusResp.ERROR_DESCRIPTION = 'Error';
            matRequestStatusResp.count = 0;
            matRequestStatusResp.hasMoreResults = false;
            matRequestStatusResp.matRequests = null;
                
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(matRequestStatusResp));
            response.setStatusCode(200);
            return response; 
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getEquipmentCategoriesTest
    @description    : Verify mock equipments
    ********************************************************
    */
    static testmethod void retrieveEquipmentsTest(){
        try {
         	NC_ConnectEquipmentWrapper.EquipmentResponse result2 = NC_ConnectEquipmentController.retrieveEquipments();   
        } catch (Exception e) {
            System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        
        Test.setMock(HttpCalloutMock.class, new WebServiceMock.GetEquipmentCatalogMock());
        NC_ConnectEquipmentWrapper.EquipmentResponse result = NC_ConnectEquipmentController.retrieveEquipments();
        System.assertEquals(1, result.eqp.ttEqp.size());
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveEquipmentsError1Test
    @description    : Verify mock equipments with different scenario
    ********************************************************
    */
    static testmethod void retrieveEquipmentsError1Test(){
        try {
            Test.setMock(HttpCalloutMock.class, new GetEquipmentCatalogMock1());
         	NC_ConnectEquipmentWrapper.EquipmentResponse result = NC_ConnectEquipmentController.retrieveEquipments();   
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : retrieveEquipmentsError2Test
    @description    : Verify mock equipments with different scenario
    ********************************************************
    */
    static testmethod void retrieveEquipmentsError2Test(){
        try {
            Test.setMock(HttpCalloutMock.class, new GetEquipmentCatalogMock2());
         	NC_ConnectEquipmentWrapper.EquipmentResponse result = NC_ConnectEquipmentController.retrieveEquipments();   
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    public class GetEquipmentCatalogMock1 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
                
            NC_ConnectEquipmentWrapper.EquipmentResponse resp = new NC_ConnectEquipmentWrapper.EquipmentResponse();
            resp.STATUS = '200';
            resp.ERROR_DESCRIPTION = '';
            resp.offset = 0;
            resp.count = 1;
            resp.eqp = null;
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    public class GetEquipmentCatalogMock2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest request) {
                
            NC_ConnectEquipmentWrapper.TtEqp ttEqp = new NC_ConnectEquipmentWrapper.TtEqp();
            ttEqp.Annotations = 'Test';
            
            NC_ConnectEquipmentWrapper.Eqp eqp = new NC_ConnectEquipmentWrapper.Eqp();
            eqp.ttEqp = new List<NC_ConnectEquipmentWrapper.TtEqp>{ttEqp};
                
            NC_ConnectEquipmentWrapper.EquipmentResponse resp = new NC_ConnectEquipmentWrapper.EquipmentResponse();
            resp.STATUS = '400';
            resp.ERROR_DESCRIPTION = '';
            resp.offset = 0;
            resp.count = 1;
            resp.eqp = eqp;
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(resp));
            response.setStatusCode(200);
            return response;
        }
    }
    
    /*
    *********************************************************
    @Method Name    : createEquipmentAndEquipmentRequestTest
    @description    : Verify request equipment and equipment creation
    ********************************************************
    */
    static testmethod void createEquipmentAndEquipmentRequestTest(){
        NC_ConnectEquipmentWrapper.TtEqp ttEqp = new NC_ConnectEquipmentWrapper.TtEqp();
        ttEqp.Annotations = 'Test';
        ttEqp.Author = 'Test';
        ttEqp.BibRecObj = 'Test';
        ttEqp.KlasID = 'Test';
        ttEqp.Medcode = 'Test';
        ttEqp.ReplaceCost = '100';
        ttEqp.Titl = 'Test';
        ttEqp.ManPartNum = 'Test';
        ttEqp.URL = '';
        ttEqp.ImageURL = '';
        ttEqp.ImageFileName = '';
        ttEqp.quantity = '1';
        ttEqp.OPACSup = 'false';
        
        Equipment__c eqp = TestDataUtility.createNDBEDPEquipment(true);
        
        String caseId = TestDataUtility.createNDBEDPCase(true).id;
        String resultStr = NC_ConnectEquipmentController.createEquipmentAndEquipmentRequest(JSON.serialize(new List<NC_ConnectEquipmentWrapper.TtEqp>{ttEqp}), caseId);
        System.assertEquals('SUCCESS', resultStr);

        Id ndbedpDemoRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Demo');
        Case cas=[SELECT Id FROM Case LIMIT 1];
        cas.RecordTypeId=ndbedpDemoRecordTypeId;
        update cas;
        
        String resultStr1 = NC_ConnectEquipmentController.createEquipmentAndEquipmentRequest(JSON.serialize(new List<NC_ConnectEquipmentWrapper.TtEqp>{ttEqp}), caseId);
        System.assertEquals('SUCCESS', resultStr1);
    }
}