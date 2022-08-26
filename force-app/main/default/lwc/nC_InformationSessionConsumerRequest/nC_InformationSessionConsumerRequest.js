import { LightningElement, track, api } from 'lwc';
import fetchConsumerList from '@salesforce/apex/NC_InformationSessionConsumerRequest.fetchConsumerList';
import sendInviationToConsumer from '@salesforce/apex/NC_InformationSessionConsumerRequest.sendInviationToConsumer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NC_InformationSessionConsumerRequest extends LightningElement {
  @api recordId;
  @track consumerList;
  @track oldConsumerList;
  @track searchInput;
  
  connectedCallback(){
   this.getConsumerData(this.recordId);
  }

    updateAll(event){
      this.consumerList = this.consumerList.map(element => {
          element.isSelected = event.target.checked;
          return element;
      });
    }

    updateSelected(event){
      this.consumerList = this.consumerList.map(element => {
          if(element.consumerId  === event.target.name){
              element.isSelected = event.target.checked;
          }
          return element;
      });
    }

    updateList(event){
      let sampleList = [];
      let consumerName;
      let consumerEmail;
      this.searchInput = event.target.value.trim().toLowerCase();
      if(this.searchInput === '' || this.searchInput === undefined || this.searchInput === null){
          this.consumerList = this.oldConsumerList ;
      }else{
          for(let i=0; i < this.oldConsumerList.length; i++){
              if(this.oldConsumerList[i].consumerName === undefined || this.oldConsumerList[i].consumerName === null){
                consumerName = '';
              }else{
                consumerName = this.oldConsumerList[i].consumerName;
              }
              
              if(this.oldConsumerList[i].consumerEmailId === undefined || this.oldConsumerList[i].consumerEmailId === null){
                consumerEmail = '';
              }else{
                consumerEmail = this.oldConsumerList[i].consumerEmailId;
              }

              if(  consumerName.toLowerCase().startsWith(this.searchInput)
                   || consumerEmail.toLowerCase().startsWith(this.searchInput)){
                  sampleList.push(this.oldConsumerList[i]);
              }
          }
          this.consumerList = sampleList; 
      }
    }


    getConsumerData(recordId){
      fetchConsumerList({recordId : recordId}).then(
        result => {
          if(result.error){
                this.showToastMessage("Error!", result.error, "error");
          }else{
            this.consumerList = result.result;
            this.oldConsumerList = this.consumerList;
          }
        }
      ).catch(
        error => {
          this.showErrorToastAndConsole(error);
        }
      );
    }

    sendInvitation(){
      sendInviationToConsumer({consumerdata : JSON.stringify(this.consumerList), recordId : this.recordId}).then(
          result => {
              if(result.error){
                 this.showToastMessage("Error!", result.error, "error");
                 this.setFocusOnCheckBox();
              }else if(result.warning){
                  this.showToastMessage("Warning!", result.warning, "warning");
              }else{
                  this.showToastMessage("Success!", result.success, "success");
                  this.dispatchEvent(new CustomEvent("refresh") );
                  this.getConsumerData(this.recordId);
              }
          }
      ).catch(
          error => {
            this.showErrorToastAndConsole(error);
          }
      );
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

  setFocusOnCheckBox() {
    setTimeout(() => {
        let checkBoxes = this.template.querySelectorAll("[data-id='checkBoxId']");
        checkBoxes[0].focus();
    }, 500);
  }
}