import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nc_mentoring_request_family_info extends LightningElement {

    @api deafFamilyMembers;
    @api memberRelationship;
    @track familyInformation = {haveDeafFamilyMembers : 'No', memberRelationship : '', relationshipIfOther : ''};
    @track showSpinner = false;
    @track hasFamilyMember = false;
    @track otherSelected = false;

    connectedCallback() {
        setTimeout(() => {
            this.setFocusOnHeading();
        }, 1000);
    }

    @api
    getData(){
        return this.familyInformation;
    }
    
    @api
    isValid(){
        let valid = false;
       
        let isAllValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if(inputCmp.checkValidity() === false) {
                    this.setFocusOnError(inputCmp);
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);
            
        if(isAllValid === false){
          return isAllValid;
        }

        isAllValid = [...this.template.querySelectorAll('lightning-dual-listbox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if(inputCmp.checkValidity() === false) {
                    this.setFocusOnError(inputCmp);
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if(isAllValid === false){
                return isAllValid;
        }
        
        isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            if(input.checkValidity() === false) {
                this.setFocusOnError(input);
            }
            return validSoFar && input.checkValidity();
        }, true);

        

        valid = isAllValid;
        console.log('Valid Input : ' + valid);
        return valid;
    }

    handleChange(event){
        if( event.target.name === 'haveDeafFamilyMembers' ){
            this.familyInformation.haveDeafFamilyMembers = event.detail.value;
            this.hasFamilyMember = this.familyInformation.haveDeafFamilyMembers == 'Yes' ? true : false;
        }else if( event.target.name === 'memberRelationship' ){
            this.familyInformation.memberRelationship = event.detail.value.join(';');
            this.otherSelected =  event.detail.value.includes("Other") ;
        }else if(event.target.name === 'relationshipIfOther'){
            this.familyInformation.relationshipIfOther = event.detail.value;
        }
    }

    updateInput(event){
        if(event.target.name === 'relationshipIfOther'){
            event.target.value = event.target.value.trim();
            this.familyInformation.relationshipIfOther = event.target.value;
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading() {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo');
            setTimeout(() => {
                headerDiv.focus();
            }, 500);
            setTimeout(() => {
                headerDiv.setAttribute('aria-labelledby', '');
            }, 5000);
        }
    }

}