/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public without sharing class NC_CampaignMemberController {
    
    /*
    *********************************************************
    @Method Name    : getCampgaignMember
    @description    : Get campgain member by id
    @param          : Id recordId
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> getCampgaignMember(Id recordId) {
        Map<String,Object> result = new Map<String,Object>();
        List<Id> contactIdList = new  List<Id>();

        Campaign campaignRecord = [SELECT Id, CreatedDate, Regional_Center_Office__c,Communications_Type__c FROM Campaign WHERE Id =: recordId WITH SECURITY_ENFORCED];
        
        for(CampaignMember member : [SELECT Id,ContactId FROM CampaignMember WHERE CampaignId =: recordId WITH SECURITY_ENFORCED]){
            contactIdList.add(member.ContactId);
        }

        result.put('campaignRecord',campaignRecord);
        result.put('contactList',[SELECT Id FROM contact WHERE Id IN: contactIdList]);
        return result;
    }

    /*
    *********************************************************
    @Method Name    : createCampaignMember
    @description    : Create campgain member
    @param          : Id recordId, List<Id> contactIds
    @return         : Map<String,Object>
    ********************************************************
    */
    @AuraEnabled
    public static Map<String,Object> createCampaignMember(Id recordId, List<Id> contactIds) {
        Map<String,Object> result = new Map<String,Object>();
        List<CampaignMember> CampaignMemberList = new  List<CampaignMember>();
        for(Id contactId : contactIds){
            CampaignMember member = new CampaignMember();
            member.ContactId = contactId;
            member.CampaignId = recordId;
            CampaignMemberList.add(member);
        }
        if(!CampaignMemberList.isEmpty()){
            SObjectAccessDecision objectDecision = SecurityLibrary.getAccessibleData('CampaignMember', CampaignMemberList, 'insert', true,'NC_CampaignMemberController','createCampaignMember');
            insert objectDecision.getRecords();
            result.put('success',true);
        }
        return result;
    }
}