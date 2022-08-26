({
	  doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId")
        };
        helper.doCallout(component, "c.retrieveDefaults", calloutParams, true, true)
        .then( $A.getCallback(result => {
            var createRecordEvent = $A.get("e.force:createRecord");
            let params = {
                "entityApiName": "Resource_Loan__c",
                "recordTypeId" : result.recordTypeId
            }
            if(result.forConsumer){
               if(result.regionalCenter){
                 params.defaultFieldValues = {
                    'Regional_Center__c' : result.regionalCenter,
                    'Consumer__c' : component.get("v.recordId"),
                    'Agency__c':result.agency
                    };
                }else {
                  params.defaultFieldValues = {
                    'Consumer__c' : component.get("v.recordId"),
                    'Agency__c':result.agency
                  };
                }
            } else{
                params.defaultFieldValues = {
                    'Staff__c' : result.currentUser
                };
            }
           
            createRecordEvent.setParams(params);
            createRecordEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire()
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    }
})