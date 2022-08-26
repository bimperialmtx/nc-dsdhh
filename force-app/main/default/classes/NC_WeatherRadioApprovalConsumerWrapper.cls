/*
*   Class Name: NC_WeatherRadioApprovalConsumerWrapper
*   Description: Wrapper for VF Page NC_WeatherRadioApprovalConsumer
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_WeatherRadioApprovalConsumerWrapper {
    public string consumerName{get;set;}
    public string consumerAddress1{get;set;}
    public string consumerCity{get;set;}
    public String consumerState{get;set;}
    public string consumerPostalCode{get;set;}
    public String currentDate{get;set;}
    public String vendorName{get;set;}
    public List<equipments> listOfEquipments{get;set;}
    public String regionalCenterName{get;set;}
    public Integer listOfEquipmentsSize{get;Set;}

    /*
    * Method Name: NC_WeatherRadioApprovalConsumerWrapper
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_WeatherRadioApprovalConsumerWrapper(String consumerName, String consumerAddress1, String consumerCity, String consumerState, String consumerPostalCode,
                                                Date currentDate, String vendorName, List<equipments> listOfEquipments, String regionalCenterName){
        this.consumerName = consumerName;
        this.consumerAddress1 =consumerAddress1;
        this.consumerCity = consumerCity;
        this.consumerState = consumerState;
        this.consumerPostalCode = consumerPostalCode;
        this.currentDate =currentDate.month() + '-' + currentDate.day() + '-' + currentDate.year();
        this.vendorName =vendorName;
        this.listOfEquipments = listOfEquipments;
        this.regionalCenterName = regionalCenterName;
        this.listOfEquipmentsSize = listOfEquipments.size();
    }


    public class equipments{
        public string name{get;set;}
        public string daysReturn{get;set;}
        public string daysRecived{get;set;}
        public string daysExchange{get;set;}

        public equipments(string name, string daysReturn, string daysRecived, string daysExchange){
            this.name = name;
            this.daysReturn = daysReturn;
            this.daysRecived = daysRecived;
            this.daysExchange = daysExchange;
        }
        
    }
}