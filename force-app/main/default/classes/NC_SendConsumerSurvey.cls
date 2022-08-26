/**
 * @description       : 
 * @author            : Gourav Nirwal
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_SendConsumerSurvey {
    /*
    *********************************************************
    @Method Name    : createSurveyInvitaions
    @description    : Create Survey Invitation for Consumers
    @param          : Id recordId, List<Id> contactIds, Map<String,Object> data
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> createSurveyInvitaions(Id recordId, List<Id> contactIds, Map<String,Object> data) {
        Map<String,Object> result = new Map<String,Object>();
        List<SurveyInvitation> surveyInvitationList = new List<SurveyInvitation>();
        for(Contact consumer : [SELECT Id,Email,Name FROM Contact WHERE ID IN : contactIds WITH SECURITY_ENFORCED]){
            SurveyInvitation invitation = new SurveyInvitation();
            invitation.Name = consumer.Id + ' ' + System.now() + ' ' + System.Label.Survey_Network_Id;
            invitation.Consumer_Email__c = consumer.Email;
            invitation.Consumer_Name__c = consumer.Name;
            invitation.SurveyId = recordId;
            invitation.CommunityId = System.Label.Survey_Network_Id;
            //invitation.ParticipantId = consumer.Id;
            invitation.Consumer_Id__c = consumer.Id;
            if(data.containsKey('MultipleTime')  && Boolean.valueOf(data.get('MultipleTime')) == true){
                invitation.OptionsCollectAnonymousResponse = true;            
            }
            if(data.containsKey('ExpirationDate') && data.get('ExpirationDate') != null){
                invitation.InviteExpiryDateTime = Datetime.valueOf(String.valueOf(data.get('ExpirationDate')).replace('T',' '));
            }
            invitation.OptionsAllowGuestUserResponse = true;
            surveyInvitationList.add(invitation);
        }
        if(!surveyInvitationList.isEmpty()){
            if(Schema.SObjectType.SurveyInvitation.isCreateable()){
               // Insert surveyInvitationList;
               SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('SurveyInvitation', surveyInvitationList, 'insert', true,'NC_SendConsumerSurvey','createSurveyInvitaions');
               insert objectDecision.getRecords();
               //result.put('invitation',surveyInvitationList);
               result.put('success',true);
            }
        }
        return result;
    }
}