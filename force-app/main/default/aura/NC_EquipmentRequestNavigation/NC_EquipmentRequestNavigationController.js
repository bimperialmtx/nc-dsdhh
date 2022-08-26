({
	doInit : function(component, event, helper) {
		/*
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__NC_CreateEquipmentRequest',
            },
            state: {
                "c__recordId": "500r000000A8pL7AAJ"
            }
        };

        var navService = component.find("navService");
        //event.preventDefault();
        navService.navigate(pageReference);*/
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__NC_CreateEquipmentRequest"  // c__<comp Name>
                },
                "state": {
                    "uid": "1",
                    "c__recordId": component.get("v.recordId") // c__<comp attribute Name>
                }
            },
            focus: true
        }).then((response) => {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "New Request Equipment"
            });
            workspaceAPI.setTabIcon({
                tabId: response,
                icon: "standard:checkout",
                iconAlt: "Add"
            });
        }).catch(function(error) {
            console.log(error);
        });
	}
})