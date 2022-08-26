/**
 * Created by ashishpandey on 08/07/21.
 * Trainer/Agency/Account Lookup in KLAS Database
 */

public class NC_NDBEDPTrainerSearch implements Queueable,Database.AllowsCallouts{
    public List<Account> accounts;
    public NC_NDBEDPTrainerSearch(List<Account> accList){
        accounts = accList ;

    }
    public void execute(QueueableContext qc){

        String api_key = String.valueOf(Label.NDBEDP_Key);
        //****Setting up the request param*****
        String patronName = accounts[0].First_Name__c+' '+accounts[0].Last_Name__c;

        String patronType = 'TA';
        String endPointTemp = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        String endPoint= endPointTemp+'?PatronName='+patronName+'&PatronType='+patronType;

        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint.replace(' ', '%20'));

        if(accounts[0].Patron_ID__c!=null){
            try{
                res = h.send(httpReq);
            }catch (Exception e){
                accounts[0].Allow_NDBEDP_Resync__c=true;
                update accounts;
                NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,patronName,e.getMessage(),e.getMessage(),'503',accounts[0]);
            }
            if(res!=null){
               
                NC_NDBEDPWrapper responseWrapper = (NC_NDBEDPWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPWrapper.class);

                if(responseWrapper.STATUS == 200) {
                    String patronId='';String patronObj='';String statusCode='';String libraryId='';
                    if(responseWrapper.patrons!=null){
                        for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                            //Comparing the Consumer in SMS with search result
                            if(person.FirstName==accounts[0].First_Name__c && person.LastName==accounts[0].Last_Name__c) {
                                patronId = person.PatronID;
                                patronObj = person.PatronObj;
                                statusCode = person.StatusCode;
                                libraryId = person.LibraryId;
                                break;
                            }
                        }
                        if(String.isNotBlank(patronId)) {
                            Account acc =[SELECT Id,Patron_ID__c,Patron_Obj__c,Status_Code__c,Library_ID__c FROM Account WHERE Id=:accounts[0].Id];
                            acc.Patron_ID__c = patronId;
                            acc.Patron_Obj__c = patronObj;
                            acc.Status_Code__c = statusCode;
                            acc.Library_ID__c = libraryId;
                            try{
                                update acc;
                            }catch (Exception e){
                                NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,patronName,res.getBody(),e.getMessage(),String.valueOf(responseWrapper.STATUS),accounts[0]);
                            }

                            //Now fetch Patron By Id so that we can get Patron Contact Info and compare with SMS
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_TrainerSearchById(accounts));
                            }
                        }
                    }else {
                        System.enqueueJob(new NC_NDBEDP_TrainerCreateUpdate(accounts));
                    }

                }else{
                    accounts[0].Allow_NDBEDP_Resync__c=true;
                    update accounts;
                    NC_CNDSUtility.insertNDBEDPTrainerError(endPointTemp,patronName,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),accounts[0]);

                }
            }
        }else {
            System.enqueueJob(new NC_NDBEDP_TrainerCreateUpdate(accounts));
        }

    }

}