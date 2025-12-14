/**
 * @description DTO class representing an application submission.
 */
public with sharing class ApplicationDTO {
    /** @description Company name. */
    @AuraEnabled
    public String companyName { get; set; }

    /** @description Federal Tax ID. */
    @AuraEnabled
    public String federalTaxId { get; set; }

    /** @description Contact information. */
    @AuraEnabled
    public ContactDTO contact { get; set; }

    /** @description Annual revenue. */
    @AuraEnabled
    public Decimal annualRevenue { get; set; }
}