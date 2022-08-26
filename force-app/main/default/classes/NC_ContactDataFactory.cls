/*
*   Class Name: NC_ContactDataFactory
*   Description: Used for creating contact data
*
*   Date            New/Modified         User                 Identifier                Description
*   30/04/2020         New         Hiten Aggarwal(mtx)
*/

@isTest
public class  NC_ContactDataFactory {
   /*
    * Method Name: createContactRecords
    * Description: creates Contact record
    * @return: List<contact> - list of Contacts
    * @param  lastName - Last Name of contact , 
    *         count - Number of records to be created , 
    *         isInsert - wheather to insert account in this method only.
    */
     
    public static List<Contact> createContactRecords(String lastName, Integer count, Boolean isInsert){
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i<count; i++){
            Contact contactRecord = new Contact();
            ContactRecord.LastName = lastName + '' + i;
            contactList.add(contactRecord);
        }
        if(isInsert){
            insert contactList;
        }
        return contactList;
    }
    
   /*
    * Method Name: setProofOfIncome
    * Description: used for setting up the proof of Income
    * @param: contactRecord - single record of contact, uploadedBy - Proof_of_Income_Provided_By__c
    * @return Contact - single record of contact
    */ 
    
    public static Contact setProofOfIncome(Contact contactRecord,String uploadedBy){
        contactRecord.Proof_of_Income_Uploaded__c = true;
        contactRecord.Proof_of_Income_Provided_By__c = 'Medicaid';
        return contactRecord;       
    }
           
   /*
    * Method Name: setProofOfResidency
    * Description: used for setting up the proof of residency
    * @param: contactRecord - single record of contact, uploadedBy - Proof_Of_Residency_Provided_By__c
    * @return Contact - single record of contact
    */ 
    
    public static Contact setProofOfResidency(Contact contactRecord,String uploadedBy){
        // contactRecord.Proof_Of_Residency__c = true;
        contactRecord.Proof_Of_Residency_Uploaded__c = true;
        contactRecord.Proof_Of_Residency_Provided_By__c = 'Bank Statement' ;
        return contactRecord;       
    }
   /*
    * Method Name: setProofOfDisablity
    * Description: used for setting up the proof of disability
    * @param: contactRecord - single record of contact , hearingDisabity - picklist value of Hearing_Disability__c
    * @return Contact - single record of contact
    */ 

    public static Contact setProofOfDisablity(Contact contactRecord,String hearingDisabity){
        contactRecord.Disability_Determination_form_Uploaded__c = true;
        contactRecord.Hearing_Disability__c = hearingDisabity; 
        return contactRecord;       
    }
    
   /*
    * Method Name: setContactMethodInformation
    * Description: used for setting all contact Method such as - phone number , preferred contact method
    * @param: contactRecord - single record of contact
    * @return Contact - single record of contact
    */ 
    
    public static Contact setContactMethodInformation(Contact contactRecord){
        contactRecord.Phone = '9876543210';
        contactRecord.Preferred_Contact_Method__c = 'Email';
        contactRecord.Email = 'test@mtx.com';
        contactRecord.Social_Security_Number__c = '192';
        return contactRecord;
    }
    
   /*
    * Method Name: setMailingAddress
    * Description: Used for setting up the mailing address
    * @param: contactRecord - single record of contact
    * @return Contact - single record of contact
    */ 

    public static Contact setMailingAddress(Contact contactRecord){
        contactRecord.MailingCity = 'Test';
        contactRecord.MailingPostalCode = '921201';
        contactRecord.MailingCountry = 'Model City';
        contactRecord.MailingStreet = '151 Marks Street';
        contactRecord.MailingState ='Jhalana';
        return contactRecord;       
    }
}