import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_interpreter_certification extends LightningElement {

    @api haveInterpreterCert;
    @api interpreterCertifications;
    @api assessmentLevelOptions;
    
    @track certificateInformation = {holdInterpreterCert: 'No', RIDNumber: '', assessmentLevel: '', certificateValue: ''};
    @track showCertifications = false;
    @track stateLevelAssessment = false;

    handleChange(event) {
        if(event.target.name == 'haveInterpreterCert') {
            this.certificateInformation.holdInterpreterCert = event.detail.value;
        } else if(event.target.name == 'assessmentLevel') {
            this.certificateInformation.assessmentLevel = event.detail.value;
        }
        
        if(this.certificateInformation.holdInterpreterCert == 'Yes') {
            this.showCertifications = true;
        } else {
            this.showCertifications = false;
        }
    }

    handleCertificationChange(event) {
        var value = event.detail.value;
        this.certificateInformation.certificateValue = value.join(';');
        if(value.includes('Cued Language Transliteration State Level Assessment')) {
            this.stateLevelAssessment = true;
            this.certificateInformation.assessmentLevel = '1';
        } else {
            this.stateLevelAssessment = false;
            this.certificateInformation.assessmentLevel = '';
        }
    }

    handleAssessmentLevel(event) {
        var value = event.detail.value;
        let inputElement = this.template.querySelector('lightning-input[data-id=assessmentLevel]');
        if(value && !isNaN(parseInt(value))) {
            value = parseInt(value);
            if(value < 1 || value > 5) {
                inputElement.setCustomValidity('Invalid input');
            } else {
                this.certificateInformation.assessmentLevel = value;
                inputElement.setCustomValidity('');
            }
        } else {
            inputElement.setCustomValidity('Invalid input');
        }
    }

    updateInput(event){
        event.target.value = event.target.value.trim();
        if( event.target.name === 'RIDNumber' ){
            this.certificateInformation.RIDNumber = event.target.value;
        }
    }

    @api
    getData(){
        return this.certificateInformation;
    }

    @api
    isValid(){
        let isValid = [...this.template.querySelectorAll('lightning-checkbox-group')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if(inputCmp.checkValidity() === false) {
                    this.setFocusOnError(inputCmp);
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);

            if(isValid === false) {
                return isValid;
            }

            isValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
                input.reportValidity();
                if(input.checkValidity() === false) {
                    this.setFocusOnError(input);
                }
                return validSoFar && input.checkValidity();
            }, true);
            
        return isValid;
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo4"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo4';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo4');
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