import { LightningElement, api, track,wire } from 'lwc';
import updateDocumentName from '@salesforce/apex/NC_FileUploadController.updateDocumentName';
import updateDocumentVersion from '@salesforce/apex/NC_FileUploadController.updateContentVersion';
import retrieveDocumentInfo from '@salesforce/apex/NC_FileUploadController.retrieveDocumentInfo';
import deleteDocumentName from '@salesforce/apex/NC_FileUploadController.deleteDocumentName';
import updateFileRelatedField from '@salesforce/apex/NC_FileUploadController.updateFileRelatedField';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord  } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import NC_DSDHH_Resource from '@salesforce/resourceUrl/NC_DSDHH_Resource';

export default class Ncdsdhh_fileupload extends NavigationMixin(LightningElement) {
    @track fileExists = '';
    @track fileInfoObject;
    @track documentId;
    @track contentDocumentId;
    @track docVisible;
    @track showModal = false;
    @track isEdit = false;
    @api disableDelete;
    @api enableUpload;
    @api
    get fileInfo() {
        return this.fileInfoObject;
    }
    set fileInfo(val) {
        //this.fileInfoObject = val;
        let tempVal={};
        tempVal= {...val};
        tempVal.editArialabel='Edit '+ tempVal.label;
        tempVal.previewArialabel='Preview '+ tempVal.label;
        tempVal.deleteArialabel='Delete '+ tempVal.label;
        tempVal.cancelArialabel='Cancel '+ tempVal.label;
        this.fileInfoObject=tempVal;
        retrieveDocumentInfo({fileName:val.label, objectId:val.id, filter: val.filter}).then(result => {
            console.log('result', result);
            this.documentId = result.documentId;
            this.contentDocumentId = result.contentDocumentId;
            this.docVisible = result.docVisible;
            console.log('doc visible-->'+val.label + '--' + this.docVisible);
        }).catch(error => console.log('error -> ', error));
    }

    connectedCallback(){
        loadScript(this, NC_DSDHH_Resource + '/scripts/NCDSDHH_Scripts.js')
        .then(() => console.log('Loaded'))
        .catch(error => console.log('error-->'+error));
    }

    filePreview(event) {
        let value = this.contentDocumentId;
        this.dispatchEvent(new CustomEvent("viewfile",{ 
            detail: {value}
        }) );
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        const fields = {
            documentId : uploadedFiles[0].documentId,
            fileName : this.fileInfo.label,
            objectId : this.fileInfo.id,
            fieldApiName : this.fileInfo.field,
            currentObjectId : this.fileInfo.recordId,
        }
        updateDocumentName(fields).then(result => {
            console.log('result-->'+JSON.stringify(result));
            this.refreshView();
            this.documentId = uploadedFiles[0].documentId;
            this.contentDocumentId = uploadedFiles[0].documentId;
            this.modalMsg=`${uploadedFiles[0].name} uploaded sucessfully under files in related section`;
            util.showToast('Sucess', 'success', this.modalMsg, 'dismissible', 10000);
            if(result && result.error) {
                this.documentId = uploadedFiles[0].documentId;
                this.contentDocumentId = uploadedFiles[0].documentId;
                this.showToast('Error', result.error, 'error');
                this.updateObjectDetails();
            }
        })
        .catch(error => {
            console.log('Error-->' + JSON.stringify(error));
        });
    }

    updateObjectDetails() {
        const fields = {
            chkbkVal: false,
            documentId : this.documentId,
            fileName : this.fileInfo.label,
            fieldApiName : this.fileInfo.field,
            currentObjectId : this.fileInfo.recordId,
        }
        updateFileRelatedField(fields)
        .then(result=>{
            this.refreshView();
            this.closeModal();
            this.documentId = null;
            this.contentDocumentId = null;
            console.log('message-->' + JSON.stringify(result));
        }).catch(error=>{
            console.log('Error-->' + JSON.stringify(error));
        });
    }

    deleteFile(event){
        const fields = {
            documentId : this.contentDocumentId,
            fileName : this.fileInfo.label,
            objectId : this.fileInfo.id,
            fieldApiName : this.fileInfo.field,
            currentObjectId : this.fileInfo.recordId,
        }
        deleteDocumentName(fields)
        .then(result=>{
            if(result == 'success') {
                this.refreshView();
                this.documentId = null;
                this.contentDocumentId = null;
                this.showToast('Success', 'File is deleted', 'success');
            } else {
                this.showToast('Error', result, 'error');
            }
            console.log('message-->' + JSON.stringify(result));
            this.closeModal();
            this.template.querySelector('c-ncdsdhh_modalwindow').disableSpinner();
        }).catch(error=>{
            console.log('Error-->' + JSON.stringify(error));
            this.template.querySelector('c-ncdsdhh_modalwindow').disableSpinner();
        });
    }

    handleUploadVersion(event){
        var uploadedFiles = event.detail.files;
        var documentId = uploadedFiles[0].documentId;
        const fields = {
            uploadId: documentId,
            recordId: this.fileInfo.recordId,
            fileName: this.fileInfo.label,
            fieldApiName : this.fileInfo.field,
            currentObjectId : this.fileInfo.recordId,
        }
        updateDocumentVersion(fields)
        .then(result=>{
            this.refreshView();
            this.contentDocumentId = documentId;
            this.isEdit = false;
            this.modalMsg=`${uploadedFiles[0].name} uploaded sucessfully under files in related section`;
            util.showToast('Sucess', 'success', this.modalMsg, 'dismissible', 10000);
            console.log('message-->' + JSON.stringify(result));
        }).catch(error=>{
            console.log('Error-->' + JSON.stringify(error));
        });

    }

    get renewState(){
        if(this.fileInfo.documentInRenewProcess){
            return 'slds-grid slds-box green-background slds-theme--shade slds-theme--alert-texture';
        }
        return 'slds-grid slds-box';
    }

    updateFile(){
        this.isEdit = true;
        this.setDataIdFocus('cancelIcon');
        this.modalMsg=`File upload is enabled`;
        util.showToast('', '', this.modalMsg, 'dismissible', 10000);
    }

    cancelEdit(){
         this.isEdit = false;
         this.setDataIdFocus('editIcon');
    }
    
    refreshView(){
        this.dispatchEvent(new CustomEvent("refresh") );
    }

    openModal(){
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
        this.setDataIdFocus('deleteicon');
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant
        });
        this.dispatchEvent(event);
    }
    setDataIdFocus(dataId) {
        setTimeout(() => {
            let closeButton = this.template.querySelector('[data-id="' + dataId + '"]');
            if (closeButton) {
                closeButton.focus();
            }
        }, 500);
    }
}