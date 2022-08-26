/*
*   Class Name: NC_AppointmentTriggerHandler
*   Description: Appointment Trigger Handler -- Logics on insert, update and delete
*
*   Date            New/Modified         User                 Identifier                Description
*   20/05/2020         New         Shubham Dadhich(mtx)
*/
public with sharing class NC_AppointmentTriggerHandler {
    
    /*
    *********************************************************
    @Method Name    : beforeInsert
    @description    : calling this method on 'before Insert' trigger event
    @param          : List<Appointment__c> newAppointmentList
    @return         : void
    ********************************************************
    */
    public static void beforeInsert(List<Appointment__c> newAppointmentList){
        checkDuplicateAppointment(newAppointmentList);
    }
    
    /*
    *********************************************************
    @Method Name    : checkDuplicateAppointment
    @description    : Checking for Duplicate Appointment for Authorization Record If Exist add Error to record.
    @param          : List<Appointment__c> newAppointmentList
    @return         : void
    ********************************************************
    */
    public static void checkDuplicateAppointment(List<Appointment__c> newAppointmentList){
        Map<Id, List<Appointment__c>> mapOfAuthorizationAndAppointment = new Map<Id, List<Appointment__c>>();
        Set<Id> setOfAutorization = new Set<Id>();
        Set<Datetime> datetimeSet = new Set<Datetime>();

        for(Appointment__c appointmentRecord : newAppointmentList){
            setOfAutorization.add(appointmentRecord.Authorization__c);
            datetimeSet.add(appointmentRecord.Hearing_Aid_Appointment__c);
        }
        
        for(Appointment__c appointmentRecord : [SELECT Id, Authorization__c, Hearing_Aid_Appointment__c FROM Appointment__c WHERE Authorization__c IN : setOfAutorization AND Hearing_Aid_Appointment__c IN : datetimeSet]){
            if(!mapOfAuthorizationAndAppointment.containsKey(appointmentRecord.Authorization__c)){
                mapOfAuthorizationAndAppointment.put(appointmentRecord.Authorization__c, new List<Appointment__c>());
            }
            mapOfAuthorizationAndAppointment.get(appointmentRecord.Authorization__c).add(appointmentRecord);
        }

        for(Appointment__c appointmentRecord : newAppointmentList){
            if(mapOfAuthorizationAndAppointment.containsKey(appointmentRecord.Authorization__c) && mapOfAuthorizationAndAppointment.get(appointmentRecord.Authorization__c).size() > 0){
                appointmentRecord.addError(NC_Constant.APPOINTMENT_EXIST_ERROR_MESSAGE);
            }
        }

    }


}