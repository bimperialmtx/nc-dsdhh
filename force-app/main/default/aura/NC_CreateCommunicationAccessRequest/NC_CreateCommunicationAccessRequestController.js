({
    doInit : function(component, event, helper) {
        let calloutParams = {
            recordId: component.get("v.recordId"),
            isNDBEDPRequest: component.get("v.isNDBEDPRequest")
        };
        helper.doCallout(component, "c.retrieveDefaults", calloutParams, true, true)
        .then( $A.getCallback(result => {
            var createRecordEvent = $A.get("e.force:createRecord");
            let params = {
                "entityApiName": "Communication_Access_Request__c",
                "recordTypeId" : result.recordTypeId
            }
            if(result.error){
              helper.showMessage("Error","error",result.error);
            }else{
                if(result.forOutreach){
    				let nameOfEvent = '';
    				let outreachId = '';
                    if(result.outreachData){
    					nameOfEvent = result.outreachData.Title_of_Event__c ? result.outreachData.Title_of_Event__c : '';
    					outreachId = result.outreachData.Id ? result.outreachData.Id : component.get("v.recordId");
                    }
                    params.defaultFieldValues = {
 						'Outreach_Request__c' : outreachId ? outreachId : component.get("v.recordId"),
    					'Name_of_Event__c' : nameOfEvent
                    };
                } else if(result.forMentoringRequest){
                    params.defaultFieldValues = {
                        'Mentoring_Request__c' : component.get("v.recordId")
                    };
                }else if(result.forAuthotizationTypeTainingVendor){
                    if(result.regionalCenter){
                        params.defaultFieldValues = {
                            'Authorization__c' : component.get("v.recordId"),
                            'Regional_Center__c' : result.regionalCenter
                        };
                    }else{
                        params.defaultFieldValues = {
                            'Authorization__c' : component.get("v.recordId")
                            
                        };
                    }
                }else if(result.forNDBEDPTainingVendor){
                    params.defaultFieldValues = {
                        'Vendor_Type__c' : 'NDBEDP Training',
                        'Request__c' : component.get("v.recordId")
                    };
                }else if(result.forNDBEDPRequest){
                    params.defaultFieldValues = {
                        'Request__c' : component.get("v.recordId")
                    };
                }else{
                    params.defaultFieldValues = {
                        'Outreach_Request__c' : result.eventAttribute.Outreach_Request__c,
                        'Staff_Attending__c' : component.get("v.recordId")
                    };
                }
                createRecordEvent.setParams(params);
                createRecordEvent.fire();
           }
           $A.get("e.force:closeQuickAction").fire();
           $A.get('e.force:refreshView').fire();
        }),
            $A.getCallback(error => {
            console.log(error);
        }));
    }
})