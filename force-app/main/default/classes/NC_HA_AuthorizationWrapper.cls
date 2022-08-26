/*
*   Class Name: NC_HA_AuthorizationWrapper
*   Description: Wrapper for VF Page NC_HA_Authorization
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_HA_AuthorizationWrapper {
    public string consumerName{get;set;}
    public string consumerAddress1{get;set;}
    public string consumerCity{get;set;}
    public String consumerState{get;set;}
    public string consumerPostalCode{get;set;}
    public string vendorName{get;set;}
    public string vendorAddress1{get;set;}
    public string vendorCity{get;set;}
    public String vendorState{get;set;}
    public string vendorPostalCode{get;set;}
    public String currentDate{get;set;}
    public Decimal authorizedAmount{get;set;}
    public String authorizationNumber{get;set;}
    public List<HearingAidSubItem> upperItemList{get;set;}
    public List<HearingAidSubItem> lowerItemList{get;set;}

    /*
    * Method Name: NC_HA_AuthorizationWrapper
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_HA_AuthorizationWrapper(String authorizationNumber, String consumerName, String consumerAddress1, String consumerCity, String consumerState, String consumerPostalCode,
                                      String vendorName, String vendorAddress1, String vendorCity, String vendorState, String vendorPostalCode,
                                      Date currentDate, Decimal authorizedAmount, List<HearingAidSubItem> upperItemList, List<HearingAidSubItem> lowerItemList){
        this.authorizationNumber = authorizationNumber;
        this.consumerName = consumerName;
        this.consumerAddress1 =consumerAddress1;
        this.consumerCity = consumerCity;
        this.consumerState = consumerState;
        this.consumerPostalCode = consumerPostalCode;
        this.vendorName = vendorName;
        this.vendorAddress1 =vendorAddress1;
        this.vendorCity = vendorCity;
        this.vendorState = vendorState;
        this.vendorPostalCode = vendorPostalCode;
        this.currentDate =currentDate.month() + '-' + currentDate.day() + '-' + currentDate.year();
        this.authorizedAmount = authorizedAmount;
        this.upperItemList = upperItemList;
        this.lowerItemList = lowerItemList;
        
    }

    public class HearingAidSubItem{
        public String name{get;set;}
        public Decimal amount{get;set;}

        public HearingAidSubItem(String name, Decimal amount){
            this.name = name;
            this.amount = amount;
        }
    }
}