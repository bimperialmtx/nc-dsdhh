({
	doInit : function(component, event, helper) {
        var filter = component.get("v.filter");
        console.log('filter-->'+filter);
        if(filter) {
            helper.validateFilter(component, event, helper);
        } else {
            component.set("v.isVisible", true);
        }
	}
})