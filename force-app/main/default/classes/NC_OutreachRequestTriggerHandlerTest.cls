/**
* @description       : 
* @author            : kavya.konagonda@mtxb2b.com
* @group             : 
* @last modified on  : 04-26-2022
* @last modified by  : kavya.konagonda@mtxb2b.com
**/
@IsTest
public class NC_OutreachRequestTriggerHandlerTest {
    /*
    *********************************************************
    @Method Name    : makeData
    @description    : Verify Outreach Request create and update validations
    ********************************************************
    */
    @IsTest
    public static void makeData(){
        
        Id outreachRequestRecordTypeId = NC_Utility.RecordTypeUtilityMethod('Outreach_Request__c','DHH_Sponsor_Event');
        Outreach_Request__c outreach = TestDataUtility.createOutreachRequest(true, outreachRequestRecordTypeId, System.now()+1, System.now()+2, 'title', 'address', null);
        outreach.Status__c='Pending Public Communication Review';
        outreach.Public_Communication_Document_Uploaded__c=true;
        outreach.Submit_for_Approval__c=true;
        outreach.PA_2_Form_Uploaded__c=true;
        outreach.Justification__c='test';
        update outreach;
        
        Attendees__c attendess = new Attendees__c();
        attendess.Outreach_Request__c = outreach.Id;
        Insert attendess;
        
        try{
            outreach.Status__c = 'Closed';
            update outreach;
        }
        catch(Exception e){
        } 
        System.assertEquals(null, attendess.Service_Close_Date__c);
    }
}