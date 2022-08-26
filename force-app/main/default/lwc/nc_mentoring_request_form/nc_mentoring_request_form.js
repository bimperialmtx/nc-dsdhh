import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchPicklist from '@salesforce/apex/NC_MentoringRequestController.fetchPicklist';
import createMentoringRequestRecord from '@salesforce/apex/NC_MentoringRequestController.createMentoringRequestRecord';
let _this;

export default class Nc_mentoring_request_form extends LightningElement {


    @track showFamilyInformation =  '';
    @track showEducationInformation = 'display: none';
    @track showNCITLBLicenseInformation = 'display: none';
    @track showKnowledgeExam = 'display: none';
    @track showInterpreterCertificationExam = 'display: none';
    @track showPerformanceExam = 'display: none';
    @track showEIPAInformation = 'display: none';
    @track showPercentageInformation = 'display: none';
    @track showInterpreterSkillInformation = 'display: none';
    @track showOtherInformation = 'display: none';
    @track showConfirmation = 'display: none'
    @track wizardData = {};
    @track currentStep = 1;
    @track originalStep = 1;
    @track showSpinner = false;
    @track mentoringService = [];
    @track interpreterSkillDevelopment = [];
    @track informationAssistance = [];
    @track after5Year = [];
    @track degree = [];
    @track memberRelationship = [];
    @track college = [];
    @track dhhInterpreterVendorList = [];
    @track videoRelayInterpreting = [];
    @track other = [];
    @track WhenPlanEIPA = [];
    @track educationPostSecondary = [];
    @track planToTakeEIPA = [];
    @track educationalK12 = [];
    @track eipaScore = [];
    @track hoursWorkedInMedicalSetting = [];
    @track communityFreelance = [];
    @track lastTakeTheEIPA = [];
    @track videoRemoteInterpreting = [];
    @track howTakenTheEIPA = [];
    @track timePeriodPerformance= [];
    @track planningKnowledge = [];
    @track planningPerformance = [];
    @track howManyTimePerformance = [];
    @track passedKnowledge = [];
    @track lastPerformance = [];
    @track haveInterpreterCert = [];
    @track interpreterCertifications = [];
    @track assessmentLevelOptions = [];
    @track takenKnowledge = [];
    @track passedPerformance = [];
    @track takenPerformance = [];
    @track licensesIssuesByNCITLB = [];
    @track deafFamilyMembers = [];
    @track educationLevel = [];
    @api recordId;
    @track isModalOpen = false;
    @track url;



    hideComponents(){
        this.showFamilyInformation =  'display: none';
        this.showEducationInformation = 'display: none';
        this.showNCITLBLicenseInformation = 'display: none';
        this.showKnowledgeExam = 'display: none';
        this.showInterpreterCertificationExam = 'display: none';
        this.showPerformanceExam = 'display: none';
        this.showEIPAInformation = 'display: none';
        this.showPercentageInformation = 'display: none';
        this.showInterpreterSkillInformation = 'display: none';
        this.showOtherInformation = 'display: none';
        this.showConfirmation = 'display; none';
    }

    navigateToFamilyInformation(event){
        this.currentStep = 1;
        this.hideComponents();
        this.showFamilyInformation =  'disyplay: block';
        let isNext = event.target.label == 'Next' ? true : false;
        this.template.querySelector('c-nc_mentoring_request_family_info').setFocusOnHeading(isNext);
    }

    navigateToEducationInformation(event){
        if(this.template.querySelector('c-nc_mentoring_request_family_info').isValid()){
            console.log('Valid ');
            this.wizardData.familyInformation = this.template.querySelector('c-nc_mentoring_request_family_info').getData();
            this.currentStep = 2;
            this.hideComponents();
            this.showEducationInformation =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_education').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToNCITL(event){
        if(this.template.querySelector('c-nc_mentoring_request_education').isValid()){
            this.wizardData.educationInformation = this.template.querySelector('c-nc_mentoring_request_education').getData();
            this.currentStep = 3;
            this.hideComponents();
            this.showNCITLBLicenseInformation =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_licenses').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToInterpreterCertification(event){
        if(this.template.querySelector('c-nc_mentoring_request_licenses').isValid()){
            this.wizardData.dataNCITL = this.template.querySelector('c-nc_mentoring_request_licenses').getData();
            this.currentStep = 4;
            this.hideComponents();
            this.showInterpreterCertificationExam =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_interpreter_certification').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToKnowledgeExam(event){
        if(this.template.querySelector('c-nc_mentoring_request_interpreter_certification').isValid()){
            this.wizardData.certificateInformation = this.template.querySelector('c-nc_mentoring_request_interpreter_certification').getData();
            this.currentStep = 5;
            this.hideComponents();
            this.showKnowledgeExam =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_knowledge_exam').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }
    
    naviagetToPerformance(event){
        if(this.template.querySelector('c-nc_mentoring_request_knowledge_exam').isValid()){
            this.wizardData.knowledgeInformation = this.template.querySelector('c-nc_mentoring_request_knowledge_exam').getData();
            this.currentStep = 6;
            this.hideComponents();
            this.showPerformanceExam =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_performance_exam').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
        
    }

    navigateToEIPA(event){
        if(this.template.querySelector('c-nc_mentoring_request_performance_exam').isValid()){
            this.wizardData.performanceInformation = this.template.querySelector('c-nc_mentoring_request_performance_exam').getData();
            this.currentStep = 7;
            this.hideComponents();
            this.showEIPAInformation =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_eipa').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToPercentageInformation(event){
        if(this.template.querySelector('c-nc_mentoring_request_eipa').isValid()){
            this.wizardData.eipaInformtion = this.template.querySelector('c-nc_mentoring_request_eipa').getData();
            this.currentStep = 8;
            this.hideComponents();
            this.showPercentageInformation =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_percentage').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToSkills(event){
        if(this.template.querySelector('c-nc_mentoring_request_percentage').isValid()){
            this.wizardData.percentageInformation = this.template.querySelector('c-nc_mentoring_request_percentage').getData();
            this.currentStep = 9;
            this.hideComponents();
            this.showInterpreterSkillInformation =  'disyplay: block';
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_skills').setFocusOnHeading(isNext);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToOthers(event){
        if(this.template.querySelector('c-nc_mentoring_request_skills').isValid()){
            this.wizardData.skillsInformation = this.template.querySelector('c-nc_mentoring_request_skills').getData();
            this.currentStep = 10;
            this.hideComponents();
            this.showOtherInformation =  'disyplay: block';
            let isModalClosed = false;
            if(this.isModalOpen === true) {
                isModalClosed = true;
                this.setFocus('submitButtonId');
            }
            this.isModalOpen = false;
            let isNext = event.target.label == 'Next' ? true : false;
            this.template.querySelector('c-nc_mentoring_request_other').setFocusOnHeading(isNext, isModalClosed);
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    navigateToConfimration(){
        if(this.template.querySelector('c-nc_mentoring_request_other').isValid()){
            this.wizardData.otherinformation = this.template.querySelector('c-nc_mentoring_request_other').getData();
            this.currentStep = 11;
            this.hideComponents();
            this.showConfirmation =  'disyplay: block';
            this.isModalOpen = true;
            setTimeout(()=>{					
                this.focusFirstEle(); },500);
            //this.setFocus('closeButton');
            console.log('Wizard Data : ' + JSON.stringify(this.wizardData));
            console.log('recordId : ' + JSON.stringify(this.recordId));
        }else{
            console.log('In Valid Value ');
            this.showToastMessage("Error!", 'Please fill all the required fields', "error");
        }
    }

    submitDetails() {
        createMentoringRequestRecord({wizardData : JSON.stringify(this.wizardData), recordId : this.recordId}).then(
            result => {
              this.url = result.url;
              this.showToastMessage("Success!", 'Mentoring Request Added!', "success");
              window.location.href = this.url;
            }
          ).catch(
            error => {
              this.showToastMessage("Error!", error, "error");
            }
        );
        this.isModalOpen = false;
    }


    connectedCallback() {
        _this = this;
        if(this.wizardData.familyInformation === undefined && this.wizardData.educationInformation=== undefined && this.wizardData.dataNCITL === undefined && this.wizardData.certificateInformation === undefined &&
            this.wizardData.knowledgeInformation === undefined && this.wizardData.performanceInformation === undefined && this.wizardData.eipaInformtion === undefined &&
            this.wizardData.percentageInformation === undefined && this.wizardData.skillsInformation === undefined && this.wizardData.otherinformation === undefined){

            this.wizardData.familyInformation = {}; 
            this.wizardData.educationInformation = {}; 
            this.wizardData.dataNCITL = {};    
            this.wizardData.certificateInformation = {}; 
            this.wizardData.knowledgeInformation = {};
            this.wizardData.performanceInformation = {};
            this.wizardData.eipaInformtion = {};
            this.wizardData.percentageInformation = {};
            this.wizardData.skillsInformation = {};
            this.wizardData.otherinformation = {};
        }
        
        // Mentoruing Services Picklist
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Mentoring_services__c' })
        .then(result =>{
            this.mentoringService = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Interpeting Skills
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Interpreting_skill_development__c' })
        .then(result =>{
            this.interpreterSkillDevelopment = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Information Assistance
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Information_Assistance__c' })
        .then(result =>{
            this.informationAssistance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // After 5 Year
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'After_5_Year__c' })
        .then(result =>{
            this.after5Year = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Degree
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Degree__c' })
        .then(result =>{
            this.degree = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Member Relationship
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Member_Relationship__c' })
        .then(result =>{
            this.memberRelationship = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // College
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'College__c' })
        .then(result =>{
            this.college = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // DHH Interpreter Vendor List
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Are_you_on_DHHS_Interpreter_Vendor_List__c' })
        .then(result =>{
            this.dhhInterpreterVendorList = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Video Realy Interpreting
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Video_Relay_Interpreting__c' })
        .then(result =>{
            this.videoRelayInterpreting = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Other
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Other__c' })
        .then(result =>{
            this.other = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // When do you plan to take the EIPA
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'When_do_you_plan_to_take_the_EIPA__c' })
        .then(result =>{
            this.WhenPlanEIPA = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Education Post Secondary
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Educational_Post_Secondary__c' })
        .then(result =>{
            this.educationPostSecondary = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Are you planning to take the EIPA
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Are_you_planning_to_take_the_EIPA__c' })
        .then(result =>{
            this.planToTakeEIPA = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Education K 12
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Educational_K_12__c' })
        .then(result =>{
            this.educationalK12 = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // What is your EIPA Score
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'What_is_your_EIPA_score__c' })
        .then(result =>{
            this.eipaScore = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Hours Worked In Medical Setting
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Hours_Worked_in_Medical_Settings__c' })
        .then(result =>{
            this.hoursWorkedInMedicalSetting = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Community Freelance
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Community_freelance__c' })
        .then(result =>{
            this.communityFreelance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Last Take The EIPA
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Last_Take_the_EIPA__c' })
        .then(result =>{
            this.lastTakeTheEIPA = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Video Remote Interpreting
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Video_Remote_Interpreting__c' })
        .then(result =>{
            this.videoRemoteInterpreting = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // How You Taken The EIPA
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Have_you_taken_the_EIPA__c' })
        .then(result =>{
            this.howTakenTheEIPA = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Time Period CASLI/NIC Or CDI Performace
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Time_Period_CASLI_NIC_or_CDI_Performance__c' })
        .then(result =>{
            this.timePeriodPerformance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Planning CASLI NIC Or CDI Knowledge
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Planning_CASLI_NIC_or_CDI_Knowledge__c' })
        .then(result =>{
            this.planningKnowledge = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Planning CASLI NIC Or CDI Performance
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Planning_CASLI_NIC_or_CDI_Performance__c' })
        .then(result =>{
            this.planningPerformance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // How Many Time CASLI NIC Or CDI Performance
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'How_Many_Times_CASLI_NIC_or_CDI_Performa__c' })
        .then(result =>{
            this.howManyTimePerformance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Passed CASLI NIC or CDI Knowledge
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Passed_CASLI_NIC_or_CDI_Knowledge__c' })
        .then(result =>{
            this.passedKnowledge = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Last CASLI NIC CDI Performance Exam
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Last_CASLI_NIC_or_CDI_Performance_Exam__c' })
        .then(result =>{
            this.lastPerformance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        //Have Interpreter or Transliteration Certification
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Have_interpreter_transliteration_Cert__c' })
        .then(result =>{
            this.haveInterpreterCert = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        //Fetch all Interpreter Certifications
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Interpreter_Certifications__c' })
        .then(result =>{
            this.interpreterCertifications = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        //Fetch all Assessment Levels
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Assessment_Level__c' })
        .then(result =>{
            this.assessmentLevelOptions = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Taken CASLI NIC or CDI Knowledge Exam
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Taken_CASLI_NIC_or_CDI_Knowledge_Exam__c' })
        .then(result =>{
            this.takenKnowledge = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Passed CASLI NIC or CDI Performance Exam
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Passed_CASLI_NIC_or_CDI_Performance_Exam__c' })
        .then(result =>{
            this.passedPerformance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Taken CASLi NIC or CDI Performance Exam
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Taken_CASLI_NIC_or_CDI_Performance_Exam__c' })
        .then(result =>{
            this.takenPerformance = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Licenses Issued by The NCITLB
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'license_Issued_by_the_NCITLB__c' })
        .then(result =>{
            this.licensesIssuesByNCITLB = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Have Deaf Family Members
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Have_Deaf_Family_Members__c' })
        .then(result =>{
            this.deafFamilyMembers = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

        // Education Level
        fetchPicklist({objectName : 'Mentoring_Request__c', fieldName : 'Education_Level__c' })
        .then(result =>{
            this.educationLevel = result;
        })
        .catch(error => {
            console.log('Error => ' + error);
        });

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

    handleKeyDown(event) {
        if(event.code == 'Escape') {
            this.navigateToOthers();
        }
    }

    setFocus(dataId) {
        setTimeout(() => {
            let closeButton = this.template.querySelector('[data-id="'+dataId+'"]');
            if(closeButton) {
                closeButton.focus();
            }
        }, 500);
    }
    focusFirstEle() {
        const focusableElements = 'button, b, h1';
        const modal = this.template.querySelector('.slds-modal');
        
        const firstFocusableElement = modal.querySelectorAll('[data-name="modal"]')[0];
        const focusableContent = modal.querySelectorAll('[data-name="modal"]');
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        
        firstFocusableElement.focus();
        
        this.template.addEventListener('keydown', function(event) {
            let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {       
                if (_this.template.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus(); 
                    event.stopPropagation()
                    event.preventDefault();
                }
            } else { 
                if (_this.template.activeElement === lastFocusableElement) {  
                    firstFocusableElement.focus(); 
                    event.preventDefault();
                    event.stopPropagation();
                }
            }
        });
    }
}