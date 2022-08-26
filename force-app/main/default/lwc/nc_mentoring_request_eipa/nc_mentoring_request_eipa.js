import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_eipa extends LightningElement {
    @api whenPlanEIPA;
    @api planToTakeEIPA;
    @api eipaScore;
    @api lastTakeTheEIPA;
    @api howTakenTheEIPA;
    

    @track eipaInformtion = {AreYouPlanningToTakeTheEIPA : 'No', haveYouTakenTheEIPA : 'No', lastTaketheEIPA: '2020', whatIsYourEIPAScore : null, whenDoYouPlanToTakeTheEIPA : 'No set plans to take the test.'};
    @track showSpinner = false;
    @track EIPAExamTaken = false;
    @track planningToTakeExam = false;

    renderedCallback() {
        let whatIsYourEIPAScore = this.template.querySelector('[data-id="whatIsYourEIPAScoreInfoId"]');
        if(whatIsYourEIPAScore) {
            whatIsYourEIPAScore.id = 'whatIsYourEIPAScoreInfo';
        }
        let whenDoYouPlanToTakeTheEIPA = this.template.querySelector('[data-id="whenDoYouPlanToTakeTheEIPAInfoId"]');
        if(whenDoYouPlanToTakeTheEIPA) {
            whenDoYouPlanToTakeTheEIPA.id = 'whenDoYouPlanToTakeTheEIPAInfo';
        }
    }

    @api
    getData(){
        return this.eipaInformtion;
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
        if( event.target.name === 'AreYouPlanningToTakeTheEIPA' ){
            this.eipaInformtion.AreYouPlanningToTakeTheEIPA = event.detail.value;
            this.planningToTakeExam = event.detail.value === 'Yes' ? true : false;
        }else if( event.target.name === 'haveYouTakenTheEIPA' ){
            this.eipaInformtion.haveYouTakenTheEIPA = event.detail.value;
            this.EIPAExamTaken = event.detail.value === 'Yes' ? true : false;
            if(this.EIPAExamTaken){
                this.eipaInformtion.whatIsYourEIPAScore = 'I don’t remember my score.';
            }else{
                this.eipaInformtion.whatIsYourEIPAScore = null;
            }
        }else if( event.target.name === 'lastTaketheEIPA' ){
            this.eipaInformtion.lastTaketheEIPA = event.detail.value;
        }else if( event.target.name === 'whatIsYourEIPAScore' ){
            this.eipaInformtion.whatIsYourEIPAScore = event.detail.value;
        }else if( event.target.name === 'whenDoYouPlanToTakeTheEIPA' ){
            this.eipaInformtion.whenDoYouPlanToTakeTheEIPA = event.detail.value;
        }
    }

    handleEIPATakenChange(event) {
        var value = event.detail.value;
        let inputElement = this.template.querySelector('lightning-input[data-id=lastTaketheEIPA]');
        if(value && !isNaN(parseInt(value))) {
            value = parseInt(value);
            var currentYear = new Date().getFullYear();
            if(value.toString().length != 4 || value > currentYear) {
                inputElement.setCustomValidity('Invalid year input');
            } else {
                this.eipaInformtion.lastTaketheEIPA = value;
                inputElement.setCustomValidity('');
            }
        } else {
            inputElement.setCustomValidity('Invalid year input');
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo7"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo7';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo7');
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