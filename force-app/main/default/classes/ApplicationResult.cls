/**
 * @description Result wrapper to handle processing an application.
 */
global without sharing class ApplicationResult {
    /** @description Boolean indicating if the result is success or there is an error.*/
    @AuraEnabled
    global Boolean success;

    /** @description Type of record created.*/
    @AuraEnabled
    global String recordType;

    /** @description Id of record created.*/
    @AuraEnabled
    global Id recordId;

    /** @description Result message.*/
    @AuraEnabled
    global String message;

    /**
     * @description Populates this result as a successful outcome.
     * @param recordType The type of record created (for example, Lead or Opportunity).
     * @param recordId The Id of the record created.
     * @return The current ApplicationResult instance.
     */
    global ApplicationResult buildSuccessResult(String recordType, Id recordId) {
        this.recordType = recordType;
        this.recordId = recordId;
        this.success = true;
        this.message = 'Success! Created ' + recordType + ' with Id ' + recordId + '.';

        return this;
    }

    /**
     * @description Populates this result as an error outcome.
     * @param message Error message describing the failure.
     * @return The current ApplicationResult instance.
     */
    global ApplicationResult buildErrorResult(String message) {
        this.success = false;
        this.message = message;

        return this;
    }
}
