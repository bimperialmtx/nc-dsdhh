@isTest
public class SurveyResponseTriggerHandlerTest {

    static testmethod void checkConsumerTest() {
        List<SurveyQuestionResponse> newList = new  List<SurveyQuestionResponse>();
        Map<Id,SurveyQuestionResponse> oldMap = new Map<Id,SurveyQuestionResponse>();
        
        Contact test_contact = new Contact(FirstName='Orig First Name',LastName='Orig Last Name',Email='orig@email.com');
       insert test_contact;

        //Insert a test survey
       Survey survey = new Survey();
       survey.Id = '5555555555';
       //insert survey;

        test.startTest();
        NC_SurveyQuestionResponseTriggerHandler.checkConsumer(newList,oldMap); 
        test.stopTest();
    }
}