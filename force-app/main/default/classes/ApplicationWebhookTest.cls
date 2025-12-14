@IsTest
private with sharing class ApplicationWebhookTest {
    private static RestResponse setupRestContext(String body) {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/external/applications';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = body == null ? null : Blob.valueOf(body);

        RestContext.request = request;
        RestContext.response = new RestResponse();
        return RestContext.response;
    }

    @IsTest
    static void shouldCreateLeadWhenNoAccountMatches() {
        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Ivan';
        contact.lastName = 'Ivanov';
        contact.email = 'ivan@example.com';
        contact.phone = '+359888123456';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Test Company';
        app.federalTaxId = '31234123';
        app.annualRevenue = 500000;
        app.contact = contact;

        String body = JSON.serialize(app);

        RestResponse restResponse = setupRestContext(body);

        Test.startTest();
        ApplicationResult result = ApplicationWebhook.handlePost();
        Test.stopTest();

        Assert.areEqual(200, restResponse.statusCode, 'Expected HTTP 200 for successful processing.');
        Assert.isTrue(result.success, 'Expected success result.');
        Assert.areEqual('Lead', result.recordType, 'Expected Lead record type.');
        Assert.isNotNull(result.recordId, 'Expected created record Id.');
        Assert.isNotNull(result.message, 'Expected result to have a success message.');

        Lead createdLead = [
            SELECT Id, Application_Source__c
            FROM Lead
            WHERE Id = :result.recordId
            LIMIT 1
        ];

        Assert.areEqual('Webhook', createdLead.Application_Source__c, 'Expected Webhook source on created Lead.');
    }

    @IsTest
    static void shouldCreateOpportunityWhenAccountMatchesByTaxId() {
        String federalTaxId = '12341234123';
        Account existingAccount = new Account(Name = 'Webhook Opportunity', Federal_Tax_Id__c = federalTaxId);
        insert existingAccount;

        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Jane';
        contact.lastName = 'Doe';
        contact.email = 'jane@example.com';
        contact.phone = '+15555550123';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Webhook Opportunity';
        app.federalTaxId = federalTaxId;
        app.annualRevenue = 750000;
        app.contact = contact;

        String body = JSON.serialize(app);

        RestResponse restResponse = setupRestContext(body);

        Test.startTest();
        ApplicationResult result = ApplicationWebhook.handlePost();
        Test.stopTest();

        Assert.areEqual(200, restResponse.statusCode, 'Expected HTTP 200 for successful processing.');
        Assert.isTrue(result.success, 'Expected success result.');
        Assert.areEqual('Opportunity', result.recordType, 'Expected Opportunity record type.');
        Assert.isNotNull(result.recordId, 'Expected created record Id.');
        Assert.isNotNull(result.message, 'Expected result to have a success message.');

        Opportunity createdOpportunity = [
            SELECT Id, AccountId, Application_Source__c
            FROM Opportunity
            WHERE Id = :result.recordId
            LIMIT 1
        ];

        Assert.areEqual(
            existingAccount.Id,
            createdOpportunity.AccountId,
            'Expected Opportunity to link to matching Account.'
        );
        Assert.areEqual(
            'Webhook',
            createdOpportunity.Application_Source__c,
            'Expected Webhook source on created Opportunity.'
        );
    }

    @IsTest
    static void shouldReturnBadRequestWhenBodyIsBlank() {
        RestResponse restResponse = setupRestContext('');

        Test.startTest();
        ApplicationResult result = ApplicationWebhook.handlePost();
        Test.stopTest();

        Assert.areEqual(400, restResponse.statusCode, 'Expected HTTP 400 for blank body.');
        Assert.isFalse(result.success, 'Expected failure result.');
        Assert.areEqual('Request body is required.', result.message, 'Expected blank-body error message.');
    }

    @IsTest
    static void shouldFailRequestWhenCompanyAndTaxIdAreEmpty() {
        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Jane';
        contact.lastName = 'Doe';
        contact.email = 'jane@example.com';
        contact.phone = '+15555550123';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = '';
        app.federalTaxId = '';
        app.annualRevenue = 750000;
        app.contact = contact;

        String body = JSON.serialize(app);

        RestResponse restResponse = setupRestContext(body);

        Test.startTest();
        ApplicationResult result = ApplicationWebhook.handlePost();
        Test.stopTest();

        Assert.areEqual(500, restResponse.statusCode, 'Expected HTTP 500 for company info.');
        Assert.isFalse(result.success, 'Expected failure result.');
        Assert.isNotnull(result.message, 'Expected error message.');
    }
}