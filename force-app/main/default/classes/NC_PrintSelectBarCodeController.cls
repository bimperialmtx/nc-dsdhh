/*
**   Class Name: NC_PrintSelectBarCodeController
**   Description: To print selected barcodes
**
**      Date            New/Modified           User                 Identifier               Description
**   25-07-2020             New          Hiten Aggarwal(mtx)
*/

public with sharing class NC_PrintSelectBarCodeController {
    public ApexPages.StandardSetController setControllerObj;
    public boolean zeroRecordSelected {get;set;}
    public string errorMessage {get;set;}
    public List<ResourceBarcode> resourceList {get;set;}
    
    
    public NC_PrintSelectBarCodeController(ApexPages.StandardSetController controller){
        setControllerObj = controller;  
        if(setControllerObj.getSelected() == null || setControllerObj.getSelected().size() == 0) {
            zeroRecordSelected = true;
            errorMessage = 'Please select atleast one resource'; 
        } else { 
            zeroRecordSelected = false;
            getBarcodeFromResources(setControllerObj.getSelected());
        }
    }
    
    /*
    *********************************************************
    @Method Name    : getBarcodeFromResources
    @description    : Set barcode url for input resources
    @param          : List<Resource__c> selectedResources
    @return         : void
    ********************************************************
    */
    private Void getBarcodeFromResources(List<Resource__c> selectedResources) {
        //resourceList = [Select Id, Generated_Bar_Code__c,Name FROM Resource__c Where Id IN: selectedResources];
        ResourceBarcode resourceData;
        resourceList = new List<ResourceBarcode>();
        for(Resource__c resource: [Select Id, Generated_Bar_Code__c,Name,Bar_Code_Number__c FROM Resource__c Where Id IN: selectedResources AND Bar_Code_Number__c != NULL WITH SECURITY_ENFORCED]){
            resourceData = new ResourceBarcode();
            resourceData.name =   resource.Name;
            resourceData.url = 'https://barcode.tec-it.com/barcode.ashx?data='+ resource.Bar_Code_Number__c +'&code=Code39&dpi=96&dataseparator=';
            resourceList.add(resourceData);
        }
    }

    public class ResourceBarcode{
        public string name {get;set;}
        public string url {get;set;}

        public ResourceBarcode(){
            this.name = '';
            this.url = '';
        }
    }
}