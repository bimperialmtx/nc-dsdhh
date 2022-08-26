public without sharing class NC_ConnectEquipmentWrapper {
    
    public class EquipmentResponse {
        @AuraEnabled
        public String STATUS{get;set;}
        @AuraEnabled
        public String ERROR_DESCRIPTION{get;set;}
        @AuraEnabled
        public Integer offset{get;set;}
        @AuraEnabled
        public Integer count{get;set;}
        @AuraEnabled
        public Eqp eqp{get;set;}
    }

    public class Eqp {
        @AuraEnabled
        public List<TtEqp> ttEqp{get;set;}
    }

    public class TtEqp {
        @AuraEnabled
        public String Annotations{get;set;}
        @AuraEnabled
        public String Author{get;set;}
        @AuraEnabled
        public String BibRecObj{get;set;}
        @AuraEnabled
        public String KlasID{get;set;}
        @AuraEnabled
        public String Medcode{get;set;}
        @AuraEnabled
        public String ReplaceCost{get;set;}
        @AuraEnabled
        public String Titl{get;set;}
        @AuraEnabled
        public String ManPartNum{get;set;}
        @AuraEnabled
        public String URL{get;set;}
        @AuraEnabled
        public String ImageURL{get;set;}
        @AuraEnabled
        public String ImageFileName{get;set;}
        @AuraEnabled
        public String quantity{get;set;}
        @AuraEnabled
        public String OPACSup{get;set;}
    }
        
}