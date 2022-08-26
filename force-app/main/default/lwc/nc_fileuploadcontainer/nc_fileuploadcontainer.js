import { LightningElement, api, track } from 'lwc';
import retriveFieldValues from '@salesforce/apex/NC_FileUploadController.mapRelatedFields';

export default class Ncdsdhh_fileuploadcontainer extends LightningElement {
    @api recordId;
    @api fileInfo;
    @api disableField;
    @api disableValue;
    @track fieldValueObject;
    @track filesInfoList = [];
    @track disableDelete = false;
    @track enableUpload = false;

    connectedCallback() {
        retriveFieldValues({recordId : this.recordId, fieldDisable : this.disableField, fieldValue : this.disableValue}).then(
            result=>{
                this.fieldValueObject = result.FieldValues;
                this.disableDelete = result.Disable;
                this.enableUpload = result.enableUpload;
                let _this = this;
                this.fileInfo.forEach(function(item) {
                    _this.retrieveFileInfo(item);
                });
            }
        ).catch(
            error=>{

            }
        );
    }
    refresh() {
        this.dispatchEvent(new CustomEvent("refresh") );
    }
    viewFile(event) {
        let value = event.detail;
        this.dispatchEvent(new CustomEvent("viewfile",{ 
            detail: {value}
        }) );
    }

    retrieveFileInfo(fileData) {
        if(fileData) {
            let fileInfoList = fileData.split(';');
            let infoItems = fileInfoList.length;
            let item = {};
            if(infoItems > 0) {
                console.log('fileInfoList --'+ fileInfoList);
                item.label = infoItems >= 1 ? fileInfoList[0].trim() : '';
                item.field = infoItems >= 2 ? fileInfoList[1].trim() : '';
                item.documentInRenewProcess = infoItems >=3 ? fileInfoList[2].trim() === "true" : false;
                item.idField = infoItems == 4 ? fileInfoList[3].trim() : '';
                item.filter = infoItems == 5 ? fileInfoList[4] : '';
                item.recordId = this.recordId;
                item.id = this.recordId;
                if(item.idField){
                    console.log(item.idField);
                    console.log(this.fieldValueObject[item.idField]);
                    if(this.fieldValueObject[item.idField]){
                        item.id = this.fieldValueObject[item.idField];
                    }
                }
                item.key = this.filesInfoList.length;
                this.filesInfoList.push(item);
            }
        }
    }
}