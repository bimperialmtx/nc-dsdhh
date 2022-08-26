({
    doInit : function(component, event, helper) {
        var caseId;
        var recordType = 'NDBEDP1';
        var url = window.location.href;
        if(url.indexOf('inContextOfRef') != -1) {
            var value = helper.getParameterByName(component , event, 'inContextOfRef');
            var context = JSON.parse(window.atob(value));
            caseId = context.attributes.recordId;
            component.set("v.parentRecordId", caseId);
        } else if(url.indexOf('c__recordId') != -1) {
            caseId = component.get("v.pageReference").state.c__recordId;
            component.set("v.parentRecordId", caseId);
        } else if(url.split('/Case/').length > 1){
            caseId = url.split('/Case/')[1].split('/')[0];
            component.set("v.parentRecordId", caseId);
        } else if(url.split('%2FCase%2F').length > 0) {
            caseId = url.split('%2FCase%2F')[1].split('%2F')[0];
            component.set("v.parentRecordId", caseId);
        }
        
        var action = component.get("c.getRecordTypes");
        action.setParams({ recordId : caseId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                if(response && response.isNDBEDPCase && response.isNDBEDPCase == 'true') {
                    component.set("v.NDBEDPRecord", true);
                } else if(response && response.RequestEquipmentId){
                    helper.createRecord(component, event, caseId, response.RequestEquipmentId);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleWindowClose: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.openTab({
            url: '/lightning/r/Case/'+ component.get("v.parentRecordId") +'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                workspaceAPI.refreshTab({
                    tabId: response,
                    includeAllSubtabs: true
                });
            }).catch(function(error) {
                console.log(error);
            });
        }).catch(function(error) {
            console.log(error);
            window.location.href = '/'+ component.get("v.parentRecordId");
            /*
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.parentRecordId")
            });
            navEvt.fire();
            window.setTimeout(
                $A.getCallback(function() {
                    $A.get('e.force:refreshView').fire();
                }), 500
            );*/
        });
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})