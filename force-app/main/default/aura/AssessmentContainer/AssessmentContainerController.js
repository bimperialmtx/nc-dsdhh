({
    closeModal : function(component, event, helper) {
		//component.set("v.inputValue",event.getParam('value'));
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
        component.find("assessment").handleSignHere();
    },
    handleApplicationEvent :function(component, event, helper) {
       
        component.set("v.showSignCmp",false);
        //$A.get('e.force:refreshView').fire();
        component.find("assessment").handleRefresh();
        component.find("assessment").handleSignHere();

    },
    handleKeyDown: function(component, event, helper) {
        if(event.code == 'Escape') {
            component.set("v.showSignCmp",false);
        	component.find("assessment").handleSignHere();
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