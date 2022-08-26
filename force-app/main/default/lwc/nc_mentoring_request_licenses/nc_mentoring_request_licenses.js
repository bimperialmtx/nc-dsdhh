import { LightningElement, api, track } from 'lwc';

export default class Nc_mentoring_request_licenses extends LightningElement {
    @api licensesIssuesByNCITLB;
    @track dataNCITL = {licenseIssuedbyTheNCITLB : 'No, I do not have an NC interpreter license.', NCITLBLicenseNumber : ''};
    @track showSpinner = false;
    @track noNCITLBNumber = true;

    @api
    getData(){
        return this.dataNCITL;
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
        if(event.target.name === 'NCITLBLicenseNumber' ){
            event.target.value = event.target.value.trim();
            this.dataNCITL.NCITLBLicenseNumber = event.target.value;
        }
    }

    handleChange(event){
        if( event.target.name === 'licenseIssuedbyTheNCITLB' ){
            this.dataNCITL.licenseIssuedbyTheNCITLB = event.detail.value;
            this.noNCITLBNumber = event.detail.value === 'No, I do not have an NC interpreter license.' || event.detail.value ===  'No, I have applied for a license, but I haven’t received it yet.' ? true : false;
        }else if( event.target.name === 'NCITLBLicenseNumber' ){
            this.dataNCITL.NCITLBLicenseNumber = event.detail.value;
        }
    }

    setFocusOnError(inputCmp) {
        setTimeout(() => {
            inputCmp.focus();
        }, 100);
    }

    @api
    setFocusOnHeading(isNext) {
        let accessibilityInfo = this.template.querySelector('[data-id="accessibilityInfo3"]');
        if(accessibilityInfo) {
            accessibilityInfo.id = 'accessibilityInfo3';
        }
        let headerDiv = this.template.querySelector('[data-id="headerDiv"]');
        if(headerDiv) {
            if(isNext) {
                headerDiv.setAttribute('aria-labelledby', 'accessibilityInfo3');
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