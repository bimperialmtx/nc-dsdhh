import { LightningElement,api,track } from 'lwc';
import getAllLineItems from '@salesforce/apex/NC_InvoiceLineItemNDBEDPController.getAllLineItems';
import updateAllLineItems from '@salesforce/apex/NC_InvoiceLineItemNDBEDPController.updateAllLineItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class Nc_invoiceLineItemsNDBEDP extends LightningElement {

    @api   recordId;                        //Record Id of Invoice
    @track editMode = false;                //check if edit mode
    @track lineItemsList = [];              //List of invoice item
    @track showSpinner = false;             //For showing spinner
    @track totalAmountBilled;               //Sum of all the amount billed
    @track totalAmountToPay;               //Sum of all the amount to Pay
    @track commentAvailable = false;
    @track hideEditButton = false;
    @track authorizedCostMap = [];
  
    
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
            if(result && result.error) {
              if(result.error.includes('ENTITY_IS_LOCKED')) {
                this.showToastMessage("Error!", "Cannot edit line items as record is submitted for approval", "error");
              } else {
                this.showToastMessage("Error!", result.error, "error");
              }
            } else {
              this.showToastMessage("Success!", "Invoice Line Item Saved", "success");
              this.dispatchEvent(new CustomEvent("refresh") );
              this.lineItemsList = this.updateZeroWithBlack(result.lineItemListWrapperList);
              this.totalAmountBilled = result.totalAmountBilled;
              this.totalAmountToPay = result.totalAmountToPay;
            }
            this.showSpinner = false;
          }
        ).catch(
          error => {
            this.showSpinner = false;
            this.showToastMessage("Error!", error.message || error.data.message, "error");
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
                    if(this.lineItemsList[i].isQuantityToBillEditable == false && this.lineItemsList[i].isAmountToBillEditable == false && this.lineItemsList[i].isQuantityToPayEditable == false && this.lineItemsList[i].isAmountToPayEditable == false) {
                        this.hideEditButton = true;
                    }
                }
                this.totalAmountBilled = result.totalAmountBilled;
                this.totalAmountToPay = result.totalAmountToPay;
                this.authorizedCostMap = result.authorizedCostMap;
                this.showSpinner = false;
            }
        ).catch(
            error => {
                this.showToastMessage("Error!", error.message || error.body.message, "error");
                this.showSpinner = false;
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

            var qtyToBillCmp = this.template.querySelector('lightning-input[data-name="'+this.lineItemsList[i].lineItemName+'"]');
            let isError = false;
            if(this.authorizedCostMap && !isNaN(quantity)) {
              for(var cost in this.authorizedCostMap) {
                if(this.authorizedCostMap[cost] != null && cost == this.lineItemsList[i].lineItemName && quantity > this.authorizedCostMap[cost]) {
                  isError = true;
                  break;
                }
              }
            }
            if(isError && qtyToBillCmp) {
              qtyToBillCmp.setCustomValidity('Should be less than Authorized Quantity to Bill');
              qtyToBillCmp.reportValidity();
            } else if(qtyToBillCmp){
              qtyToBillCmp.setCustomValidity('');
              qtyToBillCmp.reportValidity();
            }

            var qtyToPayCmp = this.template.querySelector('lightning-input[data-name="'+event.target.name+'"]');
            var quantityToPay = this.lineItemsList[i].quantityToPay;
            if(qtyToPayCmp && quantityToPay > 0 && (quantity < quantityToPay)) {
                qtyToPayCmp.setCustomValidity('Should be less than Quantity to Bill');
                qtyToPayCmp.reportValidity();
            } else if(qtyToPayCmp) {
              qtyToPayCmp.setCustomValidity('');
              qtyToPayCmp.reportValidity();
            }

            if(label === 'Mileage') {
              total =  quantity * amountAuth;
            } else {
              console.log('quantity --> ' +quantity);
              var quantityString = quantity + '';
              var after = quantityString.split(".")[1];
              console.log('after --> ' + after);
              if(after && after.length == 1) {
                after = parseFloat(after + '0');
              }
              var before = quantityString.split(".")[0];
              total = parseFloat(before) * amountAuth;
              if(quantityString.split(".")[1] != '' && quantityString.split(".")[1] != undefined){
                if(after > 0 && after <= 25) {
                  after = '15';
                } else if(after > 25 && after <= 50) {
                  after = '30';
                } else if(after > 50 && after <= 75) {
                  after = '45';
                } else if(after > 75 && after <= 99) {
                  after = '60';
                }
                var amountCalculation = amountAuth / 4;
                if(after == '15' && amountAuth != ''){
                  amountExtra = amountCalculation;
                }else if(after == '30' && amountAuth != ''){
                  amountExtra = amountCalculation * 2;
                }else if(after == '45' && amountAuth != ''){
                  amountExtra = amountCalculation * 3;
                }else if(after == '60' && amountAuth != ''){
                  amountExtra = amountCalculation * 4;
                }
              }
              total += amountExtra;
            }
            this.lineItemsList[i].quantityToBill = quantity;
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

                var amountToBillCmp = this.template.querySelector('lightning-input[data-name="'+this.lineItemsList[i].lineItemName+'"]');
                let isError = false;
                if(this.authorizedCostMap && !isNaN(this.lineItemsList[i].amountBilled)) {
                  for(var cost in this.authorizedCostMap) {
                    if(this.authorizedCostMap[cost] != null && cost == this.lineItemsList[i].lineItemName && this.lineItemsList[i].amountBilled > this.authorizedCostMap[cost]) {
                      isError = true;
                      break;
                    }
                  }
                }
                if(isError && amountToBillCmp) {
                  amountToBillCmp.setCustomValidity('Should be less than Authorized Amount');
                  amountToBillCmp.reportValidity();
                } else if(amountToBillCmp){
                  amountToBillCmp.setCustomValidity('');
                  amountToBillCmp.reportValidity();
                }
                
                var amountToPayCmp = this.template.querySelector('lightning-input[data-name="'+event.target.name+'"]');
                var amountToPay = this.lineItemsList[i].amountToPay;
                if(amountToPayCmp && amountToPay > 0 && (this.lineItemsList[i].amountBilled < amountToPay)) {
                  amountToPayCmp.setCustomValidity('Should be less than Amount Billed');
                  amountToPayCmp.reportValidity();
                } else if(amountToPayCmp) {
                  amountToPayCmp.setCustomValidity('');
                  amountToPayCmp.reportValidity();
                }
            }
            sumOfAmount += parseFloat(this.lineItemsList[i].amountBilled);
        }
        this.totalAmountBilled = parseFloat(sumOfAmount).toFixed(2);
    }

    updateAmountToPayValues(event) {
      var label = event.target.label;
      let sumOfAmount = 0;
      for(var i=0; i<this.lineItemsList.length; i++){
          if(event.target.name === this.lineItemsList[i].invoiceLineItemId){
            var quantity = parseFloat(event.target.value);
            var amountAuth = parseFloat(this.lineItemsList[i].amountAuthorized);
            var total = 0.00;
            var amountExtra = 0.00;

            var qtyToPayCmp = this.template.querySelector('lightning-input[data-name="'+event.target.name+'"]');
            var quantityToBill = this.lineItemsList[i].quantityToBill;
            if(qtyToPayCmp && (quantity > quantityToBill)) {
                qtyToPayCmp.setCustomValidity('Should be less than Quantity to Bill');
                qtyToPayCmp.reportValidity();
            } else if(qtyToPayCmp) {
              qtyToPayCmp.setCustomValidity('');
              qtyToPayCmp.reportValidity();
            }

            if(label === 'Mileage') {
              total =  quantity * amountAuth;
            } else {
              console.log('quantity --> ' +quantity);
              var quantityString = quantity + '';
              var after = quantityString.split(".")[1];
              console.log('after --> ' + after);
              if(after && after.length == 1) {
                after = parseFloat(after + '0');
              }
              var before = quantityString.split(".")[0];
              total = parseFloat(before) * amountAuth;
              if(quantityString.split(".")[1] != '' && quantityString.split(".")[1] != undefined){
                if(after > 0 && after <= 25) {
                  after = '15';
                } else if(after > 25 && after <= 50) {
                  after = '30';
                } else if(after > 50 && after <= 75) {
                  after = '45';
                } else if(after > 75 && after <= 99) {
                  after = '60';
                }
                var amountCalculation = amountAuth / 4;
                if(after == '15' && amountAuth != ''){
                  amountExtra = amountCalculation;
                }else if(after == '30' && amountAuth != ''){
                  amountExtra = amountCalculation * 2;
                }else if(after == '45' && amountAuth != ''){
                  amountExtra = amountCalculation * 3;
                }else if(after == '60' && amountAuth != ''){
                  amountExtra = amountCalculation * 4;
                }
              }
              total += amountExtra;
            }
            this.lineItemsList[i].quantityToPay = quantity;
            this.lineItemsList[i].amountToPay = total;
          }
          sumOfAmount += this.lineItemsList[i].amountToPay;
      }
      this.totalAmountToPay = parseFloat(sumOfAmount).toFixed(2);
        
    }

    //Update Amount To Pay
    updateAmountToPay(event){
      let sumOfAmount = 0;
        for(var i=0; i<this.lineItemsList.length; i++){
            if(event.target.name === this.lineItemsList[i].invoiceLineItemId){
                this.lineItemsList[i].amountToPay = parseFloat(event.target.value);

                var amountToPayCmp = this.template.querySelector('lightning-input[data-name="'+event.target.name+'"]');
                var amountBilled = this.lineItemsList[i].amountBilled;
                if(amountToPayCmp && (this.lineItemsList[i].amountToPay > amountBilled)) {
                  amountToPayCmp.setCustomValidity('Should be less than Amount Billed');
                  amountToPayCmp.reportValidity();
                } else if(amountToPayCmp) {
                  amountToPayCmp.setCustomValidity('');
                  amountToPayCmp.reportValidity();
                }
            }
            sumOfAmount += parseFloat(this.lineItemsList[i].amountToPay);
        }
        this.totalAmountToPay = parseFloat(sumOfAmount).toFixed(2);
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