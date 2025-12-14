import { LightningElement } from "lwc";
import submitApplication from "@salesforce/apex/ApplicationFormController.submitApplication";
const MESSAGES = Object.freeze({
    DEFAULT_ERROR: "An error occurred while submitting the application.",
    REQUIRED_FIELD_MISSING: "Please complete all required fields before submitting."
});
export default class ApplicationForm extends LightningElement {
    companyName = "";
    federalTaxId = "";
    contactFirstName = "";
    contactLastName = "";
    email = "";
    phone = "";
    annualRevenue = null;
    isLoading = false;
    successMessage = "";
    errorMessage = "";
    warningMessage = "";

    get isSuccess() {
        return this.successMessage.length > 0;
    }

    get areErrors() {
        return this.errorMessage.length > 0;
    }

    get areWarnings() {
        return this.warningMessage.length > 0;
    }

    handleInputChange(event) {
        const inputId = event.target.dataset.id;
        const value = event.target.value;

        switch (inputId) {
            case "companyName":
                this.companyName = value;
                break;
            case "federalTaxId":
                this.federalTaxId = value;
                break;
            case "contactFirstName":
                this.contactFirstName = value;
                break;
            case "contactLastName":
                this.contactLastName = value;
                break;
            case "email":
                this.email = value;
                break;
            case "phone":
                this.phone = value;
                break;
            case "annualRevenue":
                this.annualRevenue = value;
                break;
            default:
                break;
        }
    }

    async handleSubmitForm() {
        this.clearMessages();
        const isValid = this.validateRequiredInputs();

        if (!isValid) {
            return;
        }

        this.isLoading = true;

        try {
            const request = this.createFormRequest();
            const result = await submitApplication({ input: request });

            if (result?.success) {
                this.successMessage = result.message;
                this.clearForm();
            } else {
                this.errorMessage = result?.message || MESSAGES.DEFAULT_ERROR;
            }
        } catch (error) {
            this.errorMessage = `An error occurred: ${JSON.stringify(error)}`;
        } finally {
            this.isLoading = false;
        }
    }

    createFormRequest() {
        return {
            companyName: this.companyName,
            federalTaxId: this.federalTaxId,
            annualRevenue: this.annualRevenue,
            contact: {
                firstName: this.contactFirstName,
                lastName: this.contactLastName,
                email: this.email,
                phone: this.phone
            }
        };
    }

    validateRequiredInputs() {
        const inputs = Array.from(this.template.querySelectorAll("lightning-input"));
        const isValid = inputs.reduce((result, input) => {
            input.reportValidity();
            return result && input.checkValidity();
        }, true);

        if (!isValid) {
            this.warningMessage = MESSAGES.REQUIRED_FIELD_MISSING;
        }

        return isValid;
    }

    clearMessages() {
        this.successMessage = "";
        this.errorMessage = "";
        this.warningMessage = "";
    }

    clearForm() {
        this.companyName = "";
        this.federalTaxId = "";
        this.contactFirstName = "";
        this.contactLastName = "";
        this.email = "";
        this.phone = "";
        this.annualRevenue = "";
    }
}
