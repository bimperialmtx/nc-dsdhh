// import Grants_Login_Page_Help_Text from "@salesforce/label/c.Grants_Login_Page_Help_Text";
// import Grants_Vermont_Pandemic_Unemployment_Assistance_Program from "@salesforce/label/c.Grants_Vermont_Pandemic_Unemployment_Assistance_Program";
// import Grants_Complete_All_Required_Fields from "@salesforce/label/c.Grants_Complete_All_Required_Fields";
// import Grants_User_Name from "@salesforce/label/c.Grants_User_Name";
// import Grants_Password from "@salesforce/label/c.Grants_Password";
// import Grants_Login_Information from "@salesforce/label/c.Grants_Login_Information";
// import Grants_Button_Login from "@salesforce/label/c.Grants_Button_Login";
// import Grants_Password_Combination from "@salesforce/label/c.Grants_Password_Combination";
// import Grants_User_Name_Pattern from "@salesforce/label/c.Grants_User_Name_Pattern";
// import Grants_Button_Forget_Password from "@salesforce/label/c.Grants_Button_Forget_Password";
// import PUA_Invalid_User from "@salesforce/label/c.PUA_Invalid_User";
// import PUA_Forgot_Password_Email_Msg from "@salesforce/label/c.PUA_Forgot_Password_Email_Msg";

import isContactExist from "@salesforce/apex/NC_CommunityLoginController.isContactExist";
import registerUser from "@salesforce/apex/NC_CommunityLoginController.registerUser";
import logInUser from "@salesforce/apex/NC_CommunityLoginController.logInUser";
import forgotPassword from "@salesforce/apex/NC_CommunityLoginController.forgotPassword";
import logo from '@salesforce/resourceUrl/NC_LOGOPNG';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {LightningElement,track,api} from "lwc";

export default class Nc_community_login_page extends LightningElement {

    // Grants_Vermont_Pandemic_Unemployment_Assistance_Program = 'VT Economic Recovery Grant';
    // Grants_User_Name = Grants_User_Name;
    // Grants_Password = Grants_Password;
    // Grants_Login_Information = Grants_Login_Information;
    // Grants_Button_Login = Grants_Button_Login;
    // Grants_Password_Combination = Grants_Password_Combination;
    // Grants_User_Name_Pattern = Grants_User_Name_Pattern;
    // Grants_Login_Page_Help_Text = Grants_Login_Page_Help_Text;
    // PUA_Invalid_User = PUA_Invalid_User;
    // PUA_Forgot_Password_Email_Msg = PUA_Forgot_Password_Email_Msg;
    // Grants_Button_Forget_Password = Grants_Button_Forget_Password;

    @track dataObj = {};
    @track userSignupErrorMsg;
    @track contactExist;
    @track userExist;
    @track errorMsg;
    @track errorMsg1;
    @track errorMsg2;
    @track showLoginCard = false;
    @track showSignupCard = false;
    @track isLoadedComp = false;
    @track dobError = false;
    @track userEmail;
    @track errorForgotError = false;
    @track errorForgetMsg;
    @track forgetPassworClass;
    @track passwordError = false;
    @track password;

    @track error = "ui-text";
    @track disableSignIn = true;
    @track disableForgetPassword = true;
    @track showForgetPassword = false;
    @track showForgetThankYou = false;
    @track logoURL = logo;

    connectedCallback() {

    }


    handleInput(event) {
        if (event.target.name === 'userName') {
            this.dataObj.userName = (event.target.value).trim();
        } else if (event.target.name === 'password') {
            this.dataObj.password = (event.target.value).trim();
        }
        this.handleSignInButtonToggle();
    }

    handleSignInButtonToggle() {
        if (this.dataObj.userName &&
            this.dataObj.password) {
            this.disableSignIn = false;
        } else {
            this.disableSignIn = true;
        }
        //forget password
        this.disableForgetPassword = true;
        if (this.dataObj.userName) {
            this.disableForgetPassword = false;
        }
    }

    loginContact(event) {
        //this.isLoadedComp = true;
        this.passwordError = false;
        this.errorForgotError = false;
        this.isLoadedComp = true;
        if (this.validateLoginInformation()) {
            logInUser({
                    jsonString: JSON.stringify(this.dataObj)
                })
                .then(result => {
                    if (result.redirectUrl != null)
                        window.location.href = result.redirectUrl;
                    this.isLoadedComp = false;

                })
                .catch(error => {
                    this.errorMsg = error.body.message;
                    this.isLoadedComp = false;
                });
        } else {
            this.isLoadedComp = false;
        }
    }
    toggleLoginAndForgetPasswordForm(event) {
        this.showForgetPassword = !this.showForgetPassword;
        this.disableForgetPassword = true;
    }
    redirectToLogin() {
        this.showForgetThankYou = false;
        this.showForgetPassword = false;
        this.errorForgotError = false;
    }

    forgetPassword(event) {
        this.isLoadedComp = true;
        forgotPassword({
                jsonString: JSON.stringify(this.dataObj)
            })
            .then(result => {
                //console.log('result----',result);
                if (result == 'success') {
                    this.showForgetThankYou = true;
                    this.errorForgotError = true;
                    this.forgetPassworClass = 'slds-box slds-theme_info slds-has-success';
                    this.errorForgetMsg = 'Forget Password Email Message';
                } else {
                    this.forgetPassworClass = 'slds-box slds-theme_info slds-has-error';
                    this.errorForgotError = true;
                    this.errorForgetMsg = 'Invalid User Message';
                }
                this.isLoadedComp = false;
            })
            .catch(error => {
                this.errorMsg2 = error.body.message;
                this.isLoadedComp = false;
            });


    }

    validateLoginInformation() {
        if (this.dataObj.userName == '' || this.dataObj.userName == null || this.dataObj.userName == undefined ||
            this.dataObj.password == null || this.dataObj.password == undefined || this.dataObj.password == '') {
            this.errorMsg = 'All Fileds Error';

            return false;
        } else {
            this.errorMsg = null;
            return true;
        }
    }
    redirectToRegisterPage(event) {
        event.preventDefault();
        event.stopPropagation();
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s"));
        window.location.href = baseURL + '/s/accd-register';
    }
}