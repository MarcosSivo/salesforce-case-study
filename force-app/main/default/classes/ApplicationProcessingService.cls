/**
 * @description Service class responsible for processing applications
 */
public without sharing class ApplicationProcessingService {
    /**
     * @description Processes an application by finding a matching Account and creating the appropriate record.
     * @param app Application payload to process.
     * @param source Source label stored on created records.
     * @return ApplicationResult describing the processing outcome and created record details.
     */
    public static ApplicationResult processApplication(ApplicationDTO app, String source) {
        ApplicationResult result = new ApplicationResult();

        Account matchingAccount = getMatchingAccount(app);

        if (matchingAccount != null) {
            Opportunity opportunityRecord = new Opportunity(
                AccountId = matchingAccount.Id,
                Application_Source__c = source,
                CloseDate = Date.today().addDays(30),
                Name = app.companyName + ' - New Application',
                StageName = 'Prospecting'
            );

            insert opportunityRecord;

            result.buildSuccessResult('Opportunity', opportunityRecord.Id);
        } else {
            Lead leadRecord = new Lead(
                AnnualRevenue = app.annualRevenue,
                Application_Source__c = source,
                Company = app.companyName,
                Email = app.contact.email,
                Federal_Tax_Id__c = app.federalTaxId,
                FirstName = app.contact.firstName,
                LastName = app.contact.lastName,
                Phone = app.contact.phone
            );

            insert leadRecord;

            result.buildSuccessResult('Lead', leadRecord.Id);
        }

        return result;
    }

    /**
     * @description Finds a matching Account using Federal Tax Id or Company Name.
     * @param app Application payload used to locate a matching account.
     * @return Matching Account if found; otherwise null.
     */
    private static Account getMatchingAccount(ApplicationDTO app) {
        List<Account> accounts = [
            SELECT Id, Federal_Tax_Id__c
            FROM Account
            WHERE Federal_Tax_Id__c = :app.federalTaxId OR Name = :app.companyName
            WITH SYSTEM_MODE
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];

        return accounts.isEmpty() ? null : accounts[0];
    }
}
