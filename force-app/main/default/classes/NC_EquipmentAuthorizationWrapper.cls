/*
*   Class Name: NC_EquipmentAuthorizationWrapper
*   Description: Wrapper for VF Page NC_EquipmentAuthorization
*
*   Date            New/Modified         User                 Identifier                Description
*   22/05/2020         New         Shubham Dadhich(mtx)
*/
public without sharing class NC_EquipmentAuthorizationWrapper {
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
    public String regionalCenterName{get;set;}
    public String authorizationNumber{get;set;}
    public String equipmentsCSV{get;set;}
    public List<Equipments> listOfEquipments{get;set;}
    
    /*
    * Method Name: NC_EquipmentAuthorizationWrapper
    * Description: Constructor
    * @param: 
    * @return:
    */
    public NC_EquipmentAuthorizationWrapper(String authorizationNumber, String consumerName, String consumerAddress1, String consumerCity, String consumerState, String consumerPostalCode,
                                      String vendorName, String vendorAddress1, String vendorCity, String vendorState, String vendorPostalCode,
                                      Date currentDate, String regionalCenterName,List<Equipments> listOfEquipments){
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
        this.regionalCenterName = regionalCenterName;
        this.listOfEquipments =listOfEquipments;
        this.equipmentsCSV = '';
        this.authorizationNumber = authorizationNumber;
        for(NC_EquipmentAuthorizationWrapper.Equipments equipment : listOfEquipments){
            this.equipmentsCSV += equipment.equipmentName + ',' ;
        }
        this.equipmentsCSV = String.isNotBlank(this.equipmentsCSV) ? this.equipmentsCSV.subString(0,this.equipmentsCSV.length()-1) : '';
    }

    /*
*   Class Name: Equipments
*   Description: Inner Wrapper
*/
    public class Equipments{

        public String equipmentName{get;set;}
        public Decimal equipmentAmount{get;set;}
        public String replacementEquipment{get;set;}

        /*
        * Method Name: Equipments
        * Description: Constructor
        * @param: 
        * @return:
        */
        public Equipments(String equipmentName, Decimal equipmentAmount){
            this.equipmentName = equipmentName;
            this.equipmentAmount = equipmentAmount;
        }
        public Equipments(String equipmentName, Decimal equipmentAmount, String recordType){
            this.equipmentName = equipmentName;
            this.equipmentAmount = equipmentAmount;
            this.replacementEquipment = recordType == 'Replacement_Asset' ? 'Yes' : 'No';
        }
    }
}