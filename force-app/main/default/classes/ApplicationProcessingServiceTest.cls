@IsTest
private with sharing class ApplicationProcessingServiceTest {
    @IsTest
    static void shouldCreateLeadWhenNoAccountMatches() {
        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Ivan';
        contact.lastName = 'Ivanov';
        contact.email = 'ivan@example.com';
        contact.phone = '+359888123456';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Company Test';
        app.federalTaxId = '12345678';
        app.annualRevenue = 500000;
        app.contact = contact;

        Test.startTest();
        ApplicationResult result = ApplicationProcessingService.processApplication(app, 'Community');
        Test.stopTest();

        Assert.isTrue(result.success, 'Expected success result.');
        Assert.areEqual('Lead', result.recordType, 'Expected a Lead to be created when no Account matches.');
        Assert.isNotNull(result.recordId, 'Expected created record Id.');

        Lead createdLead = [
            SELECT Id, Application_Source__c, Company, Federal_Tax_Id__c
            FROM Lead
            WHERE Id = :result.recordId
            LIMIT 1
        ];

        Assert.areEqual('Community', createdLead.Application_Source__c, 'Expected Community source on Lead.');
        Assert.areEqual('Company Test', createdLead.Company, 'Expected Lead company to match request.');
        Assert.areEqual('12345678', createdLead.Federal_Tax_Id__c, 'Expected Lead tax id to match request.');
    }

    @IsTest
    static void shouldCreateOpportunityWhenAccountMatchesByTaxId() {
        String federalTaxId = 'BG123456789';
        Account accountRecord = new Account(Name = 'Acme Corp', Federal_Tax_Id__c = federalTaxId);
        insert accountRecord;

        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Ivan';
        contact.lastName = 'Ivanov';
        contact.email = 'ivan@example.com';
        contact.phone = '+359888123456';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Different Company Name';
        app.federalTaxId = federalTaxId;
        app.annualRevenue = 500000;
        app.contact = contact;

        Test.startTest();
        ApplicationResult result = ApplicationProcessingService.processApplication(app, 'Webhook');
        Test.stopTest();

        Assert.isTrue(result.success, 'Expected success result.');
        Assert.areEqual(
            'Opportunity',
            result.recordType,
            'Expected Opportunity to be created when Account matches by tax id.'
        );
        Assert.isNotNull(result.recordId, 'Expected created record Id.');

        Opportunity createdOpportunity = [
            SELECT Id, AccountId, Application_Source__c, Name
            FROM Opportunity
            WHERE Id = :result.recordId
            LIMIT 1
        ];

        Assert.areEqual(
            accountRecord.Id,
            createdOpportunity.AccountId,
            'Expected Opportunity to link to matching Account.'
        );
        Assert.areEqual(
            'Different Company Name - New Application',
            createdOpportunity.Name,
            'Expected Opportunity name to be derived from request company name.'
        );
        Assert.areEqual('Webhook', createdOpportunity.Application_Source__c, 'Expected Webhook source on Opportunity.');
    }

    @IsTest
    static void shouldCreateOpportunityWhenTaxIdIsBlankAndAccountMatchesByName() {
        Account accountRecord = new Account(Name = 'Name Match Co', Federal_Tax_Id__c = '4412312332');
        insert accountRecord;

        ContactDTO contact = new ContactDTO();
        contact.firstName = 'Jane';
        contact.lastName = 'Doe';
        contact.email = 'jane@example.com';
        contact.phone = '+12341231234';

        ApplicationDTO app = new ApplicationDTO();
        app.companyName = 'Name Match Co';
        app.federalTaxId = null;
        app.annualRevenue = 250000;
        app.contact = contact;

        Test.startTest();
        ApplicationResult result = ApplicationProcessingService.processApplication(app, 'Community');
        Test.stopTest();

        Assert.isTrue(result.success, 'Expected success result.');
        Assert.areEqual(
            'Opportunity',
            result.recordType,
            'Expected Opportunity to be created when Account matches by name.'
        );
        Assert.isNotNull(result.recordId, 'Expected created record Id.');

        Opportunity createdOpportunity = [
            SELECT Id, AccountId, Application_Source__c
            FROM Opportunity
            WHERE Id = :result.recordId
            LIMIT 1
        ];

        Assert.areEqual(
            accountRecord.Id,
            createdOpportunity.AccountId,
            'Expected Opportunity to link to matching Account.'
        );
        Assert.areEqual(
            'Community',
            createdOpportunity.Application_Source__c,
            'Expected Community source on Opportunity.'
        );
    }
}
