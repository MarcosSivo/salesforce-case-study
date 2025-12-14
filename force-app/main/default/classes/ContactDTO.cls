/**
 * @description DTO class representing a contact.
 */
public with sharing class ContactDTO {
    /** @description Contact first name. */
    @AuraEnabled
    public String firstName { get; set; }

    /** @description Contact last name. */
    @AuraEnabled
    public String lastName { get; set; }

    /** @description Contact email address. */
    @AuraEnabled
    public String email { get; set; }

    /** @description Contact phone number. */
    @AuraEnabled
    public String phone { get; set; }
}
