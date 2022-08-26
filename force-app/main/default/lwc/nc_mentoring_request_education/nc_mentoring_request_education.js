import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_education extends LightningElement {

    @api educationLevel;
    @api degree;
    @api college;
    @track educationInformation = {educationLevel : 'Other', degree : '', college : '', otherEducation : '', otherDegree: '', otherCollege : ''};
    @track showSpinner = false;
    @track educationLevelOther = true;
    @track otherDegreeSelected = false;
    @track otherCollegeSelected = false;
    @track noCollegeDegree = false;
    @track hightSchoolDiploma = false;

    @api
    getData(){
        return this.educationInformation;
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
            if( event.target.name === 'otherEducation' ){
                this.educationInformation.otherEducation = event.target.value;
            }else if( event.target.name === 'otherDegree' ){
                this.educationInformation.otherDegree = event.target.value;
            }else if( event.target.name === 'otherCollege' ){
                this.educationInformation.otherCollege = event.target.value;
            }
    }
    
    handleChange(event){
        if( event.target.name === 'educationLevel' ){
            this.educationInformation.educationLevel = event.detail.value;
            this.hightSchoolDiploma = this.educationInformation.educationLevel == 'High School Diploma'? true : false;
            this.educationLevelOther = this.educationInformation.educationLevel == 'Other' ? true : false;
        }else if( event.target.name === 'degree' ){
            this.educationInformation.degree = event.detail.value.join(';');
            this.otherDegreeSelected =  event.detail.value.includes("Other") ;
        }else if( event.target.name === 'college' ){
            this.noCollegeDegree = event.detail.value.includes("No college degree") ;
            if(!this.hightSchoolDiploma && !this.educationLevelOther && this.noCollegeDegree){
                event.target.value = event.target.value.filter(function(e) { return e !== "No college degree" })
                event.detail.value = event.target.value;
                this.noCollegeDegree = false;
            }else if(this.noCollegeDegree){
                event.target.value = ["No college degree"];
                event.detail.value = event.target.value;
            }
            this.otherCollegeSelected =  event.detail.value.includes("Other") ;
            this.educationInformation.college = event.detail.value.join(';');
        }else if( event.target.name === 'otherEducation' ){
            this.educationInformation.otherEducation = event.detail.value;
        }else if( event.target.name === 'otherDegree' ){
            this.educationInformation.otherDegree = event.detail.value;
        }else if( event.target.name === 'otherCollege' ){
            this.educationInformation.otherCollege = event.detail.value;
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo2"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo2';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo2');
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