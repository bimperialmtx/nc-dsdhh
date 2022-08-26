import { LightningElement,api,track } from 'lwc';
import getAllLineItems from '@salesforce/apex/NC_InvoiceLineItemStaffingController.getAllLineItems';
import updateAllLineItems from '@salesforce/apex/NC_InvoiceLineItemStaffingController.updateAllLineItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class Nc_invoice_line_item_staffing extends LightningElement {

    @api   recordId;                        //Record Id of Invoice
    @track editMode = false;                //check if edit mode
    @track lineItemsList = [];              //List of invoice item
    @track showSpinner = false;             //For showing spinner
    @track totalAmountBilled;               //Sum of all the amount billed
    @track commentAvailable = false;
  
    
    connectedCallback() {
      this.queryInvoiceLineItems();
    }

    //for saving all the changes in the Invoice line item
    submitChange() {
      this.showSpinner = true;
      if (!this.checkForError()) {
        this.showToastMessage("Error!", "Please review all the errors", "error");
        this.showSpinner = false;
        return;
      }
      for(var i in this.lineItemsList) {
        if(this.lineItemsList[i].lineItemName == 'Other' && this.lineItemsList[i].amountBilled > 0 && (this.lineItemsList[i].otherComment == null || this.lineItemsList[i].otherComment == '')) {
          this.showToastMessage("Error!", "Add Comment to proceed", "error");
          this.showSpinner = false;
          return;
        }
      }
      this.lineItemsList = this.updateBlankToZero(this.lineItemsList);
      updateAllLineItems({ lineItemData: JSON.stringify(this.lineItemsList), recordId : this.recordId  }).then(
        result => {
          this.showToastMessage("Success!", "Invoice Line Item Saved", "success");
          this.dispatchEvent(new CustomEvent("refresh") );
          this.lineItemsList = this.updateZeroWithBlack(result.lineItemListWrapperList);
          this.totalAmountBilled = result.totalAmountBilled;
          this.showSpinner = false;
        }
      ).catch(
        error => {
          this.showSpinner = false;
          this.showToastMessage("Error!", error.message || error.data.message, "error");
          console.log('errorrr1',JSON.stringify(error));
        }
      );
      this.editMode = false;
    }

    //get all the invoice item on page load
    queryInvoiceLineItems() {
      this.showSpinner = true;
      getAllLineItems({ recordId: this.recordId }).then(
        result => {
          this.lineItemsList = this.updateZeroWithBlack(result.lineItemListWrapperList);
          for(var i in this.lineItemsList) {
            if(this.lineItemsList[i].otherCommentVisible == true) {
              this.commentAvailable = true;
            }
          }
          this.totalAmountBilled = result.totalAmountBilled;
          this.showSpinner = false;
        }
      ).catch(
        error => {
          this.showToastMessage("Error!", error, "error");
          console.log('errorrr2',JSON.stringify(error));

        }
      );
    }

    updateOtherComment(event) {
      for(var i=0; i<this.lineItemsList.length; i++){
        if(event.target.name === this.lineItemsList[i].invoiceLineItemId){
          this.lineItemsList[i].otherComment = event.target.value;
        }
      }
    }
    
    //Update value in amount billed
    updateValues(event) {
      var label = event.target.label;
      let sumOfAmount = 0;
      for(var i=0; i<this.lineItemsList.length; i++){
          if(event.target.name === this.lineItemsList[i].invoiceLineItemId){
            var quantity = parseFloat(event.target.value);
            var amountAuth = parseFloat(this.lineItemsList[i].amountAuthorized);
            var total = 0.00;
            var amountExtra = 0.00;
            if(label.includes("Enhanced") || label.includes("Standard") || label === "Hours" || label === "Travel Time"){
              console.log('quantity --> ' +quantity);
              var quantityString = quantity + '';
              var after = quantityString.split(".")[1];
              console.log('after --> ' + after);
              var before = quantityString.split(".")[0];
              total = parseFloat(before) * amountAuth;
              if(quantityString.split(".")[1] != '' && quantityString.split(".")[1] != undefined){
                if(after == '5'){
                  after = '30';
                }else if(after == '4'){
                  after = '30';
                }else if(after == '2'){
                  after = '15';
                }else if(after == '3'){
                  after = '30';
                }
                var amountCalculation = amountAuth / 4;
                if(after == '15' && amountAuth != ''){
                  amountExtra = amountCalculation;
                }else if(after == '30' && amountAuth != ''){
                  amountExtra = amountCalculation * 2;
                }else if(after == '45' && amountAuth != ''){
                  amountExtra = amountCalculation * 3;
                }
              }
              total += amountExtra;
            }else{
              var quantityString = quantity + '';
              if(quantityString.split(".")[1] != '' && quantityString.split(".")[1] != undefined){
                quantity = parseFloat(quantityString.split(".")[0]);
              }
              console.log('quantity --> ' + quantity);
              total =  quantity * amountAuth;
            }
            this.lineItemsList[i].quantity = quantity;
            this.lineItemsList[i].amountBilled = total;
          }
          sumOfAmount += this.lineItemsList[i].amountBilled;
      }
      this.totalAmountBilled = parseFloat(sumOfAmount).toFixed(2);
        
    }

    //Update Amount Billed
    updateBilledAmount(event){
      let sumOfAmount = 0;
        for(var i=0; i<this.lineItemsList.length; i++){
            if(event.target.name === this.lineItemsList[i].invoiceLineItemId){
                this.lineItemsList[i].amountBilled = parseFloat(event.target.value);
            }
            sumOfAmount += parseFloat(this.lineItemsList[i].amountBilled);
        }
        this.totalAmountBilled = parseFloat(sumOfAmount).toFixed(2);
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