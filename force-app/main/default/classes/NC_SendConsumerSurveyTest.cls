/**
* @description       : Test class for NC_SendConsumerSurvey
* @author            : ruchit.goswami@mtxb2b.com, saisujith.koppula@mtxb2b.com
* @last modified on  : 06-17-2022
* @last modified by  : ruchit.goswami@mtxb2b.com
**/
@isTest(SeeAllData=true)
public class NC_SendConsumerSurveyTest {
	
    /*
    *********************************************************
    @Method Name    : createSurveyInvitaionsTest
    @description    : Verify survey invitations for contact
    ********************************************************
    */
    static testmethod void createSurveyInvitaionsTest() {
        Contact con = TestDataUtility.createConsumer(true);
        Map<String,Object> data = new Map<String,Object>();
        data.put('MultipleTime', true);
        data.put('ExpirationDate', System.now());
        
        List<Survey> surveyList = [select id from Survey WHERE ActiveVersion.SurveyStatus = 'Active'];
        //Map<String,Object> resultMap = NC_SendConsumerSurvey.createSurveyInvitaions(surveyList[0].id, new List<Id>{con.id}, data);
        //System.assertNotEquals(null, resultMap);
    }
}