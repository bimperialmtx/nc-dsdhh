/**
* @description       : Test class for Assess
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @group             : 
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class AssessTest {

    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Create test data to be used in this test class
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
        cas.Email_address__c= 'test@gmail.com';
        cas.RecordTypeId = NC_Utility.RecordTypeUtilityMethod('Case','NDBEDP_Follow_up');
        insert cas;
    }
        
    /*
    *********************************************************
    @Method Name    : fetchPicklistTest
    @description    : Verify picklist values for input object and field
    ********************************************************
    */
	static testmethod void fetchPicklistTest() {
        List<Assess.SelectOptionWrapper> resultList = Assess.fetchPicklist('Mentoring_Request__c', 'Are_you_planning_to_take_the_EIPA__c');
        System.assertNotEquals(0, resultList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : saveDatatest
    @description    : Verify Assessment record is getting created
    ********************************************************
    */
    static testmethod void saveDatatest() {
        
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Assess.AssessmentDataWrapper wrap = new Assess.AssessmentDataWrapper();
        wrap.hearing = 'test';
        wrap.narrative = 'test';
        wrap.visionloss = 'test';
        wrap.other = 'test';
        wrap.communicationskills = 'test';
        wrap.connectivity = 'test';
        wrap.hearingassessment = 'test';
        wrap.atUsage = 'test';
        wrap.computerusageexperience = new List<String>{'PC'};
        wrap.visualassessment = 'test';
        wrap.tactileassessment = 'test';
        wrap.consumergoals = 'test';
        wrap.levelofcomputerexperience = new List<String>{'Basic (PC)'};
        wrap.attestation = 'test';
        wrap.attestorsignature = System.today()+'';
        wrap.attestationdate = System.today()+'';
        wrap.mailingaddress = 'test';
        wrap.emailaddress = 'test';
        wrap.phone = 'test';
        wrap.license = 'test';
        wrap.requestId = cas.id;
        
        Assess.saveData(System.JSON.serialize(wrap));
        List<Assessment__c> assessmentList = [SELECT id FROM Assessment__c];
        System.assertNotEquals(0, assessmentList.size());
        Test.stopTest();
    }
    
    /*
    *********************************************************
    @Method Name    : getConsumerNameFromRequestTest
    @description    : Verify Consumer name from input request
    ********************************************************
    */
    static testmethod void getConsumerNameFromRequestTest() {
         Case cas=[SELECT Id FROM Case LIMIT 1];
         Test.startTest();
         Case result = Assess.getConsumerNameFromRequest(cas.Id);
         System.assertNotEquals(null, result);
         Test.stopTest();
    }
}