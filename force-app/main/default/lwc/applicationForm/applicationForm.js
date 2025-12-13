import { LightningElement } from "lwc";

export default class ApplicationForm extends LightningElement {
    companyName = "";
    federalTaxId = "";
    contactFirstname = "";
    contactLastName = "";
    email = "";
    phone = "";
    anualRevenue = "";
    isLoading = false;

    handleSubmitForm(event) {}
}
