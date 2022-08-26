import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_performance_exam extends LightningElement {
    @api takenPerformance;
    @api passedPerformance;
    @api planningPerformance;
    @api timePeriodPerformance;
    @api howManyTimePerformance;
    @api lastPerformance;

    @track performanceInformation = {takenCASLINICOrCDIPerformanceExam : 'No', passedCASLINICOrCDIPerformanceExam : 'No', howManyTimesCASLINICOrCDIPerforma: null, lastCASLINICOrCDIPerformanceExam : '2020', planningCASLINICOrCDIPerformance : 'No', timePeriodCASLINICOrCDIPerformance: 'No set plans to take the test.'};
    @track showSpinner = false;
    @track CASLIExamTaken = false;
    @track planningToTakeExam = false;
    
    renderedCallback() {
        let passedPerformanceExam = this.template.querySelector('[data-id="passedCASLINICOrCDIPerformanceExamInfoId"]');
        if(passedPerformanceExam) {
            passedPerformanceExam.id = 'passedCASLINICOrCDIPerformanceExamInfo';
        }
        let howManyTimesPerformance = this.template.querySelector('[data-id="howManyTimesCASLINICOrCDIPerformaInfoId"]');
        if(howManyTimesPerformance) {
            howManyTimesPerformance.id = 'howManyTimesCASLINICOrCDIPerformaInfo';
        }
    }

    @api
    getData(){
        return this.performanceInformation;
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
        if( event.target.name === 'takenCASLINICOrCDIPerformanceExam' ){
            this.performanceInformation.takenCASLINICOrCDIPerformanceExam = event.detail.value;
            this.CASLIExamTaken = event.detail.value === 'Yes' ? true : false;
            if(this.CASLIExamTaken){
                this.performanceInformation.howManyTimesCASLINICOrCDIPerforma = '1 time';
            }else{
                this.performanceInformation.howManyTimesCASLINICOrCDIPerforma = null;
            }
        }else if( event.target.name === 'passedCASLINICOrCDIPerformanceExam' ){
            this.performanceInformation.passedCASLINICOrCDIPerformanceExam = event.detail.value;
        }else if( event.target.name === 'howManyTimesCASLINICOrCDIPerforma' ){
            this.performanceInformation.howManyTimesCASLINICOrCDIPerforma = event.detail.value;
        }else if( event.target.name === 'lastCASLINICOrCDIPerformanceExam' ){
            this.performanceInformation.lastCASLINICOrCDIPerformanceExam = event.detail.value;
        }else if( event.target.name === 'planningCASLINICOrCDIPerformance' ){
            this.performanceInformation.planningCASLINICOrCDIPerformance = event.detail.value;
            this.planningToTakeExam = event.detail.value === 'Yes' ? true : false;
        }else if( event.target.name === 'timePeriodCASLINICOrCDIPerformance' ){
            this.performanceInformation.timePeriodCASLINICOrCDIPerformance = event.detail.value;
        }
    }

    handleExamTakenChange(event) {
        var value = event.detail.value;
        let inputElement = this.template.querySelector('lightning-input[data-id=lastCASLINICOrCDIPerformanceExam]');
        if(value && !isNaN(parseInt(value))) {
            value = parseInt(value);
            var currentYear = new Date().getFullYear();
            if(value.toString().length != 4 || value > currentYear) {
                inputElement.setCustomValidity('Invalid year input');
            } else {
                this.performanceInformation.lastCASLINICOrCDIPerformanceExam = value;
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
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo6"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo6';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo6');
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