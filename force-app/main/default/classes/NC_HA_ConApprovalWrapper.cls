/*
*   Class Name: NC_HA_ConApprovalWrapper
*   Description: Wrapper for VF Page NC_HA_ConsumerApproval
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_HA_ConApprovalWrapper {
    public string consumerName{get;set;}
    public string consumerAddress1{get;set;}
    public string consumerCity{get;set;}
    public String consumerState{get;set;}
    public string consumerPostalCode{get;set;}
    public String currentDate{get;set;}
    public String vendorName{get;set;}

    /*
    * Method Name: NC_HA_ConApprovalWrapper
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_HA_ConApprovalWrapper(String consumerName, String consumerAddress1, String consumerCity, String consumerState, String consumerPostalCode,
                                                Date currentDate, String vendorName){
        this.consumerName = consumerName;
        this.consumerAddress1 =consumerAddress1;
        this.consumerCity = consumerCity;
        this.consumerState = consumerState;
        this.consumerPostalCode = consumerPostalCode;
        this.currentDate =currentDate.month() + '-' + currentDate.day() + '-' + currentDate.year();
        this.vendorName =vendorName;
        
    }
}