/*
**   Class Name: NC_InformationReferralTriggerHandler
**   Description: Handler For NC_InformationReferralTrigger
**
**     Date            New/Modified           User                 Identifier               Description
**   05-08-2020             New          Hiten Aggarwal(mtx)
*/

public without sharing class NC_InformationReferralTriggerHandler {

    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Information_Referral__c> newList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Information_Referral__c> newList){
        updateInformationTypeCount(newList);
        updateInformationTypeCount(newList,NULL);
    }
    
    /*
    *********************************************************
    @Method Name    : beforeUpdate
    @description    : calling this method on 'before update' trigger event
    @param          : List<Information_Referral__c> newList, Map<Id,Information_Referral__c> oldMap
    @return         : void
    ********************************************************
    */
    public static void beforeUpdate(List<Information_Referral__c> newList, Map<Id,Information_Referral__c> oldMap){
        updateInformationTypeCount(newList,oldMap);
    }
    
    /*
    *********************************************************
    @Method Name    : updateInformationTypeCount
    @description    : update regional center on information referral
    @param          : List<Information_Referral__c> newList
    @return         : void
    ********************************************************
    */
    private static void updateInformationTypeCount(List<Information_Referral__c> newList){
        Map<Id,Id> sObjectIdToRegionalCenterMap = new Map<Id,Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> agecnyIdSet = new Set<Id>();
        for(Information_Referral__c informationReferral : newList){
            if(informationReferral.Consumer__c != NULL){
                contactIdSet.add(informationReferral.Consumer__c );
            }else if(informationReferral.Agency__c != NULL){
                agecnyIdSet.add(informationReferral.Agency__c);
            }
        }
        if(!agecnyIdSet.isEmpty()){
            for(Account accountRecord: [SELECT Id,Regional_Center__c FROM Account Where Id IN: agecnyIdSet WITH SECURITY_ENFORCED]){
               sObjectIdToRegionalCenterMap.put(accountRecord.Id,accountRecord.Regional_Center__c);
            }            
        }
        if(!contactIdSet.isEmpty()){
            for(Contact contactRecord: [SELECT Id,Regional_Center_Office__c FROM Contact Where Id IN: contactIdSet WITH SECURITY_ENFORCED]){
                sObjectIdToRegionalCenterMap.put(contactRecord.Id,contactRecord.Regional_Center_Office__c);
            }            
        }
        for(Information_Referral__c informationReferral : newList){
            if(informationReferral.Consumer__c != NULL){
                if(sObjectIdToRegionalCenterMap.containsKey(informationReferral.Consumer__c)){
                    informationReferral.Regional_Center__c = sObjectIdToRegionalCenterMap.get(informationReferral.Consumer__c);
                }
            }else if(informationReferral.Agency__c != NULL){
                if(sObjectIdToRegionalCenterMap.containsKey(informationReferral.Agency__c)){
                    informationReferral.Regional_Center__c = sObjectIdToRegionalCenterMap.get(informationReferral.Agency__c);
                }
            }
        }

    }
    
    /*
    *********************************************************
    @Method Name    : updateInformationTypeCount
    @description    : get and match data from information type count
    @param          : List<Information_Referral__c> newList, Map<Id,Information_Referral__c> oldMap
    @return         : void
    ********************************************************
    */
    private Static void updateInformationTypeCount(List<Information_Referral__c> newList, Map<Id,Information_Referral__c> oldMap){
        Set<String> informationTypeSet = new Set<String>();
       
        Map<Information_Referral__c,String> informationReferralToInformationType = new Map<Information_Referral__c,String>();
        
        Map<Id,Map<String, Integer>> regionalCenterToinformationTypeToCountMap = new Map<Id,Map<String, Integer>>();
        Map<Id,Map<String, Information_Type_Count__c>> regioanlCenterToInfomrationTypeCountMap = new Map<Id,Map<String, Information_Type_Count__c>>();
        List<Information_Type_Count__c> informationTypeList = new  List<Information_Type_Count__c>();
       
        Boolean countUpdate = False;
        for( Information_Referral__c informationReferral : newList){
            if((oldMap == NULL || oldMap.get(informationReferral.Id).Type_Of_Information_Given__c != informationReferral.Type_Of_Information_Given__c)
               && informationReferral.Type_of_Information_Given__c != NULL){
                   if(oldMap == NULL){
                       informationReferralToInformationType.put(informationReferral, informationReferral.Type_of_Information_Given__c);
                       informationTypeSet.addAll(informationReferral.Type_of_Information_Given__c.split(';'));
                   }else{
                       String Str = informationReferral.Type_of_Information_Given__c;
                       if(oldMap.get(informationReferral.Id).Type_Of_Information_Given__c != NULL && oldMap.get(informationReferral.Id).Type_Of_Information_Given__c != ''){
                            for(String typeValue : oldMap.get(informationReferral.Id).Type_Of_Information_Given__c.split(';')){
                                Str = Str.replace(typeValue,'');
                            }
                        }
                       informationReferralToInformationType.put(informationReferral,Str);                       
                       informationTypeSet.addAll(Str.split(';'));
                   }
               }
        }

        for(Information_Type_Count__c informationType : [SELECT Id,Name,Count__c,Regional_Center__c FROM Information_Type_Count__c WHERE Name IN: informationTypeSet AND Regional_Center__c != NULL WITH SECURITY_ENFORCED]){
            if(!regionalCenterToinformationTypeToCountMap.containsKey(informationType.Regional_Center__c)){
                regionalCenterToinformationTypeToCountMap.put(informationType.Regional_Center__c,new Map<String, Integer>());
            }
            regionalCenterToinformationTypeToCountMap.get(informationType.Regional_Center__c).put(informationType.Name, informationType.Count__c != NULL ? Integer.ValueOf(informationType.Count__c) : 0 );
            if(!regioanlCenterToInfomrationTypeCountMap.containsKey(informationType.Regional_Center__c)){
                regioanlCenterToInfomrationTypeCountMap.put(informationType.Regional_Center__c,new Map<String,Information_Type_Count__c>());
            }
				regioanlCenterToInfomrationTypeCountMap.get(informationType.Regional_Center__c).put(informationType.Name,informationType);            
        }
        
        for(Information_Referral__c informationReferral : informationReferralToInformationType.keySet()){
            for(String typeValue : informationReferral.Type_of_Information_Given__c.Split(';')){
                if(regionalCenterToinformationTypeToCountMap.containsKey(informationReferral.Regional_Center__c)){
                    if(regionalCenterToinformationTypeToCountMap.get(informationReferral.Regional_Center__c).containsKey(typeValue)){
                        if(regionalCenterToinformationTypeToCountMap.get(informationReferral.Regional_Center__c).get(typeValue) == 0){
                            informationReferral.addError('Not Enough '+ typeValue);
                        }else{
                            regionalCenterToinformationTypeToCountMap.get(informationReferral.Regional_Center__c).put(typeValue,regionalCenterToinformationTypeToCountMap.get(informationReferral.Regional_Center__c).get(typeValue)-1);
                            regioanlCenterToInfomrationTypeCountMap.get(informationReferral.Regional_Center__c).get(typeValue).Count__c = regionalCenterToinformationTypeToCountMap.get(informationReferral.Regional_Center__c).get(typeValue);
                            informationTypeList.add(regioanlCenterToInfomrationTypeCountMap.get(informationReferral.Regional_Center__c).get(typeValue));
                            countUpdate = True;
                        }
                    }
                }else{
                   informationReferral.addError('No Information Type Found For This Regional Center of Type '+ typeValue); 
                }
                
            }
        }
        if(countUpdate && !informationTypeList.isEmpty()){
            //SObjectAccessDecision decision =  SecurityLibrary.getAccessibleData('Information_Type_Count__c', informationTypeList, 'update', true, 'NC_InformationReferralTriggerHandler','updateInformationTypeCount');
            //update decision.getRecords();
            update informationTypeList;
        }
    }
}