/**
* Created by ashishpandey on 29/06/21.
* NDBEDP Patron search
*/

public class NC_NDBEDP_PatronSearch implements Queueable,Database.AllowsCallouts {
    public List<Contact> contacts;
    public NC_NDBEDP_PatronSearch(List<Contact> conList){
        contacts = conList ;
        
    }
    public void execute(QueueableContext qc){
        
        String api_key = String.valueOf(Label.NDBEDP_Key);
        //****Setting up the request param*****
        String patronName = contacts[0].FirstName+' '+contacts[0].LastName;
        
        String patronType = 'CNS';
        String endPointTemp = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        String endPoint= endPointTemp+'?PatronName='+patronName+'&PatronType='+patronType;
        //String endPoint= 'https://eis.dhstst.nc.gov/ws/rest/klas/patrons?PatronName='+patronName+'&PatronType='+patronType;
        
        Http h = new Http();
        HttpResponse res;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPoint.replace(' ', '%20'));
        
        if(contacts[0].Patron_ID__c==null){
            try{
                res = h.send(httpReq);
            }catch (Exception e){
                contacts[0].Allow_NDBEDP_Resync__c=true;
                update contacts;
                NC_CNDSUtility.insertNDBEDPError(endPoint,patronName,e.getMessage(),e.getMessage(),'503',contacts[0]);
            }
            if(res!=null){
              
                
                NC_NDBEDPWrapper responseWrapper = (NC_NDBEDPWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPWrapper.class);
                
                if(responseWrapper.STATUS == 200) {
                    String patronId='';String patronObj='';String statusCode='';String libraryId='';
                    if(responseWrapper.patrons!=null){
                        for(NC_NDBEDPWrapper.patrons person:responseWrapper.patrons){
                            //Comparing the Consumer in SMS with search result
                            Contact conObj = contacts[0];
                            if(conObj.FirstName!=null && conObj.LastName!=null && conObj.Birthdate!=null){
                                if(person.FirstName==conObj.FirstName && person.LastName==conObj.LastName  && person.BirthDate==String.valueOf(conObj.Birthdate)) {
                                    if (conObj.MiddleName!=null && person.MI==conObj.MiddleName) {
                                        patronId = person.PatronID;
                                        patronObj = person.PatronObj;
                                        statusCode = person.StatusCode;
                                        libraryId = person.LibraryId;
                                        break;
                                    }else if (conObj.MiddleName==null) {
                                        patronId = person.PatronID;
                                        patronObj = person.PatronObj;
                                        statusCode = person.StatusCode;
                                        libraryId = person.LibraryId;
                                        break;
                                    }
                                    
                                }
                            }
                        }
                        if(String.isNotBlank(patronId)) {
                            contacts[0].Patron_ID__c = patronId;
                            contacts[0].Patron_Obj__c = patronObj;
                            contacts[0].Status_Code__c = statusCode;
                            contacts[0].Library_ID__c = libraryId;
                            try{
                                update contacts;
                            }catch (Exception e){
                                contacts[0].Allow_NDBEDP_Resync__c=true;
                                update contacts;
                                NC_CNDSUtility.insertNDBEDPError(endPoint,patronName,res.getBody(),e.getMessage(),String.valueOf(responseWrapper.STATUS),contacts[0]);
                            }
                            
                            //Now fetch Patron By Id so that we can get Patron Contact Info and compare with SMS
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_PatronSearchById(contacts));
                            }
                            if(contacts[0].Status_Code__c == 'T') {//|| contacts[0].Status_Code__c == 'A'
                                NC_FetchEquipmentHistory.fetchEquipmentHistoryFuture(contacts[0].id);
                            }
                        }else {
                            if(!Test.isRunningTest()){
                            System.enqueueJob(new NC_NDBEDP_PatronCreateUpdate(contacts));
                            }
                        }
                    }else {
                        System.enqueueJob(new NC_NDBEDP_PatronCreateUpdate(contacts));
                    }
                    
                }else{
                    contacts[0].Allow_NDBEDP_Resync__c=true;
                    update contacts;
                    NC_CNDSUtility.insertNDBEDPError(endPoint,patronName,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),contacts[0]);
                    
                }
            }
        }else {
            if(!Test.isRunningTest()){
            System.enqueueJob(new NC_NDBEDP_PatronCreateUpdate(contacts));
            }
        }
        
    }
}