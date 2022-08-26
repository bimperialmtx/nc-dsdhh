import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_percentage extends LightningElement {
    @api videoRelayInterpreting;
    @api videoRemoteInterpreting;
    @api communityFreelance;
    @api educationalK12;
    @api educationPostSecondary;
    @api other;

    @track percentageInformation = {videoRelayInterpreting : '0%', videoRemoteInterpreting : '0%', communityFreelance: '0%', eucationalK12 : '0%', educationalPostSecondary : '0%', other : '0%', hoursWorkedinMedicalSettings: '0'};
    @track showSpinner = false;

    @api
    getData(){
        return this.percentageInformation;
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
        if( event.target.name === 'videoRelayInterpreting' ){
            this.percentageInformation.videoRelayInterpreting = event.detail.value;
        }else if( event.target.name === 'videoRemoteInterpreting' ){
            this.percentageInformation.videoRemoteInterpreting = event.detail.value;
        }else if( event.target.name === 'communityFreelance' ){
            this.percentageInformation.communityFreelance = event.detail.value;
        }else if( event.target.name === 'eucationalK12' ){
            this.percentageInformation.eucationalK12 = event.detail.value;
        }else if( event.target.name === 'educationalPostSecondary' ){
            this.percentageInformation.educationalPostSecondary = event.detail.value;
        }else if( event.target.name === 'other' ){
            this.percentageInformation.other = event.detail.value;
        }
    }

    handleHoursWorkedinMedicalSettings(event) {
        var value = event.detail.value;
        let inputElement = this.template.querySelector('lightning-input[data-id=hoursWorkedinMedicalSettings]');
        if(value && !isNaN(parseInt(value))) {
            value = parseInt(value);
            if(value < 0) {
                inputElement.setCustomValidity('Invalid hours input');
            } else {
                this.percentageInformation.hoursWorkedinMedicalSettings = value;
                inputElement.setCustomValidity('');
            }
        } else {
            inputElement.setCustomValidity('Invalid hours input');
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo8"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo8';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo8');
            }
            setTimeout(() => {
                headerDiv.focus();
            }, 500);
            setTimeout(() => {
                headerDiv.setAttribute('aria-labelledby', '');
            }, 10000);
        }
    }
}