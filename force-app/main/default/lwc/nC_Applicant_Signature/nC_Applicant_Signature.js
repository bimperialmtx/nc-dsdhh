import {
  LightningElement,
  track,
  api
} from 'lwc';
//import saveSignatureData from '@salesforce/apex/NC_ApplicantSignature.saveSignatureData';
import Condition_of_Acceptance_label_1 from '@salesforce/label/c.Condition_of_Acceptance_label_1';
import Condition_of_Acceptance_label_2 from '@salesforce/label/c.Condition_of_Acceptance_label_2';
import Condition_of_Acceptance_label_3 from '@salesforce/label/c.Condition_of_Acceptance_label_3';
import Condition_of_Acceptance_label_4 from '@salesforce/label/c.Condition_of_Acceptance_label_4';
import Confidentiality_Policy from '@salesforce/label/c.Confidentiality_Policy';

import saveData from '@salesforce/apex/NC_ApplicantSignature.saveData';
import getStatus from '@salesforce/apex/NC_ApplicantSignature.getStatus';
import getConsumerNameFromRequest from '@salesforce/apex/NC_ApplicantSignature.getConsumerNameFromRequest';
import fetchFields from '@salesforce/apex/NC_ApplicantSignature.fetchFields';
import saveCommentData from '@salesforce/apex/NC_ApplicantSignature.saveCommentData';
import getTodaysDate from '@salesforce/apex/NC_ApplicantSignature.getTodaysDate';
import fetchSignature from '@salesforce/apex/NC_ApplicantSignature.fetchSignature';
import getAccountFromRequest from '@salesforce/apex/NC_ApplicantSignature.getAccountFromRequest';


import logo from '@salesforce/resourceUrl/NCDSDHHLOGOAssessment';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';


export default class NC_Applicant_Signature extends LightningElement {
  @track logoURL = logo;
  @api recordId;
  @track RequestObj = {};
  @track RequestObjNew = {};
  @track consumerValueNew = '';
  @track accepted = false;
  @track todayDate;
  @track url = '/servlet/servlet.FileDownload?file=';
  @track showImage = false;
  @track openRejectModel;
  @track signHere = false;
  @track showSignLabel = false;
  @track usedInCommunity;
  signHereInfo = '';

  Condition_of_Acceptance_label_1 = Condition_of_Acceptance_label_1;
  Condition_of_Acceptance_label_2 = Condition_of_Acceptance_label_2;
  Condition_of_Acceptance_label_3 = Condition_of_Acceptance_label_3;
  Condition_of_Acceptance_label_4 = Condition_of_Acceptance_label_4;
  Confidentiality_Policy = Confidentiality_Policy;


  connectedCallback() {
    console.log('record id', this.recordId);
    this.handleConnectedCallback();
  }

  handleConnectedCallback() {
    this.setDataIdFocus('close');
    if (location.href.indexOf('/s/') > 0) {
      this.usedInCommunity = true;
    } else {
      this.usedInCommunity = false;
    }
    getConsumerNameFromRequest({
        requestId: this.recordId
      })
      .then(res => {
        console.log('consumer Name' + JSON.stringify(res));
        this.consumerValueNew = res.Contact.Name;
      }).catch(error => {
        console.log('error' + error);
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


    console.log('redord idd', this.recordId);

    getStatus({
        requestId: this.recordId
      })
      .then(res => {
        console.log('status value', JSON.stringify(res));
        this.statusValue = res.cas;
        this.ProfileName = res.user;
        console.log('status value', this.statusValue);
        if (this.statusValue != 'Applicant Signature' && this.ProfileName == 'NDBEDP Assessor') {
          console.log('profile name' + this.ProfileName);
          this.showToastMessage('error', 'Invalid status to create Applicant Signature', 'error');
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
        console.log(error);
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
        console.log('url id' + this.RequestObj.signed);
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
  }
  handleChange(event) {
    this.RequestObj[event.target.name] = event.target.value;

  }
  handleChangeNew(event) {
    this.RequestObjNew[event.target.name] = event.target.value;
  }
  @track refreshData = false;
  @track showSpinner = false;
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
  @api
  handleSignHere() {
    this.signHere = false;
    this.setDataIdFocus('signHere');
  }


  handleClick(event) {
    const allValid = [...this.template.querySelectorAll('lightning-input')]
      .reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        if (inputCmp.checkValidity() === false) {
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
          console.log('inside savedata2' + res);
          if (res == 'true') {
            if (this.refreshData == true) {
              this.handleConnectedCallback();
              this.refreshData = false;
            } else {
              console.log('inside savedata3' + res);
              this.showToastMessage('success', 'Request saved Sucessfully', 'success');
              console.log('inside savedata4');

              let value = true;
              const valueChangeEvent = new CustomEvent("valuechange", {
                detail: {
                  value
                }
              });
              // Fire the custom event
              this.dispatchEvent(valueChangeEvent);
              console.log('inside savedata5');

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
  handleRejectionModel() {
    this.openRejectModel = true;
    setTimeout(() => {
      this.focusFirstEle('.reject-confirm-modal');
    }, 500);
    this.setDataIdFocus('rejectModalId');
  }
  closeModalReject() {
    this.openRejectModel = false;
    this.setDataIdFocus('rejectButton');
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
    this.isModalOpen = true;
    setTimeout(() => {
      this.focusFirstEle('.reject-modal');
    }, 500);
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
    setTimeout(() => {
      this.focusFirstEle('.reject-modal');
    }, 500);
    this.setDataIdFocus('rejectConfirmId');
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
    if (Valid) {
      this.showSpinner = true;
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
          let message = error.body || error.body.message;
          this.showToastMessage('error', message, 'error');
          console.log(JSON.stringify(error));
        });
    }
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
      let closeButton = this.template.querySelector('[data-id="' + dataId + '"]');
      if (closeButton) {
        closeButton.focus();
      }
    }, 500);
  }

  handleKeyUp(event) {
    if (event.key === 'Escape') {
      if (this.isModalOpen === true) {
        this.closeModal();
      } else if (this.openRejectModel === true) {
        this.closeModalReject();
      }
      event.stopPropagation();
      event.preventDefault();
    }
  }

  focusFirstEle(className) {
    const focusableElements = '.modal-focused';
    console.log('focusableElements', focusableElements);
    const modal = this.template.querySelector(className);

    const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
    const focusableContent = modal.querySelectorAll(focusableElements);
    const lastFocusableElement = focusableContent[focusableContent.length - 1];

    firstFocusableElement.focus();

    this.template.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') {
        if (this.isModalOpen === true) {
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