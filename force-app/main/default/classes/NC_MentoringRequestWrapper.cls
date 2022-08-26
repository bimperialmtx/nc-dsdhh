/*
*   Class Name: NC_MentoringRequestWrapper
*   Description: 
*
*   Date            New/Modified         User                 Identifier                Description
*                      New         Hiten Aggarwal(mtx)
*/
public class NC_MentoringRequestWrapper {
    
    public String consumerId;
    public String requestId;
    public String status;
    public familyInformation familyInformation;
    public educationInformation educationInformation;
    public certificateInformation certificateInformation;
    public dataNCITL dataNCITL;
    public knowledgeInformation knowledgeInformation;
    public performanceInformation performanceInformation;
    public eipaInformtion eipaInformtion;
    public percentageInformation percentageInformation;// skillsInformation otherinformation
    public skillsInformation skillsInformation;
    public otherinformation otherinformation;
    

    public NC_MentoringRequestWrapper(){
        this.consumerId= '';
        this.requestId= '';
        this.status= 'Created';
        this.familyInformation = new familyInformation();
        this.educationInformation = new educationInformation();
        this.dataNCITL = new dataNCITL();
        this.certificateInformation = new certificateInformation();
        this.knowledgeInformation = new knowledgeInformation();
        this.performanceInformation = new performanceInformation();
        this.eipaInformtion = new eipaInformtion();
        this.percentageInformation = new percentageInformation();
        this.skillsInformation = new skillsInformation();
        this.otherinformation = new otherinformation();
    }   
    
    public class familyInformation{
         public String haveDeafFamilyMembers;
         public String memberRelationship;
         public String relationshipIfOther;
         public familyInformation(){
                this.haveDeafFamilyMembers= '';
                this.memberRelationship= '';
                this.relationshipIfOther= '';
         }
    }
    
    public class educationInformation{
         public String educationLevel;
         public String degree;
         public String college;
         public String otherEducation;
         public String otherDegree;
         public String otherCollege;
        public educationInformation(){
            this.educationLevel= '';
            this.degree= '';
            this.college= '';
            this.otherEducation= '';
            this.otherDegree= '';
            this.otherCollege= '';
        }
    }
    
    public class dataNCITL{
         public String licenseIssuedbyTheNCITLB;
         public String NCITLBLicenseNumber;
         public dataNCITL(){
            this.licenseIssuedbyTheNCITLB= '';
            this.NCITLBLicenseNumber= '';
            
        }
    }

    public class certificateInformation {
        public String holdInterpreterCert;
        public String certificateValue;
        public String assessmentLevel;
        public String RIDNumber;
        public certificateInformation() {
            this.holdInterpreterCert = '';
            this.certificateValue = '';
            this.assessmentLevel = '';
            this.RIDNumber = '';
        }
    }
    
    public class knowledgeInformation{
         public String tkenCASLINICOrCDIKnowledgeExam;
         public String passedCASLINICOrCDIKnowledge;//
         public String planningCASLINICOrCDIKnowledge;
        public knowledgeInformation(){
            this.tkenCASLINICOrCDIKnowledgeExam= '';
            this.planningCASLINICOrCDIKnowledge= '';
            this.passedCASLINICOrCDIKnowledge= '';
        }
    }
    
    public class performanceInformation{
         public String takenCASLINICOrCDIPerformanceExam;
         public String passedCASLINICOrCDIPerformanceExam;
         public String howManyTimesCASLINICOrCDIPerforma;
         public String lastCASLINICOrCDIPerformanceExam;
         public String planningCASLINICOrCDIPerformance;
         public String timePeriodCASLINICOrCDIPerformance;	
        public performanceInformation(){
            this.takenCASLINICOrCDIPerformanceExam= '';
            this.passedCASLINICOrCDIPerformanceExam= '';
            this.howManyTimesCASLINICOrCDIPerforma= '';
            this.planningCASLINICOrCDIPerformance= '';
            this.timePeriodCASLINICOrCDIPerformance= ''; 
        }
    }
    
    public class eipaInformtion{
         public String AreYouPlanningToTakeTheEIPA;
         public String haveYouTakenTheEIPA;
         public String lastTaketheEIPA;
         public String whatIsYourEIPAScore;
         public String whenDoYouPlanToTakeTheEIPA;
        public eipaInformtion(){
            this.AreYouPlanningToTakeTheEIPA= '';
            this.haveYouTakenTheEIPA= '';
            this.lastTaketheEIPA= '';
            this.whatIsYourEIPAScore= '';
            this.whenDoYouPlanToTakeTheEIPA= ''; 
        }
    }
    
    public class percentageInformation{
         public String videoRelayInterpreting;
         public String videoRemoteInterpreting;
         public String communityFreelance;
         public String eucationalK12;
         public String educationalPostSecondary;
         public String other;
         public String hoursWorkedinMedicalSettings;
        public percentageInformation(){
            this.videoRelayInterpreting= '';
            this.videoRemoteInterpreting= '';
            this.communityFreelance= '';
            this.eucationalK12= '';
            this.educationalPostSecondary= '';
            this.other= '';
            this.hoursWorkedinMedicalSettings= '';
        }
        
    }
    
    public class skillsInformation{ 
         public String informationAssistance;
         public String interpretingSkillDevelopment;
         public String mentoringservices;
        public skillsInformation(){
            this.mentoringservices= '';
            this.interpretingSkillDevelopment= '';
            this.informationAssistance= '';
        }
        
    }
    
    public class otherinformation{
         public String areYouOnDHHSInterpreterVendorList;
         public String after5Years;
         public String oherAfter5Year;
         public String currentSkillDevelopmentGoals;
         public String workshopInNorthCarolina;
        
        public otherinformation(){
            this.areYouOnDHHSInterpreterVendorList= '';
            this.after5Years = '';
            this.oherAfter5Year = '';
            this.currentSkillDevelopmentGoals= '';
            this.workshopInNorthCarolina= '';
        }
    }    
}