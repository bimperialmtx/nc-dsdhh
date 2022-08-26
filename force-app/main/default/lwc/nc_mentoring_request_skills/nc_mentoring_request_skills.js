import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_skills extends LightningElement {
    @api informationAssistance;
    @api interpreterSkillDevelopment;
    @api mentoringService;

    @track skillsInformation = {informationAssistance : '', interpretingSkillDevelopment : '', mentoringservices: ''};
    @track showSpinner = false;

    @api
    getData(){
        return this.skillsInformation;
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
        if( event.target.name === 'informationAssistance' ){
            this.skillsInformation.informationAssistance = event.detail.value.join(';');
        }else if( event.target.name === 'interpretingSkillDevelopment' ){
            this.skillsInformation.interpretingSkillDevelopment = event.detail.value.join(';');
        }else if( event.target.name === 'mentoringservices' ){
            this.skillsInformation.mentoringservices = event.detail.value.join(';');
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo9"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo9';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo9');
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