/**
 * Created by ashishpandey on 22/07/21.
 * Internal Assessor Sync With KLAS
 */

public class NC_NDBEDP_AssessorCreateUpdate implements Queueable,Database.AllowsCallouts{

    public List<User> users;
    public NC_NDBEDP_AssessorCreateUpdate(List<User> userList){ 
        users = userList ;

    }
    public void execute(QueueableContext qc){

        NC_NDBEDPRequestWrapper requestBody = new NC_NDBEDPRequestWrapper();
        List<NC_NDBEDPRequestWrapper.PatronContacts> patronContacts = new List<NC_NDBEDPRequestWrapper.PatronContacts>();
        List<NC_NDBEDPRequestWrapper.PatronContactPrefs> patronContactPrefs = new List<NC_NDBEDPRequestWrapper.PatronContactPrefs>();

        //****Map of County Name Vs Code***************
        Map<String,String> countyNameVsCode = new Map<String, String>();
        for(County_Codes_and_Names__mdt mtd :[SELECT Id,County_Code__c,County_Name__c FROM County_Codes_and_Names__mdt]){
            countyNameVsCode.put(mtd.County_Name__c,mtd.County_Code__c);
        }

        //***Language Map****************
        Map<String, String> languageMap = new Map<String, String>();
        languageMap.put('English', 'EN');
        languageMap.put('Spanish', 'SP');
        languageMap.put('Signed English', 'SEE');
        languageMap.put('ASL(American Sign Language)', 'ASL');
        languageMap.put('No Formal Language', 'NFL');


        //****Setting up the request param***************
        requestBody.PatronID= users[0].Patron_ID__c!=null?users[0].Patron_ID__c:'';
        requestBody.StatusCode= users[0].Status_Code__c!=null?users[0].Status_Code__c:'';
        requestBody.LastName= users[0].LastName!=null?users[0].LastName:null;
        requestBody.FirstName= users[0].FirstName!=null?users[0].FirstName:null;
        requestBody.MI= users[0].MiddleName!=null?users[0].MiddleName.left(1):'';
        requestBody.SuffixCode= users[0].Suffix!=null?users[0].Suffix.left(3):null;
        requestBody.BirthDate= users[0].BirthDate__c!=null?String.valueOf(users[0].BirthDate__c):'';
        if (users[0].Gender__c!=null) {
            requestBody.Gender= users[0].Gender__c=='Male'?'M':'F';
        }else {
            requestBody.Gender='';
        }

        if (users[0].Ethnicity__c!=null) {
            requestBody.Ethnicity = users[0].Ethnicity__c!=null && users[0].Ethnicity__c=='Hispanic/Latino' ?'LAT':'OTH';
        }else {
            requestBody.Ethnicity= '';
        }

        String langCode='';
        if(users[0].Primary_Language__c=='English' || users[0].Primary_Language__c=='Spanish' || users[0].Primary_Language__c=='ASL(American Sign Language)'){
            langCode = languageMap.get(users[0].Primary_Language__c);
        }else {
            langCode='OTH';
        }
        requestBody.LanguageCode= langCode;
        requestBody.LibraryID= 'NC';
        requestBody.RegEndDate= String.valueOf(Date.today()+365);
        requestBody.PatronType= users[0].Patron_Type__c!=null?users[0].Patron_Type__c:'';
        String CountyCode='';
        If(users[0].County__c!=null){
            CountyCode=countyNameVsCode.get(users[0].County__c);
        }

        //****Constructing the patronContacts phone request param*****
        if(users[0].MobilePhone!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= users[0].Patron_Contact_Obj_MobilePhone__c!=null?users[0].Patron_Contact_Obj_MobilePhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='CellP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=users[0].MobilePhone;

            patronContacts.add(patContact);
        }
        if(users[0].Work_Phone_Number__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= users[0].Patron_Contact_Obj_WorkPhone__c!=null?users[0].Patron_Contact_Obj_WorkPhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='WorkP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=users[0].Work_Phone_Number__c;

            patronContacts.add(patContact);
        }
        if(users[0].Alt_Phone_Number__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= users[0].Patron_Contact_Obj_AltPhone__c!=null?users[0].Patron_Contact_Obj_AltPhone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='OthP';
            patContact.ContactMode='SMS';
            patContact.ContactValue=users[0].Alt_Phone_Number__c;

            patronContacts.add(patContact);
        }
        //Video Phone
        if(users[0].Video_Phone__c!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= users[0].Patron_Contact_Obj_Video_Phone__c!=null?users[0].Patron_Contact_Obj_Video_Phone__c:'';
            patContact.ContactType='PH';
            patContact.ContactSubType='VidP';
            patContact.ContactMode='VID';
            patContact.ContactValue=users[0].Video_Phone__c; 

            patronContacts.add(patContact);
        }
        //****Constructing the patronContacts Email request param*****
        if(users[0].Email!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= users[0].Patron_Contact_Obj_Email__c!=null?users[0].Patron_Contact_Obj_Email__c:'';
            patContact.ContactType='EM';
            patContact.ContactSubType='Email';
            patContact.ContactMode='TXT';
            patContact.ContactValue=users[0].Email;

            patronContacts.add(patContact);
        }
        //****Constructing the patronContacts Address request param*****
        //Physical Address
        if(users[0].Street!=null){
            NC_NDBEDPRequestWrapper.PatronContacts patContact = new NC_NDBEDPRequestWrapper.PatronContacts();
            patContact.PatronContactObj= users[0].Patron_Contact_Obj_Add__c!=null?users[0].Patron_Contact_Obj_Add__c:'';
            patContact.ContactType ='ADDR';
            patContact.ContactSubType ='HomeA';
            patContact.ContactMode ='BRL';
            patContact.ContactValue = users[0].Street;
            patContact.Address = users[0].Street;
            patContact.City = users[0].City!=null?users[0].City:'';
            patContact.PostalCode = users[0].PostalCode!=null?users[0].PostalCode:'';
            patContact.CountyCode = CountyCode;
            if (users[0].CountryCode!=null) {
                patContact.CountryCode = users[0].CountryCode=='US'?'USA':users[0].CountryCode;
            }else {
                patContact.CountryCode='';
            }

            patContact.StateCode = users[0].StateCode!=null?users[0].StateCode:'';

            patronContacts.add(patContact);
        }

        //****Constructing the patronContacts Preferred Method request param*****
        if (users[0].Preferred_Contact_Method__c!=null) {
            NC_NDBEDPRequestWrapper.PatronContactPrefs patContactPref = new NC_NDBEDPRequestWrapper.PatronContactPrefs();
            if(users[0].Preferred_Contact_Method__c=='Email'){
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = users[0].Email;
                patContactPref.ContactSubType ='Email';
                patContactPref.ContactType ='EM';
                patContactPref.PatContactPrefType ='EM/HomeE';
            }else if (users[0].Preferred_Contact_Method__c=='Mobile Phone') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = users[0].MobilePhone;
                patContactPref.ContactSubType ='CellP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / CellP';
            }else if (users[0].Preferred_Contact_Method__c=='Work Phone') { 
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = users[0].Work_Phone_Number__c;
                patContactPref.ContactSubType ='WorkP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / WorkP';
            }else if (users[0].Preferred_Contact_Method__c=='Alternative Phone') {
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = users[0].Alt_Phone_Number__c;
                patContactPref.ContactSubType ='OthP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / OthP';
            }else if(users[0].Preferred_Contact_Method__c=='Video Phone'){ 
                patContactPref.ActiveDate ='';
                patContactPref.FuncCode ='Header';
                patContactPref.Order ='1';
                patContactPref.ContactValue = users[0].Video_Phone__c;
                patContactPref.ContactSubType ='VidP';
                patContactPref.ContactType ='PH';
                patContactPref.PatContactPrefType ='PH / VidP';
            }
            patronContactPrefs.add(patContactPref);

        }

        //****Setting up the patronContacts request param*****
        requestBody.PatronContacts=patronContacts;
        //****Setting up the patronContactPrefs request param*****
        requestBody.PatronContactPrefs=patronContactPrefs;


        String body= JSON.serialize(requestBody);


        String api_key = String.valueOf(Label.NDBEDP_Key);
        String endPointTemp = String.valueOf(Label.NDBEDP_Patron_Search_Create_N1_N2);
        Http h = new Http();
        HttpRequest httpReq = new HttpRequest();

        httpReq.setMethod('POST');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Content-Type','application/json');
        httpReq.setHeader('X-API-KEY',api_key);
        httpReq.setEndpoint(endPointTemp);
        httpReq.setBody(body);
        HttpResponse res;
        try{
            res = h.send(httpReq);
        }catch (Exception e){
            users[0].Allow_NDBEDP_Resync__c=true;
            update users;
            NC_CNDSUtility.insertNDBEDPAssessorError(endPointTemp,body,e.getMessage(),e.getMessage(),'503',users[0]);
        }

       
        NC_NDBEDPResponseWrapper responseWrapper = (NC_NDBEDPResponseWrapper)JSON.deserialize(res.getBody(),NC_NDBEDPResponseWrapper.class);

        if(res.getStatusCode() == 200) {
            if(responseWrapper.STATUS!=500){
                User useObj =[SELECT Id,Patron_Contact_Obj_Video_Phone__c,Address_Link_Obj__c,Patron_ID__c,Patron_Obj__c,Library_ID__c,Patron_Contact_Obj_WorkPhone__c,Allow_NDBEDP_Resync__c,Status_Code__c,
                        Patron_Contact_Obj_Add__c,Patron_Contact_Obj_Email__c,Patron_Contact_Obj_MobilePhone__c,Patron_Contact_Obj_AltPhone__c FROM User WHERE Id=:users[0].Id];
                useObj.Patron_ID__c =responseWrapper.Patron.PatronID;
                useObj.Patron_Obj__c =responseWrapper.Patron.PatronObj;
                useObj.Library_ID__c='NC';

                if (responseWrapper.Patron.PatronContacts!=null) {
                    for(NC_NDBEDPResponseWrapper.PatronContacts patContact :responseWrapper.Patron.PatronContacts){
                        if(patContact.ContactType=='ADDR' && patContact.ContactSubType=='HomeA'){
                            useObj.Address_Link_Obj__c = patContact.AddressLinkObj;
                            useObj.Patron_Contact_Obj_Add__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='EM' && patContact.ContactSubType=='Email'){
                            useObj.Patron_Contact_Obj_Email__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='CellP'){
                            useObj.Patron_Contact_Obj_MobilePhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='WorkP'){
                            useObj.Patron_Contact_Obj_WorkPhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='OthP'){
                            useObj.Patron_Contact_Obj_AltPhone__c = patContact.PatronContactObj;
                        }
                        if(patContact.ContactType=='PH' && patContact.ContactSubType=='VidP'){
                            useObj.Patron_Contact_Obj_Video_Phone__c = patContact.PatronContactObj;
                        }

                    }
                }

                useObj.Allow_NDBEDP_Resync__c=false;
                useObj.Status_Code__c='A';

                try{
                    update useObj;
                }catch (Exception e){
                    NC_CNDSUtility.insertNDBEDPAssessorError(endPointTemp,body,e.getMessage(),e.getMessage(),'503',users[0]);
                }

            }else {
                users[0].Allow_NDBEDP_Resync__c=true;
                update users;
                NC_CNDSUtility.insertNDBEDPAssessorError(endPointTemp,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),users[0]);
            }

        }else{
            users[0].Allow_NDBEDP_Resync__c=true;
            update users;
            NC_CNDSUtility.insertNDBEDPAssessorError(endPointTemp,body,res.getBody(),responseWrapper.ERROR_DESCRIPTION,String.valueOf(responseWrapper.STATUS),users[0]);
        }

    }
}