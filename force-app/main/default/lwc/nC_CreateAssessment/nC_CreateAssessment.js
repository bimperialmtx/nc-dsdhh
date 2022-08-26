import {
    LightningElement,
    api,
    track
} from 'lwc';
import fetchPicklist from '@salesforce/apex/NC_AssessmentCtrl.fetchPicklist';
import saveData from '@salesforce/apex/NC_AssessmentCtrl.saveData';
import getConsumerNameFromRequest from '@salesforce/apex/NC_AssessmentCtrl.getConsumerNameFromRequest';
import getAccountFromRequest from '@salesforce/apex/NC_AssessmentCtrl.getAccountFromRequest';
import Attestation_Label_1 from '@salesforce/label/c.Attestation_Label_1';
import Verification_of_Disability from '@salesforce/label/c.Verification_of_Disability';
import Verification_of_Disability_one from '@salesforce/label/c.Verification_of_Disability_one';
import Verification_of_Disability_two from '@salesforce/label/c.Verification_of_Disability_two';
import Verification_of_Disability_three from '@salesforce/label/c.Verification_of_Disability_three';
import Income_Eligibility from '@salesforce/label/c.Income_Eligibility';
import Income_Eligibility_two from '@salesforce/label/c.Income_Eligibility_two';
import saveCommentData from '@salesforce/apex/NC_AssessmentCtrl.saveCommentData';
import changeStatus from '@salesforce/apex/NC_AssessmentCtrl.changeStatus';
import fetchFields from '@salesforce/apex/NC_AssessmentCtrl.fetchFields';
import getStatus from '@salesforce/apex/NC_AssessmentCtrl.getStatus';
import getTodaysDate from '@salesforce/apex/NC_AssessmentCtrl.getTodaysDate';
import fetchSignature from '@salesforce/apex/NC_AssessmentCtrl.fetchSignature';


//import logo from '@salesforce/resourceUrl/NCDSDHHLOGO';
import logo from '@salesforce/resourceUrl/NCDSDHHLOGOAssessment';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class NC_CreateAssessment extends LightningElement {
    @track AssesmentObj = {};
    @api recordId;
    @api recordContactId;
    @track value = [];
    @track consumerValue = '';
    @track consumerValueNew = '';
    @track consumerEmail = '';
    @track consumerPhone = '';
    @track casecomments = '';
    @track statusValue = '';
    @track picklistOptions;
    @track picklistOptionsvisionLoss;
    @track picklistOptionsOther = [];
    @track picklistOptionscommunicationSkills = [];
    @track picklistOptionsConnectivity = [];
    @track picklistOptionsHearingAssessment = [];
    @track picklistOptionsVisualAssessment = [];
    @track picklistOptionsTactileAssessment = [];
    @track picklistOptionsComputerExperience = [];
    @track picklistOptionsATUsage = [];
    @track picklistOptionsComputerUsageExperience = [];
    @track logoURL = logo;
    @track assesmentId = '';
    @track pcMac = false;
    @track assessmentAddress = false;
    @track url = '/servlet/servlet.FileDownload?file=';
    @track showImage = false;
    @track openRejectModel;
    @track showSignLabel = false;
    @track signHere = false;
    @track usedInCommunity;
    signHereInfo = '';

    Verification_of_Disability = Verification_of_Disability;
    Verification_of_Disability_one = Verification_of_Disability_one;
    Verification_of_Disability_two = Verification_of_Disability_two;
    Verification_of_Disability_three = Verification_of_Disability_three;
    Income_Eligibility = Income_Eligibility;
    Income_Eligibility_two = Income_Eligibility_two;
    Attestation_Label_1 = Attestation_Label_1;

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
        getStatus({
                requestId: this.recordId
            })
            .then(res => {
                console.log('status value', JSON.stringify(res));
                this.statusValue = res.cas;
                this.ProfileName = res.user;
                console.log('status value', this.statusValue);
                if (this.statusValue != 'Pending Assessment' && this.ProfileName == 'NDBEDP Assessor') {
                    console.log('profile name' + this.ProfileName);
                    this.showToastMessage('error', 'Invalid status to create Assessment', 'error');
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


        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Hearing_Loss__c"
            })
            .then(res => {
                this.picklistOptions = res;
                console.log('picklist', JSON.stringify(this.picklistOptions));
            }).catch(error => {
                console.error(error);
            });

        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Vision_Loss__c"
            })
            .then(res => {
                this.picklistOptionsvisionLoss = res;
            }).catch(error => {
                console.error(error);
            });

        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Other__c"
            })
            .then(res => {
                this.picklistOptionsOther = res;
                console.log('res options' + JSON.stringify(res))
            }).catch(error => {
                console.error(error);
                console.log('error' + JSON.stringify(error))
            });

        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Communication_Skills__c"
            })
            .then(res => {
                this.picklistOptionscommunicationSkills = res;
            }).catch(error => {
                console.error(error);
            });
        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Connectivity__c"
            })
            .then(res => {
                this.picklistOptionsConnectivity = res;
            }).catch(error => {
                console.error(error);
            });
        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Hearing_Assessment__c"
            })
            .then(res => {
                this.picklistOptionsHearingAssessment = res;
            }).catch(error => {
                console.error(error);
            });
        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Visual_Assessment__c"
            })
            .then(res => {
                this.picklistOptionsVisualAssessment = res;
            }).catch(error => {
                console.error(error);
            });

        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Tactile_Assessment__c"
            })
            .then(res => {
                this.picklistOptionsTactileAssessment = res;
            }).catch(error => {
                console.error(error);
            });


        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Level_of_Computer_Experience__c"
            })
            .then(res => {
                this.picklistOptionsComputerExperience = res;
            }).catch(error => {
                console.error(error);
            });

        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "AT_Usage__c"
            })
            .then(res => {
                this.picklistOptionsATUsage = res;
            }).catch(error => {
                console.error(error);
            });

        fetchPicklist({
                objectName: "Assessment__c",
                fieldName: "Computer_usage_experience__c"
            })
            .then(res => {
                this.picklistOptionsComputerUsageExperience = res;
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


        getAccountFromRequest({
                requestId: this.recordId
            })
            .then(res => {
                if (res.External_Assessor__c != null) {
                    console.log('emaill' + JSON.stringify(res));
                    this.consumerEmail = res.External_Assessor__r.Email__c;
                    this.consumerPhone = res.External_Assessor__r.Cell_Phone__c;
                    this.consumerAddress = res.External_Assessor__r.BillingStreet + "\n" + res.External_Assessor__r.BillingCity + " " + res.External_Assessor__r.BillingState + " " + res.External_Assessor__r.BillingPostalCode + "\n" + res.External_Assessor__r.BillingCountry;
                    if (res.External_Assessor__r.Is_Vendor_on_Portal__c == false) {
                        console.log('assessor', res.External_Assessor__r.Is_Vendor_on_Portal__c);
                        this.showSignLabel = true;
                    }

                }
                if (res.Internal_Assessor__c != null) {
                    this.consumerEmail = res.Internal_Assessor__r.Email;
                    this.consumerAddress = res.Internal_Assessor__r.Street + "\n" + res.Internal_Assessor__r.City + " " + res.Internal_Assessor__r.State + " " + res.Internal_Assessor__r.PostalCode + "\n" + res.Internal_Assessor__r.Country;
                    if (res.Internal_Assessor__r.MobilePhone != null) {
                        this.consumerPhone = res.Internal_Assessor__r.MobilePhone;
                    } else if (res.Internal_Assessor__r.Phone != null) {
                        this.consumerPhone = res.Internal_Assessor__r.Phone;
                    } else if (res.Internal_Assessor__r.Work_Phone_Number__c != null) {
                        this.consumerPhone = res.Internal_Assessor__r.Work_Phone_Number__c;
                    }

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

        fetchFields({
                requestId: this.recordId
            })
            .then(res => {
                this.AssesmentObj = res;
                if (this.AssesmentObj.signed != '' && this.AssesmentObj.signed != undefined) {
                    this.url = '/servlet/servlet.FileDownload?file=';
                    this.url = this.url + this.AssesmentObj.signed;
                    console.log('url' + this.url);
                    this.showImage = true;
                } else if (this.AssesmentObj.signed == '') {
                    this.showImage = false;
                    console.log('url' + this.url);
                }

                if (this.AssesmentObj && this.AssesmentObj.mailingaddress) {
                    this.assessmentAddress = true;
                }
                if (this.AssesmentObj.other == null) {
                    this.AssesmentObj.other = [];
                }
                if (this.AssesmentObj.communicationskills == null) {
                    this.AssesmentObj.communicationskills = [];
                }
                if (this.AssesmentObj.connectivity == null) {
                    this.AssesmentObj.connectivity = [];
                }
                if (this.AssesmentObj.atUsage == null) {
                    this.AssesmentObj.atUsage = [];
                }
                if (this.AssesmentObj.computerusageexperience == null) {
                    this.AssesmentObj.computerusageexperience = [];
                }
                if (this.AssesmentObj.hearingassessment == null) {
                    this.AssesmentObj.hearingassessment = [];
                }
                if (this.AssesmentObj.visualassessment == null) {
                    this.AssesmentObj.visualassessment = [];
                }
                if (this.AssesmentObj.tactileassessment == null) {
                    this.AssesmentObj.tactileassessment = [];
                }
                if (this.AssesmentObj.levelofcomputerexperience == null) {
                    this.AssesmentObj.levelofcomputerexperience = [];
                }

                console.log('fetch', JSON.stringify(this.AssesmentObj))
            }).catch(error => {
                console.error(error);
            });

        console.log('phone', this.AssesmentObj.phone);
    }
    handleChange(event) {

        this.AssesmentObj[event.target.name] = event.target.value;
        this.AssesmentObj.requestId = this.recordId;
        console.log('handle change obj' + JSON.stringify(this.AssesmentObj));

    }

    handleChangeNew(event) {
        this.AssesmentObj[event.target.name] = event.target.value;
    }
    @track refreshData = false;
    @track showSpinner = false;


    @api
    handleRefresh() {
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

                    this.AssesmentObj.signed = result;
                    this.url = '/servlet/servlet.FileDownload?file=';
                    this.url = this.url + this.AssesmentObj.signed;
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
        //this.AssesmentObj.contactId = this.recordId;
        const allValid2 = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if (inputCmp.checkValidity() === false && validSoFar === true) {
                    this.setFocusOnError(inputCmp);
                }
                if (!(validSoFar && inputCmp.checkValidity())) {
                    this.refreshData = false;
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const allValid1 = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if (inputCmp.checkValidity() === false && validSoFar === true) {
                    this.setFocusOnError(inputCmp);
                }
                if (!(validSoFar && inputCmp.checkValidity())) {
                    this.refreshData = false;
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const allValid3 = [...this.template.querySelectorAll('lightning-checkbox-group')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if (inputCmp.checkValidity() === false && validSoFar === true) {
                    this.setFocusOnError(inputCmp);
                }
                if (!(validSoFar && inputCmp.checkValidity())) {
                    this.refreshData = false;
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const allValid = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                if (inputCmp.checkValidity() === false && validSoFar === true) {
                    this.setFocusOnError(inputCmp);
                }
                if (!(validSoFar && inputCmp.checkValidity())) {
                    this.refreshData = false;
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!this.AssesmentObj.signed && this.signHere == false && this.refreshData == false && (this.AssesmentObj.onlineAssessor || !this.AssesmentObj.onlineAssessor || this.AssesmentObj.internalAssessor)) {
            this.showToastMessage('error', 'Attestors Signature is required', 'error');
            if (allValid && allValid1 && allValid2 && allValid3) {
                this.signHereInfo = 'Applicants Signature is required';
                setTimeout(() => {
                    this.signHereInfo = '';
                }, 10000);
                this.setDataIdFocus('signHere');
            }
            return;
        }
        if (allValid && allValid1 && allValid2 && allValid3) {
            if (event != null) {
                this.AssesmentObj.frombutton = event.currentTarget.dataset.frombutton;
            } else {
                this.AssesmentObj.frombutton = null;
            }
            this.AssesmentObj.requestId = this.recordId;
            this.AssesmentObj.phone = this.consumerPhone;
            //this.AssesmentObj.refreshData=this.refreshData;
            console.log('obj' + JSON.stringify(this.AssesmentObj));
            this.showSpinner = true;
            saveData({
                    dataObj: JSON.stringify(this.AssesmentObj)
                })
                .then(res => {
                    this.showSpinner = false;
                    console.log('asssess', JSON.stringify(res));
                    this.assesmentId = res.Id;
                    console.log('refresh data' + this.refreshData);
                    if (this.refreshData == true) {
                        this.handleConnectedCallback();
                        this.refreshData = false;

                    } else {
                        this.showToastMessage('success', 'Assessment saved Sucessfully', 'success');
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
                }).catch(error => {
                    this.showSpinner = false;
                    let message = error.body || error.body.message;
                    this.showToastMessage('error', message, 'error');
                    console.log(JSON.stringify(error));
                });
        }
    }

    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        const Valid = [...this.template.querySelectorAll('.comment')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        console.log('valid', Valid);
        this.AssesmentObj.requestId = this.recordId;
        console.log('wrapper' + JSON.stringify(this.AssesmentObj));
        if (Valid) {

            this.showSpinner = true;
            saveCommentData({

                    dataObjComment: JSON.stringify(this.AssesmentObj)
                })
                .then(res => {
                    console.log('res', JSON.stringify(res));
                    this.casecomments = res.Comments__c;
                    //this.casecomments =res.Assessor_Comment__c;
                    this.isModalOpen = false;
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

                    console.log('In Catch', JSON.stringify(error));
                });
            // this.isModalOpen = false;
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
    // @track signHere=false;
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

    handleChangeStatus() {
        this.AssesmentObj.requestId = this.recordId;
        changeStatus({

                dataObjchangeStatus: JSON.stringify(this.AssesmentObj)
            })
            .then(res => {
                console.log('res', JSON.stringify(res));
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
        this.isModalOpen = false;
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