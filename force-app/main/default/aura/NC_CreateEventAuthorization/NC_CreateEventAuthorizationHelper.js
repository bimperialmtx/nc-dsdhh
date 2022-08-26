({
	getRecordTypes : function(component, event, helper) {
		var action = component.get("c.getEventAuthorizationRecordTypes");
        action.setParams({ recordId : component.get("v.outreachId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result) {
                    if(result.isError) {
                        component.set("v.isError", true);
                        component.set("v.errorMessage", result.isError);
                        helper.showToast(component, event, 'Error!', result.isError);
                        helper.closeTab(component, event);
                    } else {
                     	var options = [];
                        for(var recTypeName in result) {
                            options.push({'label': recTypeName, 'value': result[recTypeName]});
                        }
                        component.set("v.recordTypeOptions", options);
                        if(options.length > 0) {
                            component.set("v.recordTypeId", options[0].value);   
                        }   
                    }
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    createRecord: function(component, event, parentId, recordTypeId) {
        var createRecordEvent = $A.get("e.force:createRecord");
        let params = {
            "entityApiName": "Event_Authorization__c",
            "recordTypeId" : recordTypeId,
            "defaultFieldValues": {
                'DHH_Sponsor_Event__c' : parentId
            }
        }
        createRecordEvent.setParams(params);
        createRecordEvent.fire();
    },
    
    closeTab: function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    showToast : function(component, event, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})