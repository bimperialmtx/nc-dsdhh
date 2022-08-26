({
	doInit : function(component, event, helper) {
        setTimeout(() => {
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }, 100);
        var customWindow = window.open('/s/addequipmenttocart?parentRecordId='+ component.get("v.recordId") + '&isPortal=true' , '_blank');
	}
})