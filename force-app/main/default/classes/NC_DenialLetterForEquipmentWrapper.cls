/*
*   Class Name: NC_DenialLetterForEquipmentWrapper
*   Description: Wrapper for Denial Letter For Equipment
*
*   Date            New/Modified         User                 Identifier                Description
*   26/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_DenialLetterForEquipmentWrapper {
    public string consumerName{get;set;}
    public string consumerAddress1{get;set;}
    public string consumerCity{get;set;}
    public String consumerState{get;set;}
    public string consumerPostalCode{get;set;}
    public String currentDate{get;set;}
    public String vendorName{get;set;}
    public String regionalCenter{get;set;}
    public String equipmentType{get;set;}
    public String regionalPhone{get;set;}
    public String deniedReason{get;set;}
    public Boolean deniedifincomemorethan250{get;set;}
    public Boolean deniedifEDSCOORreject{get;set;}

    /*
    * Method Name: NC_DenialLetterForEquipmentWrapper
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_DenialLetterForEquipmentWrapper(String consumerName, String consumerAddress1, String consumerCity, String consumerState, String consumerPostalCode,
                                                Date currentDate, String vendorName, String regionalCenter, String equipmentType, String regionalPhone, String deniedReason,Boolean deniedifincomemorethan250,Boolean deniedifEDSCOORreject){
        this.consumerName = consumerName;
        this.consumerAddress1 =consumerAddress1;
        this.consumerCity = consumerCity;
        this.consumerState = consumerState;
        this.consumerPostalCode = consumerPostalCode;
        this.currentDate =currentDate.month() + '-' + currentDate.day() + '-' + currentDate.year();
        this.vendorName =vendorName;
        this.regionalCenter = regionalCenter;
        this.equipmentType= equipmentType;
        this.regionalPhone =regionalPhone;
        this.deniedReason = deniedReason;
        this.deniedifincomemorethan250=deniedifincomemorethan250;
        this.deniedifEDSCOORreject=deniedifEDSCOORreject;
    }
    
}