import { LightningElement, api } from 'lwc';

export default class Ncdsdhh_modalwindow extends LightningElement {
    @api name;
    showSpinner = false;
    connectedCallback(){
        setTimeout(()=>{					
            this.focusFirstEle(); },1000);
    }
    closeWindow(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    save(){
        this.showSpinner = true;
        this.dispatchEvent(new CustomEvent('save'));
    }

    @api
    disableSpinner() {
        this.showSpinner = false;
    }
    focusFirstEle() {
        const focusableElements = 'button, h2, lightning-button';
        console.log('focusableElements',focusableElements);
        const modal = this.template.querySelector('.slds-modal');
        
        const firstFocusableElement = modal.querySelectorAll('[data-name="modal"]')[0];
        const focusableContent = modal.querySelectorAll('[data-name="modal"]');
        const lastFocusableElement = focusableContent[focusableContent.length - 1];

        firstFocusableElement.focus();
        
        this.template.addEventListener('keydown', function(event) {
            let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {       
                if (this.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus(); 
                    event.stopPropagation();
                    event.preventDefault();
                }
            } else { 
                if (this.activeElement === lastFocusableElement) {  
                    firstFocusableElement.focus(); 
                    event.preventDefault();
                    event.stopPropagation();
                }
            }
        });
    }
}