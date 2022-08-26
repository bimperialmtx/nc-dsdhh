import { LightningElement,api,track } from 'lwc';
import getAllLineItems from '@salesforce/apex/NC_LineItemController.getAllLineItems';
import updateAllLineItems from '@salesforce/apex/NC_LineItemController.updateAllLineItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'



export default class NC_LineItemList extends LightningElement {
  
    @api   recordId;                        //Record Id of Invoice
    @track editMode = false;                //check if edit mode
    @track lineItemsList = [];              //List of invoice item
    @track showSpinner = false;             //For showing spinner
    @track totalBilledAmount;               //Sum of all the amount billed
    @track maxTotalAmountAuthorized;        //Total Amount authorized, if Invoice type is not hearing aid it is equal to -1
    @track maxTotalAmountAuthorizedReturned;//Total Amount Returned authorized, if Invoice type is not hearing aid it is equal to -1
    @track showTotalAmountError = false;    //For showing error of total amount 
    @track totalAmountInputClass='';              //For showing error of total amount 
    @track isHearingAid = false;
    @track statusReturned = false;
    @track invoiceApproved = false;

    @track column1;
    @track column2;
    @track column3;
    @track column4;
  
    
    connectedCallback() {
      this.queryInvoiceLineItems();
    }

    //for saving all the changes in the Invoice line item
    submitChange() {
      this.showSpinner = true;
      if (!this.checkForError() || this.showTotalAmountError) {
        this.showToastMessage("Error!", "Please review all the errors", "error");
        this.showSpinner = false;
        return;
      }
      this.lineItemsList = this.updateBlankToZero(this.lineItemsList);
      updateAllLineItems({ lineItemData: JSON.stringify(this.lineItemsList) }).then(
        result => {
          this.showToastMessage("Success!", "Invoice Line Item Saved", "success");
          this.dispatchEvent(new CustomEvent("refresh") );
          this.queryInvoiceLineItems();
          this.showSpinner = false;
        }
      ).catch(
        error => {
          this.showToastMessage("Error!", error, "error");
        }
      );
      this.editMode = false;
    }

    //get all the invoice item on page load
    queryInvoiceLineItems() {
      this.showSpinner = true;
      getAllLineItems({ recordId: this.recordId }).then(
        result => {
          this.maxTotalAmountAuthorized = Number(result.totalAmountAuthorized);
          this.maxTotalAmountAuthorizedReturned =  Number(result.totalAmountAuthorizedReturned);
          this.isHearingAid = Boolean(result.isHearingAid);
          this.statusReturned = String(result.status) == 'Returned' ? true : false;
          this.totalBilledAmount = Number(result.total);
          this.totalAmountInputClass = '' ;
          this.showTotalAmountError = false;
          this.lineItemsList = result.lineItemListWrapperList;
          this.invoiceApproved = result.invoiceApproved;
          this.lineItemsList = this.updateZeroWithBlack(this.lineItemsList);
          if(result.isNDBEDP && result.isNDBEDP == true) {
            this.column1 = 'Equipment Number';
            this.column2 = 'Equipment Name';
            this.column3 = 'Amount Billed';
            this.column4 = 'Amount to Pay';
          } else {
            this.column1 = 'Invoice Line Item Number';
            this.column2 = 'Equipment Name';
            this.column3 = 'Amount Authorized';
            this.column4 = 'Amount Billed';
          }
          this.showSpinner = false;
        }
      ).catch(
        error => {
          this.showToastMessage("Error!", error, "error");
        }
      );
    }
    
    //Update value in amount billed
    updateValues(event) {
      let sumOfAmount = 0;
      for(var i=0; i<this.lineItemsList.length; i++){
        if(event.target.name === this.lineItemsList[i].invoiceLineItemId){
          this.lineItemsList[i].amountBilled = event.target.value;
        }
        sumOfAmount += Number(this.lineItemsList[i].amountBilled);
      }
      this.totalBilledAmount = sumOfAmount;
      if(this.isHearingAid && !this.statusReturned){
        if(this.maxTotalAmountAuthorized < this.totalBilledAmount){
          this.totalAmountInputClass = 'slds-has-error' ;
          this.showTotalAmountError = true;
        }else{
          this.totalAmountInputClass = '' ;
          this.showTotalAmountError = false;
        }
      }else if(this.isHearingAid && this.statusReturned){
        if(this.maxTotalAmountAuthorizedReturned < this.totalBilledAmount){
          this.totalAmountInputClass = 'slds-has-error' ;
          this.showTotalAmountError = true;
        }else{
          this.totalAmountInputClass = '' ;
          this.showTotalAmountError = false;
        }
      }
    }

    updateBlankToZero(lineItemsList){
      lineItemsList.forEach(element => {
        if( element.amountAuthorized === '' ){
          element.amountAuthorized = 0;
        }
      });
      return lineItemsList;
    }

    updateZeroWithBlack(lineItemsList){
      lineItemsList.forEach(element => {
        if( Number(element.amountAuthorized) === 0 ){
          element.amountAuthorized = '';
        }
      });
      return lineItemsList;
    }

    //For enabling editing mode
    enableEditing() {
      this.editMode = true;
    }

    //back to non edit mode
    cancelEditing() {
      this.editMode = false;
      this.queryInvoiceLineItems();
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


}