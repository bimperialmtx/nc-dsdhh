import { LightningElement, api, track } from 'lwc';
import retriveFieldValues from '@salesforce/apex/NC_FileUploadController.mapRelatedFields';

export default class Ncdsdhh_fileuploadcontainer extends LightningElement {
    @api recordId;
    @api fileInfo1;
    @api fileInfo2;
    @api fileInfo3;
    @api fileInfo4;
    @api fileInfo5;
    @api fileInfo6;
    @api fileInfo7;
    @api fileInfo8;
    @api fileInfo9;
    @api fileInfo10;
    @track fieldValueObject;
    @track filesInfoList = [];

    connectedCallback() {
        retriveFieldValues({recordId : this.recordId}).then(
            result=>{
                console.log(result);
                this.fieldValueObject = result.FieldValues;
                this.retrieveFileInfo(this.fileInfo1);
                this.retrieveFileInfo(this.fileInfo2);
                this.retrieveFileInfo(this.fileInfo3);
                this.retrieveFileInfo(this.fileInfo4);
                this.retrieveFileInfo(this.fileInfo5);
                this.retrieveFileInfo(this.fileInfo6);
                this.retrieveFileInfo(this.fileInfo7);
                this.retrieveFileInfo(this.fileInfo8);
                this.retrieveFileInfo(this.fileInfo9);
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
                item.label = infoItems >= 1 ? fileInfoList[0] : '';
                item.field = infoItems >= 2 ? fileInfoList[1] : '';
                item.idField = infoItems == 3 ? fileInfoList[2] : '';
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