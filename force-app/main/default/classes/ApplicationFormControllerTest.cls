@IsTest
private with sharing class ApplicationFormControllerTest {
    @IsTest
    static void shouldCreateLeadWhenSubmittingValidApplication() {
        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Ivan';
        contact.lastName = 'Ivanov';
        contact.email = 'ivan@example.com';
        contact.phone = '+359888123456';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Test company';
        app.federalTaxId = '12341231';
        app.annualRevenue = 500000;
        app.contact = contact;

        Test.startTest();
        ApplicationResult result = ApplicationFormController.submitApplication(app);
        Test.stopTest();

        Assert.isTrue(result.success, 'Expected success result.');
        Assert.areEqual('Lead', result.recordType, 'Expected Lead record type.');
        Assert.isNotNull(result.recordId, 'Expected created record Id.');
        Assert.isTrue(String.isNotBlank(result.message), 'Expected a success message.');

        Lead createdLead = [
            SELECT Id, Application_Source__c
            FROM Lead
            WHERE Id = :result.recordId
            LIMIT 1
        ];
        Assert.areEqual('Community', createdLead.Application_Source__c, 'Expected Community source on created Lead.');
    }

    @IsTest
    static void shouldReturnErrorResultWhenProcessingThrows() {
        Test.startTest();
        ApplicationResult result = ApplicationFormController.submitApplication(null);
        Test.stopTest();

        Assert.isFalse(result.success, 'Expected failure result.');
        Assert.isNotNull(result.message, 'Expected an error message.');
    }
}