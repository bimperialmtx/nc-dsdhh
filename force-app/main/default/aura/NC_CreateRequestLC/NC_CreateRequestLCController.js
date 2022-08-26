({
    closeModal : function(component, event, helper) {
		//component.set("v.inputValue",event.getParam('value'));
        var modal = event.getParam('value');
        if(modal){
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
        }
	}
})