import { LightningElement,track,api } from 'lwc';
import getAllInternalStaffItems from '@salesforce/apex/Nc_InternalStaffUserRequestItemsClass.getAllInternalStaffItems';
import updateAllStaffItems from '@salesforce/apex/Nc_InternalStaffUserRequestItemsClass.updateAllStaffItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Nc_InternalStaffUserRequestItems extends LightningElement {
  @api recordId;
  @track internalStaffItemList;
  @track showSpinner = false;  
  @track editMode = false;   
  @track mileageLessThanNintyNine = true; 
  @track totalAmountBilled;


  connectedCallback() {
    this.queryAllInternalLineItems();
  }

  //For enabling editing mode
  enableEditing() {
    this.editMode = true;
  }

  //back to non edit mode
  cancelEditing() {
    this.editMode = false;
    this.queryAllInternalLineItems();
  }

  queryAllInternalLineItems(){
    this.showSpinner = true;
    getAllInternalStaffItems({ recordId: this.recordId }).then(
      result => {
        console.log('result - ' , result.iternalStaffWrapperList);
        this.internalStaffItemList = result.iternalStaffWrapperList;
        this.totalAmountBilled = result.totalAmountBilled;
        this.mileageLessThanNintyNine = result.mileageLessThanNintyNine;
        this.calculateTotalBilledAmount(this.internalStaffItemList);
        this.showSpinner = false;
      }
    ).catch(
      error => {
        this.showErrorToastAndConsole(error);
        this.showSpinner = false;
      }
    );
  }


  updateValues(event){
    let sumOfAmount = 0;
    for(var i=0 ; i < this.internalStaffItemList.length ; i++){
        if(event.target.name === this.internalStaffItemList[i].fieldApiName){
          if(event.target.name === 'Mileage__c' && event.target.value > 99){
            this.mileageLessThanNintyNine = false;
            this.internalStaffItemList[i].quantity = event.target.value;
            this.internalStaffItemList[i].amountBilled = this.internalStaffItemList[i].quantity * this.internalStaffItemList[i].amountAuthorizedOver99Miles;
           
          }else{
            this.mileageLessThanNintyNine = true;
            this.internalStaffItemList[i].quantity = event.target.value;
            this.internalStaffItemList[i].amountBilled = this.internalStaffItemList[i].quantity * this.internalStaffItemList[i].amountAuthorized;
          }
        }
        sumOfAmount += this.internalStaffItemList[i].amountBilled;
    }
    this.totalAmountBilled = sumOfAmount;
  }


  updateAmountBilled(event){
    for(var i=0 ; i < this.internalStaffItemList.length ; i++){
      if(event.target.name === this.internalStaffItemList[i].fieldApiName){
        this.internalStaffItemList[i].amountBilled = Number(event.target.value);
      }
    }
    this.calculateTotalBilledAmount(this.internalStaffItemList);
  }


  calculateTotalBilledAmount(internalStaffItemList){
    let sumOfAmount = 0;
    for(var i=0 ; i < this.internalStaffItemList.length ; i++){
      if(this.internalStaffItemList[i].amountBilled !== null && this.internalStaffItemList[i].amountBilled !== undefined && this.internalStaffItemList[i].amountBilled !== ''){
        sumOfAmount += this.internalStaffItemList[i].amountBilled;
      }
    }
    this.totalAmountBilled = sumOfAmount;
  }

  submitChange(){
    this.showSpinner = true;
    if (!this.checkForError()) {
      console.log('Values check error');
      this.showToastMessage("Error!", "Please review all the errors", "error");
      this.showSpinner = false;
      return;
    }

    updateAllStaffItems({ recordId: this.recordId,  internalStaffItemList:  JSON.stringify(this.internalStaffItemList), totalAmountBilled: JSON.stringify(this.totalAmountBilled)}).then(
      result => {
        console.log('result - ' , result.iternalStaffWrapperList)
        this.showToastMessage("Success!", "Updated Successfully", "success");
        this.dispatchEvent(new CustomEvent("refresh") );
        this.showSpinner = false;
      }
    ).catch(
      error => {
        this.showErrorToastAndConsole(error);
        this.showSpinner = false;
      }
    );
  }

  //check if component has any error
  checkForError(){
    const allValid = [...this.template.querySelectorAll('lightning-input')]
      .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
      return allValid;
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

  // show error
  showErrorToastAndConsole(error) {
    console.log('error :', JSON.stringify(error));
    if (error && error.body && error.body.pageErrors && error.body.pageErrors.length > 0 && error.body.pageErrors[0].message) {
      this.showToastMessage("Error!", error.body.pageErrors[0].statusCode + ' : ' + error.body.pageErrors[0].message, "error");
    } else if(error && error.body && error.body.fieldErrors && error.body.fieldErrors[Object.keys(error.body.fieldErrors)].length > 0 && error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].statusCode && error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].message){
      this.showToastMessage("Error!", error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].statusCode + ' : ' + error.body.fieldErrors[Object.keys(error.body.fieldErrors)][0].message , "error");
    } else {
      this.showToastMessage("Error!", JSON.stringify(error), "error");
    }
  }
}