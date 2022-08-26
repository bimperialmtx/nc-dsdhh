({
	doInit : function(component, event, helper) {
        /*var interval = window.setInterval(
            $A.getCallback(function() {
				helper.refreshPage(component, event, helper);
            }), 2000
        );*/
	},
    
    handleRefresh : function(component, event, helper) {
        helper.refreshPage(component, event, helper);
    }
})