import { LightningElement,api, track } from 'lwc';

export default class Nc_mentoring_request_steps extends LightningElement {
    @track onLoadStep;
    @track isNewEntity;
    @track activeCss = 'event active';
    @track completedCss = 'event completed';
    @track step1CSS;
    @track step2CSS;
    @track step3CSS;
    @track step4CSS;
    @track step5CSS;
    @track step6CSS;
    @track step7CSS;
    @track step8CSS;
    @track step9CSS;
    @track step10CSS;
    @track step1AriaLabel;
    @track step2AriaLabel;
    @track step3AriaLabel;
    @track step4AriaLabel;
    @track step5AriaLabel;
    @track step6AriaLabel;
    @track step7AriaLabel;
    @track step8AriaLabel;
    @track step9AriaLabel;
    @track step10AriaLabel;
    @api originalStep = 0;
    @api isLicensedUser = false;
    @api isProvider = false;


    connectedCallback() {
        this.onLoadStep = this.currentStep;
    }


    @api
    get currentStep() {
        return this.currentStep2;
    }
    set currentStep(value) {
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
        this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        this.step5CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        this.step6CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
        this.step7CSS = 'event ' + (_currentStep == 7 ? 'active ' : '') + (_currentStep > 7 || this.originalStep >= 7 ? ' completed' : '');
        this.step8CSS = 'event ' + (_currentStep == 8 ? 'active ' : '') + (_currentStep > 8 || this.originalStep >= 8 ? ' completed' : '');
        this.step9CSS = 'event ' + (_currentStep == 9 ? 'active ' : '') + (_currentStep > 9 || this.originalStep >= 9 ? ' completed' : '');
        this.step10CSS = 'event ' + (_currentStep == 10 ? 'active ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '');

        this.step1AriaLabel = (_currentStep == 1 ? ' in progress ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '') + ' (1 of 10) ';
        this.step2AriaLabel = (_currentStep == 2 ? ' in progress ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '') + (_currentStep <= 1 ? 'inactive ' : '') + ' (2 of 10) ';
        this.step3AriaLabel = (_currentStep == 3 ? ' in progress ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '') + (_currentStep <= 2 ? 'inactive ' : '') + ' (3 of 10) ';
        this.step4AriaLabel = (_currentStep == 4 ? ' in progress ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '') + (_currentStep <= 3 ? 'inactive ' : '') + ' (4 of 10) ';
        this.step5AriaLabel = (_currentStep == 5 ? ' in progress ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '') + (_currentStep <= 4 ? 'inactive ' : '') + ' (5 of 10) ';
        this.step6AriaLabel = (_currentStep == 6 ? ' in progress ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '') + (_currentStep <= 5 ? 'inactive ' : '') + ' (6 of 10) ';
        this.step7AriaLabel = (_currentStep == 7 ? ' in progress ' : '') + (_currentStep > 7 || this.originalStep >= 7 ? ' completed' : '') + (_currentStep <= 6 ? 'inactive ' : '') + ' (7 of 10) ';
        this.step8AriaLabel = (_currentStep == 8 ? ' in progress ' : '') + (_currentStep > 8 || this.originalStep >= 8 ? ' completed' : '') + (_currentStep <= 7 ? 'inactive ' : '') + ' (8 of 10) ';
        this.step9AriaLabel = (_currentStep == 9 ? ' in progress ' : '') + (_currentStep > 9 || this.originalStep >= 9 ? ' completed' : '') + (_currentStep <= 8 ? 'inactive ' : '') + ' (9 of 10) ';
        this.step10AriaLabel = (_currentStep == 10 ? ' in progress ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '') + (_currentStep <= 9 ? 'inactive ' : '') + ' (10 of 10) ';
    }

    @api
    handleCurrentStep(value) {
        this.currentStep2 = value;
        var _currentStep = parseInt(value);
        this.step1CSS = 'event ' + (_currentStep == 1 ? 'active ' : '') + (_currentStep > 1 || this.originalStep >= 1 ? ' completed' : '');
        this.step2CSS = 'event ' + (_currentStep == 2 ? 'active ' : '') + (_currentStep > 2 || this.originalStep >= 2 ? ' completed' : '');
        this.step3CSS = 'event ' + (_currentStep == 3 ? 'active ' : '') + (_currentStep > 3 || this.originalStep >= 3 ? ' completed' : '');
        this.step4CSS = 'event ' + (_currentStep == 4 ? 'active ' : '') + (_currentStep > 4 || this.originalStep >= 4 ? ' completed' : '');
        this.step5CSS = 'event ' + (_currentStep == 5 ? 'active ' : '') + (_currentStep > 5 || this.originalStep >= 5 ? ' completed' : '');
        this.step6CSS = 'event ' + (_currentStep == 6 ? 'active ' : '') + (_currentStep > 6 || this.originalStep >= 6 ? ' completed' : '');
        this.step7CSS = 'event ' + (_currentStep == 7 ? 'active ' : '') + (_currentStep > 7 || this.originalStep >= 7 ? ' completed' : '');
        this.step8CSS = 'event ' + (_currentStep == 8 ? 'active ' : '') + (_currentStep > 8 || this.originalStep >= 8 ? ' completed' : '');
        this.step9CSS = 'event ' + (_currentStep == 9 ? 'active ' : '') + (_currentStep > 9 || this.originalStep >= 9 ? ' completed' : '');
        this.step10CSS = 'event ' + (_currentStep == 10 ? 'active ' : '') + (_currentStep > 10 || this.originalStep >= 10 ? ' completed' : '');
    }


}