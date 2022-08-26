({
    setTabInfo : function(component, event, helper) {
		var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Interpreter Mentoring Request"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:form",
                iconAlt: "Interpreter Mentoring Request icon"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})