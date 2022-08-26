/**
 * @description       : 
 * @author            : kavya.konagonda@mtxb2b.com
 * @group             : 
 * @last modified on  : 04-26-2022
 * @last modified by  : kavya.konagonda@mtxb2b.com
**/
public class NC_BaseController {
  /**
    * Given an trigger name, this method will return the TriggerSupport__mdt
    * @param trigger Name
    * @return TriggerSupport__mdt
    * Created By: Hiten Aggarwal (22-04-2020)
    */
    public static TriggerSupport__mdt getTriggerSupport(String triggername){
        
        try{
          /*  TriggerSupport__mdt triggerSupport = [SELECT Id, DeveloperName, MasterLabel, Before_Insert__c, 
                                                  Before_Update__c, After_Insert__c, After_Update__c, 
                                                  Before_Delete__c, After_Delete__c, Label 
                                                  FROM TriggerSupport__mdt
                                                  WHERE MasterLabel =: triggername];
            return triggerSupport;*/
                        Map<String,TriggerSupport__mdt>triggerSupportMap=TriggerSupport__mdt.getAll();
            for(String triggerSupportValue:triggerSupportMap.keySet()) {
                if(triggerSupportMap.get(triggerSupportValue).MasterLabel.contains(triggername)) {
                    return triggerSupportMap.get(triggerSupportValue);
                }
            }     
          return null;
        }
        catch(exception ex){
            return null; 
        }
    }

}