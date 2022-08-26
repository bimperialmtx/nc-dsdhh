/**
 * Created by ashishpandey on 08/07/21.
 * NDBEDP Trainer search by id
 */

public without sharing class NC_NDBEDP_TrainerSearchById implements Queueable,Database.AllowsCallouts{
    public List<Account> accounts;
    public NC_NDBEDP_TrainerSearchById(List<Account> accList){
        accounts = accList ;

    }
    public void execute(QueueableContext qc){

        Account accountObj;//null
        for(Account acc :[SELECT Id,County__c,Allow_NDBEDP_Resync__c,Status_Code__c,Phone,Cell_Phone__c,Work_Phone__c,Alternative_Email__c,Alternative_Phone__c,Email__c, First_Name__c,Last_Name__c,Middle_Name__c,Primary_Language__c,
                BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,BillingStreet,BirthDate__c,Gender__c,Patron_ID__c
        FROM Account WHERE Id=:accounts[0].Id]){
            accountObj=acc;
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
        String patronId = accountObj!=null?accountObj.Patron_ID__c:'';

        String patronType = 'CNS';
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
            accounts[0].Allow_NDBEDP_Resync__c=true;
            update accounts;
            NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,patronId,e.getMessage(),e.getMessage(),'503',accounts[0]);
        }
        if(res!=null){
            NC_NDBEDPWrapper responseWrapper = (NC_NDBEDPWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPWrapper.class);
            if(responseWrapper.STATUS == 200) {
                if(responseWrapper.patrons!=null){
                    for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                        String genderCode;
                        if (accountObj.Gender__c!=null) {
                            genderCode= accountObj.Gender__c=='Male'?'M':'F';
                        }
                        if (person.GenderCode!=genderCode) {
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_TrainerCreateUpdate(accounts));
                            }
                            break;
                        }else
                        if(person.PatronContacts!=null){
                            for (NC_NDBEDPWrapper.PatronContacts patronCon:person.PatronContacts){
                                if (patronCon.CountyCode!= countyNameVsCode.get(accountObj.County__c)
                                        || patronCon.ContactType=='PH' && patronCon.ContactSubType=='CellP' && patronCon.ContactValue!=accountObj.Cell_Phone__c
                                        || patronCon.ContactType=='PH' && patronCon.ContactSubType=='WorkP' && patronCon.ContactValue!=accountObj.Work_Phone__c
                                        || patronCon.ContactType=='PH' && patronCon.ContactSubType=='OthP' && patronCon.ContactValue!=accountObj.Alternative_Phone__c
                                        || patronCon.ContactType=='EM' && patronCon.ContactSubType=='Email' && patronCon.ContactValue!=accountObj.Email__c) {
                                            if(!Test.isRunningTest()){
                                    System.enqueueJob(new NC_NDBEDP_TrainerCreateUpdate(accounts));
                                            }
                                    break;
                                }else {
                                    //accounts[0].Allow_NDBEDP_Resync__c=false;
                                    //update accounts; 
                                }
                            }
                        }
                    }
                }else {
                    accounts[0].Allow_NDBEDP_Resync__c=true;
                    update accounts;
                    NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,patronId,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),accounts[0]);
                }
            }else{
                accounts[0].Allow_NDBEDP_Resync__c=true;
                update accounts;
                //insertErrorRecord(String endPoint,String req, String res, String error_Desc, String statusCode, Contact con)
                NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,patronId,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),accounts[0]);

            }
        }
    }
}