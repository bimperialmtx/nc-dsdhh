({
	setTabInfo : function(component, event, helper) {
		var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Income Worksheet"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:form",
                iconAlt: "Income Worksheet icon"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})