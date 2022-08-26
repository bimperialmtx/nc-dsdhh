import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_knowledge_exam extends LightningElement {
    @api takenKnowledge;
    @api passedKnowledge;
    @api planningKnowledge;

    @track knowledgeInformation = {tkenCASLINICOrCDIKnowledgeExam : 'No', passedCASLINICOrCDIKnowledge : 'No', planningCASLINICOrCDIKnowledge: 'No set plans to take the test.'};
    @track showSpinner = false;
    @track examNotTaken = true;

    renderedCallback() {
        let passedCASLINICOrCDIKnowledge = this.template.querySelector('[data-id="passedCASLINICOrCDIKnowledgeInfoId"]');
        if(passedCASLINICOrCDIKnowledge) {
            passedCASLINICOrCDIKnowledge.id = 'passedCASLINICOrCDIKnowledgeInfo';
        }
        let planningCASLINICOrCDIKnowledge = this.template.querySelector('[data-id="planningCASLINICOrCDIKnowledgeInfoId"]');
        if(planningCASLINICOrCDIKnowledge) {
            planningCASLINICOrCDIKnowledge.id = 'planningCASLINICOrCDIKnowledgeInfo';
        }
    }

    @api
    getData(){
        return this.knowledgeInformation;
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
        if( event.target.name === 'tkenCASLINICOrCDIKnowledgeExam' ){
            this.knowledgeInformation.tkenCASLINICOrCDIKnowledgeExam = event.detail.value;
            this.examNotTaken = event.detail.value === 'No' ? true : false;
        }else if( event.target.name === 'passedCASLINICOrCDIKnowledge' ){
            this.knowledgeInformation.passedCASLINICOrCDIKnowledge = event.detail.value;
        }else if( event.target.name === 'planningCASLINICOrCDIKnowledge' ){
            this.knowledgeInformation.planningCASLINICOrCDIKnowledge = event.detail.value;
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo5"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo5';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo5');
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