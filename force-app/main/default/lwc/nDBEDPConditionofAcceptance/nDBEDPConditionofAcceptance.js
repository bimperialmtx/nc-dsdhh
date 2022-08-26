import {
  LightningElement,
  wire,
  track,
  api
} from 'lwc';
import Condition_of_Acceptance_label_1 from '@salesforce/label/c.Condition_of_Acceptance_label_1';
import Condition_of_Acceptance_label_2 from '@salesforce/label/c.Condition_of_Acceptance_label_2';
import Condition_of_Acceptance_label_3 from '@salesforce/label/c.Condition_of_Acceptance_label_3';
import Condition_of_Acceptance_label_4 from '@salesforce/label/c.Condition_of_Acceptance_label_4';

import Condition_of_Acceptance_label_1_New from '@salesforce/label/c.Condition_of_Acceptance_label_1_New';
import Condition_of_Acceptance_label_2_New from '@salesforce/label/c.Condition_of_Acceptance_label_2_New';
import Condition_of_Acceptance_label_3_New from '@salesforce/label/c.Condition_of_Acceptance_label_3_New';
import Condition_of_Acceptance_label_4_New from '@salesforce/label/c.Condition_of_Acceptance_label_4_New';
import Condition_of_Acceptance_label_5_New from '@salesforce/label/c.Condition_of_Acceptance_label_5_New';
import Condition_of_Acceptance_label_6_New from '@salesforce/label/c.Condition_of_Acceptance_label_6_New';
import Condition_of_Acceptance_label_7_New from '@salesforce/label/c.Condition_of_Acceptance_label_7_New';
import Condition_of_Acceptance_label_8_New from '@salesforce/label/c.Condition_of_Acceptance_label_8_New';
import Condition_of_Acceptance_label_9_New from '@salesforce/label/c.Condition_of_Acceptance_label_9_New';

import saveData from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.saveData';
import fetchFields from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.fetchFields';
import saveCommentData from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.saveCommentData';
import getConsumerNameFromRequest from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.getConsumerNameFromRequest';
import getAcceptedValuefromRequest from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.getAcceptedValuefromRequest';
import getStatus from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.getStatus';
import getTodaysDate from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.getTodaysDate';
import fetchSignature from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.fetchSignature';
import getAccountFromRequest from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.getAccountFromRequest';
import requestEquipmentsforRequest from '@salesforce/apex/NC_NDBEDPConditionofAcceptanceCtrl.requestEquipmentsforRequest';


//import logo from '@salesforce/resourceUrl/NCDSDHHLOGO';
import logo from '@salesforce/resourceUrl/NCDSDHHLOGOAssessment';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class NDBEDPConditionofAcceptance extends LightningElement {
  @track logoURL = logo;
  @api recordId;
  @track RequestObj = {};
  @track RequestObjNew = {};
  @track consumerValueNew = '';
  @track accepted = false;
  @track todayDate;
  @track caseList = [];
  @track showCase;
  @track url = '/servlet/servlet.FileDownload?file=';
  @track openRejectModel;
  @track showSignLabel = false;
  @track usedInCommunity;
  signHereInfo = '';

  Condition_of_Acceptance_label_1 = Condition_of_Acceptance_label_1;
  Condition_of_Acceptance_label_2 = Condition_of_Acceptance_label_2;
  Condition_of_Acceptance_label_3 = Condition_of_Acceptance_label_3;
  Condition_of_Acceptance_label_4 = Condition_of_Acceptance_label_4;

  Condition_of_Acceptance_label_1_New = Condition_of_Acceptance_label_1_New;
  Condition_of_Acceptance_label_2_New = Condition_of_Acceptance_label_2_New;
  Condition_of_Acceptance_label_3_New = Condition_of_Acceptance_label_3_New;
  Condition_of_Acceptance_label_4_New = Condition_of_Acceptance_label_4_New;
  Condition_of_Acceptance_label_5_New = Condition_of_Acceptance_label_5_New;
  Condition_of_Acceptance_label_6_New = Condition_of_Acceptance_label_6_New;
  Condition_of_Acceptance_label_7_New = Condition_of_Acceptance_label_7_New;
  Condition_of_Acceptance_label_8_New = Condition_of_Acceptance_label_8_New;
  Condition_of_Acceptance_label_9_New = Condition_of_Acceptance_label_9_New;

  connectedCallback() {
    this.handleConnectedCallback();
  }
  handleConnectedCallback() {
    this.setDataIdFocus('close');
    if (location.href.indexOf('/s/') > 0) {
      this.usedInCommunity = true;
    } else {
      this.usedInCommunity = false;
    }
    requestEquipmentsforRequest({
        requestId: this.recordId
      })
      .then(res => {
        console.log('caselistone ' + JSON.stringify(res[0]));
        if (res.length == 0) {
          this.showCase = false;
        } else {
          this.showCase = true;
        }
        this.caseList = res;
      }).catch(error => {
        console.log('error' + JSON.stringify(error));
        console.log('error2' + error);

      });


    getStatus({
        requestId: this.recordId
      })
      .then(res => {
        this.statusValue = res;
        console.log('status value', this.statusValue);
        if (this.statusValue != 'Pending Condition of Acceptance') {
          this.showToastMessage('error', 'Invalid status to create Pending Condition of Acceptance', 'error');
          let value = true;
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
              value
            }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);
        }
      }).catch(error => {
        console.error(error);
        console.log('error' + JSON.stringify(error))
      });
    fetchFields({
        requestId: this.recordId
      })
      .then(res => {
        this.RequestObj = res;
        if (this.RequestObj.signed != '') {
          this.url = '/servlet/servlet.FileDownload?file=';
          this.url = this.url + this.RequestObj.signed;
          this.showImage = true;
        } else if (this.RequestObj.signed == '') {
          this.showImage = false;
        }

      }).catch(error => {
        console.error(error);
      });

    getConsumerNameFromRequest({
        requestId: this.recordId
      })
      .then(res => {
        this.consumerValueNew = res.Contact.Name;
      }).catch(error => {
        console.error(error);
      });

    getAccountFromRequest({
        requestId: this.recordId
      })
      .then(res => {
        if (res.External_Assessor__c != null) {
          if (res.External_Assessor__r.Is_Vendor_on_Portal__c == false) {
            console.log('assessor', res.External_Assessor__r.Is_Vendor_on_Portal__c);
            this.showSignLabel = true;
          }

        }

      }).catch(error => {
        console.error(error);
      });

    getTodaysDate()
      .then((result) => {
        this.todayDate = result;
      })
      .catch((error) => {
        let message = error.message || error.body.message;
      });

    getAcceptedValuefromRequest({
        requestId: this.recordId
      })
      .then(res => {
        //this.consumerValueNew = res.Contact.Name;
        this.accepted = res.CheckRejectAssessment__c;
        console.log('accepted', this.accepted);
      }).catch(error => {
        console.error(error);
      });

  }
  handleChange(event) {
    this.RequestObj[event.target.name] = event.target.value;

  }
  handleChangeNew(event) {
    
      this.RequestObjNew[event.target.name] = event.target.value;
      
  }

  @api
  handleRefresh() {
    //this.handleConnectedCallback();
    this.refreshData = true;
    this.getSignature();
    //this.handleClick(null);
  }
  getSignature() {

    this.showSpinner = true;
    fetchSignature({
        requestId: this.recordId
      })
      .then((result) => {
        if (result) {

          this.RequestObj.signed = result;
          this.url = '/servlet/servlet.FileDownload?file=';
          this.url = this.url + this.RequestObj.signed;
          console.log('get sign' + this.url);
          this.showImage = true;
        }
        this.showSpinner = false;
        this.handleClick(null);
      })
      .catch((error) => {
        this.showSpinner = false;
        let message = error.message || error.body.message;
      });
  }
  @track signHere = false;
  @api
  handleSignHere() {
    this.signHere = false;
    this.setDataIdFocus('signHere');
  }
  @track refreshData = false;
  @track showSpinner = false;

  handleClick(event) {
    const allValid = [...this.template.querySelectorAll('lightning-input')]
      .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        if(inputCmp.checkValidity() === false) {
          this.setFocusOnError(inputCmp);
        }
        if (!(validSoFar && inputCmp.checkValidity())) {
          this.refreshData = false;
        }
        return validSoFar && inputCmp.checkValidity();
      }, true);

    if (!this.RequestObj.signed && this.signHere == false && this.refreshData == false && (this.RequestObj.onlineAssessor || !this.RequestObj.onlineAssessor || this.RequestObj.internalAssessor)) {
      this.showToastMessage('error', 'Applicants Signature is required', 'error');
      this.signHereInfo = 'Applicants Signature is required';
      setTimeout(() => {
        this.signHereInfo = '';
      }, 10000);
      this.setDataIdFocus('signHere');
      return;
    }

    if (allValid) {
      if (event != null) {
        this.RequestObj.frombutton = event.currentTarget.dataset.frombutton;
      } else {
        this.RequestObj.frombutton = null;
      }
      this.RequestObj.requestId = this.recordId;
      this.showSpinner = true;

      saveData({
          dataObj: JSON.stringify(this.RequestObj)
        })
        .then(res => {
          // this.assesmentId = res
          this.showSpinner = false;
          if (res == 'true') {
            if (this.refreshData == true) {
              this.handleConnectedCallback();
              this.refreshData = false;
            } else {
              this.showToastMessage('success', 'Request saved Sucessfully', 'success');
              let value = true;
              const valueChangeEvent = new CustomEvent("valuechange", {
                detail: {
                  value
                }
              });
              // Fire the custom event
              this.dispatchEvent(valueChangeEvent);
              window.location.reload();
            }
          }
        }).catch(error => {
          this.showSpinner = false;
          let message = error.body || error.body.message;
          this.showToastMessage('error', message, 'error');
          console.log(JSON.stringify(error));
        });
    }
  }
  handleCancel() {

    let value = true;
    const valueChangeEvent = new CustomEvent("valuechange", {
      detail: {
        value
      }
    });
    // Fire the custom event
    this.dispatchEvent(valueChangeEvent);
  }

  handleSign(event) {
    this.signHere = true;
    const valueChangeEventone = new CustomEvent("valuechangeeventone", {
      detail: {
        'value': true
      }
    });
    // Fire the custom event
    this.dispatchEvent(valueChangeEventone);
  }

  showToastMessage(title, message, variant) {
    const event = new ShowToastEvent({
      "title": title,
      "message": message,
      "variant": variant,
    });
    this.dispatchEvent(event);
  }
  @track isModalOpen = false;
  openModal() {
    // to open modal set isModalOpen tarck value as true
    // this.isModalOpen = true;
    this.openRejectModel = true;
    setTimeout(()=>{					
      this.focusFirstEle('.reject-confirm-modal');
    },500);
    this.setDataIdFocus('rejectModalId');
  }
  closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
    this.setDataIdFocus('rejectButton');
  }
  rejectConfirmation() {
    this.openRejectModel = false;
    this.isModalOpen = true;
    setTimeout(()=>{					
      this.focusFirstEle('.reject-modal');
     },500);
    this.setDataIdFocus('rejectConfirmId');
  }
  closeModalReject() {
    this.openRejectModel = false;
    this.setDataIdFocus('rejectButton');
  }
  submitDetails() {
    // to close modal set isModalOpen tarck value as false
    //Add your code to call apex method or do some processing
    const Valid = [...this.template.querySelectorAll('lightning-textarea')]
      .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);

    this.RequestObjNew.requestId = this.recordId;
    console.log('wrapper' + JSON.stringify(this.RequestObjNew));
    if(Valid){
    this.showSpinner=true;
    saveCommentData({

        dataObjComment: JSON.stringify(this.RequestObjNew)
      })
      .then(res => {

        let value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: {
            value
          }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);

        window.location.reload();
      }).catch(error => {

        console.log(JSON.stringify(error));
      });
    }
    //this.isModalOpen = false;
  }
  closeModalNew() {
    let value = true;
    const valueChangeEvent = new CustomEvent("valuechange", {
      detail: {
        value
      }
    });
    // Fire the custom event
    this.dispatchEvent(valueChangeEvent);

  }
  setFocusOnError(inputCmp) {
    setTimeout(() => {
        inputCmp.focus();
    }, 100);
  }
  setDataIdFocus(dataId) {
    setTimeout(() => {
        let closeButton = this.template.querySelector('[data-id="'+dataId+'"]');
        if(closeButton) {
            closeButton.focus();
        }
    }, 500);
  }
  handleKeyUp(event) {
    if(event.key === 'Escape') {
      if(this.isModalOpen === true) {
          this.closeModal();
      } else if (this.openRejectModel === true) {
          this.closeModalReject();
      }
      event.stopPropagation();
      event.preventDefault();
    }
  }
  focusFirstEle(className) {
    const focusableElements = 'button, p, lightning-button, lightning-textarea';
    console.log('focusableElements',focusableElements);
    const modal = this.template.querySelector(className);
    
    const firstFocusableElement = modal.querySelectorAll('[data-name="modal"]')[0];
    const focusableContent = modal.querySelectorAll('[data-name="modal"]');
    const lastFocusableElement = focusableContent[focusableContent.length - 1];

    firstFocusableElement.focus();
    
    this.template.addEventListener('keydown', function(event) {
        if(event.key === 'Escape') {
          if(this.isModalOpen === true) {
              this.closeModal();
          } else if (this.openRejectModel === true) {
              this.closeModalReject();
          }
          event.stopPropagation();
          event.preventDefault();
        }
        let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
        if (!isTabPressed) {
            return;
        }
        if (event.shiftKey) {       
            if (this.activeElement === firstFocusableElement) {
                lastFocusableElement.focus(); 
                event.stopPropagation();
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