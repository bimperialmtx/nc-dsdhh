/**
 * Created by ashishpandey on 22/07/21.
 */

/**
 * Internal Assessor Sync
 */
public class NC_NDBEDP_AssessorSearch implements Queueable,Database.AllowsCallouts {
    public List<User> users;
    public NC_NDBEDP_AssessorSearch(List<User> userList){
        users = userList ;

    }
    public void execute(QueueableContext qc){

        String api_key = String.valueOf(Label.NDBEDP_Key);
        //****Setting up the request param*****
        String patronName = users[0].FirstName+' '+users[0].LastName; 

        String patronType = users[0].Patron_Type__c!=null?users[0].Patron_Type__c:'';

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

        if(users[0].Patron_ID__c!=null){
            try{
                res = h.send(httpReq);
            }catch (Exception e){
                users[0].Allow_NDBEDP_Resync__c=true;
                update users;
                NC_CNDSUtility.insertNDBEDPAssessorError(endPointTemp,patronName,e.getMessage(),e.getMessage(),'503',users[0]);
            }
            if(res!=null){

                NC_NDBEDPWrapper responseWrapper = (NC_NDBEDPWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPWrapper.class);

                if(responseWrapper.STATUS == 200) {
                    String patronId='';String patronObj='';String statusCode='';String libraryId='';
                    if(responseWrapper.patrons!=null){
                        for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                            //Comparing the Consumer in SMS with search result
                            if(person.FirstName==users[0].FirstName && person.LastName==users[0].LastName) {
                                patronId = person.PatronID;
                                patronObj = person.PatronObj;
                                statusCode = person.StatusCode;
                                libraryId = person.LibraryId;
                                break;
                            }
                        }
                        if(String.isNotBlank(patronId)) {

                            User user =[SELECT Id,Patron_ID__c,Patron_Obj__c,Status_Code__c,Library_ID__c FROM User WHERE Id=:users[0].Id];
                            user.Patron_ID__c = patronId;
                            user.Patron_Obj__c = patronObj;
                            user.Status_Code__c = statusCode;
                            user.Library_ID__c = libraryId;
                            update user;

                            //Now fetch Patron By Id so that we can get Patron Contact Info and compare with SMS
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_AssessorSearchById(users));
                            }
                             
                        }else {
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_AssessorCreateUpdate(users));
                            }
                        }
                    }else {
                        if(!Test.isRunningTest()){
                         	System.enqueueJob(new NC_NDBEDP_AssessorCreateUpdate(users));   
                        }
                    }

                }else{
                    //users[0].Allow_NDBEDP_Resync__c=true;
                    update users;
                    NC_CNDSUtility.insertNDBEDPAssessorError(endPointTemp,patronName,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),users[0]);

                }
            }
        }else {
            if(!Test.isRunningTest()){
             	System.enqueueJob(new NC_NDBEDP_AssessorCreateUpdate(users));   
            }
        }

    }


}