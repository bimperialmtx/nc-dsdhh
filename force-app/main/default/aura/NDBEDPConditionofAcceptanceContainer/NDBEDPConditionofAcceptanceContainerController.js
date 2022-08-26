({
    initHandler : function(component, event, helper) {
        var action = component.get("c.getEquipmentDetails");
            action.setParams({
                requestId: component.get("v.recordId")
            });
        
            action.setCallback(this, function (response) {
            var result;
            result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                var toastEvent = $A.get("e.force:showToast");
                //dismissActionPanel.fire();
                if(result == true) {
                    component.set("v.callLWC",true);
                } 
                else{
                    component.set("v.callLWC",false);
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": 'Add an Equipment to proceed before starting the Condition of Acceptance'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
               
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();

                    console.log("Error message: " + JSON.stringify(errors));
                } else {
                    console.log("Unknown error");
                }
            }
        })
        $A.enqueueAction(action);
        // setTimeout(() => {
        //     var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //     dismissActionPanel.fire();
        // }, 100)
    },
    closeModal : function(component, event, helper) {
        var modal = event.getParam('value');
        if(modal){
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
        }
	},
    callSignatureComponent :function(component, event, helper) {
       
        component.set("v.showSignCmp",true);
        // var dismissActionPanel = $A.get("e.force:closeQuickAction");
        // dismissActionPanel.fire();
        let signModal = component.find("signModal");
        window.setTimeout(
            $A.getCallback(function() {
                if(signModal) {
                    signModal.getElement().focus();
                }
            }), 500
        );
    },
    closeSignatureModal :function(component, event, helper) {
       
        component.set("v.showSignCmp",false);
        component.find("conditionOfAcceptance").handleSignHere();

    },
    handleApplicationEvent :function(component, event, helper) {
       
        component.set("v.showSignCmp",false);
        //$A.get('e.force:refreshView').fire();
        component.find("conditionOfAcceptance").handleRefresh();
        component.find("conditionOfAcceptance").handleSignHere();

    },
    handleKeyDown: function(component, event, helper) {
        if(event.code == 'Escape') {
            component.set("v.showSignCmp",false);
        	component.find("conditionOfAcceptance").handleSignHere();
        event.preventDefault();
        event.stopPropagation();
        }
        //Modal Navigation
        let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
        if(isTabPressed) {
            const focusableElements = 'modal-focused';
        
            const firstFocusableElement = document.getElementsByClassName(focusableElements)[0];
            const focusableContent = document.getElementsByClassName(focusableElements);
            const lastFocusableElement = focusableContent[focusableContent.length - 1];

            if (event.shiftKey) {       
                if (document.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus(); 
                    event.stopPropagation();
                    event.preventDefault();
                }
            } else { 
                if (document.activeElement === lastFocusableElement) {  
                    firstFocusableElement.focus(); 
                    event.preventDefault();
                    event.stopPropagation();
                }
            }
        } else {
            return;
        }
    }
})