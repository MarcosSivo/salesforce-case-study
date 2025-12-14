/**
 * @description Controller class used by the application form LWC to submit applications for processing.
 */
public without sharing class ApplicationFormController {
    /**
     * @description Submits an application from the community form and returns the processing result.
     * @param input Application data submitted by the user.
     * @return ApplicationResult containing the outcome and created record details.
     */
    @AuraEnabled
    public static ApplicationResult submitApplication(ApplicationDTO input) {
        ApplicationResult result = new ApplicationResult();

        try {
            result = ApplicationProcessingService.processApplication(input, 'Community');
        } catch (Exception ex) {
            result.buildErrorResult(ex.getMessage());
        }

        return result;
    }
}