/*
*   Class Name: NC_DocumentViewerController
*   Description: Visual Force Document Data Helper
*
*   Date            New/Modified         User                 Identifier                Description
*   23/04/2020         New         Shubham Dadhich(mtx)
*/

public without sharing class NC_DocumentViewerController {
    public contactData contactDataObj {get;set;}
    public String url {get;set;}

    /*
    * Method Name: NC_DocumentViewerController
    * Description: Constructor - To Fetch Id Of From URL Paramaters
    * @param: 
    * @return void
    */
    public NC_DocumentViewerController() {
        fetchSign(ApexPages.currentPage().getParameters().get('id').escapeHtml4());
    }
    
    /*
    *********************************************************
    @Method Name    : fetchSign
    @description    : Fetch Sign to Add On Document
    @param          : String recordId
    @return         : void
    ********************************************************
    */
    public void fetchSign(String recordId){
        Attachment attachment = new Attachment();

        //Fetch Data from Object Record
        Contact con = [SELECT Id, Name, Phone, Email, MailingCity, MailingStreet, MailingCountry FROM Contact WHERE Id =: recordId WITH SECURITY_ENFORCED];

        //Parse in Document Wrapper
        contactDataObj = new contactData(con.Name, con.phone, con.Email, con.MailingCity, con.MailingStreet, con.MailingCountry);

        //Fetch Sign From Attachment Object
        for(Attachment attRecord : [SELECT Id, ParentId FROM Attachment WHERE ParentId =: recordId AND Description= 'Sign' WITH SECURITY_ENFORCED LIMIT 1]){
            attachment = attRecord;
        }
        url ='/servlet/servlet.FileDownload?file=' + attachment.Id;
    }

    /*
    *   Class Name: contactData
    *   Description: Class To Store Data and Parse it in VF Page
    *
    *   Date            New/Modified         User                 Identifier                Description
    *   23/04/2020         New         Shubham Dadhich(mtx)
    */
    public class contactData{
        public String name {get;set;}
        public String phone {get;set;}
        public String email {get;set;}
        public String city {get;set;}
        public String street {get;set;}
        public String country {get;set;}

        public contactData(String name, String phone, String email, String city, String street, String country){
            this.name = name;
            this.phone = phone;
            this.email = email;
            this.city = city;
            this.street = street;
            this.country = country;
        }
    }
}