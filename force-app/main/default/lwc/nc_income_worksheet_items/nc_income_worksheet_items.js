import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nc_income_worksheet_items extends LightningElement {

  @api incomeType;
  @api index;
  @track incomeTypeShow = {};


  connectedCallback(){
    this.incomeTypeShow = JSON.parse(JSON.stringify(this.incomeType));
  }

  closeModal(){
    this.dispatchEvent(new CustomEvent('close', {
    }));
  }

  savedata(){
    if(this.incomeTypeShow.Gross_Salary_and_Wages ==0 && this.incomeTypeShow.Unemployment ==0 &&
      this.incomeTypeShow.Social_Security ==0 && this.incomeTypeShow.Veterans_Administration==0 &&
      this.incomeTypeShow.Retirement_Pension ==0 && this.incomeTypeShow.Worker_Compensation_payments ==0&& 
      this.incomeTypeShow.Alimony ==0 && this.incomeTypeShow.Rental_Income ==0 &&this.incomeTypeShow.Child_support ==0&&
      this.incomeTypeShow.On_the_Job_training==0 && this.incomeTypeShow.AmeriCorps_Stipends ==0 && this.incomeTypeShow.Armed_Forces_pay ==0 &&
      this.incomeTypeShow.Work_Release_Payments ==0 && this.incomeTypeShow.Tobacco_buy_out_payments==0&& this.incomeTypeShow.Annuities ==0&&
      this.incomeTypeShow.Cherokee==0
      ){
        this.showToastMessage("Error!", 'Please add atleast one Income', "error");
      }
    else{ if(this.isValid()){
      this.dispatchEvent(new CustomEvent('save', {
        detail : this.incomeTypeShow,
        index : this.index
      }));
    }else{
      this.showToastMessage("Error!", 'Please Fill All The Required Fields', "error");
    }
  }
    
  }

    
  isValid(){
    let valid = false;
    let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
        input.reportValidity();
        return validSoFar && input.checkValidity();
    }, true);
    valid = isAllValid;
    console.log('Valid Input : ' + valid);
    return valid;
}


  handleChange(event){
    if(event.target.name === 'Gross_Salary_and_Wages'){
      this.incomeTypeShow.Gross_Salary_and_Wages = parseFloat(event.target.value);
    }else if(event.target.name === 'Unemployment'){
      this.incomeTypeShow.Unemployment = parseFloat(event.target.value);
    }else if(event.target.name === 'Social_Security'){
      this.incomeTypeShow.Social_Security = parseFloat(event.target.value);
    }else if(event.target.name === 'Veterans_Administration'){
      this.incomeTypeShow.Veterans_Administration = parseFloat(event.target.value);
    }else if(event.target.name === 'Retirement_Pension'){
      this.incomeTypeShow.Retirement_Pension = parseFloat(event.target.value);
    }else if(event.target.name === 'Worker_Compensation_payments'){
      this.incomeTypeShow.Worker_Compensation_payments = parseFloat(event.target.value);
    }else if(event.target.name === 'Alimony'){
      this.incomeTypeShow.Alimony = parseFloat(event.target.value);
    }else if(event.target.name === 'Rental_Income'){
      this.incomeTypeShow.Rental_Income = parseFloat(event.target.value);
    }else if(event.target.name === 'Child_support'){
      this.incomeTypeShow.Child_support = parseFloat(event.target.value);
    }else if(event.target.name === 'On_the_Job_training'){
      this.incomeTypeShow.On_the_Job_training = parseFloat(event.target.value);
    }else if(event.target.name === 'AmeriCorps_Stipends'){
      this.incomeTypeShow.AmeriCorps_Stipends = parseFloat(event.target.value);
    }else if(event.target.name === 'Armed_Forces_pay'){
      this.incomeTypeShow.Armed_Forces_pay = parseFloat(event.target.value);
    }else if(event.target.name === 'Work_Release_Payments'){
      this.incomeTypeShow.Work_Release_Payments = parseFloat(event.target.value);
    }else if(event.target.name === 'Tobacco_buy_out_payments'){
      this.incomeTypeShow.Tobacco_buy_out_payments = parseFloat(event.target.value);
    }else if(event.target.name === 'Annuities'){
      this.incomeTypeShow.Annuities = parseFloat(event.target.value);
    }else if(event.target.name === 'Cherokee'){
      this.incomeTypeShow.Cherokee = parseFloat(event.target.value);
    }else if(event.target.name === 'Adjustments'){
      this.incomeTypeShow.Adjustments = parseFloat(event.target.value);
    } 
    console.log('End of method ' + JSON.stringify(this.incomeTypeShow));
  }

  //for showing toast message
  showToastMessage(title, message, variant ){
      const event = new ShowToastEvent({
        "title": title,
        "message": message,
        "variant": variant,
      });
      this.dispatchEvent(event);
  }

  handleKeyUp(event) {
    if(event.code == 'Escape') {
      this.closeModal();
    }
    event.preventDefault();
    event.stopPropagation();
  }

  @api
  focusFirstElement() {
    const focusableElements = '.modal-focused';
    const modal = this.template.querySelector('.slds-modal');
    
    const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
    const focusableContent = modal.querySelectorAll(focusableElements);
    const lastFocusableElement = focusableContent[focusableContent.length - 1];
    
    firstFocusableElement.focus();
    
    this.template.addEventListener('keydown', function(event) {
        let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
        if (!isTabPressed) {
            return;
        }
        if (event.shiftKey) {       
            if (this.activeElement === firstFocusableElement) {
                lastFocusableElement.focus(); 
                event.stopPropagation()
                event.preventDefault();
            }
        } else { 
            if (this.activeElement === lastFocusableElement) {  
                firstFocusableElement.focus(); 
                event.preventDefault();
                event.stopPropagation();
            }
        }
    });
  }
}