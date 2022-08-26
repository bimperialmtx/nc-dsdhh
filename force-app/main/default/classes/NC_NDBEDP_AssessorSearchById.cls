/**
 * Created by ashishpandey on 22/07/21.
 * NDBEDP Assessor search by id
 */

public class NC_NDBEDP_AssessorSearchById implements Queueable,Database.AllowsCallouts{
    public List<User> users;
    public NC_NDBEDP_AssessorSearchById(List<User> userList){
        users = userList ;

    }
    public void execute(QueueableContext qc){

        User userObj;//null
        for(User use :[SELECT Id,Allow_NDBEDP_Resync__c,MobilePhone,Status_Code__c,Work_Phone_Number__c,Alt_Phone_Number__c,Email, FirstName,LastName,MiddleName,Primary_Language__c,
                City,PostalCode,StateCode,CountryCode,Street,BirthDate__c,Gender__c,Patron_ID__c
        FROM User WHERE Id=:users[0].Id]){
            userObj=use;
        }
        //***Language Map****************
        Map<String, String> languageMap = new Map<String, String>();
        languageMap.put('ASL', 'ASL(American Sign Language)');
        languageMap.put('EN', 'English');
        languageMap.put('NFL', 'No Formal Language');
        languageMap.put('SP', 'Spanish');
        languageMap.put('SEE', 'Signed English');

        //****Map of County Name Vs Code***************
        Map<String,String> countyNameVsCode = new Map<String, String>();
        for(County_Codes_and_Names__mdt mtd :[SELECT Id,County_Code__c,County_Name__c FROM County_Codes_and_Names__mdt]){
            countyNameVsCode.put(mtd.County_Name__c,mtd.County_Code__c);
        }


        String api_key = String.valueOf(Label.NDBEDP_Key);
        //****Setting up the request param*****
        String patronId = userObj!=null?userObj.Patron_ID__c:'';

        String patronType = 'TA';
        String endPointTemp = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        String endPoint= endPointTemp+'?PatronId='+patronId;

        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint);

        try{
            res = h.send(httpReq);
        }catch (Exception e){
            users[0].Allow_NDBEDP_Resync__c=true;
            update users;
            NC_CNDSUtility.insertNDBEDPAssessorError(endPoint,patronId,e.getMessage(),e.getMessage(),'503',users[0]);
        }
        if(res!=null){
            NC_NDBEDPWrapper responseWrapper = (NC_NDBEDPWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPWrapper.class);
            if(responseWrapper.STATUS == 200) {
                if(responseWrapper.patrons!=null){
                    for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                        String genderCode;
                        if (userObj.Gender__c!=null) {
                            genderCode= userObj.Gender__c=='Male'?'M':'F';
                        }
                        if (person.GenderCode!=genderCode) {
                             if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_AssessorCreateUpdate(users));
                             }
                        }else
                        if(person.PatronContacts!=null){
                            for (NC_NDBEDPWrapper.PatronContacts patronCon:person.PatronContacts){
                                if (patronCon.City!=userObj.City
                                        || patronCon.PostalCode!=userObj.PostalCode
                                        || patronCon.StateCode!=userObj.StateCode
                                        || patronCon.ContactType=='PH' && patronCon.ContactSubType=='CellP' && patronCon.ContactValue!=userObj.MobilePhone
                                        || patronCon.ContactType=='PH' && patronCon.ContactSubType=='WorkP' && patronCon.ContactValue!=userObj.Work_Phone_Number__c
                                        || patronCon.ContactType=='PH' && patronCon.ContactSubType=='OthP' && patronCon.ContactValue!=userObj.Alt_Phone_Number__c
                                        || patronCon.ContactType=='EM' && patronCon.ContactSubType=='Email' && patronCon.ContactValue!=userObj.Email) {
                                             if(!Test.isRunningTest()){
                                    System.enqueueJob(new NC_NDBEDP_AssessorCreateUpdate(users));
                                             }
                                    break;
                                }else {
                                    //users[0].Allow_NDBEDP_Resync__c=false;
                                    //update users;
                                }
                            }
                        }
                    }
                }else {
                    users[0].Allow_NDBEDP_Resync__c=true;
                    update users;
                    NC_CNDSUtility.insertNDBEDPAssessorError(endPoint,patronId,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),users[0]);
                }
            }else{
                users[0].Allow_NDBEDP_Resync__c=true;
                update users;
                //insertErrorRecord(String endPoint,String req, String res, String error_Desc, String statusCode, Contact con)
                NC_CNDSUtility.insertNDBEDPAssessorError(endPoint,patronId,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),users[0]);

            }
        }
    }
}