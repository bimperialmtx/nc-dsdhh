import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_other extends LightningElement {
    @api hoursWorkedInMedicalSetting;
    @api dhhInterpreterVendorList;
    @api after5Year;

    @track otherInformation = {areYouOnDHHSInterpreterVendorList : 'No', after5Years: '', oherAfter5Year: '', currentSkillDevelopmentGoals :'', workshopInNorthCarolina : '' };//hoursWorkedinMedicalSettings : '0 hours', 
    @track showSpinner = false;
    @track otherAfter5YearTrue = false;

    @api
    getData(){
        return this.otherInformation;
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
    
    updateInput(event){
        event.target.value = event.target.value.trim();
        if( event.target.name === 'oherAfter5Year' ){
            this.otherInformation.oherAfter5Year = event.target.value;
        }else if( event.target.name === 'currentSkillDevelopmentGoals' ){
            this.otherInformation.currentSkillDevelopmentGoals = event.target.value;
        }else if( event.target.name === 'workshopInNorthCarolina' ){
            this.otherInformation.workshopInNorthCarolina = event.target.value;
        }
    }

    handleChange(event){
        if( event.target.name === 'hoursWorkedinMedicalSettings' ){
            this.otherInformation.hoursWorkedinMedicalSettings = event.detail.value;
        }else if( event.target.name === 'areYouOnDHHSInterpreterVendorList' ){
            this.otherInformation.areYouOnDHHSInterpreterVendorList = event.detail.value;
        }else if( event.target.name === 'after5Years' ){
            this.otherInformation.after5Years = event.detail.value.join(';');
            this.otherAfter5YearTrue =  event.detail.value.includes("Other") ;
        }else if( event.target.name === 'oherAfter5Year' ){
            this.otherInformation.oherAfter5Year = event.detail.value;
        }else if( event.target.name === 'currentSkillDevelopmentGoals' ){
            this.otherInformation.currentSkillDevelopmentGoals = event.detail.value;
        }else if( event.target.name === 'workshopInNorthCarolina' ){
            this.otherInformation.workshopInNorthCarolina = event.detail.value;
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext, isModalClosed) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo10"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo10';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo10');
            }
            if(isModalClosed === false) {
                setTimeout(() => {
                    headerDiv.focus();
                }, 500);
            }
            setTimeout(() => {
                headerDiv.setAttribute('aria-labelledby', '');
            }, 10000);
        }
    }
}