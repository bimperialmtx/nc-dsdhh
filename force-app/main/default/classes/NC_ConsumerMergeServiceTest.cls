/**
* @description       : Test class for NC_ConsumerMergeService
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_ConsumerMergeServiceTest {
    /*
    *********************************************************
    @Method Name    : createData
    @description    : Create data to be used in this class
    ********************************************************
    */
    @TestSetup
    static void createData() {
        Contact con1 = TestDataUtility.createConsumer(false);
        con1.Cnds_Identifier__c = 'abc123';
        con1.Social_Security_Number__c = '1234';
        insert con1;
        
        Contact con2 = TestDataUtility.createConsumer(false);
        con2.LastName = 'xyz';
        con2.Cnds_Identifier__c = 'xyz987';
        con2.Social_Security_Number__c = '1234';
        insert con2;
        
        Id caseTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
        Case request = TestDataUtility.createCase(true, caseTypeId, con1.id, 'EDS', 'Telephone');
        
        Id authTypeId = Schema.SObjectType.Authorization__c.getRecordTypeInfosByDeveloperName().get('EDS').getRecordTypeId();
        Authorization__c auth = TestDataUtility.createAuthorization(true, authTypeId, request.id, null, con1.id);
        
        Id assetTypeId = Schema.SObjectType.Asset__c.getRecordTypeInfosByDeveloperName().get('Generic_Asset').getRecordTypeId();
		Asset__c asset = TestDataUtility.createAsset(false, assetTypeId, auth.id, null, request.id);
        asset.Contact__c = con1.id;
        insert asset;
        
        Id outreachTypeId = Schema.SObjectType.Outreach_Request__c.getRecordTypeInfosByDeveloperName().get('DHH_Sponsor_Event').getRecordTypeId();
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(false, outreachTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        outreach.Consumer__c = con1.id;
        insert outreach;
        
        TestDataUtility.createMentoringRequest(true, con1.id, request.Id);
        
        //TestDataUtility.createAttachment(true, con1.id, 'body', 'image/png', 'name', 'description');
        
        TestDataUtility.createContentDocumentLink(con1.id, false);
        
        Id consumerLoanTypeId = Schema.SObjectType.Resource_Loan__c.getRecordTypeInfosByDeveloperName().get('Consumer_Resource_Loan').getRecordTypeId();
        TestDataUtility.createResourceLoan(true, consumerLoanTypeId, 'Equipment', null, null, con1.id);
        
        TestDataUtility.createClientArchive(true, con1.id);
        
        TestDataUtility.createInformationReferral(true, con1.id);
        
        TestDataUtility.createAlternateContact(true, con1.id);
        
        TestDataUtility.createError(true, con1.id);
    }

    /*
    *********************************************************
    @Method Name    : sameSSNTest
    @description    : Verify same SSN merge functionality
    ********************************************************
    */
    static testmethod void sameSSNTest() {
        Contact con1 = [SELECT BirthDate, Social_Security_Number__c, Cnds_Identifier__c FROM Contact WHERE Cnds_Identifier__c = 'abc123'];
        Contact con2 = [SELECT BirthDate, Social_Security_Number__c, Cnds_Identifier__c FROM Contact WHERE Cnds_Identifier__c = 'xyz987'];
      
        NC_ConsumerMergeService.CNDSRequestWrapper reqWrap = new NC_ConsumerMergeService.CNDSRequestWrapper();
        reqWrap.SOURCE_CD = con1.Cnds_Identifier__c;
        reqWrap.TARGET_CD = con2.Cnds_Identifier__c;
        reqWrap.SOURCE_PERSON_ID = '';
        reqWrap.TARGET_PERSON_ID = '';
        reqWrap.TARGET_DOB = getDate(con2);
        reqWrap.TARGET_SSN = con2.Social_Security_Number__c;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ConsumerMerge/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrap));
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        NC_ConsumerMergeService.doPost();
        Test.stopTest();
        List<Authorization__c> authList = [SELECT Id,Consumer__c FROM Authorization__c WHERE Consumer__c=: con2.id];
        System.assertEquals(true, authList[0].Consumer__c!=null);
    }
    
    /*
    *********************************************************
    @Method Name    : diffSSNTest
    @description    : Verify different SSN merge functionality
    ********************************************************
    */
    static testmethod void diffSSNTest() {
        Contact con1 = [SELECT BirthDate, Social_Security_Number__c, Cnds_Identifier__c FROM Contact WHERE Cnds_Identifier__c = 'abc123'];
        Contact con2 = [SELECT BirthDate, Social_Security_Number__c, Cnds_Identifier__c FROM Contact WHERE Cnds_Identifier__c = 'xyz987'];
        
        NC_ConsumerMergeService.CNDSRequestWrapper reqWrap = new NC_ConsumerMergeService.CNDSRequestWrapper();
        reqWrap.SOURCE_CD = con1.Cnds_Identifier__c;
        reqWrap.TARGET_CD = con2.Cnds_Identifier__c;
        reqWrap.SOURCE_PERSON_ID = '';
        reqWrap.TARGET_PERSON_ID = '';
        reqWrap.TARGET_DOB = '';
        reqWrap.TARGET_SSN = con2.Social_Security_Number__c;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ConsumerMerge/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrap));
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        NC_ConsumerMergeService.doPost();
        Test.stopTest();
        List<Authorization__c> authList = [SELECT Id,Consumer__c FROM Authorization__c WHERE Consumer__c=: con2.id];
        System.assertEquals(true, authList[0].Consumer__c!=null);
    }
    
    /*
    *********************************************************
    @Method Name    : blankTargetTest
    @description    : Verify contact not present in SMS functionality
    ********************************************************
    */
    static testmethod void blankTargetTest() {
        Contact con1 = [SELECT BirthDate, Social_Security_Number__c, Cnds_Identifier__c FROM Contact WHERE Cnds_Identifier__c = 'abc123'];
        Contact con2 = [SELECT BirthDate, Social_Security_Number__c, Cnds_Identifier__c FROM Contact WHERE Cnds_Identifier__c = 'xyz987'];
        
        NC_ConsumerMergeService.CNDSRequestWrapper reqWrap = new NC_ConsumerMergeService.CNDSRequestWrapper();
        reqWrap.SOURCE_CD = con1.Cnds_Identifier__c;
        reqWrap.TARGET_CD = 'xyz123';
        reqWrap.SOURCE_PERSON_ID = '';
        reqWrap.TARGET_PERSON_ID = '';
        reqWrap.TARGET_DOB = '';
        reqWrap.TARGET_SSN = con2.Social_Security_Number__c;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ConsumerMerge/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(reqWrap));
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        NC_ConsumerMergeService.doPost();
        Test.stopTest();
        List<Authorization__c> authList = [SELECT Id,Consumer__c FROM Authorization__c WHERE Consumer__c=: con2.id];
        System.assertEquals(0, authList.size());
    }
    
    static String getDate(Contact con) {
        String dayString;
        String monthString;
        Integer day = con.BirthDate.Day(); //get day
        if(String.valueOf(day).length()==1){
            dayString= String.valueOf(day).leftPad(2, '0');
        }else {
            dayString=String.valueof(day);
        }
        Integer month = con.BirthDate.Month(); //get month
        if(String.valueOf(month).length()==1){
            monthString= String.valueOf(month).leftPad(2, '0');
        }else {
            monthString=String.valueof(month);
        }
        Integer year = con.BirthDate.Year(); //get year
        return String.valueof(year)+ monthString + dayString;
    }
}