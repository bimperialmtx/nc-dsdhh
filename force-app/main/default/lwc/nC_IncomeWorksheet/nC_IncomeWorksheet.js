import { LightningElement, track, api } from 'lwc';
import fetchPicklist from '@salesforce/apex/NC_IncomeWorksheetController.fetchPicklist';
import updateContactData from '@salesforce/apex/NC_IncomeWorksheetController.updateContactData';
import fetchContactData from '@salesforce/apex/NC_IncomeWorksheetController.fetchContactData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NC_IncomeWorksheet extends LightningElement {
  @track proofOfIncomeProvidedBy;
  @track maritalStatus;
  @track isModalOpen;
  @track name;
  @track age;
  @track relationShip;
  @track addRelationship = true;
  @track familyDetailWrappper ;
  @track FamilyDetailsWrapperList;
  @track incomeTypeList = [];
  @track incomeData = [];
  @track incomeType = [];
  @track selectedIndex;
  @track showErroMessage;
  @track alreadyFilled;
  @track showSpinner = false;
  @track url;
  @track totalAmountValue;
  @track deleteConfirmModal = false;
  @track deleteIndex;
  @track addIncomeButton;
  @track deleteButton;

  @track contactDataWrapperList;
  @api request;
  
  get deleteDisabled() {
    if(this.incomeData && this.incomeData.length > 1) {
      return false;
    } else {
      return true;
    }
  }
  set deleteDisabled(value) {
  }

  connectedCallback(){
    
    this.showSpinner = true;
    console.log(' this.showSpinner - ',  this.showSpinner);
    var defaultData = {dataIndex: 1, name:'', age:null, relationship:'', totalIncome:0, incomeType:{Gross_Salary_and_Wages: 0,Unemployment:0, Social_Security:0,Veterans_Administration:0,Retirement_Pension:0,Worker_Compensation_payments:0,Alimony:0,
    Rental_Income:0,Child_support:0,On_the_Job_training:0,AmeriCorps_Stipends:0,Armed_Forces_pay:0,Work_Release_Payments:0,Tobacco_buy_out_payments:0,Annuities:0,Cherokee:0,Adjustments:0}};
    this.setAriaLabel(defaultData, 1);

    this.incomeData.push(defaultData);
    fetchContactData({recordId : this.request}).then(
      result => {
        this.maritalStatus = result.maritalStatus;
        this.proofOfIncomeProvidedBy = result.proofOfIncomeProvidedBy;
        this.alreadyFilled = result.alreadyFilled;
        this.showErroMessage = result.showErroMessage;
        if(result.familyWrapList && result.familyWrapList.length > 0) {
          this.incomeData = result.familyWrapList;
          let count = 1;
          for(let i in this.incomeData) {
            this.incomeData[i].dataIndex = count;
            this.setAriaLabel(this.incomeData[i], count);
            count++;
          }
        }
        console.log(' showSpinner - ',  this.showSpinner);
      }
     ).catch(
      error => {
        this.showToastMessage("Error!", error, "error");
        this.showSpinner = false;
      }
     );
    this.showSpinner = false;
  }

  submitChanges(){
    this.showSpinner = true;
    this.totalAmountValue =true;
    console.log(' this.showSpinner - ',  this.showSpinner);
    console.log('string',JSON.stringify(this.incomeData));
    var totalList=this.incomeData;
    var totalList1;
    console.log('this.totalAmountValuefirst',this.totalAmountValue);
    let addIncome = this.template.querySelectorAll("[data-id='addIncomeId']");
    totalList.forEach(element => {
      // console.log('this',element.totalIncome);
      // totalList1.push(element.totalIncome);
      if(element.totalIncome == 0){
        console.log('element.totalIncome',element.totalIncome);
        this.totalAmountValue =false;
        this.setFocusOnError(addIncome[element.dataIndex-1]);
      }
      
    });
    console.log('this.totalAmountValue',this.totalAmountValue);
    if(this.isValid() && this.totalAmountValue){
        updateContactData({ familyJsonData : JSON.stringify(this.incomeData), recordId : this.request}).then(
          result => {
            if(result.success){
              console.log('url - ', result.url);
              this.url = result.url;
              this.showToastMessage("Success!", 'Family Members Added Successfully', "success");
              window.location.href = this.url;
              this.showSpinner = false;
              console.log(' this.showSpinner - ',  this.showSpinner);
            }else if(result.error){
              this.showToastMessage("Error!", result.error, "error");
              this.showSpinner = false;
            }else{
              this.showToastMessage("Error!", 'Family Members Not Added', "error");
              this.showSpinner = false;
            }
          }
        ).catch(
          error => {
            var errorMessage = error.message || error.body.message;
            if(error && error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && error.body.pageErrors[0].message) {
              errorMessage = error.body.pageErrors[0].message;
            }
            this.showToastMessage("Error!", errorMessage, "error");
            this.showSpinner = false;
          }
        );
      }else if(this.totalAmountValue==false){
        this.showToastMessage("Error!", 'Please Add the Income', "error");
        this.showSpinner = false;
      }
      else{
        this.showToastMessage("Error!", 'Please Fill All The Required Fields', "error");
        this.showSpinner = false;
      }
  }

  addMore(){
    let count = (this.incomeData && this.incomeData.length) ? (this.incomeData.length + 1) : 1;
    var defaultData = {dataIndex: count, name:'', age:null, relationship:'', totalIncome:0, incomeType:{Gross_Salary_and_Wages: 0,Unemployment:0, Social_Security:0,Veterans_Administration:0,Retirement_Pension:0,Worker_Compensation_payments:0,Alimony:0,
    Rental_Income:0,Child_support:0,On_the_Job_training:0,AmeriCorps_Stipends:0,Armed_Forces_pay:0,Work_Release_Payments:0,Tobacco_buy_out_payments:0,Annuities:0,Cherokee:0,Adjustments:0}};
    this.setAriaLabel(defaultData, count);
    this.incomeData.push(defaultData);
    this.showToastMessage("Success!", 'New Family Member row has been added', "success");
  }

  openModal(event) {
    //to open modal set isModalOpen tarck value as true
    this.selectedIndex = parseInt(event.target.name);
    this.incomeType = this.incomeData[this.selectedIndex].incomeType;
    this.isModalOpen = true;
    this.addIncomeButton = event.target;
    
    setTimeout(() => {
      let childCmp = this.template.querySelector('c-nc_income_worksheet_items');
      if(childCmp) {
        childCmp.focusFirstElement();
      }
    }, 500);
  }

  closeModal() {
    //to open modal set isModalOpen tarck value as true
    this.isModalOpen = false;
    setTimeout(() => {
      this.addIncomeButton.focus();
    }, 500);
  }

  saveData(event){
      this.incomeData[this.selectedIndex].incomeType = event.detail;
      this.incomeData[this.selectedIndex].totalIncome = parseFloat(this.incomeData[this.selectedIndex].incomeType.Gross_Salary_and_Wages + this.incomeData[this.selectedIndex].incomeType.Unemployment + this.incomeData[this.selectedIndex].incomeType.Social_Security + this.incomeData[this.selectedIndex].incomeType.Veterans_Administration + this.incomeData[this.selectedIndex].incomeType.Retirement_Pension + this.incomeData[this.selectedIndex].incomeType.Worker_Compensation_payments + this.incomeData[this.selectedIndex].incomeType.Alimony + this.incomeData[this.selectedIndex].incomeType.Rental_Income + this.incomeData[this.selectedIndex].incomeType.Child_support + this.incomeData[this.selectedIndex].incomeType.On_the_Job_training + this.incomeData[this.selectedIndex].incomeType.AmeriCorps_Stipends + this.incomeData[this.selectedIndex].incomeType.Armed_Forces_pay + this.incomeData[this.selectedIndex].incomeType.Work_Release_Payments+ this.incomeData[this.selectedIndex].incomeType.Tobacco_buy_out_payments + this.incomeData[this.selectedIndex].incomeType.Annuities + this.incomeData[this.selectedIndex].incomeType.Cherokee + this.incomeData[this.selectedIndex].incomeType.Adjustments);
      this.isModalOpen = false;
      setTimeout(() => {
        this.addIncomeButton.focus();
      }, 500);
  }

  handleChange(event){
    let index = event.target.dataset.index;
    if(event.target.name === 'Name'){
      this.incomeData[index].name = event.target.value;
    }else if(event.target.name === 'Age'){
      this.incomeData[index].age = parseInt(event.target.value);
    }else if(event.target.name === 'Relationship'){
      this.incomeData[index].relationship = event.target.value;
    }
  }

  deleteRow(event){
    this.deleteConfirmModal = true;
    this.deleteIndex = parseInt(event.target.name);
    this.deleteButton = event.target;
    setTimeout(() => {
      this.focusFirstElement();
    }, 500);
  }

  handleDeleteAction() {
    if(this.incomeData.length > 1){
      this.incomeData.splice(this.deleteIndex,1);
    }
    let count = 1;
    for(let i in this.incomeData) {
      this.incomeData[i].dataIndex = count;
      this.setAriaLabel(this.incomeData[i], count);
      count++;
    }
    this.deleteConfirmModal = false;
  }

  closeDeleteConfirmModal() {
    this.deleteConfirmModal = false;
    setTimeout(() => {
      this.deleteButton.focus();
    }, 500);
  }
    
   isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            if(input.checkValidity() === false && validSoFar === true) {
              this.setFocusOnError(input);
            }
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        console.log('Valid Input : ' + valid);
        return valid;
    }

  setFocusOnError(inputCmp) {
      setTimeout(() => {
          inputCmp.focus();
      }, 100);
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

  setDataIdFocus(dataId) {
    setTimeout(() => {
        let closeButton = this.template.querySelector('[data-id="'+dataId+'"]');
        if(closeButton) {
            closeButton.focus();
        }
    }, 500);
  }

  setAriaLabel(data, count) {
      data.nameAriaLabel = 'Name of family member ' + count;
      data.ageAriaLabel = 'Age of family member ' + count;
      data.relationshipAriaLabel = 'Relationship of family member ' + count;
      data.incomeAriaLabel = 'Income of family member ' + count;
      data.addIncomeAriaLabel = 'Add Income for family member ' + count;
      data.deleteAriaLabel = 'Delete family member ' + count;
  }

  handleKeyUp(event) {
    if(event.code == 'Escape') {
      this.closeDeleteConfirmModal();
    }
    event.preventDefault();
    event.stopPropagation();
  }

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