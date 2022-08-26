/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@isTest
public class NC_AssessmentCtrlTest {
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
        // con.AccountId=acc.Id;
        con.LastName='Test Con';
        insert con;
        
        
        
        Case cas= new Case();
        cas.ContactId=con.Id;
        cas.External_Assessor__c=acc.Id;
        // cas.Internal_Assessor__c='';
        cas.Assessor_Comment__c ='test';
        cas.Comments__c ='';
        insert cas;
        
        /*  Case cas1= new Case();
cas1.ContactId=con.Id;
cas1.Internal_Assessor__c=user.Id;
cas1.Assessor_Comment__c ='test';
cas1.Comments__c ='';
insert cas1;*/
        
        Assessment__c ass =new Assessment__c();
        ass.Request__c =cas.Id;
        Insert ass;
        
        
    }
    
    /*
*********************************************************
@Method Name    : testgetAssessorResult
@description    : Verify assessor result possible values
********************************************************
*/
    @isTest
    public static void testgetAssessorResult(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        NC_AssessmentCtrl.fetchPicklist('Case','Assessor_Result__c');
        System.assertNotEquals(null, NC_AssessmentCtrl.fetchPicklist('Case','Assessor_Result__c'));
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : getConsumerNameFromRequestTest
@description    : Verify consumer related to request
********************************************************
*/
    @isTest
    public static void getConsumerNameFromRequestTest(){
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        NC_AssessmentCtrl.getConsumerNameFromRequest(null);
        NC_AssessmentCtrl.getConsumerNameFromRequest(cas.Id);
        System.assertNotEquals(null,  NC_AssessmentCtrl.getConsumerNameFromRequest(cas.Id));
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
        Case cas=[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        NC_AssessmentCtrl.getAccountFromRequest(cas.Id);
        System.assertNotEquals(null, NC_AssessmentCtrl.getAccountFromRequest(cas.Id));
        Date result1=NC_AssessmentCtrl.getTodaysDate();
        System.assertEquals(true, result1!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : testGetAccountFromCaseAndSaveData
@description    : Verify account details related to request
********************************************************
*/
    @isTest
    public static void testGetAccountFromCaseAndSaveData(){
        List<User> user=[SELECT Id,Profile.Name,userrole.DeveloperName FROM User WHERE Profile.Name='Specialist' AND userrole.DeveloperName='Deaf_Services_Specialist' LIMIT 1];
        
        Contact con1=[SELECT Id FROM Contact LIMIT 1];
        Case cas1= new Case();
        cas1.ContactId=con1.Id;
        if(user.size()>0){
            cas1.Internal_Assessor__c =user[0].Id;
        }
        cas1.Comments__c ='';
        insert cas1;
        Test.startTest();
        try{
            Case result = NC_AssessmentCtrl.getAccountFromRequest(cas1.Id);
            Case result1=[SELECT Id,Comments__c FROM Case WHERE ContactId=:con1.Id LIMIT 1];
            System.assertEquals(false, result1.Comments__c!=null);
            Assessment__c res=NC_AssessmentCtrl.saveData('{"attestation":"testone","attestationdate":"2026-11-23","attestorsignature":"","atUsage":["Screen reader","Not familiar w/ assistive tech"],"communicationskills":["Braille – non-contractual","Speech/verbal"],"computerusageexperience":["PC","MAC"],"connectivity":["Currently has cellular phone service","Has a computer"],"consumergoals":"test","hearing":"Hearing – Severe (80-90 db PTA in the better ear)","hearingassessment":["Can hear a loud ringer","No useable hearing"],"levelofcomputerexperience":["Basic (PC)","Advanced (PC)"],"mailingaddress":"887 Parkside Avenue//nTrenton//nCalifornia//n08618//nUnited States","narrative":"test","onlineAssessor":false,"other":["Speech – (alternative or augmentative communication)","Travel issues (human guide, dog guide, note cards, ID buttons)"],"phone":"467889977","signed":"00Pr00000045l5AEAQ","tactileassessment":["Uses tactile ASL","Highly proficient in contractual Braille"],"visionloss":"Visual – visual field restriction","visualassessment":["Can use a visual signaler","Effectively uses a pen"],"frombutton":"fromaccept","requestId":"'+cas1.Id+'\","refreshData":false }');
            System.assertEquals(true, res!=null);
            NC_AssessmentCtrl.fetchFields(cas1.Id);
            System.assertNotEquals(null, NC_AssessmentCtrl.fetchFields(cas1.Id));
        }        
        Catch(Exception e){
        }
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveDataTest
@description    : Verify assessment form data
********************************************************
*/
    @isTest
    public static void saveDataTest(){
        Case cas=[SELECT Id,External_Assessor__c FROM Case LIMIT 1];
        Test.startTest();
        try{
            Assessment__c res=NC_AssessmentCtrl.saveData('{"attestation":"","attestationdate":"2021-11-23","attestorsignature":"","atUsage":null,"communicationskills":null,"computerusageexperience":null,"connectivity":null,"consumergoals":"test","hearing":"Hearing – Severe (80-90 db PTA in the better ear)","hearingassessment":null,"levelofcomputerexperience":null,"mailingaddress":"887 Parkside Avenue//nTrenton//nCalifornia//n08618//nUnited States","narrative":"test","onlineAssessor":false,"other":null,"phone":"467889977","signed":"00Pr00000045l5AEAQ","tactileassessment":null,"visionloss":"Visual – visual field restriction","visualassessment":null,"frombutton":"fromaccept","requestId":"'+cas.Id+'\","refreshData":false }');
            system.assertEquals(true, res!=null);
            Assessment__c result=NC_AssessmentCtrl.saveData('{"attestation":"test","attestationdate":"2021-11-23","attestorsignature":"","atUsage":["Screen reader","Not familiar w/ assistive tech"],"communicationskills":["Braille – non-contractual","Speech/verbal"],"computerusageexperience":["PC","MAC"],"connectivity":["Currently has cellular phone service","Has a computer"],"consumergoals":"test","hearing":"Hearing – Severe (80-90 db PTA in the better ear)","hearingassessment":["Can hear a loud ringer","No useable hearing"],"levelofcomputerexperience":["Basic (PC)","Advanced (PC)"],"mailingaddress":"887 Parkside Avenue//nTrenton//nCalifornia//n08618//nUnited States","narrative":"test","onlineAssessor":false,"other":["Speech – (alternative or augmentative communication)","Travel issues (human guide, dog guide, note cards, ID buttons)"],"phone":"467889977","signed":"00Pr00000045l5AEAQ","tactileassessment":["Uses tactile ASL","Highly proficient in contractual Braille"],"visionloss":"Visual – visual field restriction","visualassessment":["Can use a visual signaler","Effectively uses a pen"],"frombutton":"fromaccept","requestId":"'+cas.Id+'\","refreshData":false }');
            system.assertEquals(true, result!=null);
        }catch(Exception e){
            throw e;
        }
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveCommentDate
@description    : Verify reject comment data
********************************************************
*/
    @isTest
    public static void saveCommentDate(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        try{
            Case result=NC_AssessmentCtrl.saveCommentData('{"attestation":"test","attestationdate":"2021-11-23","attestorsignature":"00Pr00000045lEOEAY","atUsage":["Screen reader"],"communicationskills":["Braille – non-contractual","Speech/verbal"],"computerusageexperience":["PC"],"connectivity":["Currently has cellular phone service"],"consumergoals":"test","hearing":"Hearing – Severe (80-90 db PTA in the better ear)","hearingassessment":["Can hear a loud ringer"],"levelofcomputerexperience":["Basic (PC)"],"mailingaddress":"887 Parkside Avenue//nTrenton//nCalifornia//n08618//nUnited States","narrative":"test","onlineAssessor":false,"other":["Speech – (alternative or augmentative communication)"],"phone":"467889977","signed":"00Pr00000045l5AEAQ","tactileassessment":["Uses tactile ASL"],"visionloss":"Visual – visual field restriction","visualassessment":["Can use a visual signaler"],"comments":"test","requestId":"'+cas.Id+'\"}');
            system.assertEquals('test', result.Comments__c);      
        }catch(Exception e){
            throw e;
        }
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : saveCommentDate
@description    : Verify today's date
********************************************************
*/
    @isTest
    public static void getDateTest(){
        Test.startTest();
        Date result=NC_AssessmentCtrl.getTodaysDate();
        System.assertEquals(true, result!=null);
        Test.stopTest();
    }
    
    /*
*********************************************************
@Method Name    : fetchSignatureTest
@description    : Verify signature file data
********************************************************
*/
    @isTest
    public static void fetchSignatureTest(){
        Case cas =[SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        try{
            Id res=NC_AssessmentCtrl.fetchSignature(null);
            System.assertEquals(false, res!=null);
            Id result=NC_AssessmentCtrl.fetchSignature(cas.Id);
            System.assertEquals(false, result!=null);
            Map<String,Object> result1=NC_AssessmentCtrl.getStatus(cas.Id);
            System.assertEquals(true, result1.size()>0);
            NC_AssessmentCtrl.fetchFields(cas.Id);
            System.assertNotEquals(null, NC_AssessmentCtrl.fetchFields(cas.Id));
        }catch(Exception e){
        }
    }
    
}