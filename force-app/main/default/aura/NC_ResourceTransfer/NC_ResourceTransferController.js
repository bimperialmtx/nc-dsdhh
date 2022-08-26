({
    doInit : function(component, event, helper) {
        component.set('v.spinner',true);
        var action = component.get("c.getRegionalCenter");
        action.setParams({ id : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Message ' + response.getReturnValue().message);
                console.log('Result  ' + response.getReturnValue().result);
                if(response.getReturnValue().result != undefined){
                    component.set('v.RegionalCenterList',response.getReturnValue().result);
                }else{
                    component.set('v.errorMessage',response.getReturnValue().message);
                }
                component.set('v.spinner',false);
                
            }
            else if (state === "INCOMPLETE") {
                component.set('v.spinner',false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set('v.spinner',false);
                    }
                    component.set('v.spinner',false);
                } else {
                    console.log("Unknown error");
                    component.set('v.spinner',false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    transferResource : function(component,event,helper){
        component.set('v.spinner',true);
        var action = component.get("c.transferResourceToRegional");
        action.setParams({ id : component.get("v.recordId"), regionalCenterId : event.getSource().get("v.name") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner',false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                component.set('v.spinner',false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                    component.set('v.spinner',false);
                } else {
                    console.log("Unknown error");
                    component.set('v.spinner',false);
                }
            }
            component.set('v.spinner',false);
        });
        $A.enqueueAction(action);
    }
})