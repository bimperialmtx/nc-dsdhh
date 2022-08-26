/**
* @description       : Test class for NC_MentoringRequestController
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest
public class NC_MentoringRequestControllerTest {
	
    /*
    *********************************************************
    @Method Name    : fetchPicklistTest
    @description    : Verify mentoring request picklist values
    ********************************************************
    */
    static testmethod void fetchPicklistTest() {
        List<NC_MentoringRequestController.SelectOptionWrapper> resultList = NC_MentoringRequestController.fetchPicklist('Mentoring_Request__c', 'Are_you_planning_to_take_the_EIPA__c');
        System.assertNotEquals(0, resultList.size());
    }
    
    /*
    *********************************************************
    @Method Name    : createMentoringRequestRecordTest
    @description    : Verify mentoring request record creation
    ********************************************************
    */
    static testmethod void createMentoringRequestRecordTest() {
        NC_MentoringRequestWrapper wrap = new NC_MentoringRequestWrapper();
        Contact contactObj = TestDataUtility.createConsumer(true);
        String wizardData = '{"familyInformation":{"haveDeafFamilyMembers":"No","memberRelationship":"","relationshipIfOther":""},"educationInformation":{"educationLevel":"Other","degree":"","college":"","otherEducation":"test","otherDegree":"","otherCollege":""},"dataNCITL":{"licenseIssuedbyTheNCITLB":"No, I do not have an NC interpreter license.","NCITLBLicenseNumber":""},"certificateInformation":{"holdInterpreterCert":"No","RIDNumber":"test","assessmentLevel":"","certificateValue":""},"knowledgeInformation":{"tkenCASLINICOrCDIKnowledgeExam":"No","passedCASLINICOrCDIKnowledge":"No","planningCASLINICOrCDIKnowledge":"No set plans to take the test."},"performanceInformation":{"takenCASLINICOrCDIPerformanceExam":"No","passedCASLINICOrCDIPerformanceExam":"No","howManyTimesCASLINICOrCDIPerforma":null,"lastCASLINICOrCDIPerformanceExam":"2020","planningCASLINICOrCDIPerformance":"No","timePeriodCASLINICOrCDIPerformance":"No set plans to take the test."},"eipaInformtion":{"AreYouPlanningToTakeTheEIPA":"No","haveYouTakenTheEIPA":"No","lastTaketheEIPA":"2020","whatIsYourEIPAScore":null,"whenDoYouPlanToTakeTheEIPA":"No set plans to take the test."},"percentageInformation":{"videoRelayInterpreting":"0%","videoRemoteInterpreting":"0%","communityFreelance":"0%","eucationalK12":"0%","educationalPostSecondary":"0%","other":"0%","hoursWorkedinMedicalSettings":"0"},"skillsInformation":{"informationAssistance":"","interpretingSkillDevelopment":"","mentoringservices":""},"otherinformation":{"areYouOnDHHSInterpreterVendorList":"No","after5Years":"","oherAfter5Year":"","currentSkillDevelopmentGoals":"","workshopInNorthCarolina":""}}';
        Map<String, Object> resultMap = NC_MentoringRequestController.createMentoringRequestRecord(wizardData, contactObj.id);
        System.assertNotEquals(null, resultMap.get('url'));
    }
}